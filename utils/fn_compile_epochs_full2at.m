function [at_epochs] = fn_compile_epochs_full2at(SBJ,proc_id)
%% Wrapper function to convert multiple blocks of preclean (full) epochs to combined preproc (analysis_time)
% INPUTS:
%   SBJ [str] - ID of dataset to process
% OUTPUTS:
%   at_epochs [Nx2 int] - array of (start, stop) indices for all preclean
%       bad_epochs, compiled across runs

% Add paths
[root_dir,~] = fn_get_root_dir();
addpath(fullfile(root_dir,'emodynamics','scripts','utils'));

% Load SBJ and processing vars
eval(['run ' fullfile(root_dir,'emodynamics','scripts','SBJ_vars',[SBJ '_vars.m'])]);
eval(['run ' fullfile(root_dir,'emodynamics','scripts','proc_vars',[proc_id '_vars.m'])]);

% Load bad_epochs from preclean data and adjust to analysis_time
at_epochs = cell([numel(SBJ_vars.block_name) 1]);
block_len = zeros(size(SBJ_vars.block_name));
for b_ix = 1:numel(SBJ_vars.block_name)
    if numel(SBJ_vars.raw_file)>1
        block_suffix = strcat('_',SBJ_vars.block_name{b_ix});
        % Get block length to adjust times to fit combined preproc file
        for ep_ix = 1:numel(SBJ_vars.analysis_time{b_ix})
            block_len(b_ix) = block_len(b_ix)+diff(SBJ_vars.analysis_time{b_ix}{ep_ix});
        end
    else
        block_suffix = SBJ_vars.block_name{b_ix};   % should just be ''
    end
    bad_preclean = load(fullfile(SBJ_vars.dirs.events,[SBJ '_bad_epochs_preclean' block_suffix '.mat']));
    % Adjust to analysis_time
    if ~isempty(bad_preclean.bad_epochs)
        at_epochs{b_ix} = fn_convert_epochs_full2at(bad_preclean.bad_epochs,SBJ_vars.analysis_time{b_ix},...
            fullfile(SBJ_vars.dirs.preproc,[SBJ '_preclean' block_suffix '.mat']),1);
    end
end

% Adjust for block combinations
for b_ix = 2:numel(SBJ_vars.block_name)
    if ~isempty(at_epochs{b_ix})
        if SBJ_vars.low_srate(b_ix)~=0
            at_epochs{b_ix} = at_epochs{b_ix}+block_len(1:b_ix-1)*SBJ_vars.low_srate(b_ix);
        else
            at_epochs{b_ix} = at_epochs{b_ix}+block_len(1:b_ix-1)*proc.resample_freq;
        end
    end
end
at_epochs = vertcat(at_epochs{:});

end
