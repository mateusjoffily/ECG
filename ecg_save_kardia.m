function ecg_save_kardia(fkrd, Rt, names, onsets)
% ECG_SAVE_KARDIA Save ECG results in KARDIA software file format
%   ECG_SAVE_KARDIA(fkrd, Rt, names, onsets)
%
% Required input arguments:
%   fkrd      - KARDIA output text file name
%   Rt        - R-wave event time (seconds) or cumulative sum of IBI series
%   onsets    - onsets of events cell(1,N)
%   durations - durations of events cell(1,N)
% _________________________________________________________________________
% Written by Mateus Joffily - GATE, CNRS

%   epoch_start - Epoch start designates the duration of the baseline 
%                 before stimulus onset. It must be lower or equal to zero.
%   epoch_end   - Epoch end designates the duration of the analyses window. 
%                 For example, an epoch start equal to -3 and epoch end 
%                 equal to 12 means that the program will calculate a 3 
%                 seconds baseline before stimulus onset and heart rate
%                 values for 12 subsequent seconds.

data  = Rt';
conds = {};
trg   = [];

for j = 1:length(names)
    for k = 1:length(onsets{j})
        conds{end+1} = [names{j} '_' num2str(k)];
        trg(end+1,1) = onsets{j}(k);
    end
end

save(fkrd, 'data', 'conds', 'trg');

end

