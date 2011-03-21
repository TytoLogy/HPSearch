function out = writeTrialData(datafile, datatrace, dataID, trialNumber, repNumber)
% out = writeTrialData(datafile, datatrace, dataID, trialNumber, repNumber)
%
% Writes trial data for binary data file
% 
% Uses BinaryFileToolbox
% 
% Input Arguments:
% 
%	datafile
% 	datatrace
% 	dataID
% 	trialNumber
% 	repNumber
%
% Output Arguments:
%
% 	out
% 	
% See Also: readTrialData, fopen, fwrite;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	5 Mar 2009 2009 (SJS): file created
%--------------------------------------------------------------------------
% TO DO:
%	*Documentation!!!!
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% get the start time
time_start = now;

% open the file for appending
fp = fopen(datafile, 'a');

% check to make sure this worked
if fp == -1
	% error occurred, return error code -1
	out = -1;
	return
else
	out = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the trial header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% write the dataID
s = writeVector(fp, dataID, 'double');

% write the trial Number
s = writeVector(fp, trialNumber, 'int32');

% write the rep number
s = writeVector(fp, repNumber, 'int32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% write the datatrace (multiplexed if multichannel!)
s = writeVector(fp, datatrace, 'double');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fclose(fp);


