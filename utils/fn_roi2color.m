function [RGB] = fn_roi2color(roi)
%% Returns the RGB color code to plot a given ROI
% INPUTS:
%   roi [str or cell] - name (or list of names) of the ROI
%       can be specific or general (e.g., DLPFC or LPFC)
% OUTPUTS:
%   RGB [3 floats] - RGB for this ROI
%
% Values taken from: https://www.w3schools.com/colors/colors_groups.asp

if ischar(roi)
    n_rois = 1;
    roi = {roi};
elseif iscell(roi)
    n_rois = numel(roi);
end

RGB = zeros([n_rois 3]);
for r = 1:n_rois
    switch roi{r}
        % General ROIs
        case 'LPFC'         % Orange
            RGB(r,:) = [253 192 134]./256;
        case 'MPFC'         % Purple
            RGB(r,:) = [190 174 212]./256;
        case 'SM'           % Pink
            RGB(r,:) = [240 2 127]./256;
        case 'INS'          % Green
            RGB(r,:) = [127 201 127]./256;
        case 'OFC'          % Dark Blue
            RGB(r,:) = [56 108 176]./256;
        case 'PAR'          % Brown (was Gold; was Yellow)
            RGB(r,:) = [191 91 23]./256;%[1 0.8 0];%[1 1 0];%[0.2 0.2 0.2];
        case 'TMP'          % Maroon
            RGB(r,:) = [128 0 0]./256;
        case 'MTL'          % Cyan
            RGB(r,:) = [0 1 1];
        case 'OCC'          % Dark Gray
            RGB(r,:) = [0.2 0.2 0.2];
        case 'FWM'          % White
            RGB(r,:) = [1 1 1];
        case 'TWM'          % White
            RGB(r,:) = [1 1 1];
            
            % LPFC Subregions - oranges/reds
        case 'FPC'
            RGB(r,:) = [255 255 178]./256;%[179 0 0]./256;
        case 'dlPFC'
            RGB(r,:) = [254 204 92]./256;%[227 74 51]./256;
        case 'vlPFC'
            RGB(r,:) = [253 141 60]./256;%[252 141 89]./256;
        case 'FO'
            RGB(r,:) = [240 59 32]./256;%[116 196 118]./256;
        case 'PM'
            RGB(r,:) = [189 0 38]./256;%[253 187 132]./256;
            
            % Sensorimotor Subregions - pinks
        case 'M1'
            RGB(r,:) = [250 159 181]./256;%[253 212 158]./256;
        case 'S1'
            RGB(r,:) = [197 27 138]./256;%[140 150 198]./256;
            %        RGB(r,:) = [254 240 217]./256;
            
            % MPFC Subregions - purples
        case 'ACC'
            RGB(r,:) = [191 211 230]./256;
            %RGB(r,:) = [8 81 156]./256;
            %RGB(r,:) = [190 174 212]./256;
        case 'dmPFC'
            RGB(r,:) = [158 188 218]./256;
            %RGB(r,:) = [198 219 239]./256;
            %RGB(r,:) = [190 174 212]./256;
        case 'SMC'
            RGB(r,:) = [140 150 198]./256;
            %RGB(r,:) = [49 130 189]./256check;
            %RGB(r,:) = [190 174 212]./256;
        case 'aMCC'
            RGB(r,:) = [136 86 167]./256;
            %RGB(r,:) = [107 174 214]./256;
            %RGB(r,:) = [190 174 212]./256;
%         case 'SMA'
%             RGB(r,:) = [158 202 225]./256;
%             RGB(r,:) = [190 174 212]./256;
        case 'pMCC'
            RGB(r,:) = [129 15 124]./256;
            %RGB(r,:) = [198 219 239]./256;
            %RGB(r,:) = [190 174 212]./256;
            
            % Insula Subregions - greens
%         case 'vaINS'
%             RGB(r,:) = [0 109 44]./256;
%         case 'daINS'
%             RGB(r,:) = [49 163 84]./256;
%         case 'mINS'
%             RGB(r,:) = [161 217 155]./256;
        case 'aINS'
            RGB(r,:) = [102 194 164]./256;%[199 233 192]./256;
        case 'pINS'
            RGB(r,:) = [0 109 44]./256;%[199 233 192]./256;
            
            % OFC Subregions - blues 
        case 'mOFC'
            RGB(r,:) = [44 127 184]./256;%[56 108 176]./256;
        case 'lOFC'
            RGB(r,:) = [37 52 148]./256;%[56 108 176]./256;
            
            % Parietal - deep reds
        case 'PCC'
            RGB(r,:) = [252 174 145]./256;
            %RGB(r,:) = [239 243 255]./256;
            %RGB(r,:) = [190 174 212]./256;
        case 'PRC'
            RGB(r,:) = [251 106 74]./256;
            %RGB(r,:) = [179 205 227]./256;
        case 'SPL'
            RGB(r,:) = [222 45 38]./256;
            %RGB(r,:) = [136 86 167]./256;
        case 'IPL'
            RGB(r,:) = [165 15 21]./256;
            %RGB(r,:) = [129 15 124]./256;
            
            % Temporal Subregions - yellows/browns
        case 'PT'
            RGB(r,:) = [254 227 145]./256;% were all [1 1 0] or [0.2 0.2 0.2];
        case 'STG'
            RGB(r,:) = [254 196 79]./256;
        case 'STS'
            RGB(r,:) = [254 153 41]./256;
        case 'ITC'
            RGB(r,:) = [217 95 14]./256;
        case 'VTC'
            RGB(r,:) = [153 52 4]./256;

            % MTL (Medial Temporal Lobe) - bright colors (for now?)
        case 'HPC'
            RGB(r,:) = [0 1 1];
        case 'AMG'
            RGB(r,:) = [1 0 1];

            % Yeo Atlases
        case 'Vis'
            RGB(r,:) = [120  18 134]./256;
        case 'SM'
            RGB(r,:) = [70 130 180]./256;
        case 'DAttn'
            RGB(r,:) = [0 118  14]./256;
        case 'VAttn'
            RGB(r,:) = [196  58 250]./256;
        case 'Limb'
            RGB(r,:) = [220 248 164]./256;
        case 'FP'
            RGB(r,:) = [230 148  34]./256;
        case 'Def'
            RGB(r,:) = [205  62  78]./256;

            % Tissue Types
        case 'GM'
            RGB(r,:) = [0.4 0.4 0.4];
        case 'WM'
            RGB(r,:) = [1 1 1];
        case 'CSF'
            RGB(r,:) = [0 0 0];
            
            % Weird Cases
        case ''
            warning('WARNING: Why is the ROI label for this elec empty?');
            RGB(r,:) = [0 0 0];
        case 'OUT'          % Black
            warning('WARNING: Why are you trying to plot data mainly out of the brain???');
            RGB(r,:) = [0 0 0];
    end
end

end
