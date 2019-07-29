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

%% Extract baseline data
cfg_trim = [];
cfg_trim.trials = 'all';
cfg_trim.latency = [0.0 times.bsln_len];
bsln = ft_selectdata(cfg_trim,data);

%% Select data in stat window
cfg_trim = [0 0];
if ~isempty(strfind(st.evnt_lab,'B'))      % Baseline
    cfg_trim.latency(1) = min([cfg_trim.latency(1) 0]);
    cfg_trim.latency(2) = max([cfg_trim.latency(2) times.bsln_len]);
elseif ~isempty(strfind(st.evnt_lab,'M'))  % Movies
    cfg_trim.latency(1) = min([cfg_trim.latency(1) 0]);
    cfg_trim.latency(2) = max([cfg_trim.latency(2) times.bsln_len]);
elseif ~isempty(strfind(st.evnt_lab,'R'))  % Recovery
    cfg_trim.latency(1) = min([cfg_trim.latency(1) 0]);
    cfg_trim.latency(2) = max([cfg_trim.latency(2) times.bsln_len]);
end
cfg_trim.latency = st.stat_lim;
hfa_stat = ft_selectdata(cfg_trim,hfa);

%% Run Statistics
fprintf('===================================================\n');
fprintf('--------------------- Statistics ------------------\n');
fprintf('===================================================\n');

% Create structure for actv in fieldtrip style
actv.cond    = st.groups;
actv.time    = hfa_stat.time;
actv.label   = hfa_stat.label;
actv.dimord  = 'chan_time';
actv.avg     = squeeze(nanmean(hfa_stat.powspctrm(:,:,1,:),1));
actv.pval    = zeros(size(actv.avg));
actv.qval    = zeros(size(actv.avg));
actv.mask    = zeros(size(actv.avg));

% Compute statistics
for ch_ix = 1:numel(hfa_stat.label)
    % Compute t-test per time point
    for time_ix = 1:numel(hfa_stat.time)
        [~, actv.pval(ch_ix,time_ix)] = ttest(squeeze(hfa_stat.powspctrm(:,ch_ix,1,time_ix)));
    end
    
    % Find epochs with significant task activations
%     [~, qvals] = mafdr(pvals); % Errors on some random ch (e.g., ROF8-9
%     in IR32), so I'm trying the below function
%     [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pvals,q,method,report);
    [~, ~, ~, actv.qval(ch_ix,:)] = fdr_bh(actv.pval(ch_ix,:));
    actv.mask(ch_ix,:) = actv.qval(ch_ix,:)<=st.alpha;
    
    % Remove epochs less than actv_win
    actv_chunks = fn_find_chunks(actv.mask(ch_ix,:));
    actv_chunks(actv.mask(ch_ix,actv_chunks(:,1))==0,:) = [];
    actv_chunk_sz = diff(actv_chunks,1,2)+1;
    bad_chunks = actv_chunks(actv_chunk_sz < trial_info.sample_rate*st.actv_win,:);
    for chunk_ix = 1:size(bad_chunks,1)
        actv.mask(ch_ix,bad_chunks(chunk_ix,1):bad_chunks(chunk_ix,2)) = 0;
    end
end

%% Print results
% Compile positive and negative stats
cond_lab = {'actv' 'pos' 'neg'};
sig_mat = zeros([numel(actv.label) numel(cond_lab)]);
for ch_ix = 1:numel(actv.label)
    % Consolidate to binary sig/non-sig
    if any(squeeze(actv.qval(ch_ix,:))<st.alpha)
        sig_mat(ch_ix,1) = 1;
        % Flag whether positive or negative
        sig_idx = squeeze(actv.qval(ch_ix,:))<st.alpha;
        if any(squeeze(actv.avg(ch_ix,sig_idx))>0)
            sig_mat(ch_ix,2) = 1;
        end
        if any(squeeze(actv.avg(ch_ix,sig_idx))<0)
            sig_mat(ch_ix,3) = 1;
        end
    end
end

% Prep report
sig_report_fname = [hfa_fname(1:end-4) '_' stat_id '_sig_report.txt'];
if exist(sig_report_fname)
    system(['mv ' sig_report_fname ' ' sig_report_fname(1:end-4) '_bck.txt']);
end
sig_report = fopen(sig_report_fname,'a');
result_str = ['%-10s' repmat('%-10i',[1 numel(cond_lab)]) '\n'];

% Print header
fprintf(sig_report,'%s (n = %i)\n',SBJ,numel(actv.label));
fprintf(sig_report,[repmat('%-10s',[1 1+numel(cond_lab)]) '\n'],'label',cond_lab{:});

% Print summary lines (absolute)
fprintf(sig_report,result_str, 'count', sum(sig_mat,1));
fprintf(sig_report,strrep(result_str,'i','.3f'), 'percent',...
    sum(sig_mat,1)./numel(actv.label));

% Print Channel Lines
for ch_ix = 1:numel(actv.label)
    % Report on significant electrodes for this SBJ
    fprintf(sig_report,result_str,actv.label{ch_ix},sig_mat(ch_ix,:));
end

fclose(sig_report);

%% Save Results
out_fname = strcat(hfa_fname(1:end-4),'_',stat_id,'.mat');
fprintf('===================================================\n');
fprintf('--- Saving %s ------------------\n',out_fname);
fprintf('===================================================\n');
save(out_fname,'-v7.3','actv','st');

end
