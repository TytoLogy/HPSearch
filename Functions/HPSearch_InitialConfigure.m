%------------------------------------------------------------------------
%------------------------------------------------------------------------
% HPSearch_InitialConfigure.m
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% 
% Setup script that sets up initial settings for setting up the 
% HPSearch settings.  all set?
%
% As a bit of legacy, most of the initialization is handled through calls
% to the HPSearch_init.m function.  this is done to centralize the
% configuration information.  there are probably more elegant ways to do
% this, but this is what we have for the moment.
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 2 December, 2009
%
% Revisions:
%	10 March, 2010 (SJS):	added some comments to document code
%	24 Feb, 2012 (SJS):	updated email address
%------------------------------------------------------------------------
% To Do:
%------------------------------------------------------------------------

% each call to HPSearch_init() asks for a specific set of initial data
% that establishes settings for the various structures used by HPSearch

% load the limits (for stim values, etc) information 
% using the init routine
handles.Lim = HPSearch_init('Limits');

% load default stimulus parameters
handles.stim = HPSearch_init('Stimulus');

% load TDT parameters
handles.tdt = HPSearch_init(handles.config.TDT);

% load input device parameters
handles.indev = HPSearch_init(handles.config.INDEV);

% if no configuration for outdev, select headphone config, where input and
% output are on the same device
if ~isempty(handles.config.OUTDEV)
	handles.outdev = HPSearch_init(handles.config.OUTDEV);
else
	handles.outdev = handles.indev;
end

% analysis parameters
handles.analysis = HPSearch_init('ANALYSIS');

% curve parameters
handles.curve = HPSearch_init('CURVE');

% animal parameters
handles.animal = HPSearch_init('ANIMAL');

% display parameters
handles.display = HPSearch_init('DISPLAY');

% set TempData flag to 0;
handles.TempData = 0;

% initialize some variables for TDT control objects
handles.zBUS = [];
handles.PA5L = [];
handles.PA5R = [];

% handle to TDT input/output function  This is done so that the input and
% output process can be modularized and account for different setups (eg.,
% multiple devices) 
handles.iofunction = handles.config.IOFUNCTION;

% handle to TDT setup function.
handles.tdtsettingsfunction = handles.config.TDTSETFUNCTION;
