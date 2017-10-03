function ecg_save_hrv(fecg,fcond, ftxt)
% ECG_SAVE_HRV Save ECG results in text file format
%   ECG_SAVE_HRV(fecg,fcond, ftxt)
%
% Required input arguments:
%   fecg  - input file with ecg data and results
%   fcond - conditions file (if empty, the same as fecg)
%   ftxt  - output text file name
% _________________________________________________________________________

% Last modified 28-09-2017 Mateus Joffily

% Copyright (C) 2017 Mateus Joffily, mateusjoffily@gmail.com.
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

if nargin < 3
    error('Missing inputs');
end

if isempty(fcond)
    fcond = fecg;
end

% load ecg variables
load(fecg,'TDS','PSD','power');

% load conditions
load(fcond,'names','onsets','durations');

% Open output file
fid = fopen(ftxt, 'w');

% Write header
fprintf(fid, 'Condition\tOnset\tDuration\tSDNN\tRMSSD\t');
fprintf(fid, 'VLF\tLF\tHF\tNLF\tNHF\t');
fprintf(fid, 'PSD_series\n');

% Loop over Conditions
for j = 1:length(names)
    for k = 1:length(onsets{j})
        % Write to file
        fprintf(fid, '%s\t%0.2f\t', names{j}, onsets{j}(k));
        if durations{j} == 1
            fprintf(fid, '%0.2f\t', durations{j}(k));
        else
            fprintf(fid, '%0.2f\t', durations{j});
        end
        fprintf(fid, '%0.2f\t', TDS(j).SDNN(k));
        fprintf(fid, '%0.2f\t', TDS(j).RMSSD(k));
        fprintf(fid, '%0.2f\t', power(j).VLF(k));
        fprintf(fid, '%0.2f\t', power(j).LF(k));
        fprintf(fid, '%0.2f\t', power(j).HF(k));
        fprintf(fid, '%0.2f\t', power(j).NLF(k));
        fprintf(fid, '%0.2f\t', power(j).NHF(k));
        fprintf(fid, '%0.2f\t', PSD{j}(k,:));
        fprintf(fid, '\n');
    end
end

% Close file
fclose(fid);

end