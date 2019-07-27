function bslnd_tfr = fn_bsln_ft_tfr(tfr, bsln_lim, bsln_type, n_boots)
%% Baseline correct one TFR based on bsln_lim epoch, both from ft_freqanalysis
% INPUTS:
%   tfr [ft dataset] - full output of ft_freqanalysis
%   bsln_lim [int, int]- 2 int array of TIME indices for [start, end] of baseline period
%   bsln_type [str]   - type of baseline to implement
%       'zboot'  = pool all baselines, bootstrap means+SDs, z-score all
%           trials to the mean+SD of the bootstrapped distribution
%       'zscore' = subtract mean and divide by SD
%       'demean' = subtract mean
%       'my_relchange' = subtract mean, divide by mean (results in % change)
% OUTPUTS:
%   bslnd_tfr [ft dataset] - same tfr but baseline corrected
% [~, app_dir] = fn_get_root_dir();
% addpath([app_dir 'fieldtrip/']);
% ft_defaults
rng('shuffle'); % seed randi with time

if ~strcmp(tfr.dimord,'rpt_chan_freq_time')
    error('Check dimord to be sure trial dimension is first!')
end

% Select baseline data
cfgs = [];
cfgs.latency = bsln_lim;
bsln_tfr = ft_selectdata(cfgs,tfr);

% Create bootstrap distribution if necessary
if strcmp(bsln_type,'zboot')
    fprintf('\tComputing permutations: # boots / (%i) = ',n_boots);
    sample_means = NaN([numel(tfr.label) size(tfr.powspctrm,3) n_boots]);
    sample_stds  = NaN([numel(tfr.label) size(tfr.powspctrm,3) n_boots]);
    for boot_ix = 1:n_boots
        if mod(boot_ix,50)==0
            fprintf('%i..',boot_ix);
        end
        % Select a random set of trials (sampling WITH REPLACEMENT!)
        shuffle_ix = randi(size(tfr.powspctrm,1),[1 size(tfr.powspctrm,1)]);
        % Compute stats
        sample_means(:,:,boot_ix) = nanmean(nanmean(bsln_tfr.powspctrm(shuffle_ix,:,:,:),4),1);
        sample_stds(:,:,boot_ix)  = nanstd(nanstd(bsln_tfr.powspctrm(shuffle_ix,:,:,:),[],4),[],1);
    end
    fprintf('\n');
end

bslnd_tfr = tfr;
for ch = 1:size(tfr.powspctrm,2)
%     fprintf('\t%s (%i / %i)\n',tfr.label{ch},ch,numel(tfr.label));
    for f = 1:size(tfr.powspctrm,3)
        % Perform Baseline Correction
        for t = 1:size(tfr.powspctrm,1)
            trials  = tfr.powspctrm(t,ch,f,:);
            trl_bsln    = bsln_tfr.powspctrm(t,ch,f,:);
            switch bsln_type
                case 'zboot'
                    bslnd_tfr.powspctrm(t,ch,f,:) = (trials-mean(sample_means(ch,f,:)))/mean(sample_stds(ch,f,:));                    
                case 'zscore'
                    bslnd_tfr.powspctrm(t,ch,f,:) = (trials-nanmean(trl_bsln))/nanstd(trl_bsln);
                case 'demean'
                    bslnd_tfr.powspctrm(t,ch,f,:) = trials-nanmean(trl_bsln);
                case 'my_relchange'
                    bslnd_tfr.powspctrm(t,ch,f,:) = (trials-nanmean(trl_bsln))/nanmean(trl_bsln);
                otherwise
                    error(['Unknown bsln_type: ' bsln_type])
            end
        end
    end
end

end
