%% Photodiode Trace Cleaning Parameters: IR39
% Mark trials to ignore e.g., interruptions
ignore_trials = [];

% Set zero/baseline during a block
bsln_val = 400;

% Record epochs (in sec) with fluctuations that should be set to baseline
%	drop before B1, blip at end of B1
bsln_times = {...
    [0.0 15.0],...          % initial offset
    [115.0 120.0],...       % fake trial blip at end of B1
    [440.33 441.36],...     % 
    [599.0 600.0],...
    [611.0 626.0],...
    [644.4 645.5],...
    [647.2 648.25],...
    [666.4 667.5],...
    [1064.0 1080.0005]...% using 1080.0 leaves a tiny blip at the end
    };
% Record epochs (in sec) when baseline has shifted
bsln_shift_times = {...%could be a small shift starting at 245s
    [454.0 600.0],...
    [538.8 611.0],...
    [626.0 664.7],...
    [674.63 1080.0]...
    };
% Record amount of shift in baseline for each epoch 
bsln_shift_val = [1200 700 2600 2600];
if length(bsln_shift_times)~=length(bsln_shift_val)
    error('Number of epochs and values for baseline shift periods do not match.');
end

% Record within trial corrections
stim_times = {...
    [570.0 571.5],...   % T22 in B5
    [594.7 596.25]...   % T31 in B5
    };
stim_yval = [5013 3582]; % inc and neu at those points in time
if length(stim_times)~=length(stim_yval)
    error('Number of epochs and values for stimulus correction periods do not match.');
end

