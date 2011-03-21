function handles = HPSearch_maskEnable(handles)
%------------------------------------------------------------------------
% handles = HPSearch_maskEnable(handles)
%------------------------------------------------------------------------
% 
% Enables or disables masking noise output
%
%------------------------------------------------------------------------
% Input Arguments:
% 	Value:		Type:			Description:
% 	handles		struct		handles structure
% 					
% Output Arguments:
% 	out			handles
% 
%------------------------------------------------------------------------
% See also: HPSearch, HPSearch_tdtinit
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 27 January, 2010
%
% Revisions:
%	2 Feb 2010 (SJS):	fixed RPsettag calls that were using outdev instead of
%							handles.outdev
%------------------------------------------------------------------------

% check if mask enable is possible given current output device
% settings (determined in handles.config.OUTDEV)
if ~strcmp(handles.config.OUTDEV, 'OUTDEV:HEADPHONES+MASKER')
	warning([mfilename ': masking feature is unsupported in current TDT configuration'])
	return;
end

if handles.tdt.MaskEnable
	% enable masker
	RPsettag(handles.outdev, 'MaskAmp', handles.tdt.MaskAmp);
	RPsettag(handles.outdev, 'MaskChannel', handles.tdt.MaskChannel);
	% send soft trig 4 to turn on masking noise output
	RPtrig(handles.outdev, 4);
else
	% send soft trig 5 to turn off masking noise output
	RPtrig(handles.outdev, 5);
	pause(0.1);
end


