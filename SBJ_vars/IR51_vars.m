%% ${IR51} Processing Variables
[root_dir, app_dir] = fn_get_root_dir(); ft_dir = fullfile(app_dir,'fieldtrip');
if isempty(strfind(path,'fieldtrip'))
    addpath(ft_dir);
    ft_defaults
end

%--------------------------------------
% Basics
%--------------------------------------
SBJ_vars.SBJ = 'IR51';
SBJ_vars.raw_file = {'IR51.besa'};
SBJ_vars.block_name = {''};
SBJ_vars.low_srate  = [0];

SBJ_vars.dirs.SBJ     = [root_dir fullfile('emodynamics', 'data', SBJ_vars.SBJ, filesep)];
SBJ_vars.dirs.raw     = [SBJ_vars.dirs.SBJ fullfile('00_raw',filesep)];
% SBJ_vars.dirs.SU      = [SBJ_vars.dirs.raw 'SU_2018-06-XX/'];
SBJ_vars.dirs.import  = [SBJ_vars.dirs.SBJ fullfile('01_import', filesep)];
SBJ_vars.dirs.preproc = [SBJ_vars.dirs.SBJ fullfile('02_preproc', filesep)];
SBJ_vars.dirs.events  = [SBJ_vars.dirs.SBJ fullfile('03_events', filesep)];
SBJ_vars.dirs.proc    = [SBJ_vars.dirs.SBJ fullfile('04_proc', filesep)];
SBJ_vars.dirs.recon   = [SBJ_vars.dirs.SBJ fullfile('05_recon', filesep)];
if ~exist(SBJ_vars.dirs.raw,'dir')
    mkdir(SBJ_vars.dirs.raw);
end
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

% for pplotting the recons
SBJ_vars.recon.surf_l     = [SBJ_vars.dirs.recon 'Surfaces' fullfile(filesep) SBJ_vars.SBJ '_cortex_lh.mat'];
SBJ_vars.recon.surf_r     = [SBJ_vars.dirs.recon 'Surfaces' fullfile(filesep) SBJ_vars.SBJ '_cortex_rh.mat'];
SBJ_vars.recon.elec_pat   = [SBJ_vars.dirs.recon 'Electrodes' fullfile(filesep) SBJ_vars.SBJ '_elec_acpc_....mat'];
SBJ_vars.recon.elec_mni_v = [SBJ_vars.dirs.recon 'Electrodes' fullfile(filesep) SBJ_vars.SBJ '_elec_mni_v.mat'];
SBJ_vars.recon.elec_mni_s = [];%SBJ_vars.dirs.recon 'Electrodes/' SBJ_vars.SBJ '_elec_mni_s.mat'];
SBJ_vars.recon.fs_T1      = [SBJ_vars.dirs.recon 'Scans' fullfile(filesep) SBJ_vars.SBJ '_fs_preop_T1.mgz'];
SBJ_vars.recon.fs_DK      = [SBJ_vars.dirs.recon 'Scans' fullfile(filesep) SBJ_vars.SBJ '_fs_preop_aparc+aseg.mgz'];
SBJ_vars.recon.fs_Dx      = [SBJ_vars.dirs.recon 'Scans' fullfile(filesep) SBJ_vars.SBJ '_fs_preop_aparc.a2009s+aseg.mgz'];

%--------------------------------------
% Channel Selection
%--------------------------------------
SBJ_vars.ch_lab.probes     = {'ROF', 'RIN', 'RAC', 'LTH', 'SMA', 'RAM', 'RHH', 'RTH', 'LAM', 'LHH'};
SBJ_vars.ch_lab.probe_type = {'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg'};
SBJ_vars.ch_lab.ref_type   = {'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'};
if ~all(numel(SBJ_vars.ch_lab.probes)==[numel(SBJ_vars.ch_lab.probe_type) numel(SBJ_vars.ch_lab.ref_type)]); error('probes ~= type+ref');end; % this compare the number of channels of the above 3 lines
SBJ_vars.ch_lab.ROI        = {'all'};

%SBJ_vars.ch_lab.prefix = 'POL ';    % before every channel except 'EDF Annotations'
%SBJ_vars.ch_lab.suffix = '-Ref';    % after every channel except 'EDF Annotations'
%SBJ_vars.ch_lab.mislabel = {{'RLT12','FPG12'},{'IH;L8','IHL8'}};

SBJ_vars.ch_lab.ref_exclude = {'LHH8', 'LTH10'}; % exclude from the CAR (less used for sEEG)
SBJ_vars.ch_lab.bad = {...
    'RHH1','RHH2','RHH3','RTH1','RTH2','RTH3','RAM1','RAM2','RAM3','RAM4',... % Epileptic
    'xref', 'Gnd', 'E', 'DC01', 'DC04','*-1', '*-2'...
    };
% Note: LHH8 drifting 
% Note: 'LTH3', 'LTH4', 'LHH3','LHH4': Drifting, noisy, but look OK ar 2nd visit. Decided to keep.  
% Note: 'LTH10' Slowing noise. In some time periods are off. Double check after preprocessing
% Note: 'RIN10' is included in preprocessing, but it is noted as "out of brain". Don't include this channel in analysis. 

% bad_codes: 1 = toss (epileptic or bad); 2 = suspicious; 3 = out of brain; 0 = junk
SBJ_vars.ch_lab.bad_type = {'bad','sus','out'};
SBJ_vars.ch_lab.bad_code = [1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0];
if numel(SBJ_vars.ch_lab.bad)~=numel(SBJ_vars.ch_lab.bad_code);error('bad ~= bad_code');end
SBJ_vars.ch_lab.eeg = {'FZ','CZ','OZ','C3','C4'};
SBJ_vars.ch_lab.eog = {'LUE','LLE','RUE','RLE'};
SBJ_vars.ch_lab.photod = {'DC02'};
SBJ_vars.ch_lab.speaker    = {'DC03'};
SBJ_vars.ch_lab.ekg = {'ekg'}
%--------------------------------------
% Line Noise Parameters
%--------------------------------------
SBJ_vars.notch_freqs = [60 120 180 240 300];
SBJ_vars.bs_width    = 2;

%--------------------------------------
% Time Parameters
%--------------------------------------
SBJ_vars.analysis_time = {{[55.0 1724.0]}};

%--------------------------------------
% Trials to Reject
%--------------------------------------
% SBJ_vars.trial_reject_n = [];
