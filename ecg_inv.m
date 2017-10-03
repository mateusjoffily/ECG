function invecg = ecg_inv(ecg)
% ECG_INV Check if ecg signal is inverted.
%   invecg = ECG_INV(ecg)
%
% Input arguments:
%   ecg - ecg raw signal 
%
% Output arguments:
%   invecg - '-1' if signal is inverted or '1' if signal is not inverted
%
%--------------------------------------------------------------------------
% Written by Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

% preliminaries
ecg     = ecg-mean(ecg);
ecg_abs = abs( ecg );

% Remove outliers
while 1  
    [max_ecg, idx] = max(ecg_abs);
    amp_threshold  = max_ecg-std(ecg_abs);
    n_threshold    = 10;
    % figure, hold on, plot(ecg_abs), plot([1 length(ecg_abs)], [amp_threshold amp_threshold], 'r');
    % If there are less than n_threshold samples smaller than amp_threshold,
    % than those samples are outliers
    if length(find( ecg_abs > amp_threshold )) < n_threshold
        ecg_abs(idx) = 0;
    else
        break
    end
end

% If max peak is negative, than ecg is inverted
if ~isempty(idx)
    if ecg(idx(1))<0
        invecg=-1;
        disp([mfilename ': ecg signal inverted']);
    else
        invecg=1;
    end
else
    disp([mfilename ': unable to detect if ecg signal is inverted']);
    invecg=1;
end