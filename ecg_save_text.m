function ecg_save_text(fecg,fcond, ftxt)
% ECG_SAVE_TEXT Save ECG results in text file format
%   ECG_SAVE_TEXT(fecg,fcond, ftxt)
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
load(fout,'ecg','Rn','mIBI','IBI','IBIt','TDS','PSD','power');

% load conditions
load(fcond,'names','onsets','durations');

% Open output file
fid = fopen(ftxt, 'w');

% Write header
fprintf(fid, 'Condition\tOnset\tDuration\IBImean\IBIstd\t');
fprintf(fid, 'IBIrms\tIBI\tPSD\n');

% Loop over Conditions
for iC = 1:numel(conds)
    for iE = 1:numel(conds(iC).onsets)
        
        fprintf(fid, '%s\t%0.2f\t%0.2f\t', conds(iC).name, ...
            conds(iC).onsets(iE), conds(iC).durations(iE));
       
        fprintf(fid, '%0.2f;%0.2f\t', conds(iC).latency_wdw(:,iE));
        
        % Write to file
        fprintf(fid, '%0.4f\t', mIBI{iC}(iE));
        fprintf(fid, '%0.4f\t', TDS(iC).std(iE));
        fprintf(fid, '%0.4f\t', TDS(iC).std(iE));
        fprintf(fid, '%0.4f\n', EDL);
    end
end

% Close file
fclose(fid);

end