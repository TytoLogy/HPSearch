% CalibrateHeadphoneMic_tdtexit.m
%
% sets up multiplexer (MPX) parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Created: January, 2008 (SJS)
%
% Revisions:
%	5 Feb 2008:	Created from FFCal_tdtinit.m
%
%	4 September, 2008:
%		-	made updates for changes in TDT functions
%	23 January, 2009 (SJS):
%		-	added code to close PA5L and PA5R
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean up the RP circuits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('...closing TDT devices...');
status = PA5close(PA5L);
status = PA5close(PA5R);
status = RPclose(iodev);

	
