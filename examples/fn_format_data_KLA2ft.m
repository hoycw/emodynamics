function [data_ft] = fn_format_data_KLA2ft(data,hdr)
%% Save data in KLA data+header format to Fieldtrip format
%   Create Fieldtrip struct with most basic/necessary comopnents and nothing else
% INPUTS:
%   data [matrix] - channels by time matrix of times series data
%   hdr [struct] - contains data info
%       .sample_rate [int] - sampling rate in Hz
%       .channel_labels [cell array] - strings of the channel names

data_ft.trial   = {data};
data_ft.time    = {[1:size(data,2)]./hdr.sample_rate};
data_ft.fsample = hdr.sample_rate;
data_ft.label   = hdr.channel_labels;

end
