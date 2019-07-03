function roi_labels = fn_atlas2roi_labels(labels, atlas_id, roi_id)
%% Returns list of atlas ROI labels fitting a general ROI (groi)
% INPUTS:
%   atlas_id [str] - atlas loaded by ft_read_atlas
%   roi_id [str] - {'gROI','ROI'} label of the ROI(s) that you want to translate into atlas roi labels

[root_dir, ~] = fn_get_root_dir();

%% Read in Atlas to ROI mappings
tsv_filename = [root_dir 'emodynamics/data/atlases/atlas_mappings/atlas_ROI_mappings_' atlas_id '.tsv'];
fprintf('\tReading roi csv file: %s\n', tsv_filename);
roi_file = fopen(tsv_filename, 'r');
% roi.csv contents:
%   atlas_label, gROI_label, ROI_label, Notes (not read in)
roi_map = textscan(roi_file, '%s %s %s %s', 'HeaderLines', 1,...
    'Delimiter', '\t', 'MultipleDelimsAsOne', 0);
fclose(roi_file);

%% Map the labels
switch roi_id
%     case {'Yeo7','Yeo17'}
%         map_ix = 2;
    case {'mgROI','gROI','main3','lat','deep'}
        map_ix = 2;
    case {'ROI','thryROI','LPFC','MPFC','OFC','INS','TMP','PAR','MTL'}
        map_ix = 3;
    case {'tissue', 'tissueC'}
        map_ix = 4;
    otherwise
        error(['roi_id unknown: ' roi_id]);
end

n_no_label = 0;
roi_labels = cell(size(labels));
for l = 1:numel(labels)
    roi_labels{l} = roi_map{map_ix}{strcmp(roi_map{1},labels{l})};
    if strcmp(labels{l},'no_label_found')
        warning(['WARNING: no_label_found for label #' num2str(l) '!!!']);
    end
end

end
