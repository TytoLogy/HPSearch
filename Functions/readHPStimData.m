function [stimdata, stiminfo] = readHPStimData(varargin)
%------------------------------------------------------------------------
% [stimdata, datainfo] = readHPStimData(varargin)
%------------------------------------------------------------------------
% 
% Reads stimulus data mat file created by the HPSearch program
%
% If a datafile name is provided in varargin (e.g.,
% readHPData('c:\mydir\mynicedata.mat'), the program will attempt to 
% read from that file.  
% 
% Otherwise it will open a dialog window for the user
% to select the matlab data (.mat) file.
% 
%------------------------------------------------------------------------
% Output Arguments:
% 
% stimdata		contains the read data in a cell structure array.
% stiminfo		has the stimulus data information.
% 
%------------------------------------------------------------------------
% See Also:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 17 Nov, 2009 (SJS)
% 		adapted from readHPData.m
% Revisions:
% 	8 December, 2009 (SJS)
% 		- major revision to account for .MAT file format
%------------------------------------------------------------------------
% TO DO:
%	*Documentation!
%--------------------------------------------------------------------------

% null data and datafile arrays
stimdata = [];
stiminfo = [];

% check if datafile given by user as input exists
if nargin
	if exist(varargin{1}) == 2
		datafile = varargin{1};
	else
		error([mfilename ': datafile ' varargin{1} ' not found.']);
	end
end

% if no datafile is found or given, then open a UIpanel to select file
if isempty(datafile)
	[datafile, datapath] = uigetfile('*_stim.mat','Select data file');
	if datafile == 0
		disp('user cancelled datafile load')
		data = [];
		datainfo = [];
		return
	end
	datafile = fullfile(datapath, datafile);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read data from file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


errflag = 0;
try,
	% read calibration data
	caldata = load(datafile, 'caldata');
catch,
	lasterror
	errflag = 1;
	return;
end

try,
	% read calibration data
	stimdata = load(datafile, 'stimcache');
catch,
	lasterror
	errflag = 1;
	return;
end
