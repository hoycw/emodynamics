function SBJ05ab_HFA_actv(SBJ,an_id,stat_id)
%% function SBJ08ab_HFA_actv(SBJ,an_id,stat_id)
%   Calculates activation relative to baseline (0) via point wise t-test
%   t-test pval converted to qval via FDR
%   Smart windows based on SBJ-specific RTs
%   Writes text report of significance
% INPUTS:
%   SBJ [str] - subject ID
%   an_id [str] - HFA analysis to run stats
%   stat_id [str] - ID of the statistical parameters
% OUTPUTS:
%   actv [struct] - pseudo-FT structure with main outputs
%   st [struct] - stat params loaded via stat_id

if exist('/home/knight/','dir');root_dir='/home/knight/';ft_dir=[root_dir 'hoycw/Apps/fieldtrip/'];
elseif exist('E:\','dir');root_dir='E:\';ft_dir='C:\Toolbox\fieldtrip\';
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

%% Build null distribution
fprintf('===================================================\n');
fprintf('--------------------- Baselines -------------------\n');
fprintf('===================================================\n');
% Extract baseline data
cfg_trim = [];
cfg_trim.trials = 'all';
cfg_trim.latency = [0.0 times.bsln_len];
bsln_hfa = ft_selectdata(cfg_trim,hfa);
% bsln_cat = ft_appenddata([], bsln_hfa);
% bsln_cat = horzcat(bsln_cat.trial{:});
% if any(isnan(bsln_cat(:))); error('why are there nans in baseline?'); end

win_lim    = fn_sliding_window_lim(squeeze(bsln_hfa.powspctrm(1,1,1,:)),...
    round(st.actv.win_len*trial_info.sample_rate),...
    round(st.actv.win_step*trial_info.sample_rate));

% Build distribution of window averages
% Create structure for actv in fieldtrip style
bsln.label     = bsln_hfa.label;
bsln.dimord    = 'rpt_chan_time';
bsln.time      = bsln_hfa.time(round(mean(win_lim,2)));
bsln.avg       = nan([size(bsln_hfa.powspctrm,1) size(bsln_hfa.powspctrm,2) size(win_lim,1)]);
bsln.win_lim   = win_lim;
bsln.win_lim_s = bsln_hfa.time(win_lim);
bsln.thresh    = nan(size(bsln.label));

fprintf('Building baseline distribution...\n\t');
for ch_ix = 1:numel(bsln_hfa.label)
    fprintf('%d..',ch_ix);
    if mod(ch_ix,30)==0; fprintf('\n\t'); end
    for m_ix = 1:numel(trial_info.video_id)
        if any(isnan(squeeze(bsln_hfa.powspctrm(m_ix,ch_ix,1,:))))
            error('why are there nans in baseline?');
        end
        % Average HFA per window
        for w_ix = 1:size(win_lim,1)
            bsln.avg(m_ix,ch_ix,w_ix) = squeeze(mean(bsln_hfa.powspctrm(m_ix,ch_ix,1,win_lim(w_ix,1):win_lim(w_ix,2)),4));
        end
    end
    % Compute threshold
    bsln_vals = sort(abs(reshape(bsln.avg(:,ch_ix,:),[size(bsln.avg,1)*size(bsln.avg,3) 1])),'descend');
    bsln.thresh(ch_ix) = bsln_vals(numel(bsln_vals)*st.alpha);
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
    % NaN out non-movie data for shorter movies
    for v_ix = 1:numel(times.movie_len)
        if trial_info.video_id(v_ix)~=8
            time_idx = hfa_stat.time > times.bsln_len+times.movie_len(trial_info.video_id(v_ix));
            hfa_stat.powspctrm(v_ix,:,1,time_idx) = nan([size(hfa_stat.powspctrm,2) sum(time_idx)]);
        end
    end
elseif strcmp(st.evnt_lab,'R')
    error('need to write code for realigning data to have no nans');
elseif strcmp(st.evnt_lab,'MR')
    cfg_trim.latency = [times.bsln_len hfa.time(end)];
    hfa_stat = ft_selectdata(cfg_trim,hfa);
elseif strcmp(st.evnt_lab,'BMR')
    hfa_stat = hfa;
elseif strcmp(st.evnt_lab,'BR')
    error('why include non-consecutive events baseline and recovery?');
else
    error(['Unknown st.evnt_lab ' st.evnt_lab]);
end

%% Compute Window Parameters
win_lim    = fn_sliding_window_lim(squeeze(hfa_stat.powspctrm(1,1,1,:)),...
    round(st.actv.win_len*trial_info.sample_rate),...
    round(st.actv.win_step*trial_info.sample_rate));
win_center = round(mean(win_lim,2));

%% Run Statistics
fprintf('===================================================\n');
fprintf('--------------------- Statistics ------------------\n');
fprintf('===================================================\n');

% Create structure for actv in fieldtrip style
actv.label     = hfa_stat.label;
actv.dimord    = 'rpt_chan_time';
actv.time      = hfa_stat.time(win_center);
actv.avg       = nan([size(hfa_stat.powspctrm,1) size(hfa_stat.powspctrm,2) size(win_lim,1)]);
actv.win_lim   = win_lim;
actv.win_lim_s = hfa_stat.time(win_lim);
actv.pval      = nan(size(actv.avg));
actv.qmask     = nan(size(actv.avg));
actv.mask      = nan(size(actv.avg));

% Compute t-test per movie, channel, and window
for m_ix = 1:numel(trial_info.video_id)
    fprintf('Movie %d/%d Stats...\n\t',m_ix,numel(trial_info.video_id));
    for ch_ix = 1:numel(hfa_stat.label)
        if mod(ch_ix,30)==0; fprintf('\n\t'); end
        fprintf('%d..',ch_ix);
        for w_ix = 1:size(win_lim,1)
            % Skip windows with bad/no data
            if ~any(isnan(hfa_stat.powspctrm(m_ix,ch_ix,1,win_lim(w_ix,1):win_lim(w_ix,2))))
                actv.avg(m_ix,ch_ix,w_ix) = squeeze(nanmean(hfa_stat.powspctrm(m_ix,ch_ix,1,win_lim(w_ix,1):win_lim(w_ix,2)),4));
                % Compute one-sided test
                bsln_vals = sort(reshape(bsln.avg(:,ch_ix,:),[size(bsln.avg,1)*size(bsln.avg,3) 1]),'descend');
                actv.pval(m_ix,ch_ix,w_ix) = 1-(sum(actv.avg(m_ix,ch_ix,w_ix)>bsln_vals)/numel(bsln_vals));
                if actv.pval(m_ix,ch_ix,w_ix)<=st.alpha
                    actv.mask(m_ix,ch_ix,w_ix) = 1;
                else
                    actv.mask(m_ix,ch_ix,w_ix) = 0;
                end
                % Correct for multiple comparisons
                if actv.pval(m_ix,ch_ix,w_ix)<=st.alpha/size(win_lim,1)
                    actv.qmask(m_ix,ch_ix,w_ix) = 1;
                else
                    actv.qmask(m_ix,ch_ix,w_ix) = 0;
                end
%                 [~, actv.pval(m_ix,ch_ix,w_ix)] = ttest(squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,win_lim(w_ix,1):win_lim(w_ix,2))));
            end
        end
        
        % Adjust for multiple comparisons
%         good_idx = ~isnan(actv.pval(m_ix,ch_ix,:));
%         [~, ~, ~, actv.qval(m_ix,ch_ix,good_idx)] = fdr_bh(actv.pval(m_ix,ch_ix,good_idx));
%         actv.mask(m_ix,ch_ix,good_idx) = actv.qval(m_ix,ch_ix,good_idx)<=st.alpha;
    end
    fprintf('\n');
end

%% Print results
% Compile positive and negative stats
actv_sig_mat = zeros([numel(actv.label) numel(trial_info.video_id)]);
for m_ix = 1:numel(trial_info.video_id)
    for ch_ix = 1:numel(actv.label)
        % Consolidate to binary sig/non-sig
        if any(squeeze(actv.mask(m_ix,ch_ix,:)))
            actv_sig_mat(ch_ix,m_ix) = 1;
%             % Flag whether positive or negative
%             sig_idx = squeeze(actv.qval(m_ix,ch_ix,:))<=st.alpha;
%             if any(squeeze(actv.avg(m_ix,ch_ix,sig_idx))>0)
%                 actv_sig_mat(m_ix,ch_ix,2) = 1;
%             end
%             if any(squeeze(actv.avg(m_ix,ch_ix,sig_idx))<0)
%                 actv_sig_mat(m_ix,ch_ix,3) = 1;
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
fprintf(sig_report,'%s (n = %i)\n',SBJ,numel(actv.label));
fprintf(sig_report,['%-10s' repmat('%-10d',[1 numel(trial_info.video_id)]) '\n'],'label',trial_info.video_id);

% Print summary lines (absolute)
fprintf(sig_report,result_str, 'count', sum(actv_sig_mat,1));
fprintf(sig_report,strrep(result_str,'i','.3f'), 'percent',...
    sum(actv_sig_mat,1)./numel(actv.label));

% Print Channel Lines
for ch_ix = 1:numel(actv.label)
    % Report on significant electrodes for this SBJ
    fprintf(sig_report,result_str,actv.label{ch_ix},actv_sig_mat(ch_ix,:));
end

fclose(sig_report);

%% Save Results
out_fname = strcat(hfa_fname(1:end-4),'_',stat_id,'.mat');
fprintf('===================================================\n');
fprintf('--- Saving %s ------------------\n',out_fname);
fprintf('===================================================\n');
save(out_fname,'-v7.3','actv','bsln','st','actv_sig_mat');

end
