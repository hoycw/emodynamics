function fn_view_correlations(data,clim)
%% Check correlations across channels to find CAR inclusion
% load(import_data);
corr_mat = corrcoef(data.trial{1}');
uppertri = triu(ones(size(corr_mat)),1);
r_avg = mean(corr_mat(uppertri==1));
r_std = std(corr_mat(uppertri==1));

corr_mat_nan = corr_mat;
corr_mat_nan(eye(size(corr_mat))==1) = NaN;
chan_corr = nanmean(corr_mat_nan,1);

% plot the correlation matrix
figure;
if isempty(clim)
    imagesc(corr_mat_nan);
else
    imagesc(corr_mat_nan,clim);
end
colorbar;

% Plot the correlations by row, with mean and std
figure; hold on;
plot(chan_corr,'k');
plot(xlim,[r_avg r_avg],'b');
plot(xlim,[r_avg-r_std r_avg-r_std],'r--');
plot(xlim,[r_avg-r_std/2 r_avg-r_std/2],'r:');
legend('chan_corr','avg corr','avg-std corr','avg-std/2 corr');



% Print channels that are below threshold
fprintf('WARNING: %i / %i channels below correlation threshold:\n',...
    sum(chan_corr<r_avg-r_std/2),numel(data.label));
disp(data.label(chan_corr<r_avg-r_std/2));

end
