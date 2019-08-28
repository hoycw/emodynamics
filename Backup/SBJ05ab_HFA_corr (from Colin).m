function SBJ05ab_HFA_corr(SBJ,an_id,stat_id)
%% function SBJ08ab_HFA_corr(SBJ,an_id,stat_id)
%   Calculates correlation with covariate in sliding windows
%       Covariates: EKG, Rating time series
%   Stats: alpha level of baseline correlations (fixation)
%   Writes text report of significance
% INPUTS:
%   SBJ [str] - subject ID
%   an_id [str] - HFA analysis to run stats
%   stat_id [str] - ID of the statistical parameters
% OUTPUTS:
%   corr [struct] - pseudo-FT structure with main outputs
%   st [struct] - stat params loaded via stat_id

if exist('/home/knight/','dir');root_dir='/home/knight/';ft_dir=[root_dir 'hoycw/Apps/fieldtrip/'];
elseif exist('G:\','dir');root_dir='G:\';ft_dir='C:\Toolbox\fieldtrip\';
else root_dir='/Volumes/hoycw_clust/';ft_dir='/Users/colinhoy/Code/Apps/fieldtrip/';end

%% Set up paths
addpath(fullfile(root_dir,'emodynamics','scripts'));
addpath(fullfile(root_dir,'emodynamics','scripts','utils'));
addpath(ft_dir);
ft_defaults

%% Data Preparation
SBJ_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_vars', [SBJ '_vars.m'])];
eval(SBJ_vars_cmd);
an_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','an_vars', [an_id '_vars.m'])];
eval(an_vars_cmd);
stat_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','stat_vars', [stat_id '_vars.m'])];
eval(stat_vars_cmd);
timing_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts', 'timing_vars.m')];
eval(timing_vars_cmd);

% Load Data
hfa_fname = strcat(SBJ_vars.dirs.proc,SBJ,'_ROI_',an_id,'.mat');
load(hfa_fname);
load(strcat(SBJ_vars.dirs.events,SBJ,'_trial_info.mat'));
load([SBJ_vars.dirs.events,SBJ,'_bad_epochs_preproc.mat']);

% Load EKG as a dummy structure for the covariate of interest
load([SBJ_vars.dirs.import,SBJ,'_ekg_',num2str(trial_info.sample_rate),'hz.mat']);
cov = ekg;

% Prepare to cut trials
max_trl_len = max(trial_info.trial_offsets-trial_info.trial_onsets);
cfgs = [];
cfgs.trl = [trial_info.trial_onsets, ...             % start of trial (including baseline+buffer)
    trial_info.trial_onsets+max_trl_len, ...                   % end of trial
    zeros([length(trial_info.trial_onsets) 1]), ... % time of event relative to start of trial
    trial_info.video_id];                           % trial type
cfgs.trl = round(cfgs.trl);

%% Load Covaraites
% !!! Kuan: deal with down sampling these data to the HFA sampling rate (an.resample_freq)
if strcmp(st.model_lab,'crEKG')
    load([SBJ_vars.dirs.preproc,SBJ,'_ibi_',num2str(trial_info.sample_rate),'hz.mat']);
    cov.trial{1} = ibi_1000hz_cubic;
    % Segment to trials
    cov = ft_redefinetrial(cfgs, cov);
elseif strcmp(st.model_lab,'crRat')
    load(fullfile(root_dir,'emodynamics','data','Behavioral Data','behaviors_no film 7, with film 9 friends.mat'));
    % Segment to trials
    cov = ft_redefinetrial(cfgs, cov);
    % Add in Rating data
    for m_ix = 1:numel(trial_info.video_id)
        cov.trial{m_ix} = nan(size(cov.trial{m_ix}));
        cov.trial{m_ix}(1,1:numel(export_normative{m_ix})) = export_normative{m_ix};
    end
else
    error(['Unknown st.model_lab: ' st.model_lab]);
end

%% Remove bad_epochs from HFA
% Convert bad_epochs to trial times using cov.sampleinfo
% !!! Kuan: figure out how to get the sample number from analysis_time
% (bad_epochs_preproc) into the time/sample from the start of each movie

% Remove bad epochs
% !!! Kuan: now you need to make the data during the epochs (adjusted to
% trials) into NaN

%% Build null distribution
fprintf('===================================================\n');
fprintf('--------------------- Baselines -------------------\n');
fprintf('===================================================\n');
% Extract baseline data
cfg_trim = [];
cfg_trim.trials = 'all';
cfg_trim.latency = [0.0 times.bsln_len];
bsln_hfa = ft_selectdata(cfg_trim,hfa);
bsln_cov = ft_selectdata(cfg_trim,cov);
% bsln_cat = ft_appenddata([], bsln_hfa);
% bsln_cat = horzcat(bsln_cat.trial{:});
% if any(isnan(bsln_cat(:))); error('why are there nans in baseline?'); end

win_lim    = fn_sliding_window_lim(squeeze(bsln_hfa.powspctrm(1,1,1,:)),...
    round(st.win_len*trial_info.sample_rate),...
    round(st.win_step*trial_info.sample_rate));

% Build distribution of window averages
% Create structure for baseline corr in fieldtrip style
bsln.label     = bsln_hfa.label;
bsln.dimord    = 'rpt_chan_time';
bsln.time      = bsln_hfa.time(round(mean(win_lim,2)));
bsln.r2        = nan([size(bsln_hfa.powspctrm,1) size(bsln_hfa.powspctrm,2) size(win_lim,1)]);
bsln.win_lim   = win_lim;
bsln.win_lim_s = bsln_hfa.time(win_lim);
bsln.good_win  = false([numel(trial_info.video_id) size(bsln.time,1)]);
bsln.thresh    = nan(size(bsln.label));

fprintf('Building baseline distribution...\n\t');
for ch_ix = 1:numel(bsln_hfa.label)
    fprintf('%d..',ch_ix);
    if mod(ch_ix,30)==0; fprintf('\n\t'); end
    bsln_vals = [];
    for m_ix = 1:numel(trial_info.video_id)
        % Average HFA per window
        for w_ix = 1:size(win_lim,1)
            cov_data = squeeze(bsln_cov.trial{m_ix}(1,win_lim(w_ix,1):win_lim(w_ix,2)))';
            hfa_data = squeeze(bsln_hfa.powspctrm(m_ix,ch_ix,1,win_lim(w_ix,1):win_lim(w_ix,2)));
            % If cov and hfa don't have NaNs, compute correlation
            if ~any(isnan(cov_data)) && ~any(isnan(hfa_data))
                % !!! Kuan: can switch this to xcov, add lags
                tmp = corrcoef(hfa_data,cov_data);
                bsln.r2(m_ix,ch_ix,w_ix) = tmp(1,2);
                bsln.good_win(m_ix,w_ix) = 1;
                bsln_vals = [bsln_vals tmp(1,2)];
            end
        end
    end
    % Compute threshold
    bsln_sort = sort(abs(bsln_vals),'descend');
    bsln.thresh(ch_ix) = bsln_sort(round(numel(bsln_sort)*st.alpha));
end
fprintf('\n');

%% Select data in stat window
if strcmp(st.evnt_lab,'B')
%     hfa_stat = bsln;
    error('Why analyze just baseline? cant test bsln vs. bsln...');
elseif strcmp(st.evnt_lab,'M') || strcmp(st.evnt_lab,'BM')
    cfg_trim.latency = [times.bsln_len times.bsln_len+max(times.movie_len)];
    if strcmp(st.evnt_lab,'BM')
        cfg_trim.latency(1) = 0;
    end
    hfa_stat = ft_selectdata(cfg_trim,hfa);
    cov_stat = ft_selectdata(cfg_trim,cov);
    % NaN out non-movie data for shorter movies
    for m_ix = 1:numel(times.movie_len)
        if trial_info.video_id(m_ix)~=8
            time_idx = hfa_stat.time > times.bsln_len+times.movie_len(trial_info.video_id(m_ix));
            hfa_stat.powspctrm(m_ix,:,1,time_idx) = nan([size(hfa_stat.powspctrm,2) sum(time_idx)]);
            cov_stat.trial{m_ix}(1,time_idx) = nan([1 sum(time_idx)]);
        end
    end
elseif strcmp(st.evnt_lab,'R')
    error('need to write code for realigning data to have no nans');
elseif strcmp(st.evnt_lab,'MR')
    cfg_trim.latency = [times.bsln_len hfa.time(end)];
    hfa_stat = ft_selectdata(cfg_trim,hfa);
    cov_stat = ft_selectdata(cfg_trim,cov);
elseif strcmp(st.evnt_lab,'BMR')
    hfa_stat = hfa;
    cov_stat = cov;
elseif strcmp(st.evnt_lab,'BR')
    error('why include non-consecutive events baseline and recovery?');
else
    error(['Unknown st.evnt_lab ' st.evnt_lab]);
end

%% Compute Window Parameters
win_lim    = fn_sliding_window_lim(squeeze(hfa_stat.powspctrm(1,1,1,:)),...
    round(st.win_len*trial_info.sample_rate),...
    round(st.win_step*trial_info.sample_rate));
win_center = round(mean(win_lim,2));

%% Run Statistics
fprintf('===================================================\n');
fprintf('--------------------- Statistics ------------------\n');
fprintf('===================================================\n');

% Create structure for corr in fieldtrip style
corr.label     = hfa_stat.label;
corr.dimord    = 'rpt_chan_time';
corr.time      = hfa_stat.time(win_center);
corr.r2        = nan([size(hfa_stat.powspctrm,1) size(hfa_stat.powspctrm,2) size(win_lim,1)]);
corr.win_lim   = win_lim;
corr.win_lim_s = hfa_stat.time(win_lim);
corr.good_win  = false([numel(trial_info.video_id) size(corr.time,1)]);
corr.pval      = nan(size(corr.r2));
corr.qmask     = nan(size(corr.r2));
corr.mask      = nan(size(corr.r2));
% corr.mask2     = nan(size(corr.r2));

% Compute t-test per movie, channel, and window
for m_ix = 1:numel(trial_info.video_id)
    fprintf('Movie %d/%d Stats...\n\t',m_ix,numel(trial_info.video_id));
    for ch_ix = 1:numel(hfa_stat.label)
        if mod(ch_ix,30)==0; fprintf('\n\t'); end
        fprintf('%d..',ch_ix);
        for w_ix = 1:size(win_lim,1)
            cov_data = squeeze(cov_stat.trial{m_ix}(1,win_lim(w_ix,1):win_lim(w_ix,2)))';
            hfa_data = squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,win_lim(w_ix,1):win_lim(w_ix,2)));
            % Skip windows with bad/no data
            if ~any(isnan(hfa_data)) && ~any(isnan(cov_data))
                tmp = corrcoef(hfa_data,cov_data);
                corr.r2(m_ix,ch_ix,w_ix) = tmp(1,2);
                corr.good_win(m_ix,w_ix) = 1;
            end
            % Compute one-sided test
            bsln_vals = sort(reshape(bsln.r2(:,ch_ix,:),[size(bsln.r2,1)*size(bsln.r2,3) 1]),'descend');
            bsln_vals(isnan(bsln_vals)) = [];
            
            corr.pval(m_ix,ch_ix,w_ix) = 1-(sum(corr.r2(m_ix,ch_ix,w_ix)>bsln_vals)/numel(bsln_vals));
%             corr.mask2(m_ix,ch_ix,w_ix) = corr.r2(m_ix,ch_ix,w_ix) >= bsln.thresh(ch_ix);
            if corr.pval(m_ix,ch_ix,w_ix)<=st.alpha
                corr.mask(m_ix,ch_ix,w_ix) = 1;
            else
                corr.mask(m_ix,ch_ix,w_ix) = 0;
            end
            % Correct for multiple comparisons
            if corr.pval(m_ix,ch_ix,w_ix)<=st.alpha/size(win_lim,1)
                corr.qmask(m_ix,ch_ix,w_ix) = 1;
            else
                corr.qmask(m_ix,ch_ix,w_ix) = 0;
            end
            % Old statistical method: Test against null hypothesis corr = 0
            %   This version is testing HFA values, not r2 (left over from SBJ05ab_HFA_actv)
%             [~, corr.pval(m_ix,ch_ix,w_ix)] = ttest(squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,win_lim(w_ix,1):win_lim(w_ix,2))));
        end
        
        % Old Method: False Discovery Rate adjustment for multiple comparisons
%         good_idx = ~isnan(corr.pval(m_ix,ch_ix,:));
%         [~, ~, ~, corr.qval(m_ix,ch_ix,good_idx)] = fdr_bh(corr.pval(m_ix,ch_ix,good_idx));
%         corr.mask(m_ix,ch_ix,good_idx) = corr.qval(m_ix,ch_ix,good_idx)<=st.alpha;
    end
    fprintf('\n');
end

%% Print results
% Compile positive and negative stats
sig_mat = zeros([numel(corr.label) numel(trial_info.video_id)]);
for m_ix = 1:numel(trial_info.video_id)
    for ch_ix = 1:numel(corr.label)
        % Consolidate to binary sig/non-sig
        if any(squeeze(corr.mask(m_ix,ch_ix,:)))
            sig_mat(ch_ix,m_ix) = sum(squeeze(corr.mask(m_ix,ch_ix,:)));
%             % Flag whether positive or negative
%             sig_idx = squeeze(corr.qval(m_ix,ch_ix,:))<=st.alpha;
%             if any(squeeze(corr.r2(m_ix,ch_ix,sig_idx))>0)
%                 sig_mat(m_ix,ch_ix,2) = 1;
%             end
%             if any(squeeze(corr.r2(m_ix,ch_ix,sig_idx))<0)
%                 sig_mat(m_ix,ch_ix,3) = 1;
%             end
        end
    end
end

% Prep report
sig_report_fname = [hfa_fname(1:end-4) '_' stat_id '_sig_report.txt'];
if exist(sig_report_fname)
    system(['mv ' sig_report_fname ' ' sig_report_fname(1:end-4) '_bck.txt']);
end
sig_report = fopen(sig_report_fname,'a');
result_str = ['%-10s' repmat('%-10i',[1 numel(trial_info.video_id)]) '\n'];

% Print header
fprintf(sig_report,'%s (n = %i)\n',SBJ,numel(corr.label));
fprintf(sig_report,['%-10s' repmat('%-10d',[1 numel(trial_info.video_id)]) '\n'],'label',trial_info.video_id);

% Print summary lines (absolute)
fprintf(sig_report,result_str, 'count', sum(sig_mat>0,1));
fprintf(sig_report,strrep(result_str,'i','.3f'), 'percent',...
    sum(sig_mat>0,1)./numel(corr.label));

% Print Channel Lines
for ch_ix = 1:numel(corr.label)
    % Report on significant electrodes for this SBJ
    fprintf(sig_report,result_str,corr.label{ch_ix},sig_mat(ch_ix,:));
end

fclose(sig_report);

%% Save Results
out_fname = strcat(hfa_fname(1:end-4),'_',stat_id,'.mat');
fprintf('===================================================\n');
fprintf('--- Saving %s ------------------\n',out_fname);
fprintf('===================================================\n');
save(out_fname,'-v7.3','corr','bsln','bsln_cov','cov_stat','st','sig_mat');

end
