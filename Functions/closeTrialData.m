function out = closeTrialData(datafile, time_end)
% out = closeTrialData(datafile, time_end)
%
% Closes trial data for binary data file
% 
% Uses BinaryFileToolbox
% 
% Input Arguments:
% 
%	datafile
%
% Output Arguments:
%
% 	out
% 	
% See Also: writeTrialData, fopen, fwrite;
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
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% get the finish time
if nargin ==1
	time_end = now;
	out = time_end;
end

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

% write the END string
s = writeString(fp, 'DATA_END');

% write the time
s = writeVector(fp, time_end, 'double');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fclose(fp);


