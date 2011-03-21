% HPSearch_ProtocolConfigure.m
%------------------------------------------------------------------------
% 
% Script that sets up protocols and settings
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 2 December, 2009
%
% Revisions:
%------------------------------------------------------------------------
% To Do:
%------------------------------------------------------------------------

% build the default proctocol filename from the users protocol path 
% (defined in HPSearch_Configuration.m)
defaultprotocol = [handles.config.TYTOLOGY_PROTOCOL_PATH 'Default_protocol.mat'];

% check if the default protocol path exists
pstatus = exist(handles.config.TYTOLOGY_PROTOCOL_PATH, 'dir');

if ~pstatus
	% build the default protocol library
	disp(' ');
	disp('*************************************************************')
	disp('HPSearch could not find user protocol directory:');
	disp(['     ' handles.config.TYTOLOGY_PROTOCOL_PATH]);
	disp('*************************************************************')
	disp(' ');
	
	disp(['Building protocol library for user: ' username]);
	
	if ~exist(handles.config.TYTOLOGY_SETTINGS_PATH, 'dir')
		disp(['...creating TytoSettings directory: ' handles.config.TYTOLOGY_SETTINGS_PATH]);
		status = mkdir(handles.config.TYTOLOGY_SETTINGS_PATH);
		disp(['... status = ' num2str(status)])
		disp(' ')
	end
	
	disp(['...creating Protocols directory: ' handles.config.TYTOLOGY_PROTOCOL_PATH]);
	status = mkdir(handles.config.TYTOLOGY_PROTOCOL_PATH);
	disp(['... status = ' num2str(status)])
	disp(' ')

	
	disp(['...copying Default_protocol.mat to Protocols directory...']);
	tpath = [handles.config.TYTOLOGY_ROOT_PATH 'main\Experiments\HPSearch\'];
	dfile = [tpath 'Protocols\Default_protocol.mat'];
	disp(['...source file: ' dfile]);
	disp(['...destination: ' handles.config.TYTOLOGY_PROTOCOL_PATH]);
	status = copyfile(dfile, handles.config.TYTOLOGY_PROTOCOL_PATH);
	disp(['... status = ' num2str(status)])
	disp(' ')	
end

% load the protocol if it exists
if exist(defaultprotocol, 'file')
	tmp = load(defaultprotocol, '-MAT');
	handles.protocol = tmp.protocol;
	tmpcurve = updateUIFromProtocol(handles, handles.protocol);
	handles.curve = curveUpdateFromUI(handles);
	handles.ProtoDataLoaded = 1;
else
	handles.ProtoDataLoaded = 0;
end

	
	
