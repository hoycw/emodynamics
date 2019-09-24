function [root_dir, app_dir] = fn_get_root_dir()
%% Check with user/OS/root directory, return relevant locations
if exist('/home/knight/','dir')
    root_dir = '/home/knight/';
    app_dir   = '/home/knight/hoycw/Apps/';
elseif exist('/Volumes/hoycw_clust/','dir')
    root_dir = '/Volumes/hoycw_clust/';
    app_dir   = '/Users/colinhoy/Code/Apps/';
elseif exist('E:\','dir');
    root_dir='E:\';
    app_dir='E:\Toolbox';    
else
    error('root directory not found. where are you running this?');
end

end
