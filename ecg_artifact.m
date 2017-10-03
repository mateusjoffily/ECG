function [arti,flsi] = ecg_artifact(rr)
% ECG_ARTIFACT Detect ECG artifacts.
%   [arti,flsi] = ECG_ARTIFACT(rr)
%
% Input arguments:
%   rr - vector containing series of RR intervals 
%
% Output arguments:
%   arti = vector of indices into rr of artifacts
%   flsi = vector of indices into rr of false positive detections
%
% Description:
%   Returns indices into RR series of artifact detections and false positive
%   detections as decided by MAD/MED criteria of Berntson et al, 1990.
%
% Called by:
%   - ecg_gui.m
%
% References:
%  Berntson, Quigley, Jang & Boysen - Psychophysiology 1990 Vol.27(5) p.586.
%  Berntson & Stowell - Psychophysiology 1998 Vol.35 p.127–132.
%--------------------------------------------------------------------------
% Written by Dr. Alex Jones & Alessandro Beda (MRC EEU) 12-11-2003
% Revision 1.0
% Based on initial but incorrect implementation by Shusina Ngwa (ISVR)

len = length(rr);
cr = crit(rr);

arti = [];
flsi = [];

for k = 2:len-3
    
    B0 = rr(k - 1);
    B1 = rr(k);
    B2 = rr(k + 1);
    B3 = rr(k + 2);
    B4 = rr(k + 3);
    
    norm_seq = abs(B3 - B4) < cr;
    
    if (abs(B1 - B2) > cr)
        arti = [arti;k];
        if (abs(B1- B0) < cr)  % if previous beat satisfies criterion progress
            if ((B1 - B2) < 0) % long beat check, if yes do following b2
                if norm_seq       
                    x = B2/2;            % divide long beat by 2 
                    if ( ((x - B1) + (x - B3)) / 2 < -cr)    %( x - B1 < -cr & x - B3 < -cr )
                        arti(end) = [];
                        flsi = [flsi;k];                        
                    end    
                end    
            else               % short beat
            if norm_seq       
                    if ( B1 < B3 )                 
                        x = B1 + B2;               
                    else
                        x = B2 + B3;               
                    end
                    
                    if ( x - B0 > cr && x - B2 > cr )
                        arti(end) = [];
                        flsi = [flsi;k];
                    end
                end   
            end    
        end    
    end
end    

%--------------------------------------------------------------------------
function [cr] = crit(rr)

% Returns the criteria for artifact identification (cr) for a given rr 
% interval series (rr).
%
% rr - rr intervals
% cr - Criteria ie (MAD+MED)/2 according to paper by Berntson 1990 Psychophysiology
%
% Written by Dr. Alex Jones & Dr. Alessandro Beda on 12.11.2003 (MRC EEU)
% Revision 1.1
%
% 16/11/2003 - AJ - revised to give accurate estimate of quartiles and
% median - now copes with small sections of data.
%
% ** Fixed -> NB this function does not give exact values of median and
% quartiles. **

if (isempty(rr))
    error('Error - no input');
end    

len = length(rr);

rr = sort(rr);
intind = ((0:len-1)/len)+(1/(2*len));
size(rr)
m = interp1(intind,rr,0.5,'linear','extrap');
q1 = interp1(intind,rr,0.25,'linear','extrap');
q3 = interp1(intind,rr,0.75,'linear','extrap');

QD = (q3 - q1) / 2;
MAD = (m - 2.9 * QD) / 3;
MED = 3.32 * QD;

cr = (MAD + MED) / 2;