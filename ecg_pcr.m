function [mIBI,rIBI,rIBIt] = ecg_pcr(Rt,onsets,durations)
% ECG_PCR phasic cardiac responses
%   [] = ECG_PCR(Rt, onsets, durations)
%
% Input arguments:
%   Rt        - R-wave event time (seconds) or cumulative sum of IBI series
%   onsets    - onsets of events cell(1,N)
%   durations - durations of events cell(1,N)
%
% Output arguments:
%   mIBI      - mean IBI (miliseconds)
%   rIBI      - interbeat interval (IBI) per epoch at 2Hz (miliseconds)
%   rIBIt     - IBI time (seconds)
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

%   epoch_start - Epoch start designates the duration of the baseline 
%                 before stimulus onset. It must be lower or equal to zero.
%   epoch_end   - Epoch end designates the duration of the analyses window. 
%                 For example, an epoch start equal to -3 and epoch end 
%                 equal to 12 means that the program will calculate a 3 
%                 seconds baseline before stimulus onset and heart rate
%                 values for 12 subsequent seconds.
epoch_start = -3;
epoch_end   = 12;
Fs          = 2;
DT          = -epoch_start:1/Fs:epoch_end;

no          = length(onsets);
mIBI        = cell(1,no);
rIBI        = cell(1,no);
rIBIt       = cell(1,no);

[IBI,IBIt]  = ecg_hp(Rt,'instantaneous');  % interbeat interval (second)

% loop over events
for n = 1:no
    T                 = length(onsets{n});
    mIBI{n}           = nan(T,1);
    rIBIt{n}          = nan(T,length(DT));
    rIBI{n}           = nan(T,length(DT));
    
    % loop over trials
    for t = 1:T
        T0            = onsets{n}(t);
        if length(durations{n}) == T
            T1        = T0 + durations{n}(t);
        else
            T1        = T0 + durations{n};
        end
        mIBI{n}(t)    = 1000*ecg_stat(Rt', T0, T1, 'mean', 'sec');
        
        rIBItx        = T0+DT;
        rIBIx         = ecg_interp(IBIt',1000*IBI',rIBItx,'constant');
        rIBIt{n}(t,:) = rIBItx;
        rIBI{n}(t,:)  = rIBIx;
    end
end

end