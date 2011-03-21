function out = writeDataFileHeader(datafile, curve, stim, tdt, analysis, caldata, indev, outdev)
%--------------------------------------------------------------------------
% out = writeDataFileHeader(datafile, curve, stim, tdt, analysis, caldata, indev, outdev);
%--------------------------------------------------------------------------
%
% Writes header for binary data file
% 
% Uses BinaryFileToolbox
% 
%--------------------------------------------------------------------------
% Input Arguments:
% 
%	datafile			data file name
% 	curve				curve data structure
% 	stim				stimulus data structure
% 	tdt				tdt data structure
% 	analysis			analysis structure
% 	caldata			calibration data
% 	indev				input device structure
% 	outdev			output TDT device structure
%
% Output Arguments:
%	out				status
%--------------------------------------------------------------------------
% See Also: writeData, fopen, fwrite, BinaryFileToolbox
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	20 Feb 2009 (SJS): file created
%	4 Mar 2009 (SJS):
%		-wrote code to make this do something!
%	6 Mar 2009 (SJS):
% 		-writes indev and outdev information
% 		-eliminated PA5 and zBUS input vars - never used!
%	6 November, 2009 (SJS): updated documentation
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% get the start time
time_start = now;

% open the file for writing - create the file anew 
% (subsequent fopen() calls should use 'a' to append to file, 
%  unless you wish to destroy the data...)
fp = fopen(datafile, 'w');

% check to make sure this worked
if fp == -1
	% error occurred, return error code -1
	out = -1;
	return
else
	out = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% write the filename (may be useful in future if filename is
% changed????)
s = writeString(fp, datafile);

% write a string that says 'HEADER_START'
s = writeString(fp, 'HEADER_START');

% now write the time (use datestr(timevalue) to get human readable form)
s = writeVector(fp, time_start, 'double');

% now, write the curve structure
% ***embed the name of this and all structs***
s = writeStruct(fp, curve, 'curve');

% write the stim structure
s = writeStruct(fp, stim, 'stim');

% write the tdt structure
s = writeStruct(fp, tdt, 'tdt');

% write the analysis structure
s = writeStruct(fp, analysis, 'analysis');

% write the calibration data struct (caldata)
s = writeStruct(fp, caldata, 'caldata');

% write the indev data struct (indev)
s = writeStruct(fp, extractRPDevInfo(indev), 'indev');

% write the outdev data struct (outdev)
s = writeStruct(fp, extractRPDevInfo(outdev), 'outdev');

% write the end of the header string
s = writeString(fp, 'HEADER_END');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the beginning of the data string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
s = writeString(fp, 'DATA_START');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fclose(fp);


