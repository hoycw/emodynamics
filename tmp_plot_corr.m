SBJ = 'IR51';
an_id = 'HGm_zscB30_sm0_wn250';
stat_id = 'crEKG_MR_wl10k_ws1k';
% stat_ids = {'crEKG_MR_wl1k_ws1k','crEKG_MR_wl5k_ws1k','crEKG_MR_wl10k_ws1k','crEKG_MR_wl10k_ws2k','crEKG_MR_wl30k_ws3k',...
%             'crRat_MR_wl1k_ws1k','crRat_MR_wl5k_ws1k','crRat_MR_wl10k_ws1k','crRat_MR_wl10k_ws2k','crRat_MR_wl30k_ws3k'};

%%
SBJ_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_vars', [SBJ '_vars.m'])];
eval(SBJ_vars_cmd);
timing_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts', 'timing_vars.m')];
eval(timing_vars_cmd);

load(strcat(SBJ_vars.dirs.events,SBJ,'_trial_info.mat'));
stat_fname = strcat(SBJ_vars.dirs.proc,SBJ,'_ROI_',an_id,'_',stat_id,'.mat');
load(stat_fname);
hfa_fname = strcat(SBJ_vars.dirs.proc,SBJ,'_ROI_',an_id,'.mat');
load(hfa_fname);

%% Cut trial lim
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

%%
ofc = {'ROF1-2','ROF2-3'};
ins = {'RIN1-2','RIN2-3','LAM5-6','LAM6-7'};
cin = {'RAC1-2','RAC2-3','RAC3-4','RAC4-5','SMA1-2','SMA2-3','SMA3-4','SMA4-5'};
amg = {'LAM1-2','LAM2-3','LAM3-4','LAM4-5'};

ofc_ch_ix = zeros(size(ofc));
for ch_ix = 1:numel(ofc); ofc_ch_ix(ch_ix) = find(strcmp(hfa_stat.label,ofc{ch_ix}));end
ins_ch_ix = [];
for ch_ix = 1:numel(ins); ins_ch_ix(ch_ix) = find(strcmp(hfa_stat.label,ins{ch_ix}));end
cin_ch_ix = [];
for ch_ix = 1:numel(cin); cin_ch_ix(ch_ix) = find(strcmp(hfa_stat.label,cin{ch_ix}));end
amg_ch_ix = [];
for ch_ix = 1:numel(amg); amg_ch_ix(ch_ix) = find(strcmp(hfa_stat.label,amg{ch_ix}));end

%% Plot Example HFA time series
stat_alpha = 0.05;%0.05/size(corr.win_lim,1);
for ch_ix = amg_ch_ix
    figure('Name',['AMG: ' corr.label{ch_ix}]);
    for m_ix = 1:8
        subplot(8,1,m_ix); hold on;
        title(trial_info.video_id(m_ix));
        plot(hfa_stat.time,squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:)),'k');
        %     plot(corr.time,squeeze(corr.avg(m_ix,ch_ix,:)),'b');
        cov_avg = nanmean(cov_stat.trial{m_ix});
        cov_std = nanstd(cov_stat.trial{m_ix});
        plot(cov_stat.time{m_ix},(cov_stat.trial{m_ix}-cov_avg)/cov_std,'r');
        set(gca,'YLim',[-5 10]);
        %     set(gca,'YLim',[min(squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:))) max(squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:)))]);
        yl = get(gca,'YLim');
        % Plot significant epochs
        good_idx = ~isnan(corr.pval(m_ix,ch_ix,:));
        sig_chunks = fn_find_chunks(squeeze(corr.pval(m_ix,ch_ix,:)<=stat_alpha));
        sig_chunks(squeeze(corr.pval(m_ix,ch_ix,sig_chunks(:,1)))>stat_alpha,:) = [];
        for sig_ix = 1:size(sig_chunks,1)
            sig_times = corr.time(sig_chunks(sig_ix,:));
            patch([sig_times(1)-st.win_len/2 sig_times(1)-st.win_len/2 sig_times(2)+st.win_len/2 sig_times(2)+st.win_len/2],...
                [yl(1) yl(2) yl(2) yl(1)], 'k', 'FaceAlpha', 0.3);
        end
        
        %     plot(corr.time(logical(squeeze(corr.mask(m_ix,ch_ix,:)))),...
        %          corr.avg(logical(squeeze(corr.mask(m_ix,ch_ix,:)))),'r');
        %     plot(corr.time(logical(squeeze(~corr.mask(m_ix,ch_ix,:)))),...
        %          corr.avg(logical(squeeze(~corr.mask(m_ix,ch_ix,:)))),'k');
    end
end

%% Plot elec HFA matrix per movie
clim_per = [1 99];
all = corr.r2;
clims = [prctile(all(:),clim_per(1)) prctile(all(:),clim_per(2))];
for m_ix = 1:8
    figure('Name',num2str(trial_info.video_id(m_ix)));
    imagesc(squeeze(corr.r2(m_ix,:,:)));
    set(gca,'YDir','normal');
    colorbar;
    caxis(clims);
    ax = gca;
%     ax.XTick = 100:100:size(corr.time,2);
    ticks = ax.XTick;
    ax.XTickLabel = corr.time(ticks)-times.bsln_len;
    ax.XLabel.String = 'Time (s)';
    ax.YLabel.String = 'Channels';
end


% for m_ix = 1:8
%     % HFA
%     subplot(4,8,fn_rowcol2subplot_ix(4,8,1,m_ix));
%     plot(corr.time,squeeze(corr.avg(m_ix,ch_ix,:)));
%     % pval
%     subplot(4,8,fn_rowcol2subplot_ix(4,8,2,m_ix));
%     plot(corr.time,squeeze(corr.pval(m_ix,ch_ix,:)));
%     % qval
%     subplot(4,8,fn_rowcol2subplot_ix(4,8,3,m_ix));
%     plot(corr.time,squeeze(corr.qval(m_ix,ch_ix,:)));
%     % mask
%     subplot(4,8,fn_rowcol2subplot_ix(4,8,4,m_ix));
%     plot(corr.time,squeeze(corr.mask(m_ix,ch_ix,:)));
% end
