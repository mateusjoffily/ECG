function beat_idx = ecg_beat_detect(ecg, fs, w, t, p)
% ECG_BEAT_DETECT Automatic ECG R-wave detection.
%   beat_idx = ECG_BEAT_DETECT(ecg, fs, w, t, p)
%
% Input arguments:
%   ecg - ecg signal 
%   fs - ecg sampling rate (Hz) 
%   w - [sec] R-wave normalisation window
%   t - [a.u.] amplitude threshold
%   p - [sec] lag window preventing large T-waves detection
%
% Output arguments:
%   beat_idx - index of detected R-waves into ecg input vector 
% 
% References:
%   Friesen, Jannett, Jadallah, Yates, Quint and Nagle (1990)
% -------------------------------------------------------------------------
% Written by Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

if nargin<2
    return
elseif nargin<5
    % Use default values
    w = 1.0;  % [sec] R-wave normalisation window
    t = 0.3;  % [a.u.] amplitude threshold
    p = 0.3;  % [sec] lag window preventing large T-waves detection 
end

% Truncate ecg values below zero
%--------------------------------------------------------------------------
ecg = uint16((2^8-1)*ecg/max(ecg));


% Calculate first derivative
%--------------------------------------------------------------------------
d1ecg=diff(ecg)*fs;
% Detect ecg maxima
id0max=find(d1ecg(1:end-1)>0 & d1ecg(2:end)<=0)+1;


% Calculate second derivative
%--------------------------------------------------------------------------
d2ecg=diff(d1ecg)*fs;
% Detect first derivative maxima
id1max=find(d2ecg(1:end-1)>0 & d2ecg(2:end)<=0)+1;


% Normalize data within 'w' seconds window 
%--------------------------------------------------------------------------
w=fix(w*fs);
for i=1:w:length(d1ecg)-(w-1)
    v=i+[0:w-1];
    d1ecg(v)=(d1ecg(v)/max(d1ecg(v)));
end
ws=rem(length(d1ecg),w);
if ws>0
    d1ecg(end-(ws-1):end)=(d1ecg(end-(ws-1):end)/max(d1ecg(end-(ws-1):end)));
end


% Square first derivative maximas
%--------------------------------------------------------------------------
d1ecg2=zeros(size(d1ecg));
d1ecg2(id1max)=d1ecg(id1max).^2;


% Threshold squared first devirative
%--------------------------------------------------------------------------
id1sqr=find(d1ecg2>t);


% First ecg maxima after a thresholded first derivative is a valid R-wave
%--------------------------------------------------------------------------
beat_idx=[];
for i=1:length(id1sqr)
    I=find(id0max-id1sqr(i)>=0);
    beat_idx(i)=id0max(I(1));
end


% Prevent large T-waves detection
%--------------------------------------------------------------------------
% Detect beats closer than 'p' seconds and remove the smallest one
p=fix(p*fs);
idx=find(diff(beat_idx)<p);
while ~isempty(idx)
    % Remove smallest amplitude beat
    if ecg(beat_idx(idx(1))) < ecg(beat_idx(idx(1)+1))
        beat_idx(idx(1))=[];
    else
        beat_idx(idx(1)+1)=[];
    end
    idx=find(diff(beat_idx)<p);
end

% Detect ectopic beats
%--------------------------------------------------------------------------
beat_time=(beat_idx-1)/fs;
[RR, RR_time]=ecg_hp(beat_time, 'instantaneous');
[arti,flsi] = ecg_artifact(RR);

if ~isempty(arti)
    disp([mfilename ': ' num2str(numel(arti)) ' artifacts detected.']);
end
if ~isempty(flsi)
    disp([mfilename ': ' num2str(numel(flsi)) ' false positives detected.']);
end


