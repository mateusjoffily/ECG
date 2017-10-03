function conf_example
% Sets the variables that are used by ecg_*.m and scr_*.m routines.
% A new conf_*.m file must be created for every experimental session.
% 
%  'config' structure fields:
%    (string)  config.input.mat 
%    (string)  config.output.mat
%    (string)  config.output.txt
%    (cell array of strings) config.subject(n).info
%    (integer) config.subject(:).ch.scr
%    (integer) config.subject(:).ch.ecg
%    (integer) config.subject(:).ch.mrk
%    (1-by-n vector) config.exp.seq
%    (string)  config.exp.trial(:).name
%    (integer) config.exp.trial(:).scr.NumMarkers
%    (string)  config.exp.trial(:).scr.ev(:).name
%    (integer) config.exp.trial(:).scr.ev(:).onset.refmark
%    (double)  config.exp.trial(:).scr.ev(:).onset.time
%    (integer) config.exp.trial(:).scr.ev(:).offset.refmark
%    (double)  config.exp.trial(:).scr.ev(:).offset.time
%
% see lines below for description of the structure fields.
%
% Warning: 
%   To avoid MATLAB warning message: 'Function call invokes inexact match', 
%   you must rename the current function name (line 1) equal to the  
%   conf_*.m filename itself. 
% -------------------------------------------------------------------------
% Mateus Joffily - NeuroII/UFRJ & CNC/CNRS

% Global config structure
global config

%--------------------------------------------------------------------------
% Set auxiliary variables (optional)

% root directory 
[rootdir,name,e,v] = fileparts(mfilename('fullpath'));

%--------------------------------------------------------------------------
% Set input file names

% Matlab format input file (*.mat)
% This file must be provided by the user with two variables 
% named 'data' and 'fs'.
% 'data ' is a n-by-m matrix, where: 
%   n is the number of channels recorded
%   m is the number of time samples recorded
% 'fs' is the sampling frequency (Hz)
% If you use BIOPAC, you can use the routine 'acq2mat.m' to automaticaly
% convert input files from the acknowledge .acq  to matlab .mat format. 
config.input.mat='\myrootdir\mydata.mat';


%--------------------------------------------------------------------------
% Set output file names

% Those files will be genetared by ana_main.m routine and will contain the 
% analysis results. Two output files containing the same information will 
% be generated: one in matlab (.mat) format and another in text (.txt)
% format. 
config.output.mat='\myrootdir\myresultfile.mat';
config.output.txt='\myrootdir\myresultfile.txt';

%--------------------------------------------------------------------------
% Set subjects

% Every subject recorded in the input file (config.input.mat), 
% must be specified here.
% subject(n).info   - any information concerning subject n. 
%                    'info' is a cell array of strings.
% subject(n).ch.scr - row index of scr data in 'data' matrix (see above)
% subject(n).ch.mrk - row index of markers data in 'data' matrix (see above)
%                     markers are any TTL signal recorded simultaneously 
%                     with the physiological signal that indicates the  
%                     occurance of an event of interest.
config.subject(1).info={'name' 'age' 'sex'};
config.subject(1).ch.scr=1;   
config.subject(1).ch.mrk=2;

% Create another config.subject entrie, if more than one subject was
% recorded in the input file. For instance:
% config.subject(2).info={'name2' 'age2' 'sex2'};
% config.subject(2).ch.scr=3;   
% config.subject(2).ch.mrk=4;


%--------------------------------------------------------------------------
% ECG specific defaults
% Two programs are available for automatic R-waves detection and Graphical
% User Interface (GUI) for ecg analysis: 'joffily' and 'ecglab'.
% You can specify which one you want to use below:

config.ecg.gui = 'joffily';       % GUI
config.ecg.RR_detect = 'ecglab';  % R-waves detection


%--------------------------------------------------------------------------
% Set experiment protocol

% Trials presentation order.
% Each integer in the 'seq' vector refers to a trial type (see below).
config.exp.seq = [1 1 1 2 2 2 1 1 1 2 2 2 1 1 1 2 2 2];

% Trials type definition, where t is the number of different trials type.
% trial(t).name                     - trial n name.
% trial(t).NumMarkers               - number of markers recorded during 
%                                     trial.
% trial(t).ev(e)                    - events of interest associated with 
%                                     trial t.
% trial(t).scr.ev(e).name           - event e name.
% trial(t).scr.ev(e).onset.refmark  - number of the marker used as 
%                                     reference for event e onset.
% trial(t).scr.ev(e).onset.time     - onset time of event e relative to 
%                                     'onset.refmark' time.
% trial(t).scr.ev(e).offset.refmark - number of the marker used as 
%                                     reference for event e offset.
% trial(t).scr.ev(e).offset.time    - offset time of event e relative to 
%                                     'offset.refmark' time.
config.exp.trial(1).name = 'Neutral';
config.exp.trial(1).scr.NumMarkers = 2;
config.exp.trial(1).scr.ev(1).name = 'Fixation';
config.exp.trial(1).scr.ev(1).onset.refmark = 1;
config.exp.trial(1).scr.ev(1).onset.time = 1;
config.exp.trial(1).scr.ev(1).offset.refmark = 1;
config.exp.trial(1).scr.ev(1).offset.time = 3;
config.exp.trial(1).scr.ev(2).name = 'Picture';
config.exp.trial(1).scr.ev(2).onset.refmark = 2;
config.exp.trial(1).scr.ev(2).onset.time = 1;
config.exp.trial(1).scr.ev(2).offset.refmark = 2;
config.exp.trial(1).scr.ev(2).offset.time = 3;

config.exp.trial(2).name = 'Positive';
config.exp.trial(2).scr.NumMarkers = 2;
config.exp.trial(2).scr.ev(1).name = 'Fixation';
config.exp.trial(2).scr.ev(1).onset.refmark = 1;
config.exp.trial(2).scr.ev(1).onset.time = 1;
config.exp.trial(2).scr.ev(1).offset.refmark = 1;
config.exp.trial(2).scr.ev(1).offset.time = 3;
config.exp.trial(2).scr.ev(2).name = 'Picture';
config.exp.trial(2).scr.ev(2).onset.refmark = 2;
config.exp.trial(2).scr.ev(2).onset.time = 1;
config.exp.trial(2).scr.ev(2).offset.refmark = 2;
config.exp.trial(2).scr.ev(2).offset.time = 3;
