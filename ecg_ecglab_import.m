function ecg_ecglab_import(cnffile, subjIdx)
% ECG_ECGLAB_IMPORT Import R-waves indexes from ecglab into ecg struct.
%   ECG_ECGLAB_IMPORT(cnffile, subjIdx)
%
% Input arguments:
%   cnffile - config full file name 
%   subjIdx - index of the subject in the config file to be imported
%
% References:
%   Azevedo de Carvalho et al. (?) Development of a Matlab Software for 
%   Analysis of Heart Rate Variability
% -------------------------------------------------------------------------
% Written by Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

% Initialize ecg structure to avoid conflict with matlab signal processing
% toolbox ecg function
ecg =[];

% Load configuration file
%--------------------------------------------------------------------------
if nargin == 0 | isempty(cnffile)
    % Select experiment configuration file to load
    [cnffile, cnfpath] = uigetfile('conf_*.m', 'Select conf_*.m file');
    cnffile = fullfile(cnfpath, cnffile);
    
    msg = sprintf('All previously detected beats will be replaced!\nAre you sure to continue?');
    bn=questdlg(msg, 'Confirmation', 'Yes','No','No');
    if strcmp(bn, 'No'), return, end;
end

% Load configuration parameters
clear functions             % clear previous loaded functions
clear global config
run(cnffile);               % load config file information
global config
matfile=config.input.mat;               % ecg raw data file
ecglabfile=config.ecglab.import.file;   % ecglab filename

% Select subject to be imported
%--------------------------------------------------------------------------

% Create selectedData cell array (1xn)
for n=1:numel(config.subject)
    selectedData{n}=config.subject(n).info{1};
    for i=2:numel(config.subject(n).info)
        selectedData{n}=strcat(selectedData{n}, ',', config.subject(n).info{i});
    end
end

% Get subject index
if nargin == 3
    % Check if subject index exists
    if subjIdx > numel(config.subject)
        disp([mfilename ': subject index (' num2str(subjIdx) ') not found.']);
        return
    end
else
    subjIdx = menu('Select subject:', {selectedData{:} 'Cancel'});
    if subjIdx > numel(selectedData)
        return
    end
end

% Set subjinfo
subjinfo=selectedData{subjIdx};

% Load ecg data
%--------------------------------------------------------------------------
[matpath,matfile,ext,versn] = fileparts(matfile);
load(fullfile(matpath, matfile));
disp([mfilename ': ' matfile ' / ' subjinfo]);

% Check if ecg struct exists
%--------------------------------------------------------------------------
if ~exist('ecg', 'var') | isempty(ecg(subjIdx).chanEcg)
    disp([mfilename ': ecg struct is empty!']);
    return;
end

% Import R-wave indexes only
%--------------------------------------------------------------------------
[fpath, ffile, fext] =  fileparts(ecglabfile);

fonr = sprintf('%s.onr', fullfile(fpath, ffile));
   
% Open ecglab R-wave file 
fid = fopen(fonr,'r');
ecg_ondar = fread(fid,'int32');
fclose(fid);

ecg(subjIdx).beat_idx = ecg_ondar;

% Save imported data
%--------------------------------------------------------------------------
save(fullfile(matpath, matfile), 'ecg', '-APPEND');
