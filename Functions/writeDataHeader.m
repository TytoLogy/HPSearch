function out = writeDataHeader(filename, handles)
% out = writeDataHeader(filename, handles)
%
% Writes header for binary data file
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	5 Feb 2009 (SJS): file created
%	
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

% open the file for writing
% fp = fopen(datafile, 'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% time
	fwrite(fp, now, 'float32');
	
	fwrite(fp, prod(size(speakers_randperm)), 'float32');
	fwrite(fp, duration, 'float32');
	fwrite(fp, stim_delay, 'float32');
	fwrite(fp, record_duration, 'float32');
	fwrite(fp, lowfreq, 'float32');
	fwrite(fp, highfreq, 'float32');
	fwrite(fp, inchannel, 'float32');
	fwrite(fp, reps, 'float32');
	fwrite(fp, indev.Fs, 'float32');
	fwrite(fp, decifactor, 'float32');				
	fwrite(fp, outdev.Fs, 'float32');
	fileinit = 0;
% 					
% out.curvetype = protocol.curvetype;				% type of curve
% out.stimtype = protocol.stimtype					% type of stimulus
% out.nreps = protocol.nreps;						% # of reps
% out.ITDrangestr = protocol.ITDrangestr;		% ITD range
% out.ILDrangestr = protocol.ILDrangestr;		% ILD range
% out.ABIrangestr = protocol.ABIrangestr;		% ABI range
% out.FREQrangestr = protocol.FREQrangestr;		% FREQ range
% out.BCrangestr = protocol.BCrangestr;			% BC range (%)
% 
