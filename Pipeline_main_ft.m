%% Preprocessing Pipeline
% This script should be run in sections. Functions/scripts with the SBJ##
% prefix can be run automatically, and all other sections should be
% manually editted for each dataset.
clear all; close all;

%% Check which root directory
if exist('/home/knight/','dir');root_dir='/home/knight/';ft_dir=[root_dir 'hoycw/Apps/fieldtrip/'];
elseif exist('E:\','dir');root_dir='E:\';ft_dir='C:\Toolbox\fieldtrip';
else root_dir='/Volumes/hoycw_clust/';ft_dir='/Users/colinhoy/Code/Apps/fieldtrip/';end

%% Set Up Directories
addpath(fullfile(root_dir,'emodynamics','scripts'));
addpath(fullfile(root_dir,'emodynamics','scripts','utils'));
addpath(ft_dir);
ft_defaults

%% Step 0 - Processing Variables
SBJ = 'IR77';
proc_id = 'main_ft';
eval(['run ' fullfile(root_dir,'emodynamics','scripts','proc_vars',[proc_id '_vars.m'])]);

%% ========================================================================
%   Step 1- Load SBJ and Processing Variable Structures
%  ========================================================================
SBJ_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_vars',[SBJ '_vars.m'])];
eval(SBJ_vars_cmd);

%% ========================================================================
%   Step 1.1- Load iEEG data (to get channel lebels)
%  ========================================================================

b_ix = 1

if strcmp(SBJ_vars.raw_file{b_ix}(end-2:end),'mat')
    load(SBJ_vars.dirs.raw_filename{b_ix});
else
    cfg = [];
    cfg.dataset = SBJ_vars.dirs.raw_filename{b_ix};
    cfg.continuous = 'yes';
    cfg.channel = 'all';
    data = ft_preprocessing(cfg);
end

% To know the time of analyses (get task onset and offset time from photodiode and speaker)
load(fullfile('E:','emodynamics','scripts','utils','cfg_plot.mat'))
ft_databrowser(cfg_plot,data)

%% ========================================================================
%   Fill out SBJ_vars --  channel labels 
%  ========================================================================
% SBJ_vars.SBJ = 'IR51';
% SBJ_vars.raw_file = {'IR51.besa'};
% SBJ_vars.block_name = {''};
% SBJ_vars.low_srate  = [0];
% 
% SBJ_vars.ch_lab.probes     = {'ROF', 'RIN', 'RAC', 'LTH', 'SMA', 'RAM', 'RHH', 'RTH', 'LAM', 'LHH'};
% SBJ_vars.ch_lab.probe_type = {'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg', 'seeg'};
% SBJ_vars.ch_lab.ref_type   = {'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP', 'BP'};

% Run below if necessary (for corrections)
%SBJ_vars.ch_lab.prefix = 'POL ';    % before every channel except 'EDF Annotations'
%SBJ_vars.ch_lab.suffix = '-Ref';    % after every channel except 'EDF Annotations'
%SBJ_vars.ch_lab.mislabel = {{'RLT12','FPG12'},{'IH;L8','IHL8'}};

% Below is only for SU patients
% SBJ_vars.ch_lab.nlx          = [1,1,1,0,0,0,1,1,1,1,0,0];
% SBJ_vars.ch_lab.wires        = {'mram','mrhh','mrth','mlam','mlhh','mlth'};
% SBJ_vars.ch_lab.wire_type    = {'su','su','su','su','su','su'};
% SBJ_vars.ch_lab.wire_ref     = {'','','','','',''};
% SBJ_vars.ch_lab.wire_ROI     = {'all'};
% SBJ_vars.ch_lab.nlx_suffix   = '_00XX';
% SBJ_vars.ch_lab.nlx_nk_align = {'LAP4','LAP5'};
% SBJ_vars.nlx_macro_inverted  = 1;

% SBJ_vars.ch_lab.ref_exclude = {}; % exclude from the CAR (less used for sEEG)
% SBJ_vars.ch_lab.bad = {};
% SBJ_vars.ch_lab.bad_code = [];
% SBJ_vars.ch_lab.eeg = {};
% SBJ_vars.ch_lab.eog = {};
% SBJ_vars.ch_lab.photod = {};
% SBJ_vars.ch_lab.speaker    = {};
% SBJ_vars.ch_lab.ekg    = {};

% SBJ_vars.analysis_time = {{[onset_time offset_time]}};


%% ========================================================================
%   Step 2- Quick Import and Processing for Data Cleaning/Inspection
%  ========================================================================
SBJ00_cleaning_prep(SBJ,proc.plot_psd);


%% ========================================================================
%   Re visit after Bob
%  ========================================================================
block_ix = 1;
keep_db_out = 1; 
db_out = SBJ00b_view_preclean(SBJ,block_ix,keep_db_out,'reorder','','label_size',6);%,'ylim',[-100 100]
%db_out = SBJ00b_view_preclean(SBJ,block_ix,keep_db_out);

% Save out the bad_epochs from the preprocessed data
bad_epochs = db_out.artfctdef.visual.artifact;
tiny_bad = find(diff(bad_epochs,1,2)<10);
if ~isempty(tiny_bad)
    warning('Tiny bad epochs detected:\n');
    disp(bad_epochs(tiny_bad,:));
    bad_epochs(tiny_bad,:) = [];
end
save(fullfile(SBJ_vars.dirs.events,[SBJ '_bad_epochs_preclean.mat']),'-v7.3','bad_epochs');


%% ========================================================================
%   Step 3- Import Data, Resample, and Save Individual Data Types
%  ========================================================================
SBJ01_import_data(SBJ,proc_id);

%% ========================================================================
%   Step 4- Preprocess Neural Data
%  ========================================================================
SBJ02_preproc(SBJ,proc_id)

%% Second visual cleaning after preprocessing
load(fullfile(SBJ_vars.dirs.preproc,[SBJ '_preproc_' proc_id '.mat']));
% Load bad_epochs from preclean data and adjust to analysis_time
preclean_ep_at = fn_compile_epochs_full2at(SBJ,proc_id);

% Plot data with bad_epochs highlighted
load(fullfile(root_dir,'emodynamics','scripts','utils','cfg_plot.mat'));
% If you want to see preclean bad_epochs:
cfg_plot.artfctdef.visual.artifact = preclean_ep_at;
if isfield(data,'sampleinfo')   % the data.sample_info field can mess up the viewing sometimes...
    data = rmfield(data,'sampleinfo');
end
out = ft_databrowser(cfg_plot,data);
% adjust font size if needed
cfg_plot.fontsize = 6;  

% Save out the bad_epochs from the preprocessed data
bad_epochs = out.artfctdef.visual.artifact;
tiny_bad = find(diff(bad_epochs,1,2)<10);
if ~isempty(tiny_bad)
    warning('Tiny bad epochs detected:\n');
    disp(bad_epochs(tiny_bad,:));
    bad_epochs(tiny_bad,:) = [];
end
save(fullfile(SBJ_vars.dirs.events,[SBJ '_bad_epochs_preproc.mat']),'-v7.3','bad_epochs');

%% ========================================================================
%   Step 5a- Manually Clean Photodiode Trace: Load & Plot
%  ========================================================================
% Load data
for b_ix = 1:numel(SBJ_vars.block_name)
    % Create a block suffix in cases with more than one recording block
    if numel(SBJ_vars.raw_file)==1 || isfield(SBJ_vars.dirs,'nlx')
        block_suffix = '';
    else
        block_suffix = strcat('_',SBJ_vars.block_name{b_ix});
    end
    evnt_fname = fullfile(SBJ_vars.dirs.import,[SBJ '_evnt' block_suffix '.mat']);
    load(evnt_fname);
    
    % Plot event channels
    photo_ix = find(strcmp(SBJ_vars.ch_lab.photod,evnt.label));
    plot(evnt.time{1}, evnt.trial{1}(photo_ix,:));
    
    % Add videos that are in log but not in the photodiode
    %   (empty if all videos are in log and photodiode)
    ignore_trials = [];
    
    %% ========================================================================
    %   Step 5b- Manually Clean Photodiode Trace: Mark Sections to Correct
    %  ========================================================================
    % Create correction times and values in a separate file in ~/emodynamics/scripts/SBJ_evnt_clean/
%     SBJ_evnt_clean_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_evnt_clean',[SBJ '_evnt_clean_params' block_suffix '.m'])];
%     eval(SBJ_evnt_clean_cmd);
    
    %% ========================================================================
    %   Step 5c- Manually Clean Photodiode Trace: Apply Corrections
    %  ========================================================================
%     % Correct baseline shift
%     for shift_ix = 1:length(bsln_shift_times)
%         epoch_idx = floor(bsln_shift_times{shift_ix}(1)*evnt.fsample):floor(bsln_shift_times{shift_ix}(2)*evnt.fsample);
%         epoch_idx(epoch_idx<1) = [];
%         evnt.trial{1}(photod_ix,epoch_idx) = evnt.trial{1}(photod_ix,epoch_idx) - bsln_shift_val(shift_ix);
%     end
%     % zero out drifts
%     for zero_ix = 1:length(bsln_times)
%         epoch_idx = floor(bsln_times{zero_ix}(1)*evnt.fsample):floor(bsln_times{zero_ix}(2)*evnt.fsample);
%         epoch_idx(epoch_idx<1) = [];
%         evnt.trial{1}(photod_ix,epoch_idx) = bsln_val;
%     end
%     
%     % level out stimulus periods
%     for stim_ix = 1:length(stim_times)
%         epoch_idx = floor(stim_times{stim_ix}(1)*evnt.fsample):floor(stim_times{stim_ix}(2)*evnt.fsample);
%         epoch_idx(epoch_idx<1) = [];
%         evnt.trial{1}(photod_ix,epoch_idx) = stim_yval(stim_ix);
%     end
    
    % Save corrected data
    out_fname = fullfile(SBJ_vars.dirs.preproc,[SBJ '_evnt_clean' block_suffix '.mat']);
    save(out_fname, 'evnt', 'ignore_trials', 'photo_ix');
    
    %% ========================================================================
    %   Step 6- Parse Event Traces into Behavioral Data
    %  ========================================================================
    SBJ04_photo_parse(SBJ,b_ix,1,1);
end

%% ========================================================================
%   Step 6- Create elec struct based on ROIs
%  ========================================================================
% convert raw elec file from recon to bipolar re-referenced (patient and group space)
fn_compile_elec_atlas(SBJ,'main_ft','pat','',1);
fn_compile_elec_atlas(SBJ,'main_ft','mni','v',1);
% Add tissue compartment info (GM, WM, CSF)
fn_save_elec_atlas(SBJ,'main_ft','pat','','DK');
fn_save_elec_atlas(SBJ,'main_ft','pat','','Dx');

%% ========================================================================
%   Step 6a?- May be before the previous step?
%  ========================================================================
% convert raw elec file from recon to bipolar re-referenced (patient and group space)

fn_elec_import_orig(SBJ,'main_ft','pat','',1);

