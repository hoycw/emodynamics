SBJ = 'IR51';
an_id = 'HGm_zscB30_sm0_wn250';
stat_ids = {'crEKG_MR_wl1k_ws1k','crEKG_MR_wl5k_ws1k','crEKG_MR_wl10k_ws1k','crEKG_MR_wl10k_ws2k','crEKG_MR_wl30k_ws3k',...
            'crRat_MR_wl1k_ws1k','crRat_MR_wl5k_ws1k','crRat_MR_wl10k_ws1k','crRat_MR_wl10k_ws2k','crRat_MR_wl30k_ws3k'};
hfa_fname = strcat(SBJ_vars.dirs.proc,SBJ,'_ROI_',an_id,'.mat');
out_fname = strcat(hfa_fname(1:end-4),'_',stat_id,'.mat');


ch_ix = 28;

% Plot Example HFA time series
stat_alpha = 0.05;%0.05/size(actv.win_lim,1);
figure('Name',actv.label{ch_ix});
for m_ix = 1:8
    subplot(8,1,m_ix); hold on;
    title(trial_info.video_id(m_ix));
    plot(hfa_stat.time,squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:)),'k');
    plot(actv.time,squeeze(actv.avg(m_ix,ch_ix,:)),'r');
    set(gca,'YLim',[min(squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:))) max(squeeze(hfa_stat.powspctrm(m_ix,ch_ix,1,:)))]);
    yl = get(gca,'YLim');
    % Plot significant epochs
    good_idx = ~isnan(actv.pval(m_ix,ch_ix,:));
    sig_chunks = fn_find_chunks(squeeze(actv.pval(m_ix,ch_ix,:)<=stat_alpha));
    sig_chunks(squeeze(actv.pval(m_ix,ch_ix,sig_chunks(:,1)))>stat_alpha,:) = [];
    for sig_ix = 1:size(sig_chunks,1)
        sig_times = actv.time(sig_chunks(sig_ix,:));
        patch([sig_times(1)-st.win_len/2 sig_times(1)-st.win_len/2 sig_times(2)+st.win_len/2 sig_times(2)+st.win_len/2],...
            [yl(1) yl(2) yl(2) yl(1)], 'k', 'FaceAlpha', 0.3);
    end
    
    %     plot(actv.time(logical(squeeze(actv.mask(m_ix,ch_ix,:)))),...
    %          actv.avg(logical(squeeze(actv.mask(m_ix,ch_ix,:)))),'r');
    %     plot(actv.time(logical(squeeze(~actv.mask(m_ix,ch_ix,:)))),...
    %          actv.avg(logical(squeeze(~actv.mask(m_ix,ch_ix,:)))),'k');
end

% Plot elec HFA matrix per movie
clim_per = [1 99];
all = actv.avg;
clims = [prctile(all(:),clim_per(1)) prctile(all(:),clim_per(2))];
for m_ix = 1:8
    figure('Name',num2str(trial_info.video_id(m_ix)));
    imagesc(squeeze(actv.avg(m_ix,:,:)));
    set(gca,'YDir','normal');
    colorbar;
    caxis(clims);
    ax = gca;
%     ax.XTick = 100:100:size(actv.time,2);
    ticks = ax.XTick;
    ax.XTickLabel = actv.time(ticks)-times.bsln_len;
    ax.XLabel.String = 'Time (s)';
    ax.YLabel.String = 'Channels';
end