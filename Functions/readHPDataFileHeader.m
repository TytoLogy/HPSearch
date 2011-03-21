function H = readHPDataFileHeader(fp)
% H = readHPDataFileHeader(fp)
%
% read header from binary data file from headphone data
% 
% Uses BinaryFileToolbox
% 
% Input Arguments:
% 
%	fp		file stream
%
% Output Arguments:
% 
%	H
%
% See Also: writeDataFileHeader, fopen, fwrite;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	4 Mar 2009 (SJS): file created
%	5 Mar 2009 (SJS):
% 		-moved reading of DATA_START string to readHPData, more appropriate
% 		 to do this there
% 	6 Mar 2009 (SJS):
% 		- reads in indev and outdev information
%	22 June, 2009 (SJS):
% 		-	changed to readHPDataFileHeader.m for clarity
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% check to make sure we don't have a bogus fp
if fp == -1
	% error occurred, return error code 0
	H = 0;
	return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read the header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% read the filename 
H.filename = readString(fp);

% read a string that says 'HEADER_START'
H.startstring = readString(fp);

% now read the time (use datestr(timevalue) to get human readable form)
H.time_start = readVector(fp);

% now, read the curve structure
H.curve = readStruct(fp);

% read the stim structure
H.stim = readStruct(fp);

% read the tdt structure
H.tdt = readStruct(fp);

% read the analysis structure
H.analysis = readStruct(fp);

% read the calibration data struct (caldata)
H.caldata = readStruct(fp);

% read the indev structure
H.indev = readStruct(fp);

% read the outdev data struct (outdev)
H.outdev = readStruct(fp);

% read a string that says 'HEADER_END'
H.endstring = readString(fp);
