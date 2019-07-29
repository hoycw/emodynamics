function SBJ04_photo_parse(SBJ, proc_id, block, plot_it, save_it)
% INPUTS:
%   SBJ [str] - uniquely identifies the subject, e.g., 'IR54'
%   block [int] - index of which block of data should be analyzed
%   plot_it [0/1] - optional. plot_it = 1 to plot detected events
%   save_it [0/1] - whether to save output

%% File paths
if exist('/home/knight/','dir');root_dir='/home/knight/';ft_dir=[root_dir 'hoycw/Apps/fieldtrip/'];
elseif exist('G:\','dir');root_dir='G:\';ft_dir='C:\Toolbox\fieldtrip\';
else root_dir='/Volumes/hoycw_clust/';ft_dir='/Users/colinhoy/Code/Apps/fieldtrip/';end
addpath(fullfile(root_dir,'emodynamics','scripts','utils'));

% Set up SBJ and directory info
SBJ_vars_cmd = ['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_vars', [SBJ '_vars.m'])];
eval(SBJ_vars_cmd);
if numel(SBJ_vars.raw_file)>1
    block_suffix = strcat('_',SBJ_vars.block_name{block});
else
    block_suffix = SBJ_vars.block_name{block};   % should just be ''
end

evnt_filename = [SBJ_vars.dirs.preproc SBJ '_evnt_clean',block_suffix,'.mat'];
output_filename = [SBJ_vars.dirs.events SBJ '_trial_info',block_suffix,'.mat'];

%% Get data sampling rate
if SBJ_vars.low_srate(block)
    data_fsample = SBJ_vars.low_srate(block);
else
    eval(['run ' fullfile(root_dir,'emodynamics','scripts','proc_vars',[proc_id '_vars.m'])]);
    data_fsample = proc.resample_freq;
end

%% Determine event onset sample points
% Load input data
fprintf('Loading %s\n',evnt_filename);
load(evnt_filename);
data_photo = evnt.trial{1}(photo_ix,:);
data_photo_orig = data_photo;

% Bring data down to zero
data_photo = data_photo - min(data_photo);

% Read photodiode data
fprintf('\tReading photodiode data\n');
min_event_length = 5 * evnt.fsample;    %trial must be at least 0.8 sec (actually ~1.5s?)
[evnt_on, evnt_off, data_shades] = read_photodiode(data_photo, min_event_length, 2);  %2 different shades (bsln, evnt)
if save_it
    fig_fname = [SBJ_vars.dirs.events SBJ '_photo_segmentation.fig'];
    saveas(gcf,fig_fname);
end
clear data_photo;

% Diff to get edges which correspond to onsets and offsets
data_shades = [diff(data_shades) 0]; % Add a point because diff removes one
photo_onsets = find(data_shades>0)'; % 1 to 2 is video onset. Transpose to make column vector
photo_offsets = find(data_shades<0)'; % 1 to 2 is video onset. Transpose to make column vector
fprintf('\t\tFound %d trials in photodiode channel\n', length(photo_onsets));

% Plot photodiode event durations to check consistency
if plot_it
    figure;
    dur = evnt_off{2}-evnt_on{2};
    plot(dur);
    ylabel('Photodiode Durations');
    xlabel('Trial');
    title(['[min, mean, max] = [' num2str(min(dur)) ',' num2str(mean(dur)) ',' num2str(max(dur)) ']']);
    if any(dur<60)
        warning(['WARNING!!! ' num2str(sum(dur<60)) ' photodiode events are less than 60 ms!']);
        disp(dur(dur<60));
    end
    if save_it
        fig_fname = [SBJ_vars.dirs.events SBJ '_photo_durations.png'];
        saveas(gcf,fig_fname);
    end
end

%% Read in log file
trial_info.video_id = SBJ_vars.video_id;
% Open file
% fprintf('\tReading log file\n');
% log_h = fopen([SBJ_vars.dirs.events SBJ '_eventInfo' block_suffix '.txt'], 'r');

% Parse log file
% file_contents = textscan(log_h, '%f %d', 'Delimiter', ',', 'MultipleDelimsAsOne', 1);
% trial_info.video_id = file_contents{2}; <<<<<< Will update this one for films played
% trial_info.log_onset_time = file_contents{1};
% fprintf('\t\tFound %d trials in log file\n', length(trial_info.video_id));

% Remove trials to ignore
trial_info.video_id(ignore_trials) = [];
% trial_info.log_onset_time(ignore_trials) = [];
trial_info.ignore_trials = ignore_trials;
fprintf('\t\tIgnoring %d trials\n', length(ignore_trials));

% If log and photodiode have different n_trials, plot and error out
if (length(trial_info.video_id) ~= length(photo_onsets))
    % Plot photodiode data
    plot_photo = data_photo_orig - min(data_photo_orig);
    plot_photo = plot_photo / (max(plot_photo)-min(plot_photo));
    plot_photo = plot_photo + 0.25;
    figure; hold on;
    plot(plot_photo, 'k');
    % Plot video onsets
    for video_n = 1:length(photo_onsets)
        plot([photo_onsets(video_n) photo_onsets(video_n)],[1.30 1.40],'r','LineWidth',2);
        plot([photo_onsets(video_n) photo_onsets(video_n)],[-0.35 0.35],'r','LineWidth',2);
    end
    error('\nNumber of trials in log is different from number of trials found in event channel\n\n');
end

% Convert to data samples and add to trial_info
trial_info.trial_onsets  = (photo_onsets/evnt.fsample)*data_fsample;
trial_info.trial_offsets = (photo_offsets/evnt.fsample)*data_fsample;

%% Add film details
% Film Number:
% 1. Disgust: Roaches
% 2. Happy: Modern Times
% 3. Fear: Witness
% 4. Neutral: Sticks
% 5. Fear: Cujo
% 6. Disgust: Poop Lady
% 7. Neutral: ColorBars
% 8. Happy: Lucy 
% Note that order of these films diffed between subjects

baseline_len = 32;                          % time in seconds for fixation
film_len     = [90.133 90.067 90.133 90.067 90.133 90.033 90.133 94.7]; % time for films in seconds (Lucy is +5s)
recovery_len = 32.033;                          % time of recovery film in seconds
trial_info.video_onsets    = zeros(size(trial_info.trial_onsets));
trial_info.recovery_onsets = zeros(size(trial_info.trial_onsets));
for v_ix = 1:numel(trial_info.video_onsets)
    trial_info.video_onsets(v_ix) = trial_info.trial_onsets(v_ix) + baseline_len*data_fsample;
    trial_info.recovery_onsets(v_ix) = trial_info.video_onsets(v_ix) + film_len(trial_info.video_id(v_ix))*data_fsample;
    
    % Print difference between photodiode and estimated time
    photo_len = trial_info.trial_offsets(v_ix)-trial_info.trial_onsets(v_ix);
    estimate = (baseline_len+film_len(trial_info.video_id(v_ix))+recovery_len)*data_fsample;
    if abs(photo_len-estimate) > data_fsample % Warning in red if > 1s off
        fprintf(2,'\tVideo %d: photo_len - (baseline+film+recovery) = %.3f s\n',v_ix,...
            (photo_len - estimate)/data_fsample);
    else
        fprintf('\tVideo %d: photo_len - (baseline+film+recovery) = %.3f s\n',v_ix,...
            (photo_len - estimate)/data_fsample);
    end
end

%% Save results
if save_it
    save(output_filename,'-v7.3', 'trial_info');
end

%% Plot results
if plot_it
    % Plot event onsets
    figure;%('Position', [100 100 1200 800]);
    hold on;
    
    % Plot photodiode data
    plot_photo = data_photo_orig - min(data_photo_orig);
    plot_photo = plot_photo / (max(plot_photo)-min(plot_photo));
    plot_photo = plot_photo + 0.25;
    plot(evnt.time{1}, plot_photo, 'Color', [0.5 0.8 0.8]);
    plot([0 evnt.time{1}(end)],[0.25 0.25],'k');
    
    % Plot video onsets
    for video_n = 1:length(trial_info.video_onsets)
        % Baseline onsets
        plot([trial_info.trial_onsets(video_n) trial_info.trial_onsets(video_n)]/data_fsample,[1.30 1.40],'b','LineWidth',2);
        plot([trial_info.trial_onsets(video_n) trial_info.trial_onsets(video_n)]/data_fsample,[-0.35 0.35],'b','LineWidth',2);
        % Video onsets
        plot([trial_info.video_onsets(video_n) trial_info.video_onsets(video_n)]/data_fsample,[1.30 1.40],'c','LineWidth',2);
        plot([trial_info.video_onsets(video_n) trial_info.video_onsets(video_n)]/data_fsample,[-0.35 0.35],'c','LineWidth',2);
        % Recovery onsets
        plot([trial_info.recovery_onsets(video_n) trial_info.recovery_onsets(video_n)]/data_fsample,[1.30 1.40],'g','LineWidth',2);
        plot([trial_info.recovery_onsets(video_n) trial_info.recovery_onsets(video_n)]/data_fsample,[-0.35 0.35],'g','LineWidth',2);
        % Trial offsets
        plot([trial_info.trial_offsets(video_n) trial_info.trial_offsets(video_n)]/data_fsample,[1.30 1.40],'r','LineWidth',2);
        plot([trial_info.trial_offsets(video_n) trial_info.trial_offsets(video_n)]/data_fsample,[-0.35 0.35],'r','LineWidth',2);        
        
    end
    
    if save_it
        fig_fname = [SBJ_vars.dirs.events SBJ '_events.fig'];
        saveas(gcf,fig_fname);
    end
end

end

