function beat_idx = ecg_ecglab_detect(ecg, fs, algorithm)
% ECG_ECGLAB_DETECT Automatic ECG R-wave detection using ECGLAB routines.
%   beat_idx = ECG_ECGLAB_DETECT(ecg, fs)
%
% Input arguments:
%   ecg       - ecg signal 
%   fs        - ecg sampling rate (Hz) 
%   algorithm - ecglab detection algorithm: 
%               '1' = Slow algorithm  or '2' = Fast algorithm
%
% Output arguments:
%   beat_idx  - index of detected R-waves into ecg input vector 
% 
% References:
%   Azevedo de Carvalho et al. (?) Development of a Matlab Software for 
%   Analysis of Heart Rate Variability
% -------------------------------------------------------------------------
% Written by Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

% Define sampling rate as a global variable
global samplerate_ecg
samplerate_ecg = fs;

% Normalize and trucate data
ecg            = double(uint16((2^8-1)*ecg/max(ecg)));

% Detect RR using ecglabRR routine
beat_idx       = ecglabRR_detecta_ondar(ecg, algorithm);

end
