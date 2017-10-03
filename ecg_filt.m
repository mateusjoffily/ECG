function [ecgout,filtout] = ecg_filt(ecgin, fs, filtin, plot_ok)
% ECG_FILT ECG filters
%   ecgout = ECG_FILT(ecgin, fs)
%
% Input arguments:
%    ecgin - ecg raw data
%    fs    - samplig frequency (Hz)
%
% Optional input arguments:
%    filtin - (1) 'default' - use defalut ecg filter params
%             (2) structure containing pre-defined filter parameters (see
%                 filt_main.m)
%    plot_ok - display signal plots [boolean]
%
% Output arguments:
%    ecgout - ecg filtered data
%    filtout - structure containing ECG filter parameters (see filt_main.m)
%
%--------------------------------------------------------------------------
% Written by Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

% Display frequence response and filtered signal
if nargin < 4, plot_ok = false; end

% Zero-mean ecgin
ecgout = ecgin - mean(ecgin);

if nargin >= 3 && isempty(filtin)
    filtin(1).name = 'none';
    
elseif nargin < 3 || ischar(filtin) && strcmp(filtin, 'default')
    clear filtin;
    % Default ECG filter parameters
    % notch filter at power line frequency (50-60Hz)
    line_freq      = 50;                           % europe=50Hz, america=60Hz                
    filtin(1).name = 'butter';                     % Butterworth filter 
    filtin(1).type = 'stop';                       % bandstop filter 
    filtin(1).n    = 2;                            % filter order
    filtin(1).fc   = [line_freq-1 line_freq+1];    % cutoff frequency (Hz)   
    
    % Baseline removal
    filtin(2).name = 'butter';                     % Butterworth filter
    filtin(2).type = 'high';                       % high-pass filter
    filtin(2).n    = 2;                            % filter order
    filtin(2).fc   = 0.5;                          % cutoff frequency (Hz)
    
    % Muscle activity removal
    filtin(3).name = 'butter';                     % Butterworth filter
    filtin(3).type = 'low';                        % low-pass filter
    filtin(3).n    = 2;                            % filter order
    filtin(3).fc   = 35;                           % cutoff frequency (Hz)
end

% Filter ECG signal
[ecgout,filtout] = filt_main(ecgout, fs, filtin, plot_ok);

end
