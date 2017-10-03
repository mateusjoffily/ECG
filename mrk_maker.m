function [onsets, durations] = mrk_maker(data, fs, subjID, event_code)

% Use : Chrisa2017-06-06T15_59_23_ID173TEST1_acq3.acq
%       Notes for this subject : did [4 mistakes + 1 not valid] at 5th table
% [onsets, durations] = mrk_maker(data,fs,1,1:4); 

datalength = size(data,2);

% figure
% Nchans = size(data,1);
% for i = 1:Nchans
%     subplot(Nchans,1,i)
%     plot((0:datalength-1)/fs, data(i,:));
%     ylabel(sprintf('%d',i));
% end
% linkaxes

% Bit channel
s3 = 4;   %Sujet_bit3
s2 = 3;   %Sujet_bit2
s1 = 2;   %Sujet_bit1
s0 = 1;   %Sujet_bit0
e3 = 8;   %Evt_bit3
e2 = 7;   %Evt_bit2
e1 = 6;   %Evt_bit1
e0 = 5;   %Evt_bit0
    
% Force bit channel to be binary
for i = [s3 s2 s1 s0 e3 e2 e1 e0]
    zmark = zscore(data(i,:));
    zmark(zmark<=0) = 0;
    zmark(zmark>0) = 1;
    data(i,:) = zmark;
end

% Subject of interest's mask
subject = 2.^(0:3) * data([s0 s1 s2 s3],:);
subject(subject ~= subjID) = 0;
subject(subject == subjID) = 1;

% Remove subject markers with pulse length less than 5ms
subject = marker_cleanup(subject, fs, 5, subjID);

% Event marker code
% 1 = global instructions and questionaires
% 2 = start of first table
% 4 = made a mistake, same table presented again
% 8 = respiration
%
% Note : may be there is some extra markers in the very beginning of the file
% Event sequence :   1 (instruction) + [ 2 (skills ~5min) ] * 4 
%                  + 1 (questionnaire 1) + 1 (questionnaire 2)? 
%                  + 1 (respiration) + 1 (instructions)
%                  + [ 2 (main task) ] * 7
event   = 2.^(0:3) * data([e0 e1 e2 e3],:);
event   = event .* subject;
event   = event_cleanup(event);

% Onsets
Nevents = length(event_code);
onsets  = cell(1,Nevents);
for n = 1:Nevents
    event_aux = (event == event_code(n));
    onsets{n} = (find(diff(event_aux) > 0) + 1) / fs;
end

% Durations
durations{1} = onsets{1}(2:2:end) - onsets{1}(1:2:end) + 1;  % instruction
durations{2} = 5;                         % first table 
durations{3} = 5;                         % same table if error

end
    
function x = marker_cleanup(x, fs, t, id)

% minimum pulse length
n = ceil(fs*(t*10^-3));

i1 = find(diff(x) > 0) + 1;
i2 = find(diff(x) < 0);

if length(i1) ~= length(i2)
    % Error found
    disp(['marker_cleanup: i1 <> i2: ' id]);
    x =[];
    return
end

c = 0;
for i = 1:length(i1)
    di = i2(i)-i1(i);
    if di < 0 
        % Error found
        disp(['marker_cleanup: i2-i1 < 0: ' id]);
        x =[];
        return
    end
    if di <= n
        disp(['marker_cleanup: di < n: ' id ' at ' num2str(i1(i)/fs) 's']);
        c = c + 1;
        x(i1(i):i2(i)) = 0;
    end
end

disp(['marker_cleanup: ' id ' -> total=' num2str(length(i1)) ...
      ', removed=' num2str(c)]);
  
end

function x = event_cleanup(x)

while true
    i1 = find(diff(x) > 0) + 1;
    i2 = find(diff(x) < 0);
    
    if length(i1) > length(i2)
        % slow positive slope
        ix = find(diff(i1) == 1);
        x(i1(ix)) = x(i1(ix)+1);
    elseif length(i1) < length(i2)
        % slow negative slope
        ix = find(diff(i2)==1);
        x(i2(ix)+1) = x(i2(ix));
    else
        break
    end
    
end

end