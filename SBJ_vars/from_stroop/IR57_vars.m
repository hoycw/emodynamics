%% IR57 Processing Variables
[root_dir, app_dir] = fn_get_root_dir(); ft_dir = [app_dir 'fieldtrip/'];
if isempty(strfind(path,'fieldtrip'))
    addpath(ft_dir);
    ft_defaults
end

%--------------------------------------
% Basics
%--------------------------------------
SBJ_vars.SBJ = 'IR57';
SBJ_vars.raw_file = {'2017032319_0023.besa'};
SBJ_vars.block_name = {''};
SBJ_vars.low_srate  = [0];

SBJ_vars.dirs.SBJ     = [root_dir 'PRJ_Stroop/data/' SBJ_vars.SBJ '/'];
SBJ_vars.dirs.raw     = [SBJ_vars.dirs.SBJ '00_raw/'];
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
SBJ_vars.recon.elec_mni_v = [SBJ_vars.dirs.recon 'Electrodes/' SBJ_vars.SBJ '_elec_mni_v.mat'];
SBJ_vars.recon.elec_mni_s = [];
SBJ_vars.recon.fs_T1      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_T1.mgz'];
SBJ_vars.recon.fs_DK      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_aparc+aseg.mgz'];
SBJ_vars.recon.fs_Dx      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_aparc.a2009s+aseg.mgz'];

%--------------------------------------
% Channel Selection
%--------------------------------------
SBJ_vars.ch_lab.probes     = {'RSM','RAC','ROF','RIN','RTI','RTH',... % NOTE: RHH gone because 5 is only non-bad
                              'LSMA','LAC','LOF','LIN','LTI','LTH'};%'LHH' 'LAM' 'RAM' don't count because all elecs are bad
SBJ_vars.ch_lab.probe_type = {'seeg','seeg','seeg','seeg','seeg','seeg',...
                              'seeg','seeg','seeg','seeg','seeg','seeg'};
SBJ_vars.ch_lab.ref_type   = {'BP','BP','BP','BP','BP','BP',...
                              'BP','BP','BP','BP','BP','BP'};
if ~all(numel(SBJ_vars.ch_lab.probes)==[numel(SBJ_vars.ch_lab.probe_type) numel(SBJ_vars.ch_lab.ref_type)]); error('probes ~= type+ref');end;
SBJ_vars.ch_lab.ROI        = {'all'};%'RSM*','RAC*','ROF*','RIN*','RTI*',...
%                              'LAC*','LOF*',...%LAM4,5 are inferior anterior insula, so this used to have LAM4-5 and 5-6
%                              '-LOF1-2','-RTI2-3','-RIN4-5'}; %these are rejected based on variance
SBJ_vars.ch_lab.eeg_ROI    = {'CZ','FPZ'};

SBJ_vars.ch_lab.ref_exclude = {}; %exclude from the CAR
SBJ_vars.ch_lab.bad = {...
    'RHH1','RHH2','RHH3','RHH4','ROF1','RAM1','RAM2','RAM3','RTH1','RTH2','RTH3',...%epileptic
    'LHH1','LHH2','LHH3','LHH4','LHH5','LHH6','LHH7','LHH8','LHH9','LHH10',...%epileptic
    'LTH1','LTH2','LTH3','LAM1','LAM2','LAM3',...%epileptic
    'LTH4','LTH5','LTH6','LAM4','LAM5','LAM6','LAM7','LAM8','LAM9',...% epileptic spread
    'RAM4','RAM5','RAM6','RAM7','RAM8','RAM9','RTH4','RTH5',...%epileptic spread
    'RHH8','RHH9',...%spike trigger slowing
    'RSM2','RSM3','RIN9','RIN10','LTI2','LTI3','RHH6',...%bad line noise
    'RSM9','RSM10','RAC10','RAM10','RTH9','RTH10','LOF10','LAM10',...%out of brain
    'LTH10','RTH8','RHH10','RTI10',...% added to out of brain
    'RHH7',...%marked as bad in visual for some reason?
    'Z','T4','O2','T3',...%bad eeg channels
    'DC01','DC03','XREF','E',...% not real data
    'EKG'...
    };
% LHH1,2,4,6 also have bad line noise
% bad_codes: 1 = toss (epileptic or bad); 2 = suspicious; 3 = out of brain; 0 = junk
SBJ_vars.ch_lab.bad_type = {'bad','sus','out'};
SBJ_vars.ch_lab.bad_code = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 ...
                            3 3 3 3 3 3 3 3 3 3 3 3 2 0 0 0 0 0 0 0 0 0];
if numel(SBJ_vars.ch_lab.bad)~=numel(SBJ_vars.ch_lab.bad_code);error('bad ~= bad_code');end
SBJ_vars.ch_lab.eeg = {'FPZ' 'CZ' 'OZ' 'C3' 'C4' 'FP1' 'FP2' 'O1'};
SBJ_vars.ch_lab.CZ_lap_ref = {'C3','C4'};
SBJ_vars.ch_lab.FPZ_lap_ref = {'FP1','FP2'};
SBJ_vars.ch_lab.eog = {'LUC','LLC','RUC','RLC'};
SBJ_vars.ch_lab.photod = {'DC02'};
SBJ_vars.ch_lab.mic    = {'DC04'};

%--------------------------------------
% Line Noise Parameters
%--------------------------------------
% most have only regular harmonics with normal width, and 120 and 240 are weak
% RBT, RPIN, RSMA,LAC have an extra peak at 200
% RHH6 has really bad at all harmonics, like LUE and other nonsense chan
SBJ_vars.notch_freqs = [60 120 180 240 300];
SBJ_vars.bs_width    = 2;

%--------------------------------------
% Time Parameters
%--------------------------------------
SBJ_vars.analysis_time = {{[70 1040]}};

% %--------------------------------------
% % Save SBJ_vars
% %--------------------------------------
% out_filename = [SBJ_vars.dirs.SBJ SBJ '_vars.mat'];
% save(out_filename,'SBJ_vars');

%--------------------------------------
% Artifact Rejection Parameters
%--------------------------------------
% Add rejection of LOF1-2, maybe RTI2-3, RIN4-5
SBJ_vars.artifact_params.std_limit_raw = 7;
SBJ_vars.artifact_params.hard_threshold_raw = 700;

SBJ_vars.artifact_params.std_limit_diff = 7;
SBJ_vars.artifact_params.hard_threshold_diff = 35;

%--------------------------------------
% Trials to Reject
%--------------------------------------
% These should be indices AFTER SBJ05 has run!
SBJ_vars.trial_reject_n = [50 125 131 134 213 214 306 311];
% BADBADBAD SBJ_vars.trial_reject_ix = [22, 95, 174, 176, 180, 245, 254];
