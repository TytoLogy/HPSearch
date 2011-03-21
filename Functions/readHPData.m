function [data, datainfo] = readHPData(varargin)
%------------------------------------------------------------------------
% [data, datainfo] = readHPData(varargin)
%------------------------------------------------------------------------
% 
% Reads binary data file created by the HPSearch program
%
% If a datafile name is provided in varargin (e.g.,
% readHPData('c:\mydir\mynicedata.dat'), the program will attempt to 
% read from that file.  
% 
% Otherwise it will open a dialog window for the user
% to select the data (.dat) file.
% 
%------------------------------------------------------------------------
% Output Arguments:
% 
% data			contains the read data in a cell structure array.
% datainfo		has the file header information.
% 
%------------------------------------------------------------------------
% See Also:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 5 March, 2009 (SJS) 
%			- adapted from rfrand_readdata.m
% 
% Revisions:
%	17 Nov, 2009 (SJS): added some documentation.
%	13 March, 2010 (SJS): will now demultiplex any multichannel spike
% 								spike data in data{n}.datatrace
%------------------------------------------------------------------------
% TO DO:
%	*Documentation!
%--------------------------------------------------------------------------

data = [];
datafile = [];

if nargin
	if exist(varargin{1}) == 2
		datafile = varargin{1};
	else
		error([mfilename ': datafile ' varargin{1} ' not found.']);
	end
end

if isempty(datafile)
	[datafile, datapath] = uigetfile('*.dat','Select data file');
	if datafile == 0
		disp('user cancelled datafile load')
		return
	end
	datafile = fullfile(datapath, datafile);
end


fp = fopen(datafile, 'r');

errflag = 0;
try,
	% read the header
	datainfo = readHPDataFileHeader(fp);
catch,
	lasterror
	errflag = 1;
	fclose(fp);
	return;
end

[numreps, numtrials] = size(datainfo.curve.trialRandomSequence);
nettrials = numreps*numtrials;

disp([mfilename sprintf(': reading %d reps, %d trials', numreps, numtrials)]);

try,
	% read the data start string
	datastartstring = readString(fp);
catch,
	lasterror
	errflag = 2;
	fclose(fp);
	return;
end

try,
	% read the data
	data = readTrialData(fp, nettrials);
catch,
	lasterror
	errflag = 3
	fclose(fp);
	return;
end

try,
	% read the data end string
	dataendstring = readString(fp);
catch,
	lasterror
	errflag = 4;
	fclose(fp);
	return;
end

try,
	% read the data end time
	datainfo.time_end = readVector(fp);
catch,
	lasterror
	errflag = 5;
	fclose(fp);
	return;
end

fclose(fp);

% now, demultiplex the data if there are more than 1 channel in the data
% traces
if datainfo.tdt.nChannels > 1
	nTrials = length(data)
	for n = 1:nTrials
		data{n}.datatrace = mcDeMux(data{n}.datatrace, datainfo.tdt.nChannels);
	end
end

	


