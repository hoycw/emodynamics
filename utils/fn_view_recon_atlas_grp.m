function fn_view_recon_atlas_grp(SBJs, proc_id, reg_type, show_labels,...
                                 hemi, atlas_id, roi_id, plot_out, varargin)
%% Plot a reconstruction with electrodes
% INPUTS:
%   SBJs [cell array str] - subject IDs to plot
%   proc_id [str] - name of analysis pipeline, used to pick elec file
%   plot_type [str] - {'ortho', '3d'} choose 3 slice orthogonal plot or 3D surface rendering
%   reg_type [str] - {'v', 's'} choose volume-based or surface-based registration
%   show_labels [0/1] - plot the electrode labels
%   hemi [str] - {'l', 'r', 'b'} hemisphere to plot
%   atlas_id [str] - {'DK','Dx'}; REMOVED: {'Yeo7','Yeo17'}
%   roi_id [str] - ROI grouping by which to color the atlas ROIs
%       'gROI','mgROI','main3' - general ROIs (lobes or broad regions)
%       'ROI','thryROI','LPFC','MPFC','OFC','INS' - specific ROIs (within these larger regions)
%       REMOVED: 'Yeo7','Yeo17' - colored by Yeo networks
%       'tissue','tissueC' - colored by tisseu compartment, e.g., GM vs WM vs OUT
%   plot_out [0/1] - include electrodes that don't have an atlas label or in hemi?

[root_dir, app_dir] = fn_get_root_dir(); ft_dir = [app_dir 'fieldtrip/'];

%% Handle variables
% Handle variable inputs
if ~isempty(varargin)
    for v = 1:2:numel(varargin)
        if strcmp(varargin{v},'view_angle')
            view_angle = varargin{v+1};
        elseif strcmp(varargin{v},'mesh_alpha') && varargin{v+1}>0 && varargin{v+1}<=1
            mesh_alpha = varargin{v+1};
        else
            error(['Unknown varargin ' num2str(v) ': ' varargin{v}]);
        end
    end
end

% Define default options
% view_space = 'mni';
if ~exist('view_angle','var')
    view_angle = fn_get_view_angle(hemi,roi_id);
end
if ~exist('mesh_alpha','var')
    % assume SEEG
    mesh_alpha = 0.3;
end
if show_labels
    lab_arg = 'label';
else
    lab_arg = 'off';
end
if strcmp(reg_type,'v') || strcmp(reg_type,'s')
    reg_suffix = ['_' reg_type];    % MNI space
else
    reg_suffix = '';                % Patient space
end

% ROI info
[roi_list, ~] = fn_roi_label_styles(roi_id);
fprintf('Using atlas: %s\n',atlas_id);

%% Load elec struct
elec     = cell([numel(SBJs) 1]);
good_sbj = true(size(SBJs));
all_roi_labels = {};
all_roi_colors = [];
for sbj_ix = 1:numel(SBJs)
    SBJ = SBJs{sbj_ix};
    SBJ_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_vars', [SBJ '_vars.m'])];
    eval(SBJ_vars_cmd);
    
    try
        elec_fname = [SBJ_vars.dirs.recon,SBJ,'_elec_',proc_id,'_mni',reg_suffix,'_',atlas_id,'_full.mat'];
        if exist([elec_fname(1:end-4) '_' roi_id '.mat'],'file')
            elec_fname = [elec_fname(1:end-4) '_' roi_id '.mat'];
        end
        tmp = load(elec_fname); elec{sbj_ix} = tmp.elec;
    catch
        error([elec_fname 'doesnt exist, exiting...']);
    end
    
    % Append SBJ name to labels
    for e_ix = 1:numel(elec{sbj_ix}.label)
        elec{sbj_ix}.label{e_ix} = [SBJs{sbj_ix} '_' elec{sbj_ix}.label{e_ix}];
    end
    
    % Match elecs to atlas ROIs
    if any(strcmp(atlas_id,{'DK','Dx'}))%'Yeo7'
        if ~isfield(elec{sbj_ix},'man_adj')
            elec{sbj_ix}.roi       = fn_atlas2roi_labels(elec{sbj_ix}.atlas_lab,atlas_id,roi_id);
        end
        if strcmp(roi_id,'tissueC')
            elec{sbj_ix}.roi_color = fn_tissue2color(elec{sbj_ix});
%         elseif strcmp(atlas_id,'Yeo7')
%             elec{sbj_ix}.roi_color = fn_atlas2color(atlas_id,elec{sbj_ix}.roi);
        else
            elec{sbj_ix}.roi_color = fn_roi2color(elec{sbj_ix}.roi);
        end
%     elseif any(strcmp(atlas_id,{'Yeo17'}))
%         if ~isfield(elec{sbj_ix},'man_adj')
%             elec{sbj_ix}.roi       = elec{sbj_ix}.atlas_lab;
%         end
%         elec{sbj_ix}.roi_color = fn_atlas2color(atlas_id,elec{sbj_ix}.roi);
    end
    
    if ~plot_out
        % Remove electrodes that aren't in atlas ROIs & hemisphere
        good_elecs = fn_select_elec_lab_match(elec{sbj_ix}, hemi, atlas_id, roi_id);
    else
        % Remove electrodes that aren't in hemisphere
        good_elecs = fn_select_elec_lab_match(elec{sbj_ix}, hemi, [], []);
    end
    % fn_select_elec messes up if you try to toss all elecs
    if isempty(good_elecs)
        elec{sbj_ix} = {};
        good_sbj(sbj_ix) = false;
    else
        cfgs = [];
        cfgs.channel = good_elecs;
        elec{sbj_ix} = fn_select_elec(cfgs, elec{sbj_ix});
        all_roi_labels = [all_roi_labels; elec{sbj_ix}.roi];
        all_roi_colors = [all_roi_colors; elec{sbj_ix}.roi_color];
    end
    clear SBJ SBJ_vars SBJ_vars_cmd
end

%% Combine elec structs
elec = ft_appendsens([],elec{good_sbj});
elec.roi       = all_roi_labels;    % appendsens strips that field
elec.roi_color = all_roi_colors;    % appendsens strips that field

%% Load brain recon
mesh = fn_load_recon_mesh([],'mni',reg_type,hemi);

%% 3D Surface + Grids (3d, pat/mni, vol/srf, 0/1)
h = figure;

% Plot 3D mesh
ft_plot_mesh(mesh, 'facecolor', [0.781 0.762 0.664], 'EdgeColor', 'none', 'facealpha', mesh_alpha);

% Plot electrodes on top
for e = 1:numel(elec.label)
    cfgs = []; cfgs.channel = elec.label(e);
    elec_tmp = fn_select_elec(cfgs,elec);
    ft_plot_sens(elec_tmp, 'elecshape', 'sphere',...
                 'facecolor', elec_tmp.roi_color, 'label', lab_arg);
end

view(view_angle); material dull; lighting gouraud;
l = camlight;
fprintf(['To reset the position of the camera light after rotating the figure,\n' ...
    'make sure none of the figure adjustment tools (e.g., zoom, rotate) are active\n' ...
    '(i.e., uncheck them within the figure), and then hit ''l'' on the keyboard\n'])
set(h, 'windowkeypressfcn',   @cb_keyboard);

end
