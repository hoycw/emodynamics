





SBJ = 'IR77';
an_id = 'HGm_zscB2t3_sm4_wn250';
stat_id = 'crIbi_MR_wl200_ws200_wl15k_ws1k_lg5k_max';



stat_ids = {'crIbi_MR_wl100_ws100_wl10k_ws1k_lg5k_abs',...
            'crIbi_MR_wl100_ws100_wl10k_ws1k_lg5k_max',...
            'crIbi_MR_wl100_ws100_wl15k_ws1k_lg5k_abs',...
            'crIbi_MR_wl100_ws100_wl15k_ws1k_lg5k_max',...
            'crIbi_MR_wl200_ws200_wl10k_ws1k_lg5k_abs',...
            'crIbi_MR_wl200_ws200_wl10k_ws1k_lg5k_max',...
            'crIbi_MR_wl200_ws200_wl15k_ws1k_lg5k_abs',...
            'crIbi_MR_wl200_ws200_wl15k_ws1k_lg5k_max',...
            'crRat_MR_wl100_ws100_wl10k_ws1k_lg5k_abs',...
            'crRat_MR_wl100_ws100_wl10k_ws1k_lg5k_max',...
            'crRat_MR_wl100_ws100_wl15k_ws1k_lg5k_abs',...
            'crRat_MR_wl100_ws100_wl15k_ws1k_lg5k_max',...
            'crRat_MR_wl200_ws200_wl10k_ws1k_lg5k_abs',...
            'crRat_MR_wl200_ws200_wl10k_ws1k_lg5k_max',...
            'crRat_MR_wl200_ws200_wl15k_ws1k_lg5k_abs',...
            'crRat_MR_wl200_ws200_wl15k_ws1k_lg5k_max'};




stat_id = 'crIbi_MR_wl200_ws200_wl15k_ws1k_lg5k_abs';
        
        
        



SBJ = 'IR77';
an_id = 'HGm_zscB2t3_sm4_wn250';
stat_ids = {'crRat_MR_wl15k_ws1k_lg5k_abs'};









SBJ = 'IR51';
an_id = 'HGm_zscB2t3_sm4_wn250';
stat_id = 'crIbi_MR_wl15k_ws1k_lg5k_max';


stat_id = 'crRsa_MR_wl15k_ws1k_lg5k';



stat_id = 'crIbi_MR_wl15k_ws1k_lg5k';



stat_ids = {'crIbi_MR_wl15k_ws1k_lg5k_max',...
            'crIbi_MR_wl15k_ws1k_lg5k_min',...            
            'crIbi_MR_wl15k_ws1k_lg5k_abs'};



stat_ids = {'crRat_MR_wl15k_ws1k_lg5k_max',...
            'crRat_MR_wl15k_ws1k_lg5k_min',...            
            'crRat_MR_wl15k_ws1k_lg5k_abs'};




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
elseif exist('E:\','dir');root_dir='E:\';ft_dir='C:\Toolbox\fieldtrip\';
else root_dir='/Volumes/hoycw_clust/';ft_dir='/Users/colinhoy/Code/Apps/fieldtrip/';end

%% Set up paths
addpath(fullfile(root_dir,'emodynamics','scripts'));
addpath(fullfile(root_dir,'emodynamics','scripts','utils'));
addpath(ft_dir);
ft_defaults

%%
for st_ix = 1:numel(stat_ids)
    SBJ05ab_HFA_corr_actv(SBJ,an_id,stat_ids{st_ix})
end


% an_id = 'HGm_zscB2t3_sm4_wn250';
% stat_id = 'crRat_MR_wl15k_ws2k_lg5k'; 
