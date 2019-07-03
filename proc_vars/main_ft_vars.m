%% Pipeline Processing Variables: "main_ft"

% Data Preprocessing
proc.plot_psd      = '1by1';         % type of plot for channel PSDs
proc.resample_yn   = 'yes';
proc.resample_freq = 1000;
proc.demean_yn     = 'yes';
proc.hp_yn         = 'yes';
proc.hp_freq       = 0.5;            % [] skips this step
proc.hp_order      = 4;              % Leaving blank causes instability error, 1 or 2 works
proc.lp_yn         = 'yes';
proc.lp_freq       = 300;            % [] skips this step
proc.notch_type    = 'bandstop';     % method for nothc filtering out line noise

% Trial Cut Parameteres
proc.evnt_lab      = 'S';         % 'S'/'R': lock trial to these event

% Varaince-Based Trial Rejection Parameters
proc.var_std_warning_thresh = 3;
