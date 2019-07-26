function SBJ05_HFA_save(SBJ,proc_id,an_id)
% Calculates high frequency activity, computes cluster-based statistics, and plots the results
% clear all; %close all;

% Set up paths
if exist('/home/knight/hoycw/','dir');root_dir='/home/knight/hoycw/';ft_dir=[root_dir 'Apps/fieldtrip/'];
else root_dir='/Volumes/hoycw_clust/';ft_dir='/Users/colinhoy/Code/Apps/fieldtrip/';end
addpath([root_dir 'emodynamics/scripts/']);
addpath([root_dir 'emodynamics/scripts/utils/']);
addpath(ft_dir);
ft_defaults

%% Data Preparation
SBJ_vars_cmd = ['run ' root_dir 'emodynamics/scripts/SBJ_vars/' SBJ '_vars.m'];
eval(SBJ_vars_cmd);
an_vars_cmd = ['run ' root_dir 'emodynamics/scripts/an_vars/' an_id '_vars.m'];
eval(an_vars_cmd);

% Load Data
load(strcat(SBJ_vars.dirs.preproc,SBJ,'_preproc_',proc_id,'.mat'));
load(strcat(SBJ_vars.dirs.events,SBJ,'_trial_info_final.mat'));

%% Select Channel(s)
cfgs = [];
cfgs.channel = SBJ_vars.ch_lab.ROI;
roi = ft_selectdata(cfgs,data);
roi_fsample = roi.fsample;
clear data;

%% Compute HFA
fprintf('===================================================\n');
fprintf('------------------ HFA Calculations ---------------\n');
fprintf('===================================================\n');
if strcmp(an.HFA_type,'multiband')
    cfg_hfa.trials = 'all';
    hfa = ft_freqanalysis(cfg_hfa, roi_trl);
elseif strcmp(an.HFA_type,'hilbert')
    % Create fake ft_freqanalysis struct
    hfa.label = roi_trl.label;
    hfa.freq  = an.fois;
    hfa.time  = roi_trl.time{1};
    hfa.powspctrm = zeros([numel(roi_trl.trial) numel(roi_trl.label) numel(an.fois) numel(roi_trl.time{1})]);
    hfa.dimord = 'rpt_chan_freq_time';
    hfa.trialinfo = roi_trl.trialinfo;
    for f_ix = 1:numel(an.fois)
        cfg_hfa.bpfreq = an.bp_lim(f_ix,:);
        cfg_hfa.hilbert = 'abs';
        fprintf('\n------> %s filtering: %.03f - %.03f\n', an.HFA_type, an.bp_lim(f_ix,1), an.bp_lim(f_ix,2));
        hfa_tmp = ft_preprocessing(cfg_hfa,roi_trl);
        for t_ix = 1:numel(roi_trl.trial)
            hfa.powspctrm(t_ix,:,f_ix,:) = hfa_tmp.trial{t_ix};
        end
    end
    clear hfa_tmp;
elseif strcmp(an.HFA_type,'broadband')
    error('Stop using broadband and use filter-hilbert or multitapers you dummy!');
    %         % Filter to single HFA band
    %         cfgpp=[];.hpfilter='yes';.hpfreq=70;.lpfilter='yes';lpfreq=150;
    %         roi = ft_preprocessing(cfgpp,roi);
else
    error('Unknown an.HFA_type provided');
end

%% Baseline Correction
fprintf('===================================================\n');
fprintf('---------------- Baseline Correction --------------\n');
fprintf('===================================================\n');
switch an.bsln_type
    case {'zboot', 'zscore'}
        hfa = fn_bsln_ft_tfr(hfa,an.bsln_lim,an.bsln_type,an.bsln_boots);
    case {'relchange', 'demean', 'my_relchange'}
        error(['bsln_type ' an.bsln_type ' is not compatible with one-sample t test bsln activation stats']);
%         cfgbsln = [];
%         cfgbsln.baseline     = bsln_lim;
%         cfgbsln.baselinetype = bsln_type;
%         cfgbsln.parameter    = 'powspctrm';
%         hfa = ft_freqbaseline(cfgbsln,hfa);
    otherwise
        error(['No baseline implemented for bsln_type: ' an.bsln_type]);
end

%% Smooth Power Time Series
if an.smooth_pow_ts
    % error catches
    if ~strcmp(an.lp_yn,'yes')
        if strcmp(an.hp_yn,'yes')
            error('Why are you only high passing?');
        else
            error('Why is smooth_pow_ts yes but no lp or hp?');
        end
    end
    fprintf('===================================================\n');
    fprintf('----------------- Filtering Power -----------------\n');
    fprintf('===================================================\n');
    for ch_ix = 1:numel(hfa.label)
        for f_ix = 1:numel(hfa.freq)
            if strcmp(an.lp_yn,'yes') && strcmp(an.hp_yn,'yes')
                hfa.powspctrm(:,ch_ix,f_ix,:) = fn_EEGlab_bandpass(...
                    hfa.powspctrm(:,ch_ix,f_ix,:), roi_fsample, an.hp_freq, an.lp_freq);
            elseif strcmp(an.lp_yn,'yes')
                hfa.powspctrm(:,ch_ix,f_ix,:) = fn_EEGlab_lowpass(...
                    hfa.powspctrm(:,ch_ix,f_ix,:), roi_fsample, an.lp_freq);
            else
                error('weird non-Y/N filtering options!');
            end
        end
    end
end

%% Merge multiple bands
cfg_avg = [];
cfg_avg.freq = 'all';
cfg_avg.avgoverfreq = 'yes';
hfa = ft_selectdata(cfg_avg,hfa);

%% Downsample
if an.resample_ts && hfa.fsample~=an.resample_freq
    cfgrs = [];
    cfgrs.resamplefs = an.resample_freq;
    cfgrs.detrend = 'no';
    hfa = ft_resampledata(cfgrs, hfa);
end

%% Save Results
data_out_fname = strcat(SBJ_vars.dirs.proc,SBJ,'_ROI_',an_id,'.mat');
fprintf('===================================================\n');
fprintf('--- Saving %s ------------------\n',data_out_fname);
fprintf('===================================================\n');
save(data_out_fname,'-v7.3','hfa','an');

end
