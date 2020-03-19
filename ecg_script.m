% Example script for processing and analyising Electrocardiogram data (ECG)
% _________________________________________________________________________

% Written by Mateus Joffily, CNRS

% Matlab data file (.mat) must contain 'data' and 'fs' variables:
% data - m-by-n matrix of ECG and EDA data (m channels by n samples)
% fs   - ECG and EDA sampling rate (Hz)
%
% Two scripts are available for converting data from commercial systems:
% - acq2mat.m (Biopac ACQ format)           (see 'help acq2mat')
% - vhdr2mat.m (BrainAmp VHDR format)       (see 'help vhdr2mat')
%--------------------------------------------------------------------------
% Select *.mat data file (see 'help load')
addpath(fullfile('.','ECG'),'-BEGIN');

% Set up and preliminaries
%==========================================================================
% Select *.mat data file (see 'help load')
[fdata, pdata] = uigetfile('*.mat', 'Select data file');
[pdata,fdata]  = fileparts(fullfile(pdata,fdata));
load(fullfile(pdata, fdata), 'data', 'fs');    % load data

% display feedback message
fprintf(1,'Reading %s: %s\n' , fdata, subjID);

% reshape data matrix
if size(data,1) > size(data,2)
    data = data';
end

% event markers (see https://github.com/mateusjoffily/EDA/eda_conditions)
names     = {};
onsets    = {};
durations = {};

% output file name
fout  = fullfile(pdata, sprintf('%s_%s', fdata, subjID));
fpcr  = [fout '_ecg_pcr.txt'];      % Phasic Cardiac Responses
fhrv  = [fout '_ecg_hrv.txt'];      % HRV analyses
fkrd  = [fout '_ecg_kardia'];   % kardia data

% ECG analysis
%==========================================================================
chECG = 1;                   % ECG channel
ecg   = data(chECG,:);       % ECG data

% Pre-filter ECG signal
%--------------------------------------------------------------------------
ecg   = ecg_filt(ecg, fs, 'default');

% Detect R-waves using ECGLAB
%--------------------------------------------------------------------------
Rn    = ecg_ecglab_detect(ecg, fs, 2);

% Plot ECG signal and RR detection (GUI)
%--------------------------------------------------------------------------
Rn    = ecg_gui(ecg, fs, Rn);        % R-wave event index
Rt    = (Rn-1)/fs;                   % R-wave event time (seconds)

% Phasic Cardiac Responses
%--------------------------------------------------------------------------
[mIBI, IBI, IBIt] = ecg_pcr(Rt, onsets, durations);

% HRV analysis 
%--------------------------------------------------------------------------
[TDS,PSD,power]   = ecg_hrv(Rt, onsets, durations);

% Save ECG data in MATLAB file (see 'help save')
%--------------------------------------------------------------------------
save(fout,'ecg','Rn','Rt','mIBI','IBI','IBIt',...
          'TDS','PSD','power','-APPEND');

% Save ECG results in TEXT file
%--------------------------------------------------------------------------
ecg_save_pcr(fout,[],fpcr);
ecg_save_hrv(fout,[],fhrv);

% Save ECG results in KARDIA format
%--------------------------------------------------------------------------
ecg_save_kardia(fkrd,Rt,names,onsets);


