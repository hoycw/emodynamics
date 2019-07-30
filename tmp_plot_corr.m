an_id = 'HGm_zscB30_sm0_wn250';
stat_ids = {'crEKG_MR_wl1k_ws1k','crEKG_MR_wl5k_ws1k','crEKG_MR_wl10k_ws1k','crEKG_MR_wl10k_ws2k','crEKG_MR_wl30k_ws3k',...
            'crRat_MR_wl1k_ws1k','crRat_MR_wl5k_ws1k','crRat_MR_wl10k_ws1k','crRat_MR_wl10k_ws2k','crRat_MR_wl30k_ws3k'};
hfa_fname = strcat(SBJ_vars.dirs.proc,SBJ,'_ROI_',an_id,'.mat');
out_fname = strcat(hfa_fname(1:end-4),'_',stat_id,'.mat');

ch_ix = 28;

% Plot Example HFA time series
stat_alpha = 0.05;%0.05/size(corr.win_lim,1);
figure('Name',corr.label{ch_ix});
for m_ix = 1:8
    subplot(8,1,m_ix); hold on;
    title(trial_info.video_id(m_ix));
    plot(hfa_stat.time,squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:)),'k');
%     plot(corr.time,squeeze(corr.avg(m_ix,ch_ix,:)),'b');
    cov_avg = nanmean(cov_stat.trial{m_ix});
    cov_std = nanstd(cov_stat.trial{m_ix});
    plot(cov_stat.time{m_ix},(cov_stat.trial{m_ix}-cov_avg)/cov_std,'r');
    set(gca,'YLim',[min(squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:))) max(squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:)))]);
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

% Plot elec HFA matrix per movie
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
