function beat_idx = ecg_gui(ecg, fs, beat_idx)
% ECG_GUI Graphical user interface for ECG R-wave detection.
%   [invecg, beat_idx] = ECG_GUI(ecg, fs, invecg, beat_idx)
%
% Input arguments:
%   ecg      - ecg data 
%   fs       - ecg sampling rate (Hz) 
%   beat_idx - index of R-waves previously detected into ecg input vector
%
% Output arguments:
%   beat_idx - index of R-waves into ecg input vector
%
% Description:
%   Provides an Graphical User Interface to control ECG R-waves detection.
%   The functionalities currently implemented are: 
%   (1) Set detection amplitude threshold
%   (2) Remove detected ECG beat
%   (3) Add ECG beat at mean inter beats interval
%   (4) Automatic R-wave detection (uses ecg_beat_detect.m)
%   (5) Plot Interval RR (IRR) serie
%   (6) Plot IRR Difference serie
%
% Called by:
%   - ecg_main.m
% -------------------------------------------------------------------------
% Adapted by Mateus Joffily - NeuroII/UFRJ

% Backup values
beat_idx_backup = beat_idx;

% ecg samples time stamps
tecg            = (0:length(ecg)-1)/fs;
% limits of graph's time axis
taxis           = [0 tecg(end)];

% create figure
nn=figure('units','normal', ...
          'name','ECG_GUI - Neuro II / UFRJ', ...
          'number','off', ...
          'Color', 'w', ...
          'resize','on');

button=0;  % inilialize button value
while button < 10   % loop until 'exit'
    
    % Plot whole ecg signal + detected beats
    plot(tecg, ecg, 'k', ...
         (beat_idx-1)/fs, ecg(beat_idx), 'r.');
     
    % adjust graph's axes limits
    iaxis = find(tecg >= taxis(1) & tecg <= taxis(2));
    if isempty(iaxis)
        iaxis = [1:length(ecg)];
    end
    axis_scaling = [taxis min(ecg(iaxis))-0.1 max(ecg(iaxis))+0.2];
    axis(axis_scaling);

    % graph's labels
    xlabel('time (s)');
    ylabel('amplitude (a.u.)');
    
    % command menu
    button=menu('Choose option','Display whole signal', ...
               'Set threshold','Previous window', 'Next window', ...
               'Remove beat', ...
               ... 'Add beat', ... % remove this option for the moment
               'Add Mean beat', ...
               'Automatic Detection', ...
               'View RR Interval', 'View IRR Difference', ...
               'Cancel and Exit','Save and Exit');
    
    % Save current time axis limits
    taxis = axis;
    taxis = taxis(1:2);
    
    % execute command
    switch button
        case 1 % Show whole signal
            taxis = [0 tecg(end)];

        case 2 % Detect R-waves above amplitude threshold
            title('Press LEFT mouse button to set threshold');
            [x,y,bot]=ginput(1);
            if bot ~= 1
                title('TRY AGAIN');
                pause(2);
                continue
            end
            
            v=axis;
            if v(1)<0,
                v(1)=0;
            elseif v(1)>(length(ecg)-1)/fs,
                v(1)=(length(ecg)-1)/fs;
            end
            if v(2)<0,
                v(2)=0;
            elseif v(2)>(length(ecg)-1)/fs,
                v(2)=(length(ecg)-1)/fs;
            end
            if v(1) >= v(2), continue, end
                
            t_idx=1+[round(v(1)*fs):round(v(2)*fs)];
            ecg_win=ecg(t_idx);

            % Automaticaly detect R-waves
            beat_idx_win = ecg_beat_detect(ecg_win, fs);
            % reshape beat_idx_win as 1-by-N vector
            beat_idx_win = reshape(beat_idx_win,1,length(beat_idx_win));
            % Remove beats with amplitude below threshold
            idx = find(ecg_win(beat_idx_win) < y);
            beat_idx_win(idx) = [];
            % find beats previously detected inside time window
            idx = find(ismember(beat_idx,t_idx));
            % remove beats
            beat_idx(idx) = [];
            % insert new detected beats
            if ~isempty(beat_idx_win)
                beat_idx = sort([beat_idx; (t_idx(1)+beat_idx_win-1)']);
            end

        case 3 % Move backward
            v=axis;
            v1=v(1)-(v(2)-v(1));
            if v1 < 0
                v1=0;
            end
            v2=v1+(v(2)-v(1));
            if v2>(length(ecg)-1)/fs
                v2=(length(ecg)-1)/fs;
            end
            taxis = [v1 v2];

        case 4 % Move forward
            v=axis;
            v2=v(2)+(v(2)-v(1));
            if v2>(length(ecg)-1)/fs
                v2=(length(ecg)-1)/fs;
            end
            v1=v2-(v(2)-v(1));
            if v1 < 0
                v1=0;
            end
            taxis = [v1 v2];

        case 5 % Delete beat at mouse location
            title('Press LEFT mouse button to delete beat');
            [x,y,bot]=ginput(1);
            if bot==1 & x >= 0 & x<=(length(ecg)-1)/fs
                k=round(x*fs)+1;
                % Closest beat to selected point
                [b,ib]=min(abs(beat_idx-k));
                beat_idx(ib) = [];
            else
                title('TRY AGAIN');
                pause(2);
            end

%         case 7 % Add beat at mouse location
%             title('Press LEFT mouse button to add beat');
%             [x,y,bot]=ginput(1);
%             if bot==1 & x >= 0 & x<=(length(ecg)-1)/fs
%                 k = round(x*fs)+1;
%                 beat_idx = unique([beat_idx k]);
%             else
%                 title('TRY AGAIN');
%                 pause(2);
%             end
            
        case 6 % Add mean beat at mouse location
            title('Press LEFT mouse button to add mean beat');
            [x,y,bot]=ginput(1);
            if bot==1 && x >= 0 && x<=(length(ecg)-1)/fs
                k = round(x*fs)+1;
                % Find the closest two beats to the selected point
                [s,is]=sort(abs(beat_idx-k));
                % calculate mean time beetween closest beats
                t_mean_beat = mean((beat_idx(is(1:2))-1)/fs);
                % add beat at t_mean_time
                k = round(t_mean_beat*fs)+1;
                beat_idx = unique([beat_idx; k]);
            else
                title('TRY AGAIN');
                pause(2);
            end

        case 7 % Automatic beat detection inside current window
 
            % get ecg segment inside window
            v=axis;
            v1=v(1);
            if v1 < 0
                v1=0;
            end
            v2=v(2);
            if v2>(length(ecg)-1)/fs
                v2=(length(ecg)-1)/fs;
            end
            if v(1) >= v(2), continue, end
            
            t_idx=1+[round(v1*fs):round(v2*fs)];
            ecg_win=ecg(t_idx);

            % user interface
            prompt={'R-wave normalisation window [sec]', ...
                    'Amplitude threshold [a.u.]', ...
                    'Lag window preventing large T-waves detection [sec]'};
            def={'1.0', '0.3', '0.3'};
            dlgTitle='R-waves automatic detection parameters';
            lineNo=1;
            answer=inputdlg(prompt,dlgTitle,lineNo,def);

            if ~isempty(answer) && ~(isempty(answer{1}) || ...
                    isempty(answer{2}) || isempty(answer{3}))
                w=str2num(answer{1}); % R-wave normalisation window [sec]
                t=str2num(answer{2}); % Amplitude threshold [a.u.]
                p=str2num(answer{3}); % Lag window preventing large T-waves detection [sec]'
                
                % Automaticaly detect R-waves
                beat_idx_win = ecg_beat_detect(ecg_win, fs, w, t, p);
            else
                return
            end
            
            % find beats previously detected inside time window
            idx = ismember(beat_idx,t_idx);
            % remove beats
            beat_idx(idx) = [];
            % insert new detected beats
            beat_idx      = sort([beat_idx; t_idx(1)+beat_idx_win(:)-1]);

        case 8 % Plot RR series
            %beat_idx=find(i_beat>0);
            beat_time     = (beat_idx-1)/fs;
            [RR, RR_time] = ecg_hp(beat_time, 'instantaneous');

            % Detect ectopic beats
            [arti,flsi] = ecg_artifact(RR);
            
            % Plot graph
            figure(nn);
            plot(RR_time,RR);
            hold on;
            plot(RR_time,RR,'xr');
            plot(RR_time(arti),RR(arti),'og');
            plot(RR_time(flsi),RR(flsi),'ob');
            xlabel('seconds');
            ylabel('RR Interval in seconds');
            title('Press ENTER to return to main window...');
            hold off;
            
            % adjust graph's axes limits
            iaxis = find(RR_time >= taxis(1) & RR_time <= taxis(2));
            if isempty(iaxis)
                iaxis = [1:length(RR)];
            end
            axis_scaling = [taxis min(RR(iaxis))-0.1 max(RR(iaxis))+0.2];
            axis(axis_scaling);
    
            % pause
            pause;
            
            % Save current axis limits
            taxis = axis;
            taxis = taxis(1:2);
            
        case 9 % Plot RR interval differences
            %beat_idx=find(i_beat>0);
            beat_time=(beat_idx-1)/fs;
            [RR, RR_time]=ecg_hp(beat_time, 'instantaneous');

            % Calculate RR difference
            RRdiff=(diff(RR)./RR(1:end-1))*100;
            RRdiff_t=RR_time(1:end-1);
            
            % Detect RR artifacts
            [arti,flsi] = ecg_artifact(RR);
            
            % Remove artifacts that are outside RRdiff length
            arti(arti>numel(RRdiff)) = [];
            flsi(flsi>numel(RRdiff)) = [];
            
            % Plot graph
            figure(nn);
            plot(RRdiff_t,RRdiff);
            hold on,
            plot(RRdiff_t,RRdiff,'xr');
            plot(RR_time(arti),RRdiff(arti),'og');
            plot(RR_time(flsi),RRdiff(flsi),'ob');
            plot([RR_time(2) RR_time(end)], [20 20], 'g--');
            plot([RR_time(2) RR_time(end)], [-20 -20], 'g--');
            xlabel('seconds');
            ylabel('% RR interval difference');
            title('Press ENTER to return to main window...');
            hold off;
            
            % adjust graph's axes limits
            iaxis = find(RRdiff_t >= taxis(1) & RRdiff_t <= taxis(2));
            if isempty(iaxis)
                iaxis = [1:length(RRdiff)];
            end
            axis_scaling = [taxis min(RRdiff(iaxis))-0.1 max(RRdiff(iaxis))+0.2];
            axis(axis_scaling);
    
            % pause
            pause;
            
            % Save current axis limits
            taxis = axis;
            taxis = taxis(1:2);
            
        case 10 % Cancel changes & Quit
            % Restore backup values
            beat_idx = beat_idx_backup;
            close(nn);

        case 11 % Save & Quit
            close(nn);
    end

end

