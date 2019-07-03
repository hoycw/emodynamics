function [RGB] = fn_tissue2color(elec)
%% Convert tissue probabilities into colorscale for plotting
% INPUTS:
%   elec [str] - should have .tissue_prob and .tissue_labels 

% Define bad tissue types and threshold to color them
bad_ix = [find(strcmp(elec.tissue_labels,'CSF')),
          find(strcmp(elec.tissue_labels,'OUT'))];
bad_thresh = 0.6;

RGB = zeros([numel(elec.label) 3]);
for e = 1:numel(elec.label)
    if any(elec.tissue_prob(e,bad_ix)>bad_thresh)   % color red if bad
        RGB(e,:) = [1 0 0];
    else                                    % otherwise color as inverse of GM probability
        RGB(e,:) = 1-elec.tissue_prob(e,1);
    end
end

end
