function violin_example
% Example of using violinplot

violin_list = elec.label;   % You would have a list of the ones you need to draw, so could be ROI, etc.
violin_colors = RGB_values;
%   maybe consider sorting the electrodes by ROI
corr_values = zeros([n_windows numel(elec.label)]);

% Create and format the plot
fig_name = 'violin example';
figure('Name',fig_name);%,'units','normalized', 'outerposition',[0 0 0.5 0.6],'Visible',fig_vis);

violins = violinplot(corr_values, violin_list, 'ViolinAlpha',0.3);
% violinplot.m properties (see documention in function)
% ShowData: probably 'yes' to see the indivdiual window as scatter plot
%   within the violin, or 'no' if that's too messy
% Width: how wide the violins will be in axis space
%   you could use this width + a little to draw the significance
%   threshold per electrode
% ShowMean: choose to plot the mean instead of the median

% Adjust plot propeties
for violin_ix = 1:numel(violin_list)
    % Need to pick the color of each violin based on ROI or something...
    % Change the color of each violin
    violins(violin_ix).ViolinColor = violin_colors{violin_ix};
    % Change box plot properties
    violins(violin_ix).BoxPlot.FaceColor = violin_colors{violin_ix};
    violins(violin_ix).EdgeColor = violin_colors{violin_ix};
    % Change scatter colors to mark SBJ
    if only_one_data_point
        % violin.MedianColor is plotted over only ScatterPlot point,
        % don't need to color other scatter dots
        violins(violin_ix).MedianColor = ...
            SBJ_colors(plot_onset_sbj{cond_ix}(1,good_roi_map{cond_ix}(violin_ix)),:);
    else
        scat_colors = zeros([numel(violins(violin_ix).ScatterPlot.XData) 3]);
        for dp_ix = 1:numel(data_points)
            scat_colors(dp_ix,:) = RGB;
        end
        violins(violin_ix).ScatterPlot.MarkerFaceColor = 'flat';   % Necessary for CData to work
        violins(violin_ix).ScatterPlot.MarkerEdgeColor = 'flat';   % Necessary for CData to work
        violins(violin_ix).ScatterPlot.CData = scat_colors;
    end
    
    % Plot significance threshold
    line([violin_ix-sig_width violin_ix+sig_width],[thresh(violin_ix) thresh(violin_ix)]);
    
end

% Add label and min RT for perspective
ax = gca;
ax.YLabel.String = y_label;

% If you "mirror" the plot, the violins will go L/R instead of up/down
if mirror_plot
    view([90 -90]);
end

end
