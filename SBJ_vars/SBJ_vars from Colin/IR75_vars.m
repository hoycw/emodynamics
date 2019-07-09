%% IR75 Processing Variables
[root_dir, app_dir] = fn_get_root_dir(); ft_dir = [app_dir 'fieldtrip/'];
if isempty(strfind(path,'fieldtrip'))
    addpath(ft_dir);
    ft_defaults
end

%--------------------------------------
% Basics
%--------------------------------------
SBJ_vars.SBJ = 'IR75';
SBJ_vars.raw_file = {};%'IR75_raw_R1.mat'};
SBJ_vars.block_name = {''};% there's a second block I don't want to process right now, so leaving blank here
SBJ_vars.low_srate  = [0];

SBJ_vars.dirs.SBJ     = [root_dir 'PRJ_Stroop/data/' SBJ_vars.SBJ '/'];
SBJ_vars.dirs.raw     = [SBJ_vars.dirs.SBJ '00_raw/'];
SBJ_vars.dirs.SU      = [SBJ_vars.dirs.raw 'SU_2018-06-XX/'];
SBJ_vars.dirs.import  = [SBJ_vars.dirs.SBJ '01_import/'];
SBJ_vars.dirs.preproc = [SBJ_vars.dirs.SBJ '02_preproc/'];
SBJ_vars.dirs.events  = [SBJ_vars.dirs.SBJ '03_events/'];
SBJ_vars.dirs.proc    = [SBJ_vars.dirs.SBJ '04_proc/'];
SBJ_vars.dirs.recon   = [SBJ_vars.dirs.SBJ '05_recon/'];
if ~exist(SBJ_vars.dirs.import,'dir')
    mkdir(SBJ_vars.dirs.import);
end
if ~exist(SBJ_vars.dirs.preproc,'dir')
    mkdir(SBJ_vars.dirs.preproc);
end
if ~exist(SBJ_vars.dirs.events,'dir')
    mkdir(SBJ_vars.dirs.events);
end
if ~exist(SBJ_vars.dirs.proc,'dir')
    mkdir(SBJ_vars.dirs.proc);
end
if ~exist(SBJ_vars.dirs.recon,'dir')
    mkdir(SBJ_vars.dirs.recon);
end

SBJ_vars.dirs.raw_filename = strcat(SBJ_vars.dirs.raw,SBJ_vars.raw_file);

SBJ_vars.recon.surf_l     = [SBJ_vars.dirs.recon 'Surfaces/' SBJ_vars.SBJ '_cortex_lh.mat'];
SBJ_vars.recon.surf_r     = [SBJ_vars.dirs.recon 'Surfaces/' SBJ_vars.SBJ '_cortex_rh.mat'];
SBJ_vars.recon.elec_pat   = [SBJ_vars.dirs.recon 'Electrodes/' SBJ_vars.SBJ '_elec_acpc_f.mat'];
SBJ_vars.recon.elec_mni_v = [SBJ_vars.dirs.recon 'Electrodes/' SBJ_vars.SBJ '_elec_mni_frv.mat'];
SBJ_vars.recon.elec_mni_s = [];
SBJ_vars.recon.fs_T1      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_T1.mgz'];
SBJ_vars.recon.fs_DK      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_aparc+aseg.mgz'];
SBJ_vars.recon.fs_Dx      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_aparc.a2009s+aseg.mgz'];

%--------------------------------------
% Channel Selection
%--------------------------------------
SBJ_vars.ch_lab.probes     = {'RAM','RHH','RTH','RAP','RPP','RBH',...
                              'LAM','LHH','LTH','LAP','LPP','LBH'};
SBJ_vars.ch_lab.probe_type = {'seeg','seeg','seeg','seeg','seeg','seeg',...
                              'seeg','seeg','seeg','seeg','seeg','seeg'};
SBJ_vars.ch_lab.ref_type   = {'BP','BP','BP','BP','BP','BP',...
                              'BP','BP','BP','BP','BP','BP'};
if ~all(numel(SBJ_vars.ch_lab.probes)==[numel(SBJ_vars.ch_lab.probe_type) numel(SBJ_vars.ch_lab.ref_type)]); error('probes ~= type+ref');end;
SBJ_vars.ch_lab.ROI        = {'all'};%'ROF*','FOA*'};
SBJ_vars.ch_lab.eeg_ROI    = {};

SBJ_vars.ch_lab.nlx          = [1,1,1,0,0,0,1,1,1,1,0,0];
SBJ_vars.ch_lab.wires        = {'mram','mrhh','mrth','mlam','mlhh','mlth'};
SBJ_vars.ch_lab.wire_type    = {'su','su','su','su','su','su'};
SBJ_vars.ch_lab.wire_ref     = {'','','','','',''};
SBJ_vars.ch_lab.wire_ROI     = {'all'};
SBJ_vars.ch_lab.nlx_suffix   = '_00XX';
SBJ_vars.ch_lab.nlx_nk_align = {'LAP4','LAP5'};
SBJ_vars.nlx_macro_inverted  = 1;

% SBJ_vars.ch_lab.prefix = 'POL ';    % before every channel except 'EDF Annotations'
SBJ_vars.ch_lab.suffix = '_0003';    % after every channel except 'EDF Annotations'
% SBJ_vars.ch_lab.mislabel = {{'RLT12','FPG12'},{'IH;L8','IHL8'}};

SBJ_vars.ch_lab.ref_exclude = {}; %exclude from the CAR
SBJ_vars.ch_lab.bad = {...
    };
% emodim .bad:
%     'LHH1','LHH2','LHH3','LAM1',... % epileptic (source)
%     'LAP1','LAP2','LAP3','RBH1','RBH2','RBH3','RBH4','RPP1','RPP2','RPP3','RPP4',... % in the peri-ventricular heterotopias
%     'RAP1','RAP2','RAP3','LBH1','LBH2','LBH3','LPP1','LPP2','LPP3',... % in the peri-ventricular heterotopias
%     'LAP9','LAP10','RBH8','RBH9','RBH10','RPP8','RPP9','RPP10',...% out of brain
%     'RAP8','RAP9','RAP10','LBH9','LBH10','LPP8','LPP9','LPP10',...% out of brain
%     'EKG',...% EKG
%     'Mark1','Mark2','REF',...% not real data
%     'DC01','DC02','DC03','DC04','E','Events','G',...% not real data
% bad_codes: 1 = toss (epileptic or bad); 2 = suspicious; 3 = out of brain; 0 = junk
SBJ_vars.ch_lab.bad_type = {'bad','sus','out'};
SBJ_vars.ch_lab.bad_code = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 3 3 3 3 0 0 0 0 0 0 0];
if numel(SBJ_vars.ch_lab.bad)~=numel(SBJ_vars.ch_lab.bad_code);error('bad ~= bad_code');end
SBJ_vars.ch_lab.eeg = {'C3','C4','CZ','FZ','OZ'};
SBJ_vars.ch_lab.eog = {'RUC','RLC','LLC','LUC'};
SBJ_vars.ch_lab.photod  = {'Photo1'};
SBJ_vars.photo_inverted = 1;

%--------------------------------------
% Line Noise Parameters
%--------------------------------------
SBJ_vars.notch_freqs = [60 120 180 240 300];
SBJ_vars.bs_width    = 2;

%--------------------------------------
% Time Parameters
%--------------------------------------
SBJ_vars.analysis_time = {{[0.0 0.0]}};

%--------------------------------------
% Trials to Reject
%--------------------------------------
% SBJ_vars.trial_reject_n = [];
