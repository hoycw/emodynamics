SBJ = 'IR51';
an_id = 'HGm_zscB30_sm0_wn250';
stat_ids = {...'crEKG_MR_wl1k_ws1k','crEKG_MR_wl5k_ws1k','crEKG_MR_wl10k_ws1k','crEKG_MR_wl10k_ws2k',...'crEKG_MR_wl30k_ws3k',...
            'crRat_MR_wl1k_ws1k','crRat_MR_wl5k_ws1k','crRat_MR_wl10k_ws1k','crRat_MR_wl10k_ws2k'};%,'crRat_MR_wl30k_ws3k'};

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