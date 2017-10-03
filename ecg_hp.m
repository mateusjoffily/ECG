function [hp, thp] = ecg_hp(Rt, method)
% ECG_HP Calculate the 'instantaneous' or 'delayed' heart period.
%   [hp, thp] = ECG_HP(t, method)
%
% Input arguments:
%   Rt     - R-wave peak times (cumulative sum of IBI series)
%   method - 'instantaneous': return the instantaneous HP
%            'delayed': return the delayed HP 
%            (see description below)
%
% Output arguments:
%   hp     - instantaneous heart period
%   thp    - instantaneous heart period time
%
% Description:
%   The instantaneous heart period is defined as f(t)=t[n+1]-t[n] 
%   for t[n]<=t<t[n+1], where t[n] is the occurance of the n-th heart beat.
% 
%   An alternative would be to measure the delayed heart period defined
%   as f(t)=t[n]-t[n-1] for t[n]<=t<t[n+1].
% 
% References:
%   Guimaraes & Santos (1998), and De-Boer, Karemaker & Strackee (1985)
%
% -------------------------------------------------------------------------
% Written by Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

if length(Rt) > 1
    
    hp      = diff(Rt);
    if strcmp(method, 'instantaneous')
        thp = Rt(1:end-1);
        
    elseif strcmp(method, 'delayed')
        thp = Rt(2:end);
        
    else
        disp ([mfilename ': "' method '" method unknown.' ]);
        hp  = [];
        thp = [];
    end
    
else
    hp      = [];
    thp     = [];    
end

end
