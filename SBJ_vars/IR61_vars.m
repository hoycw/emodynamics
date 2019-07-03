%% IR61 Processing Variables
[root_dir, app_dir] = fn_get_root_dir(); ft_dir = [app_dir 'fieldtrip/'];
if isempty(strfind(path,'fieldtrip'))
    addpath(ft_dir);
    ft_defaults
end

%--------------------------------------
% Basics
%--------------------------------------
SBJ_vars.SBJ = 'IR61';
SBJ_vars.raw_file = {'2009010101_00XX.besa'};
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
SBJ_vars.recon.elec_pat   = [SBJ_vars.dirs.recon 'Electrodes/' SBJ_vars.SBJ '_elec_acpc.mat'];
SBJ_vars.recon.elec_mni_v = [SBJ_vars.dirs.recon 'Electrodes/' SBJ_vars.SBJ '_elec_mni_v.mat'];
SBJ_vars.recon.elec_mni_s = [];
SBJ_vars.recon.fs_T1      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_T1.mgz'];
SBJ_vars.recon.fs_DK      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_aparc+aseg.mgz'];
SBJ_vars.recon.fs_Dx      = [SBJ_vars.dirs.recon 'Scans/' SBJ_vars.SBJ '_fs_preop_aparc.a2009s+aseg.mgz'];

%--------------------------------------
% Channel Selection
%--------------------------------------
SBJ_vars.ch_lab.probes     = {'LOF','LAC','RAM','ROF','RAC'};%tossed all of LAM, LHH, LTH, RHH, RTH
SBJ_vars.ch_lab.probe_type = {'seeg','seeg','seeg','seeg','seeg'};
SBJ_vars.ch_lab.ref_type   = {'BP','BP','BP','BP','BP'};
if ~all(numel(SBJ_vars.ch_lab.probes)==[numel(SBJ_vars.ch_lab.probe_type) numel(SBJ_vars.ch_lab.ref_type)]); error('probes ~= type+ref');end;
SBJ_vars.ch_lab.ROI        = {'all'}; %nothing else left, just LOF, LAC, ROF, RAC + RAM6-7
                              %'LOF*','LAC*','ROF*','RAC*','RAM4-5','RAM5-6',... % RAM5,6 inf. ant. Insula, RAM4 is WM nearby
                              %'RHH5-6','RHH6-7'}; % RHH5,6 in inf. post. Insula, RHH7 WM nearby
% SBJ_vars.ch_lab.eeg_ROI    = {'CZ','FZ','FPZ'};

SBJ_vars.ch_lab.ref_exclude = {}; %exclude from the CAR
SBJ_vars.ch_lab.bad = {...
    'LAM1','LAM2','LAM3','LAM4','LAM5','LAM6','LAM7','LAM8','LAM9','LAM10',... %epileptic and sprtead and slowing
    'LHH1','LHH2','LHH3','LHH4','LHH5','LHH6','LHH7','LHH8','LHH9','LHH10',...%epileptic and spread and slowing
    'LTH1','LTH2','LTH3','LTH4','LTH5','LTH6','LTH7','LTH8','LTH9','LTH10',...%epileptic and spread and slowing
    'RAM1','RAM2','RAM3','RAM4','RAM5','RAM8','RAM9',...%epileptic and spread and slowing
    'RHH2','RHH3','RHH4','RHH5','RHH6','RHH7','RHH8','RHH9','RHH10',...%epileptic and spread and slowing
    'RTH1','RTH2','RTH3','RTH4','RTH5','RTH6','RTH7','RTH8','RTH9','RTH10',...%epileptic and spread and slowing
    'LOF1','LOF10','LAC10','RAM10','RHH1','RAC10','ROF10',...%out of brain
    'Z','---(13)','---(14)','---(17)','---(18)',...% not real?
    'REF','EKG','DC01','DC03','DC04'...%non-neural
    };
    % BEWARE: LTH4 (ventricle), LHH1+RAM9 (border)
    % 'LAM3','LHH7',...%loose
    % watch out for FZ, Janna said it was bad
% bad_codes: 1 = toss (epileptic or bad); 2 = suspicious; 3 = out of brain; 0 = junk
SBJ_vars.ch_lab.bad_type = {'bad','sus','out'};
SBJ_vars.ch_lab.bad_code = [1 1 1 1 1 1 1 1 1 1 ...
                            1 1 1 1 1 1 1 1 1 1 ...
                            1 1 1 1 1 1 1 1 1 1 ...
                            1 1 1 1 1 1 1       ...
                            1 1 1 1 1 1 1 1 1   ...
                            1 1 1 1 1 1 1 1 1 1 ...
                            3 3 3 3 3 3 3 0 0 0 0 0 0 0 0 0 0];
if numel(SBJ_vars.ch_lab.bad)~=numel(SBJ_vars.ch_lab.bad_code);error('bad ~= bad_code');end
SBJ_vars.ch_lab.eeg = {'FZ','FPZ','CZ','OZ','C3','C4'};
SBJ_vars.ch_lab.eog = {'LLE','LUE','RLE','RUE'};
SBJ_vars.ch_lab.photod = {'DC02'};

%--------------------------------------
% Line Noise Parameters
%--------------------------------------
SBJ_vars.notch_freqs = [60 120 180 240 300];
SBJ_vars.bs_width    = 2;

%--------------------------------------
% Time Parameters
%--------------------------------------
SBJ_vars.analysis_time = {{[0 0]}};

%--------------------------------------
% Trials to Reject
%--------------------------------------
% SBJ_vars.trial_reject_n = [201 233];
