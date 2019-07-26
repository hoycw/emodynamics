%% Pipeline Processing Variables: "main_ft"

% SBJ00_PreCleaning
proc.plot_psd      = '1by1';         % type of plot for channel PSDs

% SBJ01_Import
proc.resample_yn   = 'yes';
proc.resample_freq = 1000;

% SBJ02_Preprocessing
proc.demean_yn     = 'yes';
proc.hp_yn         = 'yes';
proc.hp_freq       = 0.01;           % [] skips this step
proc.hp_order      = 2;              % Leaving blank causes instability error, 1 or 2 works
proc.lp_yn         = 'yes';
proc.lp_freq       = 300;            % [] skips this step

