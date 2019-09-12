%% ${SBJ} Processing Variables
[root_dir, app_dir] = fn_get_root_dir(); ft_dir = [app_dir fullfile('fieldtrip',filesep)];
if isempty(strfind(path,'fieldtrip'))
    addpath(ft_dir);
    ft_defaults
end

%--------------------------------------
% Basics
%--------------------------------------
SBJ_vars.SBJ = 'IR77';
SBJ_vars.raw_file = {'IR77.besa'};
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
SBJ_vars.recon.elec_pat   = [SBJ_vars.dirs.recon 'Electrodes' fullfile(filesep) SBJ_vars.SBJ '_elec_acpc_f.mat'];
SBJ_vars.recon.elec_mni_v = [SBJ_vars.dirs.recon 'Electrodes' fullfile(filesep) SBJ_vars.SBJ '_elec_mni_v.mat'];
SBJ_vars.recon.elec_mni_s = [];%SBJ_vars.dirs.recon 'Electrodes/' SBJ_vars.SBJ '_elec_mni_s.mat'];
SBJ_vars.recon.fs_T1      = [SBJ_vars.dirs.recon 'Scans' fullfile(filesep) SBJ_vars.SBJ '_fs_preop_T1.mgz'];
SBJ_vars.recon.fs_DK      = [SBJ_vars.dirs.recon 'Scans' fullfile(filesep) SBJ_vars.SBJ '_fs_preop_aparc+aseg.mgz'];
SBJ_vars.recon.fs_Dx      = [SBJ_vars.dirs.recon 'Scans' fullfile(filesep) SBJ_vars.SBJ '_fs_preop_aparc.a2009s+aseg.mgz'];

%--------------------------------------
% Channel Selection
%--------------------------------------
% SBJ_vars.ch_lab.probes     = {'RAM','RHH','RTH','RAC','RPC','ROF','RIN','LAM','LHH','LTH','LAC','LSM','LPC','LOF','LIN','2IN','LSP'}; % e.g., 'LAM', 'RAM', 'LTH', etc.
SBJ_vars.ch_lab.probes     = {'RAM','RHH','RTH','RAC','RPC','ROF','RIN','LAM','LHH','LTH','LAC','LSM','LPC','LOF','LIN','PIN','LSP'}; % e.g., 'LAM', 'RAM', 'LTH', etc.
SBJ_vars.ch_lab.probe_type = {'seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg','seeg'}; % 'seeg' or 'ecog'
SBJ_vars.ch_lab.ref_type   = {'BP','BP','BP','BP','BP','BP','BP','BP','BP','BP','BP','BP','BP','BP','BP','BP','BP'}; % either 'BP' or 'CAR or 'CARall'
if ~all(numel(SBJ_vars.ch_lab.probes)==[numel(SBJ_vars.ch_lab.probe_type) numel(SBJ_vars.ch_lab.ref_type)]); error('probes ~= type+ref');end; % this compare the number of channels of the above 3 lines
SBJ_vars.ch_lab.ROI        = {'all'};

%SBJ_vars.ch_lab.prefix = 'POL ';    % before every channel except 'EDF Annotations'
%SBJ_vars.ch_lab.suffix = '-Ref';    % after every channel except 'EDF Annotations'
SBJ_vars.ch_lab.mislabel = {{'2IN1','PIN1'},{'2IN2','PIN2'},{'2IN3','PIN3'},{'2IN4','PIN4'},{'2IN5','PIN5'},{'2IN6','PIN6'},{'2IN7','PIN7'},{'2IN8','PIN8'},{'2IN9','PIN9'},{'2IN10','PIN10'}};

% Below is only for SU patients
% SBJ_vars.ch_lab.nlx          = [1,1,1,0,0,0,1,1,1,1,0,0];
% SBJ_vars.ch_lab.wires        = {'mram','mrhh','mrth','mlam','mlhh','mlth'};
% SBJ_vars.ch_lab.wire_type    = {'su','su','su','su','su','su'};
% SBJ_vars.ch_lab.wire_ref     = {'','','','','',''};
% SBJ_vars.ch_lab.wire_ROI     = {'all'};
% SBJ_vars.ch_lab.nlx_suffix   = '_00XX';
% SBJ_vars.ch_lab.nlx_nk_align = {'LAP4','LAP5'};
% SBJ_vars.nlx_macro_inverted  = 1;


SBJ_vars.ch_lab.ref_exclude = {'LAM9','RTH4'...
                               'LHH4'}; % exclude from the CAR (less used for sEEG)
SBJ_vars.ch_lab.bad = {'REF','E','Z','DC02','DC03','DC04'...
                        ,'LIN7','LIN8','LIN9','LIN10'...
                        ,'LHH10'... suspect out of brain (high frequency noise)
                         ,'LSM7','LSM8','LSM9','LSM10','2IN9','2IN10'};% out of brain
% bad_codes: 1 = toss (epileptic or bad); 2 = suspicious; 3 = out of brain; 0 = junk
SBJ_vars.ch_lab.bad_type = {'bad','sus','out'};
SBJ_vars.ch_lab.bad_code = [0,0,0,0,0,0,1,1,1,1,2,3,3,3,3,3,3];
if numel(SBJ_vars.ch_lab.bad)~=numel(SBJ_vars.ch_lab.bad_code);error('bad ~= bad_code');end
SBJ_vars.ch_lab.eeg = {'FZ', 'CZ', 'OZ', 'C3', 'C4'};
SBJ_vars.ch_lab.eog = {'LUC', 'LLC', 'RUC', 'RLC'};
SBJ_vars.ch_lab.photod = {'DC01'};     % From experimenter notes (e.g., when noted as '1', means 'DC01') 
SBJ_vars.ch_lab.speaker    = {}; % From experimenter notes 
SBJ_vars.ch_lab.ekg    = {'EKG'}; 

%--------------------------------------
% Line Noise Parameters
%--------------------------------------
SBJ_vars.notch_freqs = [60 120 180 240 300];
SBJ_vars.bs_width    = 2;

%--------------------------------------
% Time Parameters
%--------------------------------------
SBJ_vars.analysis_time = {{[0.0 1895.0]}};

% Three examples for specifying the time of analyses 
% SBJ_vars.analysis_time = {{[55.0 1724.0]}};  <<< most simple case
% SBJ_vars.analysis_time = {{[55.0 500] [700 1724.0]}}; << one run, two epochs (e.g., a nurse came in) 
% SBJ_vars.analysis_time = {{[55.0 500] [700 1724.0]},{[55.0 500] [700 1724.0]}}; << for some reason, two runs

%--------------------------------------
% Trials to Reject
%--------------------------------------
% SBJ_vars.trial_reject_n = [];

%--------------------------------------
% Film Trials Numbers
%--------------------------------------
SBJ_vars.video_id = [3,2,6,7,8,5,4,1]';
% 1. Disgust: Roaches (154000 ms)
% 2. Happy: Modern Times (154000 ms)
% 3. Fear: Witness (154000 ms)
% 4. Neutral: Sticks (154000 ms)
% 5. Fear: Cujo (154000 ms)
% 6. Disgust: Poop Lady (154000 ms)
% 7. Neutral: ColorBars (154000 ms)
% 8. Happy: Lucy (159000 ms)

