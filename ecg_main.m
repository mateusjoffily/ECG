function ecg_main(cnffile, subjIdx)
% ECG_MAIN Main program for ECG analysis.
%   ECG_MAIN(cnffile, subjIdx)
%
% Input arguments:
%   cnffile - config full file name 
%   subjIdx - index of the subject to be analysed in the config file
%
% Description:
%   ECG_MAIN is main routine for ecg analyses. It is the one that 
%   should be called from the command line by the user.
%
%   see ECG_GUI for further description.
%--------------------------------------------------------------------------
% Written by Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

% Default GUI and R-wave detection routines
RR_gui_default = 'joffily';    % it can only be 'joffily'. 
                               % ecglabRR.m GUI is not working with 
                               % ecg_main.m for the moment.
RR_detect_default = 'joffily';  % it can be 'joffily' or 'ecglab'

% Load configuration file
%--------------------------------------------------------------------------
if nargin == 0 | isempty(cnffile)
    % Select experiment configuration file to load
    [cnffile, cnfpath] = uigetfile('conf_*.m', 'Select conf_*.m file');
    if cnffile == 0, return, end;
    cnffile = fullfile(cnfpath, cnffile);
end

% Load configuration parameters
clear functions             % clear previous loaded functions
clear global config
run(cnffile);               % load config file information
global config
matfile=config.input.mat;   % ecg raw data file

% Select GUI and R-wave detection routines to be used
%--------------------------------------------------------------------------
if isfield(config, 'ecg')
    if isfield(config.ecg, 'gui')
        RR_gui = config.ecg.gui;
    else
        % Otherwise, use default
        RR_gui = RR_gui_default;     
    end
    
    if isfield(config.ecg, 'RR_detect')
        RR_detect = config.ecg.RR_detect;
    else
        % Otherwise, use default
        RR_detect = RR_detect_default;     
    end
else
    % Otherwise, use default
    RR_gui = RR_gui_default;
    RR_detect = RR_detect_default;
end

% Create subject information cell array (1xn)
%--------------------------------------------------------------------------
for n=1:numel(config.subject)
    subjInfoAll{n}=config.subject(n).info{1};
    for i=2:numel(config.subject(n).info)
        subjInfoAll{n}=strcat(subjInfoAll{n}, ',', config.subject(n).info{i});
    end
end

% Get subject index
if nargin == 2
    % Check if subject index exists
    if subjIdx > numel(config.subject)
        disp([mfilename ': subject index (' num2str(subjIdx) ') not found.']);
        return
    end
else
    if numel(subjInfoAll) > 1
        subjIdx = menu('Select subject:', {subjInfoAll{:} 'Cancel'});
    else
        subjIdx = 1;
    end
    if subjIdx > numel(subjInfoAll)
        return
    end
end

% Set subject information
subjInfo=subjInfoAll{subjIdx};
disp([cnffile ': ' subjInfo]);

% Load ecg data
%--------------------------------------------------------------------------
[matpath,matfile,ext,versn] = fileparts(matfile);
load(fullfile(matpath, matfile));
disp([mfilename ': ' matfile ' / ' subjInfo]);

% If it is the first time ecg is analysed: ecg struct must not exist
if ~exist('ecg', 'var')
    % Initialize ecg recording channel
    ecg(length(subjInfoAll)).chanEcg=[];
    
    % Get ecg default filter params
    [aux filt] = ecg_filt([], fs, 'default'); 
    ecg(length(subjInfoAll)).filt = filt;
end

% Get ecg raw signal
ecgraw = data(config.subject(subjIdx).ecg.ch, :);  
% Remove ecg signal mean
ecgraw = ecgraw-mean(ecgraw);
% Filter ecg signal
ecgfilt = ecg_filt(ecgraw, fs, ecg(subjIdx).filt, false);  
% Normalize ecg signal
ecgfilt = ecgfilt/max(ecgfilt);

% If it is the first time ecg is analysed
if isempty(ecg(subjIdx).chanEcg)    
    ecg(subjIdx).chanEcg=config.subject(subjIdx).ecg.ch;
    ecg(subjIdx).chanMrk=config.subject(subjIdx).mrk.ch;
    ecg(subjIdx).subjinfo=config.subject(subjIdx).info;
    ecg(subjIdx).inv=1;
    
    %ecg(subjIdx).inv=ecg_inv(ecgfilt);   % Check if ECG signal is inverted
    ecgfilt=ecgfilt*ecg(subjIdx).inv;    % Invert ECG signal

    % Automaticaly detect R-waves
    switch RR_detect
        case 'joffily'
            beat_idx = ecg_beat_detect(ecgfilt, fs);
        case 'ecglab'
            beat_idx = ecg_ecglab_detect(ecgfilt, fs, 2);
    end
    
    % reshape beat_idx as 1-by-N vector
    beat_idx = reshape(beat_idx,1,length(beat_idx));
    ecg(subjIdx).beat_idx = beat_idx;
    
else
    ecgfilt=ecgfilt*ecg(subjIdx).inv;      % Invert ecg signal
end

% Open GUI
%--------------------------------------------------------------------------
switch RR_gui
    case 'joffily'
        [ecg(subjIdx).inv,  ecg(subjIdx).beat_idx] = ...
             ecg_gui(ecgfilt, fs, ecg(subjIdx).inv, ecg(subjIdx).beat_idx);
         
%     case 'ecglab'   % not working for the moment
%         ecg(subjIdx).beat_idx = ecg_ecglab(ecgfilt, fs);

    otherwise
        disp([mfilename ': unknown GUI:' RR_gui]);
end

% Save analysed data
%--------------------------------------------------------------------------
save(fullfile(matpath, matfile), 'ecg', '-APPEND');
