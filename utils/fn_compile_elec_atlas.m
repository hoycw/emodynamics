function fn_compile_elec_atlas(SBJ,proc_id,view_space,reg_type,atlas_id)
%% Compile ROI info (biggest changes are from single electrodes into bipolar pairs)
%   Goes from smallest to largest (ELEC1-ELEC2, ELEC2-ELEC3, etc.)
%   Pairs are drawn from imported data labels, then preprocessing logic is applied
%
% INPUTS:
%   SBJ [str] - name of subject
%   proc_id [str] - name of analysis pipeline
%   view_space [str] - {'pat','mni'} select patient native or mni group space
%   reg_type [str] - {'v', 's'} choose volume-based or surface-based registration
%   atlas_id [str] - {'DK','Dx','Yeo7','Yeo17'}

% Set up paths
[root_dir, app_dir] = fn_get_root_dir(); ft_dir = [app_dir 'fieldtrip' filesep];
addpath(fullfile(root_dir,'emodynamics','scripts'));
addpath(fullfile(root_dir,'emodynamics','scripts','utils'));
addpath(ft_dir);
ft_defaults

%% Load variables
eval(['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_vars',[SBJ '_vars.m'])]);
eval(['run ' fullfile(root_dir,'emodynamics','scripts','proc_vars',[proc_id '_vars.m'])]);

%% Load Elec struct
if ~isempty(reg_type)
    warning(['view_space = "' view_space '" does not require reg_type; ignoring reg_type = ' reg_type]);
end
if strcmp(reg_type,'v') || strcmp(reg_type,'s')
    reg_suffix = ['_' reg_type];
else
    reg_suffix = '';
end

elec_fname = fullfile(SBJ_vars.dirs.recon,[SBJ '_elec_' proc_id '_' view_space reg_suffix '_orig_' atlas_id '.mat']);
out_fname  = fullfile(SBJ_vars.dirs.recon,[SBJ '_elec_' proc_id '_' view_space reg_suffix '_' atlas_id '_full.mat']);
load(elec_fname);

%% For grids/strips only, add GM weight and exit
if ~any(strcmp(SBJ_vars.ch_lab.ref_type,'BP'))
    % Add missing fields
    elec.reref     = 1;
    elec.gm_weight = ones(size(elec.label));
    elec.inputs    = cell(size(elec.label));   % just empty
    elec.roi_flag  = zeros(size(elec.label));
    for e = 1:numel(elec.label)
        if elec.tissue_prob(e,strcmp(elec.tissue_labels,'GM'))~=1
            elec.roi_flag(e) = 1;
        end
    end
    
    % Check if elec.cfg.previous got ridiculously large, and keep only first
    var_stats = whos('elec');
    if var_stats.bytes>1000000
        elec.cfg = rmfield(elec.cfg,'previous');
    end
    fprintf('============== Saving %s ==============\n',out_fname);
    save(out_fname, '-v7.3', 'elec');
    
    % Exit this function
    return;
end

%% Load atlas to resolve any ties
atlas = fn_load_recon_atlas(SBJ,atlas_id);

%% Apply montage per probe
left_out_ch = {};
danger_name = false([1 numel(SBJ_vars.ch_lab.probes)]);
name_holder = cell([2 numel(SBJ_vars.ch_lab.probes)]);
elec_reref  = cell([1 numel(SBJ_vars.ch_lab.probes)]);
for p = 1:numel(SBJ_vars.ch_lab.probes)
    cfg = [];
    cfg.channel = ft_channelselection(strcat(SBJ_vars.ch_lab.probes{p},'*'), elec.label);
    probe_elec  = fn_select_elec(cfg,elec);
    
    % Check if the names of these elecs will cause problems
    eeg1010_match = strfind(probe_elec.label,'AF');
    if ~isempty([eeg1010_match{:}])
        danger_name(p)   = true;
        name_holder{1,p} = probe_elec.label;
        name_holder{2,p} = fn_generate_random_strings(numel(probe_elec.label),'',10);
        probe_elec.label = name_holder{2,p};
    end
    
    % Create referencing scheme
    if strcmp(SBJ_vars.ch_lab.ref_type{p},'BP')
        cfg.montage.labelold = cfg.channel;
        [cfg.montage.labelnew, cfg.montage.tra, left_out_ch{p}] = fn_create_ref_scheme_bipolar(cfg.channel);
        cfg.updatesens = 'yes';
        elec_reref{p} = ft_apply_montage(probe_elec, cfg.montage);%, 'feedback', 'none', 'keepunused', 'no', 'balancename', bname);
        elec_reref{p} = fn_combine_ROI_bipolar_logic(elec_reref{p},out_fname(1:end-4),atlas);
    else
        elec_reref{p} = probe_elec;
    end
end

%% Recombine
cfg = [];
elec = ft_appendsens(cfg,elec_reref{:});

% Re-label any problematic channel labels
if any(danger_name)
    for d_ix = find(danger_name)
        for s_ix = 1:numel(name_holder{2,d_ix})
            elec.label{strcmp(elec.label,name_holder{2,2}{s_ix})} = name_holder{1,d_ix}{s_ix};
        end
    end
end

% Remove non-ROI (bad) electrodes (shouldn't do anything if non-reref)
cfgs = [];
cfgs.channel = SBJ_vars.ch_lab.ROI;
elec = fn_select_elec(cfgs,elec);

%% Add Back Stripped Fields Channel Types
elec.atlas_id      = atlas_id;
elec.type          = 'ieeg';
elec.tissue_labels = elec_reref{1}.tissue_labels;
elec.reref         = 1;

% fields = fieldnames(elec_reref{1});
% fields = setdiff(fields,fieldnames(elec));   % still included: 'chanposold', 'labelold', 'tra'
fields = {'atlas_lab', 'atlas_lab2', 'gm_weight', 'hemi', 'inputs',...
            'roi_flag', 'tissue', 'tissue2', 'tissue_prob'};
for f = 1:numel(fields)
    % Initialize to get column not row
    if iscell(elec_reref{p}.(fields{f}))
        elec.(fields{f}) = cell(size(elec.label));
    elseif strcmp(fields{f},'tissue_prob')
        elec.(fields{f}) = zeros([numel(elec.label) numel(elec.tissue_labels)]);
    else
        elec.(fields{f}) = zeros(size(elec.label));
    end
    % Retrieve info from indivdiual reref probes
    for p = 1:numel(SBJ_vars.ch_lab.probes)
        for p_e = 1:numel(elec_reref{p}.label)
            e_ix = strcmp(elec.label,elec_reref{p}.label{p_e});
            if any(e_ix)   % check if removed by SBJ_vars.ch_lab.ROI
                if iscell(elec_reref{p}.(fields{f}))
                    elec.(fields{f}){e_ix} = elec_reref{p}.(fields{f}){p_e};
                elseif strcmp(fields{f},'tissue_prob')
                    elec.(fields{f})(e_ix,:) = elec_reref{p}.(fields{f})(p_e,:);
                else
                    elec.(fields{f})(e_ix) = elec_reref{p}.(fields{f})(p_e);
                end
                
                elec.chantype{e_ix} = SBJ_vars.ch_lab.probe_type{p};
            end
        end
    end
end

%% Save data
% Check if elec.cfg.previosu got ridiculously large, and keep only first
var_stats = whos('elec');
if var_stats.bytes>1000000
    elec.cfg = rmfield(elec.cfg,'previous');
end
fprintf('============== Saving %s ==============\n',out_fname);
save(out_fname, '-v7.3', 'elec');

end
