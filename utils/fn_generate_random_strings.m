function [rand_strs] = fn_generate_random_strings(n_strs,symbols,len)
%% Generate cell array of random strings
% INPUTS:
%   n_strs [int] - number of strings to generate
%   symbols [char array] - string containing all the possible symbols in the desired strings
%       [] - empty string will use all lowercase letters, uppercaseletters, and 0-9
%   len [int] - length of the generated strings

if isempty(symbols)
    symbols = ['a':'z' 'A':'Z' '0':'9'];
end

rand_strs = cell([n_strs 1]);
for s = 1:n_strs
    nums = randi(numel(symbols),[1 len]);
    rand_strs{s} = symbols(nums);
end

end