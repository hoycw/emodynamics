function [root_dir, app_dir] = fn_get_root_dir()
%% Check with user/OS/root directory, return relevant locations
if exist('/home/knight/hoycw/','dir')
    root_dir = '/home/knight/hoycw/';
    app_dir   = [root_dir 'Apps/'];
elseif exist('/Volumes/hoycw_clust/','dir')
    root_dir = '/Volumes/hoycw_clust/';
    app_dir   = '/Users/colinhoy/Code/Apps/';
elseif exist('G:\','dir');
    root_dir='G:\';
    app_dir='C:\Toolbox';
else
    error('root directory not found. where are you running this?');
end

end
