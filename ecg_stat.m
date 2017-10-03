function [HRstat, Ncycles] = ecg_stat(Rt, T0, T1, stat, unit)
% ECG_STAT Return statistic within analysis window
%   [HRstat, Ncycles] = ECG_STAT(t, T0, T1, stat, unit)
%
% Input arguments:
%   t    - R-wave peak times (cumulative sum of IBI series)
%   T0   - analysis window onset
%   T1   - analysis window offset
%   stat - statistics: 'mean', 'min', 'max', 'sdnn' or 'rmssd'
%   unit - output (HRstat) unit: 'sec', 'hz' or'bpm'.
%          'sec' = heart period.
%          'hz'  = heart rate in beats/sec.
%          'bpm' = heart rate in beats/min.
%
% Output arguments:
%   HRstat - statistic output
%   Ncycles - cycle count
%
% Description:
%   Each interval [t0;t1]; [t1;t2]; ... is considered as a cardiac cycle.
%   For an analysis window delimited by [T0;T1], the number of cycles
%   within the window is counted. The cycle [ti-1; ti] is counted as:
%   1                         , if T0 <= ti-1 < ti <= T1;
%   (ti - T0)/(ti - ti-1)     , if ti-1 < T0 < ti <= T1;
%   (T1 - ti-1)/(ti - ti-1)   , if T0 <= ti-1 < T1 < ti;
%   (T1 - T0)=(ti - ti-1)     , if ti-1 < T0 < T1 < ti.
%   Having defined the cycle count within a window, the mean heart rate
%   is defined as the ratio of this count to the total window length.
%
% References:
%   Dinh et al, 1999; see also Reyes and Vila, 1998
%--------------------------------------------------------------------------
% Written by Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

% Initialize output variables
HRstat  = NaN;
Ncycles = NaN;

% index of beat inside analysis window [T0;T1]
i = find(Rt>=T0 & Rt<=T1);

if isempty(i)
    % There isn't any beat inside analysis window [T0;T1]
    % (ti-1 < T0 < T1 < ti)
    i0 = find(Rt<T0);
    i1 = find(Rt>T1);
    if isempty(i0) || isempty(i1)
        disp([mfilename ': Missing heartbeat instant before T0 or after T1.']);
        return
    end
    tb = [Rt(i0(end)) Rt(i1(1))];   % beat time
    tc = [T0 T1];                   % cycle time

else
    % Analysis window [T0;T1] is longer than heart periods
    tb = Rt(i);                     % beat time
    tc = Rt(i);                     % cycle time

    % Adjust beat and cycle times to analysis window
    if Rt(i(1)) ~= T0
        if i(1)-1 < 1
            disp([mfilename ': Missing heartbeat instant before T0.']);
            return
        end
        tb = [Rt(i(1)-1) tb];
        tc = [T0 tc];
    end
    if Rt(i(end)) ~= T1
        if i(end)+1 > length(Rt)
            disp([mfilename ': Missing heartbeat instant after T1.']);
            return
        end
        tb = [tb Rt(i(end)+1)];
        tc = [tc T1];
    end
end

% Instantaneous heart period
IBI     = diff(tb);

% Cycle count within analysis window
Ncycles = sum(diff(tc)./IBI);

% Analysis window length
winlen  = T1-T0;

switch stat
    case 'mean'
        HRstat     = winlen/Ncycles;

    case 'min'
        if strcmp(unit,'bpm') || strcmp(unit, 'hz')
            HRstat = max(IBI);
        else
            HRstat = min(IBI);
        end

    case 'max'
        if strcmp(unit,'bpm') || strcmp(unit, 'hz')
            HRstat = min(IBI);
        else
            HRstat = max(IBI);
        end

    case 'sdnn'
        HRstat     = std(IBI);

    case 'rmssd'
        HRstat     = sqrt( mean( diff(IBI).^2 ) );

end

switch unit
    case 'hz'
        HRstat     = 1/HRstat;

    case 'bpm'
        HRstat     = 60/HRstat;
end

end