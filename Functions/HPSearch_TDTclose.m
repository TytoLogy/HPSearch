function varargout = HPSearch_TDTclose(handles)
%------------------------------------------------------------------------
%varargout = HPSearch_TDTclose(handles)
%------------------------------------------------------------------------
% 
% Closes/shuts down TDT I/O Hardware for HPSearch program
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	handles		project handles
% 
% Output Arguments:
% 	varargout{1}	modified handles
%
%------------------------------------------------------------------------
% See also: 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad J. Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 8 October, 2009 (SJS)
%
% Revisions:
%	30 Mar 2012 (SJS): added RZ6_RZ5 case, changed email
%------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------


% Exit gracefully (close TDT objects, etc)
disp('...closing TDT devices...');
TDTINIT = TDTInitStatus(handles);

if TDTINIT
	switch(handles.config.CONFIGNAME)
		case	'MEDUSA+HEADPHONES'
			% turn off the monitor via software trigger 2
			RPtrig(handles.indev, 2);
			disp('...closing PA5L')
			handles.PA5L.status = PA5close(handles.PA5L);
			disp('...closing PA5R')
			handles.PA5R.status = PA5close(handles.PA5R);
			disp('...closing indev')
			handles.indev.status = RPclose(handles.indev);
			disp('...closing outdev')
			handles.outdev.status = RPclose(handles.outdev);
			disp('...closing zBUS')
			handles.zBUS.status = zBUSclose(handles.zBUS);
			TDTINIT = 0;
			save(handles.config.TDTLOCKFILE, 'TDTINIT');
			
		case 'RX8_IO'
			disp('...closing PA5L')
			handles.PA5L.status = PA5close(handles.PA5L);
			disp('...closing PA5R')
			handles.PA5R.status = PA5close(handles.PA5R);
			disp('...closing indev')
			handles.indev.status = RPclose(handles.indev);

			TDTINIT = 0;
			save(handles.config.TDTLOCKFILE, 'TDTINIT');
			
		case 'RX6_RZ5'
			% turn off the monitor via software trigger 2
			RPtrig(handles.indev, 2);
			disp('...closing PA5L')
			handles.PA5L.status = PA5close(handles.PA5L);
			disp('...closing PA5R')
			handles.PA5R.status = PA5close(handles.PA5R);
			disp('...closing indev')
			handles.indev.status = RPclose(handles.indev);
			disp('...closing outdev')
			handles.outdev.status = RPclose(handles.outdev);
			disp('...closing zBUS')
			handles.zBUS.status = zBUSclose(handles.zBUS);
			TDTINIT = 0;
			save(handles.config.TDTLOCKFILE, 'TDTINIT');
			
		case 'RZ6_RZ5'
			% turn off the monitor via software trigger 2
			RPtrig(handles.indev, 2);
			disp('...closing PA5L')
			handles.PA5L.status = PA5close(handles.PA5L);
			disp('...closing PA5R')
			handles.PA5R.status = PA5close(handles.PA5R);
			disp('...closing indev')
			handles.indev.status = RPclose(handles.indev);
			disp('...closing outdev')
			handles.outdev.status = RPclose(handles.outdev);
			disp('...closing zBUS')
			handles.zBUS.status = zBUSclose(handles.zBUS);
			TDTINIT = 0;
			save(handles.config.TDTLOCKFILE, 'TDTINIT');
	
		otherwise
			warning('%s: Unknown configuration string %s', mfilename, handles.config.CONFIGNAME);
	end
else
	warning([mfilename 'TDTINIT is not set!'])
end
varargout{1} = handles;
