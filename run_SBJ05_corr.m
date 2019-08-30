SBJ = 'IR51';
an_id = 'HGm_zscB2t3_sm4_wn250';
stat_id = 'crRat_MR_wl15k_ws1k_lg5k';

stat_id = 'crRsa_MR_wl15k_ws1k_lg5k';

stat_id = 'crEKG_MR_wl15k_ws1k_lg5k';



stat_ids = {'crRat_MR_wl15k_ws1k_lg5k',...
            'crEKG_MR_wl15k_ws1k_lg5k'};




stat_ids = {'crRat_MR_wl5k_ws1k_lg1k',...
            'crRat_MR_wl5k_ws1k_lg3k',...
            'crRat_MR_wl15k_ws2k_lg5k',...
            'crEKG_MR_wl5k_ws1k_lg1k',...
            'crEKG_MR_wl5k_ws1k_lg3k',...
            'crEKG_MR_wl15k_ws2k_lg5k'};

% the following won't run. no enough data for baseline.....       
stat_ids = {'crRat_MR_wl30k_ws3k_lg5k',...
            'crEKG_MR_wl30k_ws3k_lg5k'};


if exist('/home/knight/','dir');root_dir='/home/knight/';ft_dir=[root_dir 'hoycw/Apps/fieldtrip/'];
elseif exist('G:\','dir');root_dir='G:\';ft_dir='C:\Toolbox\fieldtrip\';
else root_dir='/Volumes/hoycw_clust/';ft_dir='/Users/colinhoy/Code/Apps/fieldtrip/';end

%% Set up paths
addpath(fullfile(root_dir,'emodynamics','scripts'));
addpath(fullfile(root_dir,'emodynamics','scripts','utils'));
addpath(ft_dir);
ft_defaults

%%
for st_ix = 1:numel(stat_ids)
    SBJ05ab_HFA_corr(SBJ,an_id,stat_ids{st_ix})
end


% an_id = 'HGm_zscB2t3_sm4_wn250';
% stat_id = 'crRat_MR_wl15k_ws2k_lg5k'; 
