function ecg_ecglab_export(cnffile, subjIdx)
% ECG_ECGLAB_EXPORT Export ecg data into ecglab format.
%   ECG_ECGLAB_EXPORT(cnffile, subjIdx)
%
% Input arguments:
%   cnffile - config full file name 
%   subjIdx - index of the subject to be analysed in the config file
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
end

% Load configuration parameters
clear functions             % clear previous loaded functions
clear global config
run(cnffile);               % load config file information
global config
matfile=config.input.mat;               % ecg raw data file
ecglabfile=config.ecglab.export.file;   % ecglab filename

% Select subject to be exported
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

% Adjust ecg data
%--------------------------------------------------------------------------
% Get ecg raw signal
ecgraw = data(config.subject(subjIdx).ch.ecg, :);  
% Remove ecg signal mean
ecgraw = ecgraw-mean(ecgraw);
% Filter ecg signal
ecgfilt = ecg_filt(ecgraw, fs, ecg(subjIdx).filt, false);  
% Convert ecg into unsigned 16-bit integer
ecgfilt = uint16((2^8-1)*ecgfilt/max(ecgfilt));

% Export data
%--------------------------------------------------------------------------
[fpath, ffile, fext] =  fileparts(ecglabfile);

fecg = sprintf('%s.ecg', fullfile(fpath, ffile));
fonr = sprintf('%s.onr', fullfile(fpath, ffile));

% ECG sampling rate
fid=fopen(fullfile(fpath,'samplerate_ecg.cfg'),'w');
fprintf(fid,'%0.4f', fs);
fclose(fid);

% ECG signal filename
fid=fopen(fullfile(fpath,'filename.cfg'),'w');
fprintf(fid,'%s', fecg);
fclose(fid);

% ECG plot time window
fid=fopen(fullfile(fpath,'segundos_janela.cfg'),'w');
fprintf(fid,'5');
fclose(fid);

% Export ECG signal 
fid=fopen(fecg,'w');
fwrite(fid,ecgfilt,'uint16');
fclose(fid);

% Export R-wave indexes 
fid=fopen(fonr,'w');
fwrite(fid,ecg(subjIdx).beat_idx,'int32');
fclose(fid);

