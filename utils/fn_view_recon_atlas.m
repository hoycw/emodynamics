function fn_view_recon_atlas(SBJ, proc_id, view_space, reg_type, show_labels,...
                             hemi, atlas_id, roi_id, plot_out, varargin)
%% Plot a reconstruction with electrodes
% INPUTS:
%   SBJ [str] - subject ID to plot
%   proc_id [str] - name of analysis pipeline, used to pick elec file
%       'full' for the bipolar logic combined
%   view_space [str] - {'pat', 'mni'}
%   reg_type [str] - {'v', 's'} choose volume-based or surface-based registration
%   show_labels [0/1] - plot the electrode labels
%   hemi [str] - {'l', 'r', 'b'} hemisphere to plot
%   plot_out [0/1] - exclude electrodes that don't match atlas or aren't in hemisphere
%   atlas_id [str] - {'DK','Dx'}; NOT: {'Yeo7','Yeo17'}
%   roi_id [str] - ROI grouping by which to color the atlas ROIs
%       'gROI','mgROI','main3' - general ROIs (lobes or broad regions)
%       'ROI','thryROI','LPFC','MPFC','OFC','INS' - specific ROIs (within these larger regions)
%       REMOVED: 'Yeo7','Yeo17' - colored by Yeo networks
%       'tissue','tissueC' - colored by tisseu compartment, e.g., GM vs WM vs OUT

[root_dir, app_dir] = fn_get_root_dir(); ft_dir = [app_dir 'fieldtrip/'];

%% Handle variables
SBJ_vars_cmd = ['run ' root_dir 'emodynamics/scripts/SBJ_vars/' SBJ '_vars.m'];
eval(SBJ_vars_cmd);

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
if ~exist('view_angle','var')
    view_angle = fn_get_view_angle(hemi,roi_id);
end
if ~exist('mesh_alpha','var')
    if any(strcmp(SBJ_vars.ch_lab.probe_type,'seeg'))
        mesh_alpha = 0.3;
    else
        mesh_alpha = 0.8;
    end
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
if strcmp(proc_id,'full') || any(strcmp(roi_id,{'tissueC','tisue'}))
    proc_id = 'main_ft';
    elec_suffix = '_full';
else
    elec_suffix = '';
end

%% Load elec struct
try
    elec_fname = [SBJ_vars.dirs.recon,SBJ,'_elec_',proc_id,'_',view_space,reg_suffix,'_',atlas_id,elec_suffix,'.mat'];
    if exist([elec_fname(1:end-4) '_' roi_id '.mat'],'file')
        elec_fname = [elec_fname(1:end-4) '_' roi_id '.mat'];
    end
    load(elec_fname);
catch
    answer = input(['Could not load requested file: ' elec_fname ...
        '\nDo you want to run the atlas matching now? "y" or "n"\n'],'s');
    if strcmp(answer,'y')
        fn_save_elec_atlas(SBJ,proc_id,view_space,reg_type,atlas_id);
    else
        error('not running atlas assignment, exiting...');
    end
end

%% Remove electrodes that aren't in atlas ROIs
if ~plot_out
    cfgs = [];
    cfgs.channel = fn_select_elec_lab_match(elec, hemi, atlas_id, roi_id);
    elec = fn_select_elec(cfgs, elec);
end

%% Load brain recon
mesh = fn_load_recon_mesh(SBJ,view_space,reg_type,hemi);

%% Match elecs to atlas ROIs
fprintf('Using atlas: %s\n',atlas_id);
if any(strcmp(atlas_id,{'DK','Dx'}))%'Yeo7'
    if ~isfield(elec,'man_adj')
        elec.roi       = fn_atlas2roi_labels(elec.atlas_lab,atlas_id,roi_id);
    end
    if strcmp(roi_id,'tissueC')
        elec.roi_color = fn_tissue2color(elec);
%     elseif strcmp(atlas_id,'Yeo7')
%         elec.roi_color = fn_atlas2color(atlas_id,elec.roi);
    else
        elec.roi_color = fn_roi2color(elec.roi);
    end
% elseif any(strcmp(atlas_id,{'Yeo17'}))
%     if ~isfield(elec,'man_adj')
%         elec.roi       = elec.atlas_lab;
%     end
%     elec.roi_color = fn_atlas2color(atlas_id,elec.roi);
end

%% 3D Surface + Grids (3d, pat/mni, vol/srf, 0/1)
h = figure;

% Plot 3D mesh
ft_plot_mesh(mesh, 'facecolor', [0.781 0.762 0.664], 'EdgeColor', 'none', 'facealpha', mesh_alpha);

% Plot electrodes on top
% [roi_list, roi_colors] = fn_roi_label_styles(roi_id);
cfgs = [];
for e = 1:numel(elec.label)
    cfgs.channel = elec.label(e);
    elec_tmp = fn_select_elec(cfgs, elec);
    ft_plot_sens(elec_tmp, 'elecshape', 'sphere', 'facecolor', elec_tmp.roi_color, 'label', lab_arg);
end
% for roi_ix = 1:numel(roi_list)
%     if any(strcmp(elec.roi,roi_list{roi_ix}))
%         cfgs.channel = elec.label(strcmp(elec.roi,roi_list{roi_ix}));
%         elec_tmp = fn_select_elec(cfgs, elec);
%         ft_plot_sens(elec_tmp, 'elecshape', 'sphere', 'facecolor', roi_colors{roi_ix},...
%             'label', lab_arg);
%     end
% end

view(view_angle); material dull; lighting gouraud;
l = camlight;
fprintf(['To reset the position of the camera light after rotating the figure,\n' ...
    'make sure none of the figure adjustment tools (e.g., zoom, rotate) are active\n' ...
    '(i.e., uncheck them within the figure), and then hit ''l'' on the keyboard\n'])
set(h, 'windowkeypressfcn',   @cb_keyboard);

end
