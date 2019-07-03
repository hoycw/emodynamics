function fn_view_recon_atlas_grp_ROI(SBJs, proc_id, reg_type, show_labels,...
                                 hemi, atlas_id, roi_id, plot_roi, varargin)
%% Plot a reconstruction with electrodes
% INPUTS:
%   SBJs [cell array str] - subject IDs to plot
%   proc_id [str] - name of analysis pipeline, used to pick elec file
%   plot_type [str] - {'ortho', '3d'} choose 3 slice orthogonal plot or 3D surface rendering
%   reg_type [str] - {'v', 's'} choose volume-based or surface-based registration
%   show_labels [0/1] - plot the electrode labels
%   hemi [str] - {'l', 'r', 'b'} hemisphere to plot
%   atlas_id [str] - {'DK','Dx'}; REMOVED: {'Yeo7','Yeo17'}
%   roi_id [str] - gROI grouping to pick mesh and color specific ROIs
%       'LPFC','MPFC','OFC','INS','TMP','PAR'
%   plot_roi [str] - which surface mesh to plot

%% Handle variables
% Error cases
if strcmp(hemi,'b') && ~strcmp(plot_roi,'OFC')
    error('hemi must be l or r for all non-OFC plots');
end
if ~any(strcmp(plot_roi,{'LPFC','MPFC','INS','OFC','TMP','PAR','lat','deep'}))
    error('roi_id needs to be a lobe, "lat", or "deep"');
end

% Handle variable inputs
if ~isempty(varargin)
    for v = 1:2:numel(varargin)
        if strcmp(varargin{v},'view_angle')
            view_angle = varargin{v+1};
        elseif strcmp(varargin{v},'mesh_alpha') && varargin{v+1}>0 && varargin{v+1}<=1
            mesh_alpha = varargin{v+1};
        elseif strcmp(varargin{v},'fig_ftype')
            fig_ftype = varargin{v+1};
        elseif strcmp(varargin{v},'save_fig')
            save_fig = varargin{v+1};
        else
            error(['Unknown varargin ' num2str(v) ': ' varargin{v}]);
        end
    end
end

%% Define default options
if ~exist('view_angle','var')
    view_angle = fn_get_view_angle(hemi,plot_roi);
end
if ~exist('fig_ftype','var')
    fig_ftype = 'png';
end
if ~exist('save_fig','var')
    save_fig = 0;
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

if any(strcmp(plot_roi,{'deep','lat'}))
    [plot_roi_list, ~] = fn_roi_label_styles(plot_roi);
else
    plot_roi_list = {plot_roi};
end

[root_dir, ~] = fn_get_root_dir();
out_dir = [root_dir 'emodynamics/results/recons/'];

%% Load elec struct
elec     = cell([numel(SBJs) 1]);
good_sbj = true(size(SBJs));
all_roi_labels = {};
all_roi_colors = [];
for sbj_ix = 1:numel(SBJs)
    SBJ = SBJs{sbj_ix};
    SBJ_vars_cmd = ['run ' root_dir 'emodynamics/scripts/SBJ_vars/' SBJ '_vars.m'];
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
    
    % Select elecs matching hemi, atlas, and plot_roi_list
    plot_elecs = zeros([numel(elec{sbj_ix}.label) numel(plot_roi_list)]);
    for roi_ix = 1:numel(plot_roi_list)
        plot_elecs(:,roi_ix) = strcmp(elec{sbj_ix}.roi,plot_roi_list{roi_ix});
    end
    good_elecs = intersect(fn_select_elec_lab_match(elec{sbj_ix}, hemi, atlas_id, roi_id),...
                             elec{sbj_ix}.label(any(plot_elecs,2)));
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

%% Load Atlas
atlas = fn_load_recon_atlas([],atlas_id);

% Get Atlas-ROI mapping
atlas_labels = fn_atlas_roi_select_mesh(atlas_id, plot_roi, hemi);
if strcmp(plot_roi,'deep')
    mtl_ix = ~cellfun(@isempty,strfind(atlas_labels,'Hippocampus')) | ...
             ~cellfun(@isempty,strfind(atlas_labels,'Amygdala'));
    mtl_labels = atlas_labels(mtl_ix);
    atlas_labels = atlas_labels(~mtl_ix);
end

%% Select ROI mesh
cfg = [];
cfg.inputcoord = atlas.coordsys;
cfg.atlas = atlas;
cfg.roi = atlas_labels;
roi_mask = ft_volumelookup(cfg,atlas);
seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain = roi_mask;

if exist('mtl_labels','var')
    cfg.roi = mtl_labels;
    mtl_mask = ft_volumelookup(cfg,atlas);
    
    mtl_seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
    mtl_seg.brain = mtl_mask;
end

cfg = [];
cfg.method      = 'iso2mesh';   % surface toolbox Arjen found
cfg.radbound    = 2;            % scalar indicating the radius of the target surface mesh element bounding sphere
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 100000;
cfg.smooth      = 3;
roi_mesh = ft_prepare_mesh(cfg, seg);
if exist('mtl_seg','var')
    mtl_mesh = ft_prepare_mesh(cfg, mtl_seg);
end

%% 3D Surface + Grids (3d, pat/mni, vol/srf, 0/1)
fig_name = ['GRP_' atlas_id '_' roi_id '_' plot_roi '_' hemi];
h = figure('Name',fig_name);

% Plot 3D mesh
ft_plot_mesh(roi_mesh, 'facecolor', [0.781 0.762 0.664], 'EdgeColor', 'none', 'facealpha', mesh_alpha);
if exist('mtl_mesh','var')
    ft_plot_mesh(mtl_mesh, 'facecolor', [0.781 0.762 0.664], 'EdgeColor', 'none', 'facealpha', mesh_alpha);
end

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

