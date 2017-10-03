function [TDS,PSD,power] = ecg_hrv(Rt,onsets,durations)
% ECG_HRV heart rate variability
%   [TDS,PSD,power] = ECG_HRV(Rt,onsets,durations)
%
% Input arguments:
%   Rt        - R-wave event time (seconds) or cumulative sum of IBI series
%   onsets    - onsets of events cell(1,N)
%   durations - durations of events cell(1,N)
%
% Output arguments:
%   TDS       - Time domain HRV statistics (miliseconds)
%   PSD       - Power Spectral Density estimate using FFT 
%   power     - power at ferquency bands
%
% Description:
%                 onsets=cell(1,N) and durations=cell(1,N), contains the
%                 onsets{2}=[10 40 100 130] and durations{2}=[0 3 0 3]
%                 of events.
%                 The duration vectors can contain a single entry if the
%                 durations are identical for all events.
%
% -------------------------------------------------------------------------
% Written by Mateus Joffily - GATE, CNRS

% setup and preliminaries
no      = length(onsets); 
TDS     = struct('SDNN',[],'RMSSD',[]);   % Time domain statistics
F       = cell(1,no);                      % FFT frequencies
PSD     = cell(1,no);                      % power spectrum density
power   = struct('VLF',[],'LF',[],'HF',[],'NLF',[],'NHF',[]);

% FFT parameters
Fs = 2;            % sample rate
N  = 512;          % points

% interbeat interval (IBI)
[IBI,IBIt] = ecg_hp(Rt,'instantaneous');  % interbeat interval (second)

% loop over events
for n = 1:no
    T      = length(onsets{n});
    F{n}   = nan(T,N/2);
    PSD{n} = nan(T,N/2);

    % loop over trials
    for t = 1:T
        T0             = onsets{n}(t);
        if length(durations{n}) == T
            T1 = T0 + durations{n}(t);
        else
            T1 = T0 + durations{n};
        end

        % Time domain statistics
        %------------------------------------------------------------------
        TDS(n).SDNN(t)  = 1000*ecg_stat(Rt', T0, T1, 'sdnn', 'sec');
        TDS(n).RMSSD(t) = 1000*ecg_stat(Rt', T0, T1, 'rmssd', 'sec');

        % Frequency domain statistics
        %------------------------------------------------------------------
        % spline interpolation
        rIBIt  = T0:1/Fs:T1;
        rIBI   = ecg_interp(IBIt',1000*IBI',rIBIt,'spline');

        % detrend
        drIBI  = detrend(rIBI,'constant');

        % windowing method
        wdw    = hanning(length(drIBI))';
        fdrIBI = drIBI.*wdw;

        % FFT
        cw          = (1/N) * sum(wdw.^2); % coef. to remove window effect
        PSDx        = abs(fft(fdrIBI,N)).^2 / (N*Fs*cw);
        Fx          = (0:Fs/N:Fs-Fs/N)';
        PSD{n}(t,:) = 2*PSDx(1:ceil(length(PSDx)/2));
        F{n}(t,:)   = Fx(1:ceil(length(Fx)/2));

        % power at frequency bands
        power(n).VLF(t)   = spPower(F{n}(t,:),PSD{n}(t,:),'vlf');
        power(n).LF(t)    = spPower(F{n}(t,:),PSD{n}(t,:),'lf');
        power(n).HF(t)    = spPower(F{n}(t,:),PSD{n}(t,:),'hf');
        power(n).NLF(t)   = spPower(F{n}(t,:),PSD{n}(t,:),'nlf');
        power(n).NHF(t)   = spPower(F{n}(t,:),PSD{n}(t,:),'nhf');
    end
end

end


function power = spPower(F,PSD,freq)

% define frequency bands
vlf  = 0.04;                            % very low frequency band
lf   = 0.15;                            % low frequency band
hf   = 0.4;                             % high frequency band

N    = length(PSD);                     % number of points in the spectrum
maxF = F(2)*N;                          % maximum frequency

if hf > F(end),
    hf          = F(end);
    if lf > hf,
        lf      = F(end-1);
        if vlf > lf,
            vlf = F(end-2);
        end
    end
end

% limiting points in each band
index_vlf     = round(vlf*N/maxF)+1;
index_lf      = round(lf*N/maxF)+1;
index_hf      = round(hf*N/maxF)+1;
if index_hf > N
    index_hf  = N;
end

switch freq
    case {'total'}
        % total energy (from 0 to hf) in ms^2
        total = F(2)*sum(PSD(1:index_hf-1));
        power = total;
        
    case {'vlf'}
        % energy of very low frequencies (from 0 to vlf2)
        vlf   = F(2)*sum(PSD(1:index_vlf-1));
        power = vlf;
        
    case {'lf'}
        % energy of low frequencies (from vlf2 to lf2)
        lf    = F(2)*sum(PSD(index_vlf:index_lf-1));
        power = lf;
        
    case {'hf'}
        % energy of high frequencies (from lf2 to hf2)
        hf    = F(2)*sum(PSD(index_lf:index_hf-1));
        power = hf;
        
    case {'nlf'}
        % normalized low frequency
        lf    = F(2)*sum(PSD(index_vlf:index_lf-1));
        hf    = F(2)*sum(PSD(index_lf:index_hf-1));
        nlf   = lf/(lf+hf);
        power = nlf;
        
    case {'nhf'}
        % normalized high frequency
        lf    = F(2)*sum(PSD(index_vlf:index_lf-1));
        hf    = F(2)*sum(PSD(index_lf:index_hf-1));
        nhf   = hf/(lf+hf);
        power = nhf;
        
    otherwise
        disp('Uknown frequency range selection')
        power = nan;
        
end

end

function [alpha,n,Fn] = DFA(y,varargin)

% set default values for input arguments
sliding = '';
minbox  = 4;
maxbox  = floor(length(y)/4);

% check input arguments
nbIn = nargin;
if nbIn > 1
    if ~ischar(varargin{1})
        minbox     = varargin{1};
        if ~ischar(varargin{2})
            maxbox = varargin{2};
        else
            error('Input argument missing.');
        end
    end
    for i=1:nbIn-1
        if isequal (varargin{i},'s'), sliding='s';end
    end
end

% initialize output variables
alpha = [];
n     = NaN(1,maxbox-minbox+1);
Fn    = NaN(1,maxbox-minbox+1);

% transpose data vector if necessary
s     = size(y);
if s(1)>1
    y = y';
end

% substract mean
y     = y-mean(y);

% integrate time series
y     = cumsum(y);

N     = length(y); % length of data vector

% error message when box size exceeds permited limits
if minbox < 4 || maxbox > N/4
    disp([mfilename ': either minbox too small or maxbox too large!']);
    return
end

% begin loop to change box size
count = 1;
for n = minbox:maxbox;
    i = 1;
    r = N;
    m = [];
    l = [];
    
    % begin loop to create a new detrended time series using boxes of size n starting
    % from the beginning of the original time series
    while i+n-1<=N % create box size n
        x     = y(i:i+n-1);
        x     = detrend(x);               % linear detrending
        m     = [m x];
        if strcmp(sliding,'s')
            i = i + 1;                    % sliding window
        else
            i = i + n;                    % non-overlapping windows
        end
    end
    
    % begin loop to create a new detrended time series with boxes of size n starting
    % from the end of the original time series
    while r-n+1>=1
        z     = y(r:-1:r-n+1);
        z     = detrend(z);
        l     = [l z];
        if strcmp(sliding,'s')
            r = r-1;
        else
            r = r-n;
        end
    end
    
    % root-mean-square fluctuation of the new time series
    % concatenate the two detrended time series
    Fn(count) = sqrt( mean( [m l].^2 ) );
    count     = count+1;
    
end

n = minbox:maxbox;

% plot the DFA
% figure;
% plot(log10(n),log10(Fn))
% xlabel('log(n)')
% ylabel('log(Fn)')
% title('Detrended Fluctuation Analysis')

% calculate scaling factor alpha
coeffs    = polyfit(log10(n),log10(Fn),1);
alpha     = coeffs(1);

end

