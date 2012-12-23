function varargout = HPSearch_TDTopen(handles)
%------------------------------------------------------------------------
%varargout = HPSearch_TDTopen(handles)
%------------------------------------------------------------------------
% 
%--- Initializes TDT I/O Hardware ----------------------------------------
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	handles		project handles
% 
% Output Arguments:
% 	modified handles
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
%	13 Oct 2009 (SJS): updated documentation
%	30 Mar 2012 (SJS): added RZ6_RZ5 for new RosenLab setup, updated email
%------------------------------------------------------------------------
% TO DO:
%------------------------------------------------------------------------

% TDTINIT_FORCE is usually 0, unless user chooses 'RESTART' if TDTINIT is 
% set in the .tdtlock.mat file
TDTINIT_FORCE = 0;

% Start the TDT circuits
disp('...starting TDT hardware...');

% check if the lock variable (TDTINIT) in .tdtlock.mat lockfile is set
if ~exist(handles.config.TDTLOCKFILE, 'file')
	warning('%s: could not find TDT lock file %s', mfilename, handles.config.TDTLOCKFILE)
	disp('Creating it, assuming TDT HW is not initialized');
	TDTINIT = 0;
	save(handles.config.TDTLOCKFILE, 'TDTINIT');
else
	% load the lock information
	load(handles.config.TDTLOCKFILE);
end

% check TDT INIT status
if TDTINIT
	questStr = {'Strange... TDTINIT already set in .tdtlock.mat', ...
					'TDT Hardware might be active.', ...
					'Continue, Restart TDT Hardware, or Abort?'};
	respStr = questdlg(questStr, 'HPSearch: TDTINIT error', 'Continue', 'Restart', 'Abort', 'Abort');
	
	switch upper(respStr)
		case 'CONTINUE'
			disp([mfilename ': continuing anyway...'])
			% return handles that were passed in
			varargout{1} = handles;
			return
				
		case 'ABORT'
			disp([mfilename ': aborting...'])
			% return empty
			varargout{1} = [];
			return

		case 'RESTART'
			disp([mfilename ': starting TDT hardware...'])
			TDTINIT_FORCE = 1;
	end
	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if TDTINIT is not set (TDT hardware not initialized) OR if
% TDTINIT_FORCE is set, initialize TDT hardware
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~TDTINIT || TDTINIT_FORCE

	disp([mfilename ': Configuration = ' handles.config.CONFIGNAME])
	
	% different initialization depending on hardware configuration
	switch(handles.config.CONFIGNAME)

		case	'MEDUSA+HEADPHONES'
			try
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize zBus control
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting zBUS...')
				tmpdev = zBUSinit('GB');
				handles.zBUS.C = tmpdev.C;
				handles.zBUS.handle = tmpdev.handle;
				handles.zBUS.status = tmpdev.status;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize RX5/Medusa
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting Medusa...')
				tmpdev = RX5init('GB');
				handles.indev.C = tmpdev.C;
				handles.indev.handle = tmpdev.handle;
				handles.indev.status = tmpdev.status;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize RX8_2
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting RX8 for headphone output...')
				tmpdev = RX8init('GB', handles.outdev.Dnum);
				handles.outdev.C = tmpdev.C;
				handles.outdev.handle = tmpdev.handle;
				handles.outdev.status = tmpdev.status;
				
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize Attenuators
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.PA5L = PA5init('GB', 1, read_ui_val(handles.Latten));
				handles.PA5R = PA5init('GB', 2, read_ui_val(handles.Ratten));
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Loads circuits
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.indev.status = RPload(handles.indev);
				handles.outdev.status = RPload(handles.outdev);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Starts Circuits
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				inStatus = RPrun(handles.indev);
				outStatus = RPrun(handles.outdev);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Get circuit information
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% get the input and output sampling rates
				handles.outdev.Fs = RPsamplefreq(handles.outdev);
				handles.indev.Fs = RPsamplefreq(handles.indev);
				% get the tags and values for the circuits
				tmptags = RPtagnames(handles.outdev);
				handles.outdev.TagName = tmptags;				
				tmptags = RPtagnames(handles.indev);
				handles.indev.TagName = tmptags;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% set the lock
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
				TDTINIT = 1;
			catch
				TDTINIT = 0;
				disp([mfilename ': error starting TDT hardware'])
				err = lasterror
				disp(err.message);
				disp(err.identifier);
				disp(err.stack);
			end
			% save TDTINIT in lock file
			save(handles.config.TDTLOCKFILE, 'TDTINIT');

		case 'RX8_IO'
			try
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize zBus control
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting zBUS...')
				handles.zBUS = [];
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize RX8_2
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting RX8 for headphone output & spike input...')
				tmpdev = RX8init('GB', handles.indev.Dnum);
				handles.indev.C = tmpdev.C;
				handles.indev.handle = tmpdev.handle;
				handles.indev.status = tmpdev.status;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize Attenuators
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.PA5L = PA5init('GB', 1, read_ui_val(handles.Latten));
				handles.PA5R = PA5init('GB', 2, read_ui_val(handles.Ratten));
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Loads circuits
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.indev.status = RPload(handles.indev);
				handles.outdev.status = handles.indev.status;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Starts Circuits
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				RPrun(handles.indev);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Get circuit information (sample rate)
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.outdev.Fs = RPsamplefreq(handles.indev);
				handles.indev.Fs = RPsamplefreq(handles.indev);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% set the lock
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				TDTINIT = 1;
			catch
				TDTINIT = 0;
				disp([mfilename ': error starting TDT hardware'])
				disp(LASTERR);
			end
			% save TDTINIT in lock file
			save(handles.config.TDTLOCKFILE, 'TDTINIT');
			
		%% old RosenLab setup
		case	'RX6_RZ5'
			try
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize zBus control
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting zBUS...')
				tmpdev = zBUSinit('GB');
				handles.zBUS.C = tmpdev.C;
				handles.zBUS.handle = tmpdev.handle;
				handles.zBUS.status = tmpdev.status;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize RZ5/Medusa
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting Medusa attached to RZ5...')
				tmpdev = RZ5init('GB');
				handles.indev.C = tmpdev.C;
				handles.indev.handle = tmpdev.handle;
				handles.indev.status = tmpdev.status;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize RX6_1
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting RX6 for headphone output...')
				tmpdev = RX6init('GB', handles.outdev.Dnum);
				handles.outdev.C = tmpdev.C;
				handles.outdev.handle = tmpdev.handle;
				handles.outdev.status = tmpdev.status;
				
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize Attenuators
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.PA5L = PA5init('GB', 1, read_ui_val(handles.Latten));
				handles.PA5R = PA5init('GB', 2, read_ui_val(handles.Ratten));
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Loads circuits
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.indev.status = RPload(handles.indev);
				handles.outdev.status = RPload(handles.outdev);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Starts Circuits
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				inStatus = RPrun(handles.indev);
				outStatus = RPrun(handles.outdev);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Get circuit information
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% get the input and output sampling rates
				handles.outdev.Fs = RPsamplefreq(handles.outdev);
				handles.indev.Fs = RPsamplefreq(handles.indev);
				% get the tags and values for the circuits
				tmptags = RPtagnames(handles.outdev);
				handles.outdev.TagName = tmptags;				
				tmptags = RPtagnames(handles.indev);
				handles.indev.TagName = tmptags;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% set the lock
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
				TDTINIT = 1;
			catch
				TDTINIT = 0;
				disp([mfilename ': error starting TDT hardware'])
				err = lasterror
				disp(err.message);
				disp(err.identifier);
				disp(err.stack);
			end
			% save TDTINIT in lock file
			save(handles.config.TDTLOCKFILE, 'TDTINIT');
	
		%% new RosenLab setup
		case	'RZ6_RZ5'
			try
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize zBus control
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting zBUS...')
				tmpdev = zBUSinit('GB');
				handles.zBUS.C = tmpdev.C;
				handles.zBUS.handle = tmpdev.handle;
				handles.zBUS.status = tmpdev.status;
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize RZ5/Medusa
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting Medusa attached to RZ5...')
				tmpdev = RZ5init('GB');
				handles.indev.C = tmpdev.C;
				handles.indev.handle = tmpdev.handle;
				handles.indev.status = tmpdev.status;

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize RZ6_1
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				disp('...starting RZ6 for loudspeaker output...')
				tmpdev = RZ6init('GB', handles.outdev.Dnum);
				handles.outdev.C = tmpdev.C;
				handles.outdev.handle = tmpdev.handle;
				handles.outdev.status = tmpdev.status;
				
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Initialize Attenuators
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.PA5L = PA5init('GB', 1, read_ui_val(handles.Latten));
				handles.PA5R = PA5init('GB', 2, read_ui_val(handles.Ratten));
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Loads circuits
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				handles.indev.status = RPload(handles.indev);
				handles.outdev.status = RPload(handles.outdev);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Starts Circuits
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				inStatus = RPrun(handles.indev);
				outStatus = RPrun(handles.outdev);
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Send zBus A and B triggers to initialize and check enable
				% status
				%	- might fix issue with fucked up sample rate
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				zBUStrigA_PULSE(handles.zBUS);
				zBUStrigB_PULSE(handles.zBUS);
				tmp = RPgettagval(handles.indev, 'Enable');
				tmp = RPgettagval(handles.outdev, 'Enable');
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Get circuit information
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% get the input and output sampling rates
				handles.outdev.Fs = RPsamplefreq(handles.outdev);
				handles.indev.Fs = RPsamplefreq(handles.indev);
				% get the tags and values for the circuits
				tmptags = RPtagnames(handles.outdev);
				handles.outdev.TagName = tmptags;				
				tmptags = RPtagnames(handles.indev);
				handles.indev.TagName = tmptags;

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% set the lock
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%				
				TDTINIT = 1;
			catch
				TDTINIT = 0;
				disp([mfilename ': error starting TDT hardware'])
				err = lasterror
				disp(err.message);
				disp(err.identifier);
				disp(err.stack);
			end
			% save TDTINIT in lock file
			save(handles.config.TDTLOCKFILE, 'TDTINIT');
			%------------------------------------------------------------------------

	end		% end of SWITCH
end
varargout{1} = handles;
