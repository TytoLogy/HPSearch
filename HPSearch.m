function varargout = HPSearch(varargin)
% HPSEARCH M-file for HPSearch.fig
%      HPSEARCH, by itself, creates a new HPSEARCH or raises the existing
%      singleton*.
%
%      H = HPSEARCH returns the handle to a new HPSEARCH or the handle to
%      the existing singleton*.
%
%      HPSEARCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HPSEARCH.M with the given input arguments.
%
%      HPSEARCH('Property','Value',...) creates a new HPSEARCH or raises the
%      existing singleton*.  
%

% Last Modified by GUIDE v2.5 21-Dec-2012 18:22:34

% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
					   'gui_Singleton',  gui_Singleton, ...
					   'gui_OpeningFcn', @HPSearch_OpeningFcn, ...
					   'gui_OutputFcn',  @HPSearch_OutputFcn, ...
					   'gui_LayoutFcn',  [] , ...
					   'gui_Callback',   []);
	if nargin && ischar(varargin{1})
		gui_State.gui_Callback = str2func(varargin{1});
	end

	if nargout
		[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
		gui_mainfcn(gui_State, varargin{:});
	end
% End initialization code - DO NOT EDIT
%--------------------------------------------------------------------------

%------------------------------------------------------------------------
%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 2006 (???)
%
% Revisions: Many....
%	26 Feb 2012 (SJS): added code to setup paths (taken from SingleMicCal.m)
%------------------------------------------------------------------------
% To Do:  Much too much...
%------------------------------------------------------------------------
%------------------------------------------------------------------------

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input/Output GUI functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% --- Executes just before HPSearch is made visible
%--------------------------------------------------------------------------
%	Moved most of the functionality into individual scripts and/or functions
%  to keep this code readable and modular.  See individual files for 
%	details
%--------------------------------------------------------------------------
function HPSearch_OpeningFcn(hObject, eventdata, handles, varargin)
	%---------------------------------------------------------------
	% Initial setup
	% ***** need to update this information!!!!!
	% This consists of a few things:
	% 	(1) check and, if necessary, set paths
	% 	(2) read in hardware configuration
	% 		
	%---------------------------------------------------------------

	%---------------------------------------------------------------
	% some constants
	%---------------------------------------------------------------
	FORCE_INITPATHS = 0;
	FORCE_CONFIGPATH = 0;

	%---------------------------------------------------------------
	% first off, need to process varargin
	%---------------------------------------------------------------
	if ~isempty(varargin)
		v = 1;
		while v <= length(varargin)
			if strcmpi(varargin{v}, 'InitPaths')
				% InitPaths was given as argument -- set the force flag to 1
				FORCE_INITPATHS = 1;
				v = v + 1;
			elseif strcmp(varargin{v}, 'AddConfigPath')
				% AddConfigPath was given - set FORCE_CONFIGPATH to 1
				FORCE_CONFIGPATH = 1;
				v = v + 1;
			else
				warning('%s: Unknown option %s', mfilename, varargin{v});
				v = v + 1;
			end
		end
	end

	%----------------------------------------------------------
	% Setup Paths
	%----------------------------------------------------------
	disp([mfilename ': checking paths'])
	% directory when using installed version:
	pdir = ['C:\TytoLogy\TytoLogySettings\' getenv('USERNAME')];
	% development tree
	% 	pdir = ['C:\Users\sshanbhag\Code\Matlab\TytoLogy\TytoLogySettings\' getenv('USERNAME')];
	
	if isempty(which('RPload')) || FORCE_INITPATHS
		% could not find the RPload.m function (which is in TytoLogy
		% toolbox) which suggests that the paths are not set or are 
		% incorrect for this setup.  load the paths using the tytopaths program.
		disp([mfilename ': loading paths using ' pdir '\tytopaths.m']);
		run(fullfile(pdir, 'tytopaths'));
		% now recheck
		if isempty(which('RPload'))
			error('%s: tried setting paths via %s, but failed.  sorry.', ...
						mfilename, fullfile(pdir, 'tytopaths.m'));
		end
	else
		% seems okay, so continue
		disp([mfilename ': paths ok, launching programn'])
	end

	% load the configuration information, store in config structure
	if isempty(which('HPSearch_Configuration')) || FORCE_CONFIGPATH
		% need to add user config path
		% orig
 		addpath(['C:\TytoLogy\TytoLogySettings\' getenv('USERNAME')]);
		% debugging/working
% 		addpath(['C:\Users\sshanbhag\Code\Matlab\TytoLogy\TytoLogySettings\' getenv('USERNAME')]);
		
	end
	
	%----------------------------------------------------------
	% load the configuration information, store in config structure
	% The HPSearch_Configuration.m function file will usually live in the
	% <tytology path>\TytoSettings\<username\ directory
	%----------------------------------------------------------
	handles.config = HPSearch_Configuration;
	% run script that processes initial configuration
	HPSearch_InitialConfigure;
	% save handles
	guidata(hObject, handles);

	%-------------------------------------
	% Load Calibration Settings
	%-------------------------------------
	HPSearch_CalibrationConfigure;
	guidata(hObject, handles);
	
	%-------------------------------------
	% load default protocol and update UI
	%-------------------------------------
	HPSearch_ProtocolConfigure;
	guidata(hObject, handles);
	
	%-------------------------------------
	% set script Data flag
	%-------------------------------------
	handles.ScriptLoaded = 0;
	handles.script = [];
	guidata(hObject, handles);
	
	%-------------------------------------
	% update the UI from the stimulus
	%-------------------------------------
	updateUIfromStim(handles, handles.stim);	
% 	handles.StimInterval = 1;
	
	%-------------------------------------
	% Update handles structure
	%-------------------------------------
	handles.output = hObject;
	guidata(hObject, handles);
	
	%---------------------------------------------------------
	% Final task is to check if the tdt lock has been set
	% if so, this might indicate that a program that 
	% uses the TDT hardware is running or has crashed without
	% cleaning up
	%---------------------------------------------------------
	% check if the file (path/name stored in handles.config.TDTLOCKFILE)
	% exists
	if exist(handles.config.TDTLOCKFILE, 'file')
		% if so, load it and check status of TDTINIT
		load(handles.config.TDTLOCKFILE)
		if TDTINIT
			% if yes, see if user wants to override
			usr_ans = query_user('ignore TDT lock');
			if usr_ans
				TDTINIT = 0;
				save(handles.config.TDTLOCKFILE, 'TDTINIT');
			else
				% otherwise, close the program
				CloseRequestFcn(hObject, [], handles)
			end
		end
	else
		% TDTLOCKFILE not found - tell user and continue
		disp('just a note: tdt lock file not found')
		disp(['     ' handles.config.TDTLOCKFILE])
		disp(' ')
	end			
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line. --------
function varargout = HPSearch_OutputFcn(hObject, eventdata, handles) 
	% Get default command line output from handles structure
	varargout{1} = handles.output;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function CloseRequestFcn(hObject, eventdata, handles)
	% check TDT hardware status
	if TDTInitStatus(handles)
		% if hardware is enabled, close the TDT interface object
		handles = HPSearch_TDTclose(handles);
		guidata(hObject, handles);
	end
	delete(hObject);
%--------------------------------------------------------------------------

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TDT Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Enables (or disables) TDT hardware
%--------------------------------------------------------------------------
function TDTEnableButton_Callback(hObject, eventdata, handles)
	% some colors for the button states - Green, Blue, Red
	ENABLECOLOR = [0.0 0.75 0.0];
	INITCOLOR = [0.0 0.0 1.0];
	DISABLECOLOR = [1.0 0.0 0.0];
	
	% get the state of the buttons
	buttonState = read_ui_val(handles.TDTEnableButton);
	
	if buttonState
		%---------------------------------------------------------
		% User pressed button to enable TDT Circuits
		%---------------------------------------------------------
		% change button to 'initialize' mode settings
		set(handles.TDTEnableButton, 'ForegroundColor', INITCOLOR);
		update_ui_str(handles.TDTEnableButton, 'initializing')
		
		% Attempt to open TDT hardware
		handlesReturned = HPSearch_TDTopen(handles);
		
		if ~isempty(handlesReturned)
			%---------------------------------------------------------
			% TDT hardware successfully started
			%---------------------------------------------------------
			handles = handlesReturned;
			guidata(hObject, handles);

			% change button to 'Running' mode settings
			update_ui_str(handles.TDTEnableButton, 'TDT Disable')
			set(handles.TDTEnableButton, 'ForegroundColor', DISABLECOLOR);
			% turn on masking noise if desired
			if strcmp(handles.config.OUTDEV, 'OUTDEV:HEADPHONES+MASKER')
				HPSearch_maskEnable(handles);
			end
		else
			%---------------------------------------------------------
			% TDT hardware startup failed
			%---------------------------------------------------------
			warning([mfilename ':HPSearch_TDTopen returned empty value for handles...']);
			warning([mfilename 'Aborting...']);
			update_ui_str(handles.TDTEnableButton, 'TDT Enable');
			set(handles.TDTEnableButton, 'ForegroundColor', ENABLECOLOR);
		end

	else
		%---------------------------------------------------------
		% User pressed button to disable (turn off) TDT Circuits
		%---------------------------------------------------------
		% turn off masking noise
		if strcmp(handles.config.OUTDEV, 'OUTDEV:HEADPHONES+MASKER')
			HPSearch_maskEnable(handles);
			pause(0.1);
		end
		% disable TDT Circuits
		update_ui_str(handles.TDTEnableButton, 'disabling')		
		handlesReturned = HPSearch_TDTclose(handles);
		update_ui_str(handles.TDTEnableButton, 'TDT Enable')
		set(handles.TDTEnableButton, 'ForegroundColor', ENABLECOLOR);

		if ~isempty(handlesReturned)
			%-------------------------------------------------------
			% TDT hardware successfully shut down
			%-------------------------------------------------------
			handles = handlesReturned;
			guidata(hObject, handles);
		else
			%-------------------------------------------------------
			% TDT hardware shutdown failure
			%-------------------------------------------------------
			warning([mfilename ':HPSearch_TDTclose returned empty value for handles...'])
			warning([mfilename 'Aborting...'])
			update_ui_str('TDT Enable');
			set(handles.TDTEnableButton, 'ForegroundColor', [0.0 0.75 0.0]);
		end
	
	end

	guidata(hObject, handles);
%--------------------------------------------------------------------------

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action button (Run, RunCurve) callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
function RunButton_Callback(hObject, eventdata, handles)
	disp('Run...')
	HPSearch_Run
	handles.data.state = read_ui_val(hObject);
	guidata(hObject,handles);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function MonitorButton_Callback(hObject, eventdata, handles)
	% Determine run state from value of button - need to do this in order to be
	% able to stop/start 
	state = read_ui_val(handles.MonitorButton);

	% if user wants to start monitor, check if tdt hardware is initialized
	if state && ~TDTInitStatus(handles)
		% HW is not initialized and user clicked the monitor button
		% (button state == 1)
		warning([mfilename ': TDT Hardware is not Initialized!'])
		disp('Cancelling monitor request...')
		% change string on button and color
		update_ui_str(hObject, 'Monitor ON');
		set(hObject, 'ForegroundColor', [0.0 0.5 0.0]);
		% set the button to 'OFF'
		update_ui_val(hObject, 0);
		% enable the Curve and Run buttons
		enable_ui(handles.CurveButton);
		enable_ui(handles.RunButton);

	elseif state == 0 && TDTInitStatus(handles)
		% HW is initialized, user clicked monitor button to OFF
		% (Button state == 0)
		disp('Turning off monitor');
		% Button was pressed to stop Run
		set(hObject, 'String', 'Monitor ON')
		set(hObject, 'ForegroundColor', [0.0 0.5 0.0]);
		update_ui_val(hObject, 0);
		RPsettag(handles.indev, 'MonitorEnable', 0);
		enable_ui(handles.CurveButton);
		enable_ui(handles.RunButton);

	elseif state && TDTInitStatus(handles)
		% HW is initialized and state == 1 (user turned on button)
		disp('Turning on monitor');
		% Button was pressed to start Monitor
		% change string on button and color
		set(hObject, 'String', 'Monitor OFF')
		set(hObject, 'ForegroundColor', [1.0 0 0.0]);
		% disable the curve and run buttons to avoid user mucking things up
		disable_ui(handles.CurveButton);
		disable_ui(handles.RunButton);
		
		% Initialize TDT hardware
		% first, update the channel number (SJS, 22 Jun 09)
		handles.analysis.channelNum = read_ui_val(handles.DisplayChannelCtrl);
		handles.tdt.MonitorChannel = handles.analysis.channelNum;
		guidata(hObject, handles);
		
		% set TDT values, get sampling rates for input (Fs(1)) and output Fs(2)
		Fs = handles.tdtsettingsfunction(handles.indev, handles.outdev, handles.tdt);
		handles.indev.Fs = Fs(1);
		handles.outdev.Fs = Fs(2);

		%-------------------------------------------------------
		% Monitor channel parameters
		%-------------------------------------------------------
		RPsettag(handles.indev, 'MonChan', handles.tdt.MonitorChannel);
		RPsettag(handles.indev, 'MonitorEnable', 1);
		RPsettag(handles.indev, 'MonGain', handles.tdt.MonitorGain);	
		guidata(hObject, handles);
	
	else
		warning([mfilename ': unknown state!'])
		disp('Cancelling monitor request...')
		update_ui_str(hObject, 'Monitor ON');
		set(hObject, 'ForegroundColor', [0.0 0.5 0.0]);
		update_ui_val(hObject, 0);
		enable_ui(handles.CurveButton);
		enable_ui(handles.RunButton);		
	end
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
% This initiates the HPCurve() function that will vary a sound parameter,
% present the sound over headphones, and record/display the response.
% Data are either saved to a tmp file or to a user-specified data file.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% NOTE: Because of the way callbacks work in Matlab GUI, every time the
% button is clicked, this function will be called.  As a result, special
% attention must be paid to the status of the program with regard to TDT
% initialization and curve running.  some complexities are minimized by
% disabling certain buttons/functions in the GUI, but this of course adds
% other concerns to keep track of!
%--------------------------------------------------------------------------
function CurveButton_Callback(hObject, eventdata, handles)
	disp('Run Curve...')
	
	% get the state of the curve button
	%	if 1, then user is starting run
	%	if 0, then user is stopping/cancelling run
	state = read_ui_val(hObject);
	
	fprintf('curve button state %d, TDTinitstatus %d', state, TDTInitStatus(handles));
	
	%------------------------------------------------------------------
	% user wants to start run, but TDT hardware is not started
	%------------------------------------------------------------------
	if state && ~TDTInitStatus(handles)
		warndlg(	{'Cannot run curve', 'TDT Hardware is not enabled!'},...
					['HPSearch Warning:', mfilename]);
				
		%re-name the curve and run buttons
		update_ui_str(handles.CurveButton, 'Run Curve');
		set(handles.CurveButton, 'ForegroundColor', [0.0 0.5 0.0]);
		enable_ui(handles.RunButton);
		enable_ui(handles.CurveButton);
		update_ui_val(handles.CurveButton, 0);
	
	%------------------------------------------------------------------
	% user wants to stop run, TDT hardware is running
	%------------------------------------------------------------------
	elseif state == 0 && TDTInitStatus(handles)		
		% Terminate the curve
		disp('Curve running!!!')
		disp('Please use cancel/pause buttons to interrupt data collection.');		
		update_ui_val(handles.CurveButton, 1);
		% 		% Terminate the curve
		% 		disp('Curve running, will stop');
		% 		%re-name the curve and run buttons
		% 		update_ui_str(handles.CurveButton, 'Run Curve');
		% 		set(handles.CurveButton, 'ForegroundColor', [0.0 0.5 0.0]);
		% 		enable_ui(handles.RunButton);
		% 		enable_ui(handles.CurveButton);
		% 		% ensure the button is "off"
		% 		update_ui_val(handles.CurveButton, 0);

	%------------------------------------------------------------------
	% user wants to run curve, TDT hardware is running, so all is well
	%------------------------------------------------------------------
	else
		disp('Starting curve...');
	
		%-------------------------------------------------------
		% relabel the curve button, 
		% change foreground color, 
		% enable the Curve button, disable Run button
		%-------------------------------------------------------
		update_ui_str(hObject, 'Running...');
		set(hObject, 'ForegroundColor', [1.0 0.0 0.0]);
		enable_ui(handles.CurveButton);
		disable_ui(handles.RunButton);
		
		%-------------------------------------------------------
		% Get animal, penetration, etc. information
		%-------------------------------------------------------
		% first, make local copy of the structure to be changed
		animal= handles.animal;
		% update date and time
		exptime = now;
		handles.exptime = exptime;
		animal.expDate = datestr(exptime, 1);
		animal.expTime = datestr(exptime, 13);
		% retrieve limits information
		anlimits = HPSearch_init('LIMITS');
		% retrieve editable fields in animal structure
		edfields = HPSearch_SettingsMenuFields('ANIMAL');
		% update settings, using current information and limit information
		animal= HPSearch_settingsUpdate(animal, anlimits, edfields);
		% if animal is non-empty, update the handles and commit changes
		if ~isempty(animal)
			handles.animal = animal;
			guidata(hObject, handles);	
		else
			disp('using default animal settings...')
			animal = handles.animal;
		end

		%-------------------------------------------------------
		% Get data filename info
		%-------------------------------------------------------
		[curvefile, curvepath] = HPCurve_buildOutputDataFileName(handles, exptime);
		if isequal(curvefile, 0)
			% user selected "cancel" on the uiputfile dialog box			
			%re-name the curve and run buttons
			update_ui_str(handles.CurveButton, 'Run Curve');
			set(handles.CurveButton, 'ForegroundColor', [0.0 0.5 0.0]);
			enable_ui(handles.RunButton);
			enable_ui(handles.CurveButton);
			update_ui_val(handles.CurveButton, 0);
			return;
		end
		
		%-------------------------------------------------------
		% Build stimulus file name (if save stimulus is requested)
		%-------------------------------------------------------
		if handles.curve.saveStim
			% break down data file name
			[pathstr, dname, ext] = fileparts(curvefile);
			% append "_stim" to the filename
			stimfile = [pathstr filesep dname '_stim' '.mat'];
			handles.curve.stimfile = stimfile;
			guidata(hObject, handles);
		end

		%-------------------------------------------------------
		% Initialize TDT hardware
		%-------------------------------------------------------
		% first, update the channel number (SJS, 22 Jun 09)
		handles.analysis.channelNum = read_ui_val(handles.DisplayChannelCtrl);
		handles.tdt.MonitorChannel = handles.analysis.channelNum;
		guidata(hObject, handles);
		
		% set TDT values via the handle to the tdtsettingsfunction()
		% then, get sampling rates for input (Fs(1)) and output Fs(2) devices
		Fs = handles.tdtsettingsfunction(handles.indev, handles.outdev, handles.tdt);
		handles.indev.Fs = Fs(1);
		handles.outdev.Fs = Fs(2);

		% update the curve settings from the UI
		handles.curve = curveUpdateFromUI(handles);

		%-------------------------------------------------------
		% create a comment parameter
		% this is a temporary thing, will need to create UI bit for this
		%-------------------------------------------------------
		handles.comment = 'comment';
		guidata(hObject, handles);

		%-------------------------------------------------------
		% Monitor channel parameters
		%-------------------------------------------------------
		RPsettag(handles.indev, 'MonChan', handles.tdt.MonitorChannel);
		RPsettag(handles.indev, 'MonitorEnable', 1);
		RPsettag(handles.indev, 'MonGain', handles.tdt.MonitorGain);	

		%-------------------------------------------------------
		% select and get the handle of the RespPlot figure in the main window
		%-------------------------------------------------------
		H.RespPlot = handles.RespPlot;
		H.Rasterplot = handles.RasterPlot;

		%-------------------------------------------------------
		% make some local copies of config structs to simplify code
		%-------------------------------------------------------
		% TDT HW things
		indev = handles.indev;
		outdev = handles.outdev;
		PA5 = {handles.PA5L handles.PA5R};
		zBUS = handles.zBUS;
		% calibration, stimulus, recording, & analysis options (thresholds)
		stim = handles.stim;
		tdt = handles.tdt;
		caldata = handles.caldata;
		analysis = handles.analysis;
		curve = handles.curve;

		%-------------------------------------------------------
		%-------------------------------------------------------
		%*************** RUN CURVE ****************************
		%-------------------------------------------------------
		% for new types of curves, edit the 
		% HPCurve_buildStimCache() function to generate the
		% appropriate stimulus type(s)
		%-------------------------------------------------------
		%-------------------------------------------------------
		
		% first build stimulus cache
		[stimcache, curve.trialRandomSequence] = ...
				HPCurve_buildStimCache(curve, stim, tdt, caldata, indev, outdev);
		
		% then run through the stimuli
		if ~isempty(stimcache)
			%-------------------------------------------------------
			% add some information to the curve struct - this is mostly 
			% so that the curve information is included when the curve 
			% struct is written to the data file header by the 
			% HPCurve_playCache function
			%-------------------------------------------------------
			% randomized sequence for stimuli
			curve.trialRandomSequence = stimcache.trialRandomSequence;
			% version code for data file
			curve.dataVersion = HPSearch_init('DATAVERSION');
	
			% save stimulus cache as a mat file if saveStim is selected
			if curve.saveStim
				disp(['Writing stimulus cache to MAT file ' stimfile])
 				save(stimfile, 'stimcache', 'caldata', '-MAT')
			end
			
			% get the date and time
			time_start = now;
			
			% Call HPCurve_playCache to play the stimuli and record response
			curvedata = HPCurve_playCache(stimcache, curvefile, ...
													curve, stim, tdt, analysis, caldata, ...
													indev, outdev, PA5, zBUS, ...
													handles.iofunction, ...
													H.RespPlot, H.Rasterplot, handles.FeedbackText);
			% get the finish time
			time_end = now;

		else 
			curvedata = [];
		end

		%-------------------------------------------------------
		% if we have data, then save curve info
		%-------------------------------------------------------
		if ~isempty(curvedata) && (curvedata.cancelFlag == 0);
			% first, build the curvesettings structure from the various
			% settings structs used in HPSearch
			curvesettings.curve = curve;
			curvesettings.stim = stim;
			curvesettings.tdt = tdt;
			curvesettings.analysis = analysis;
			curvesettings.caldata = caldata;
			% store start and stop times as strings
			curvesettings.time_start = datestr(time_start);
			curvesettings.time_stop = datestr(time_end);
			
			% remove the stimulus traces from the stimcache and add to
			% curvesettings struct
			curvesettings.stimcache = rmfield(stimcache, 'Sn');

			% extract the file name parts from the filename
			[nullpath, curvename, nullext] = fileparts(curvefile);

			% build the curve settings file path
			curvesettingsfile = fullfile(curvepath, [curvename '.mat']);
			
			% save the curvesettings struct (has curve information)
			% and the curvedata struct (has curve data spike counts
			% but NO RAW DATA!).  
			% IMPORTANT: remember that the data in curve data
			% are already sorted into a [# of test values X # of reps] array
			save(curvesettingsfile, '-MAT', 'curvesettings', 'curvedata');			
			
			%-------------------------------------------------------
			% Plot Curve
			%-------------------------------------------------------
			figure
			errorbar(curvedata.depvars_sort, ...
								mean(curvedata.spike_counts'), ...
								std(curvedata.spike_counts'), 'bo-');
			xlabel(curve.curvetype);
			ylabel('# spikes per stimulus');
			title({curve.curvetype})
			drawnow

		% if not, throw a warning
		else
			if curvedata.cancelFlag
				warning('User (you?) cancelled curve data collection.');
			else
				warning('Error in running HPCurve, sorry.  really.  I am.');
			end
		end

		% save handle info
		guidata(hObject, handles);

		%-------------------------------------------------------
		%re-enable the curve and run buttons
		%-------------------------------------------------------
		update_ui_str(hObject, 'Run Curve');
		set(hObject, 'ForegroundColor', [0.0 0.5 0.0]);
		enable_ui(handles.RunButton);
		enable_ui(handles.CurveButton);
		guidata(hObject, handles);

	end
%--------------------------------------------------------------------------

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks for Curve controls
%
%	These are the front panel controls in the Curve subsection that are used
%	to run curves (e.g., ITD, ILD, Freq resp...)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for numerical values, the general procedure (with some exceptions) is:
%	1)	check to make sure it's a number! these things can be entered
% 		as strings and users can and will misbehave...
% 	2)	check if the requested value or range lies within the limits set
% 		in handles.Lim (initialized by call to HPSearch_init)
% 	3)	if not, revert to old setting and give a warning
% 		if so, update the values in handles.curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in cCurveTypeCtrl.
function cCurveTypeCtrl_Callback(hObject, eventdata, handles)
% 	% store the curve type before updating
% 	oldCurveType = handles.curve.curvetype;

	% get the Curve Types String (cell array)
	curveTypes = read_ui_str(hObject);
	% retrieve the curve type string that is selected
	selectedCurveString = upper(curveTypes{read_ui_val(hObject)});
	switch selectedCurveString
		case 'ITD'
			disp('ITD curve selected');
			handles.curve.curvetype = 'ITD';
			guidata(hObject, handles);
		case 'ILD'
			disp('ILD curve selected');
			handles.curve.curvetype = 'ILD';
			guidata(hObject, handles);
		case 'FREQ'
			disp('FREQ curve selected');
			handles.curve.curvetype = 'FREQ';
			guidata(hObject, handles);
		case 'BC'
			disp('BC (Binaural Correlation) curve selected');
			handles.curve.curvetype = 'BC';
			guidata(hObject, handles);
		case 'ABI'
			disp('ABI (Average Binaural Intensity) curve selected');
			handles.curve.curvetype = 'ABI';
			guidata(hObject, handles);
		case 'SAM_PERCENT'
			disp('sAM Pct (sinusoidally amp. modulation percent) curve selected');
			handles.curve.curvetype = 'SAM_PERCENT';
			guidata(hObject, handles);
		case 'SAM_FREQ'
			disp('sAM Freq (sinusoidally amp. modulation frequency) curve selected');
			handles.curve.curvetype = 'SAM_FREQ';
			guidata(hObject, handles);
	end
%--------------------------------------------------------------------------


% --- Executes on selection change in cStimulusTypeCtrl.
function cStimulusTypeCtrl_Callback(hObject, eventdata, handles)
	% get the Stimulus Types String (cell array)
	stimTypes = read_ui_str(hObject);
	% retrieve the stim type string that is selected
	selectedStimString = upper(stimTypes{read_ui_val(hObject)});
	% update curve settings
	switch selectedStimString
		case 'NOISE'
			disp('Noise selected');
			handles.curve.stimtype = 'NOISE';
			guidata(hObject, handles);
		case 'TONE'
			disp('Tone selected');
			handles.curve.stimtype = 'TONE';
			guidata(hObject, handles);
	end
%--------------------------------------------------------------------------

%-------------------------------------------------------------------------
function TempDataCtrl_Callback(hObject, eventdata, handles)
	% read the value of the object (checkbox)
	handles.TempData = read_ui_val(hObject);
	handles.curve.TempData = handles.TempData;
	% store the handles structure
	guidata(hObject, handles);
	% change font weight
	update_checkbox(hObject);
%-------------------------------------------------------------------------

% --- Executes on button press in SaveStimCtrl.
function SaveStimCtrl_Callback(hObject, eventdata, handles)
	% read the value of the object (checkbox)
	handles.curve.saveStim = read_ui_val(hObject);
	% store the handles structure
	guidata(hObject, handles);
	% change font weight
	update_checkbox(hObject);
%-------------------------------------------------------------------------

% --- Executes on button press in RadVaryCtrl.
function RadVaryCtrl_Callback(hObject, eventdata, handles)
	% read the value of the object (checkbox)
	handles.curve.RadVary = read_ui_val(hObject);
	handles.stim.RadVary = handles.curve.RadVary;
	% store the handles structure
	guidata(hObject, handles);
	% change font weight
	update_checkbox(hObject);
%-------------------------------------------------------------------------

% --- Executes on button press in FreezeStimCtrl.
function FreezeStimCtrl_Callback(hObject, eventdata, handles)
	% read the value of the object (checkbox)
	handles.curve.freezeStim = read_ui_val(hObject);
	handles.stim.freezeStim = handles.curve.freezeStim;
	% store the handles structure
	guidata(hObject, handles);	% change font weight
	% change font weight
	update_checkbox(hObject);
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
function cNreps_Callback(hObject, eventdata, handles)
	% convert to integer
	tmp = round(read_ui_str(hObject, 'n'));
	% check if in bounds
	if checkCurveLimits(tmp, handles.Lim.Nreps)
		% save if it is
		handles.curve.nreps = tmp;
		guidata(hObject, handles);
	else
		% otherwise, slap the user and reset the value to old (presumably
		% good) setting
		warndlg(sprintf('# Reps out of bounds [%d - %d]', ... 
					handles.Lim.Nreps(1), handles.Lim.Nreps(2)), mfilename);
		update_ui_str(hObject, handles.curve.nreps);
	end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function cITDrange_Callback(hObject, eventdata, handles)
	tmpstr = read_ui_str(hObject);
	% evaluate the string to generate the ITD array
	tmparr = eval(tmpstr);
	% check if numeric
	if ~isnumeric(tmparr(1))
		% if something goes bad with creating tmparr, abort
		warndlg('bad ITDrange string', mfilename)
		% revert to old string (presumably valid!)
		update_ui_str(handles.curve.ITDrangestr);
		return
	end
	
	% so it's numeric.  Is it in bounds?
	if checkCurveLimits(tmparr, handles.Lim.ITD)
		% save if it is
		handles.curve.ITDrangestr = tmpstr;
		handles.curve.ITDrange = tmparr;
		% update # of trials based on # of elements in curve variable
		if strcmpi(handles.curve.curvetype, 'ITD')
			handles.curve.nTrials = length(handles.curve.ITDrange);
		end
		guidata(hObject, handles);
	else
		% otherwise, slap the user and reset the value to old 
		% (presumably good) setting
		warndlg(sprintf('ITD range out of bounds [%d - %d]', ... 
					handles.Lim.ITD(1), handles.Lim.ITD(2)), mfilename);
		update_ui_str(hObject, handles.curve.ITDrangestr);
	end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function cILDrange_Callback(hObject, eventdata, handles)
	tmpstr = read_ui_str(hObject);
	% evaluate the string to generate the ILD array
	tmparr = eval(tmpstr);
	% check if numeric
	if ~isnumeric(tmparr(1))
		% if something goes bad with creating tmparr, abort
		warndlg('bad ILD range string', mfilename)
		% revert to old string (presumably valid!)
		update_ui_str(handles.curve.ILDrangestr);
		return
	end
	% so it's numeric.  Is it in bounds?
	if checkCurveLimits(tmparr, handles.Lim.ILD)
		% save if it is
		handles.curve.ILDrangestr = tmpstr;
		handles.curve.ILDrange = tmparr;
		% update # of trials based on # of elements in curve variable
		if strcmpi(handles.curve.curvetype, 'ILD')
			handles.curve.nTrials = length(handles.curve.ILDrange);
		end
		guidata(hObject, handles);
	else
		warndlg(sprintf('ILD range out of bounds [%d - %d]', ... 
					handles.Lim.ILD(1), handles.Lim.ILD(2)), mfilename);
		update_ui_str(hObject, handles.curve.ILDrangestr);
	end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function cABIrange_Callback(hObject, eventdata, handles)
	tmpstr = read_ui_str(hObject);
	tmparr = eval(tmpstr);
	if ~isnumeric(tmparr(1))
		warndlg('bad ABIrange string', mfilename)
		update_ui_str(handles.curve.ABIrangestr);
		return
	end
	if checkCurveLimits(tmparr, handles.Lim.ABI)
		handles.curve.ABIrangestr = tmpstr;
		handles.curve.ABIrange = tmparr;
		% update # of trials based on # of elements in curve variable
		if strcmpi(handles.curve.curvetype, 'ABI')
			handles.curve.nTrials = length(handles.curve.ABIrange);
		end
		guidata(hObject, handles);
	else
		warndlg(sprintf('ITD range out of bounds [%d - %d]', ... 
					handles.Lim.ABI(1), handles.Lim.ABI(2)), mfilename);
		update_ui_str(hObject, handles.curve.ABIrangestr);
	end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function cFREQrange_Callback(hObject, eventdata, handles)
	tmpstr = read_ui_str(hObject);
	tmparr = eval(tmpstr);
	if ~isnumeric(tmparr(1))
		warndlg('bad Freq range string', mfilename)
		update_ui_str(handles.curve.FREQrangestr);
		return
	end
	if checkCurveLimits(tmparr, handles.Lim.F)
		handles.curve.FREQrangestr = tmpstr;
		handles.curve.FREQrange = tmparr;
		% update # of trials based on # of elements in curve variable
		if strcmpi(handles.curve.curvetype, 'FREQ')
			handles.curve.nTrials = length(handles.curve.FREQrange);
		end
		guidata(hObject, handles);
	else
		warndlg(sprintf('Freq range out of bounds [%d - %d]', ... 
					handles.Lim.F(1), handles.Lim.F(2)), mfilename);
		update_ui_str(hObject, handles.curve.FREQrangestr);
	end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function cBCrange_Callback(hObject, eventdata, handles)
	tmpstr = read_ui_str(hObject);
	tmparr = eval(tmpstr);
	if ~isnumeric(tmparr(1))
		warndlg('bad BC range string', mfilename)
		update_ui_str(handles.curve.BCrangestr);
		return
	end
	if checkCurveLimits(tmparr, handles.Lim.BC)
		handles.curve.BCrangestr = tmpstr;
		handles.curve.BCrange = tmparr;
		% update # of trials based on # of elements in curve variable
		if strcmpi(handles.curve.curvetype, 'BC')
			handles.curve.nTrials = length(handles.curve.BCrange);
		end
		guidata(hObject, handles);
	else
		warndlg(sprintf('BC range out of bounds [%d - %d]', ... 
					handles.Lim.BC(1), handles.Lim.BC(2)), mfilename);
		update_ui_str(hObject, handles.curve.BCrangestr);
	end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function csAMPCTrange_Callback(hObject, eventdata, handles)
	tmpstr = read_ui_str(hObject);
	tmparr = eval(tmpstr);
	if ~isnumeric(tmparr(1))
		warndlg('bad sAM Percent range string', mfilename)
		update_ui_str(handles.curve.sAMPCTrangestr);
		return
	end
	if checkCurveLimits(tmparr, handles.Lim.BC)
		handles.curve.sAMPCTrangestr = tmpstr;
		handles.curve.sAMPCTrange = tmparr;
		% update # of trials based on # of elements in curve variable
		if strcmpi(handles.curve.curvetype, 'SAM_PERCENT')
			handles.curve.nTrials = length(handles.curve.sAMPCTrange);
		end
		guidata(hObject, handles);
	else
		warndlg(sprintf('sAM Percent range out of bounds [%d - %d]', ... 
					handles.Lim.sAMPercent(1), handles.Lim.sAMPercent(2)), mfilename);
		update_ui_str(hObject, handles.curve.sAMPCTrangestr);
	end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function csAMFREQrange_Callback(hObject, eventdata, handles)
	tmpstr = read_ui_str(hObject);
	tmparr = eval(tmpstr);
	if ~isnumeric(tmparr(1))
		warndlg('bad sAM Frequency range string', mfilename)
		update_ui_str(handles.curve.sAMFREQrangestr);
		return
	end
	if checkCurveLimits(tmparr, handles.Lim.sAMFreq)
		handles.curve.sAMFREQrangestr = tmpstr;
		handles.curve.sAMFREQrange = tmparr;
		% update # of trials based on # of elements in curve variable
		if strcmpi(handles.curve.curvetype, 'SAM_FREQ')
			handles.curve.nTrials = length(handles.curve.sAMFREQrange);
		end
		guidata(hObject, handles);
	else
		warndlg(sprintf('sAM Frequency range out of bounds [%d - %d]', ... 
					handles.Lim.sAMFreq(1), handles.Lim.sAMFreq(2)), mfilename);
		update_ui_str(hObject, handles.curve.sAMFREQrangestr);
	end
%--------------------------------------------------------------------------


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks for front panel controls: SOUND
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in SearchStimulusTypeCtrl.
function SearchStimulusTypeCtrl_Callback(hObject, eventdata, handles)
	% get the Search Stim String (cell array)
	stimTypes = read_ui_str(hObject);
	% retrieve the search stim  type string that is selected
	stimString = upper(stimTypes{read_ui_val(hObject)});
	switch stimString
		case 'NOISE'
			disp('Noise search stimulus selected');
			handles.stim.type = 'NOISE';
			guidata(hObject, handles);
		case 'TONE'
			disp('Tone search stimulus selected');
			handles.stim.type = 'TONE';
			guidata(hObject, handles);
		case 'SAM'
			disp('sAM search stimulus selected');
			handles.stim.type = 'SAM';
			guidata(hObject, handles);
	end
	% change UI to suit type of stim
	sAMhandles = get(handles.sAMPanel, 'Children');
	switch stimString
		case {'NOISE', 'TONE'}
			for n = 1:length(sAMhandles)
				hide_uictrl(sAMhandles(n));
			end
			set(handles.sAMPanel, 'Visible', 'off');
			set(handles.lsAMPercent, 'Visible', 'off');
			set(handles.lsAMFreq, 'Visible', 'off');
		case 'SAM'
			for n = 1:length(sAMhandles)
				show_uictrl(sAMhandles(n));
			end
			set(handles.sAMPanel, 'Visible', 'on');
			set(handles.lsAMPercent, 'Visible', 'on');
			set(handles.lsAMFreq, 'Visible', 'on');
	end
%--------------------------------------------------------------------------

% LEFT Attenuator slider + text -------------------------------------------
function Latten_Callback(hObject, eventdata, handles)
	handles.stim.Latten = slider_update(handles.Latten, handles.LAttentext, '%.1f');
	guidata(hObject, handles);
function LAttentext_Callback(hObject, eventdata, handles)
	handles.stim.Latten = text_update(handles.LAttentext, handles.Latten, handles.Lim.Latten, '%.1f');
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% RIGHT Attenuator slider + text ------------------------------------------
function Ratten_Callback(hObject, eventdata, handles)
	handles.stim.Ratten = slider_update(handles.Ratten, handles.RAttentext, '%.1f');
	guidata(hObject, handles);
function RAttentext_Callback(hObject, eventdata, handles)
	handles.stim.Ratten = text_update(handles.RAttentext, handles.Ratten, handles.Lim.Ratten, '%.1f');
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% ILD slider + text -------------------------------------------------------
function ILD_Callback(hObject, eventdata, handles)
	handles.stim.ILD = slider_update(handles.ILD, handles.ILDtext, '%.1f');
	guidata(hObject, handles);
function ILDtext_Callback(hObject, eventdata, handles)
	handles.stim.ILD = text_update(handles.ILDtext, handles.ILD, handles.Lim.ILD, '%.1f');
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% ITD slider + text -------------------------------------------------------
function ITD_Callback(hObject, eventdata, handles)
	handles.stim.ITD = slider_update(handles.ITD, handles.ITDtext);
	guidata(hObject, handles);
function ITDtext_Callback(hObject, eventdata, handles)
	handles.stim.ITD = text_update(handles.ITDtext, handles.ITD, handles.Lim.ITD);
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% ABI slider + text -------------------------------------------------------
function ABI_Callback(hObject, eventdata, handles)
	handles.stim.ABI = slider_update(handles.ABI, handles.ABItext);
	guidata(hObject, handles);
function ABItext_Callback(hObject, eventdata, handles)
	handles.stim.ABI = text_update(handles.ABItext, handles.ABI, handles.Lim.ABI);
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% BinauralCorrelation slider + text --------------------------------------
function BC_Callback(hObject, eventdata, handles)
	handles.stim.BC = slider_update(handles.BC, handles.BCtext);
	guidata(hObject, handles);
function BCtext_Callback(hObject, eventdata, handles)
	handles.stim.BC = text_update(handles.BCtext, handles.BC, handles.Lim.BC);
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% FREQUENCY slider + text -------------------------------------------------
function F_Callback(hObject, eventdata, handles)
% a few caveats with the frequency control:
% 1) max and min F will depend on BW (bandwidth) AND calibration max and min
	handles.stim.F = slider_update(handles.F, handles.Ftext);
	
	if sum(strcmpi(handles.stim.type, {'NOISE', 'SAM'}))
		maxF = floor(handles.stim.F + handles.stim.BW/2);
		minF = ceil(handles.stim.F - handles.stim.BW/2);
		
		if minF < handles.Lim.F(1)
			warning([mfilename ': min Freq is too low, using lowest possible setting']);
			minF = handles.Lim.F(1);
		end
		
		if maxF > handles.Lim.F(2)
			warning([mfilename ': max Freq is too high, using highest possible setting']);
			maxF = handles.Lim.F(2);
		end
		
		update_ui_str(handles.FreqMaxtext, maxF);
		update_ui_str(handles.FreqMintext, minF);
	else
		update_ui_str(handles.FreqMaxtext, round(handles.stim.F));
		update_ui_str(handles.FreqMintext, round(handles.stim.F));		
	end
	guidata(hObject, handles);
%--------------------------------------------------------------------------
function Ftext_Callback(hObject, eventdata, handles)
	handles.stim.F = text_update(handles.Ftext, handles.F, handles.Lim.F);
	
	if sum(strcmpi(handles.stim.type, {'NOISE', 'SAM'}))
		maxF = floor(handles.stim.F + handles.stim.BW/2);
		minF = ceil(handles.stim.F - handles.stim.BW/2);
		if minF < handles.Lim.F(1)
			warning([mfilename ': min Freq is too low, using lowest possible setting']);
			minF = handles.Lim.F(1);
		end
		if maxF > handles.Lim.F(2)
			warning([mfilename ': max Freq is too high, using highest possible setting']);
			maxF = handles.Lim.F(2);
		end		
		update_ui_str(handles.FreqMaxtext, maxF);
		update_ui_str(handles.FreqMintext, minF);
	else
		update_ui_str(handles.FreqMaxtext, round(handles.stim.F));
		update_ui_str(handles.FreqMintext, round(handles.stim.F));		
	end
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% BandWidth slider and text -----------------------------------------------
function BW_Callback(hObject, eventdata, handles)
	% get slider value
	tmpbw = slider_update(handles.BW, handles.BWtext);
	% compute temp. upper and lower freq bounds
	tmpfmin = ceil(handles.stim.F - (tmpbw/2) );
	tmpfmax = floor(handles.stim.F + (tmpbw/2) );
	% get limits of frequency values (if calibration data are loaded)
	if isfield(handles, 'caldata')
		Bounds = [handles.caldata.freq(1) handles.caldata.freq(end)];
	else
		Bounds = handles.Lim;
	end		

	% check lower bound
	if ~between(tmpfmin, Bounds(1), Bounds(2))
		disp('BW out of range, using min freq possible')
		tmpfmin = Bounds(1);
		tmpbw = tmpfmax - tmpfmin;
	end
	if ~between(tmpfmax, Bounds(1), Bounds(2))
		disp('BW out of range, using max freq possible')
		tmpfmax = Bounds(2);
		tmpbw = tmpfmax - tmpfmin;
	end
	
	handles.stim.BW = tmpbw;
	handles.stim.Flo = tmpfmin;
	handles.stim.Fhi = tmpfmax;
	
	if sum(strcmpi(handles.stim.type, {'NOISE', 'SAM'}))
		update_ui_str(handles.FreqMaxtext, tmpfmax);
		update_ui_str(handles.FreqMintext, tmpfmin);
	else
		update_ui_str(handles.FreqMaxtext, round(handles.stim.F));
		update_ui_str(handles.FreqMintext, round(handles.stim.F));		
	end
	guidata(hObject, handles);
%--------------------------------------------------------------------------
function BWtext_Callback(hObject, eventdata, handles)
	tmpbw = text_update(handles.BWtext, handles.BW, handles.Lim.BW);
	
	% compute temp. upper and lower freq bounds
	tmpfmin = ceil(handles.stim.F - (tmpbw/2) );
	tmpfmax = floor(handles.stim.F + (tmpbw/2) );
	% get limits of frequency values (if calibration data are loaded)
	if isfield(handles, 'caldata')
		Bounds = [handles.caldata.freq(1) handles.caldata.freq(end)];
	else
		Bounds = handles.Lim;
	end		
		
	% check lower bound
	if ~between(tmpfmin, Bounds(1), Bounds(2))
		disp('BW out of range, using min freq possible')
		tmpfmin = Bounds(1);
		tmpbw = tmpfmax - tmpfmin;
	end
	if ~between(tmpfmax, Bounds(1), Bounds(2))
		disp('BW out of range, using max freq possible')
		tmpfmax = Bounds(2);
		tmpbw = tmpfmax - tmpfmin;
	end	
	
	handles.stim.BW = tmpbw;
	handles.stim.Flo = tmpfmin;
	handles.stim.Fhi = tmpfmax;
	
	if sum(strcmpi(handles.stim.type, {'NOISE', 'SAM'}))
		update_ui_str(handles.FreqMaxtext, tmpfmax);
		update_ui_str(handles.FreqMintext, tmpfmin);
	else
		update_ui_str(handles.FreqMaxtext, round(handles.stim.F));
		update_ui_str(handles.FreqMintext, round(handles.stim.F));		
	end
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% Frequency MAX text ------------------------------------------------------
function FreqMaxtext_Callback(hObject, eventdata, handles)
	origVal = handles.stim.Fhi;
	
	newVal = read_ui_str(handles.FreqMaxtext, 'n');
	if isnan(newVal)
		errordlg({'FreqMax must be numeric!', ...
						'Reverting to original value...'}, ...
						'Freq Max Value Error')
		newVal = origVal;
		update_ui_str(handles.FreqMaxtext, origVal);
		return
	elseif newVal >= handles.Lim.F(2)
		errordlg({sprintf('FreqMax must be less than %d', handles.Lim.F(2)), ...
						'Reverting to original value...'}, ...
						'Freq Max Value out of bounds')
		newVal = origVal;
		update_ui_str(handles.FreqMaxtext, origVal);
		return
	end
	
	handles.stim.Fhi = newVal;
	update_ui_str(handles.FreqMaxtext, newVal);
	
	if sum(strcmpi(handles.stim.type, {'NOISE', 'SAM'}))
		% recalculate BW
		handles.stim.BW = handles.stim.Fhi - handles.stim.Flo;
		handles.stim.F = handles.stim.Flo + round(handles.stim.BW / 2);
		update_ui_val(handles.F, handles.stim.F);
		update_ui_str(handles.Ftext, handles.stim.F);
		update_ui_val(handles.BW, handles.stim.BW);
		update_ui_str(handles.BWtext, handles.stim.BW);
	else
		handles.stim.F = newVal;
		update_ui_str(handles.FreqMaxtext, round(handles.stim.F));
		update_ui_str(handles.FreqMintext, round(handles.stim.F));
		update_ui_val(handles.F, handles.stim.F);
		update_ui_str(handles.Ftext, handles.stim.F);
	end
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% Frequency MIN text -----------------------------------------------------
function FreqMintext_Callback(hObject, eventdata, handles)
	origVal = handles.stim.Flo;
	
	newVal = read_ui_str(handles.FreqMintext, 'n');
	if isnan(newVal)
		errordlg({'FreqMin must be numeric!', ...
						'Reverting to original value...'}, ...
						'Freq Min Value Error')
		update_ui_str(handles.FreqMintext, origVal);
		return
	elseif newVal <= handles.Lim.F(1)
		errordlg({sprintf('FreqMin must be greater than %d', handles.Lim.F(1)), ...
						'Reverting to original value...'}, ...
						'Freq Min Value out of bounds')
		update_ui_str(handles.FreqMintext, origVal);
		return
	end
	
	handles.stim.Flo = newVal;
	update_ui_str(handles.FreqMintext, newVal);
	
	if sum(strcmpi(handles.stim.type, {'NOISE', 'SAM'}))
		% recalculate BW
		handles.stim.BW = handles.stim.Fhi - handles.stim.Flo;
		handles.stim.F = handles.stim.Flo + round(handles.stim.BW / 2);
		update_ui_val(handles.F, handles.stim.F);
		update_ui_str(handles.Ftext, handles.stim.F);
		update_ui_val(handles.BW, handles.stim.BW);
		update_ui_str(handles.BWtext, handles.stim.BW);
	else
		handles.stim.F = newVal;
		update_ui_str(handles.FreqMaxtext, round(handles.stim.F));
		update_ui_str(handles.FreqMintext, round(handles.stim.F));
		update_ui_val(handles.F, handles.stim.F);
		update_ui_str(handles.Ftext, handles.stim.F);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function LSpeakerEnable_Callback(hObject, eventdata, handles)
	handles.stim.LSpeakerEnable = read_ui_val(hObject);
	guidata(hObject, handles);
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function RSpeakerEnable_Callback(hObject, eventdata, handles)
	handles.stim.RSpeakerEnable = read_ui_val(hObject);
	guidata(hObject, handles);
%-------------------------------------------------------------------------

% --- Executes on button press in MaskEnable.
function MaskEnable_Callback(hObject, eventdata, handles)
	% check if mask enable is possible given current output device
	% settings (determined in handles.config.OUTDEV)
	if ~strcmp(handles.config.OUTDEV, 'OUTDEV:HEADPHONES+MASKER')
		warning([mfilename ': that feature is unsupported in current TDT configuration'])
		update_ui_val(hObject, 0);
		return;
	end

	% Determine run state from value of button 
	state = read_ui_val(hObject);

	% if user wants to start masking noise, 
	% check if tdt hardware is initialized
	if state && ~TDTInitStatus(handles)
		% HW is not initialized and user clicked the monitor button
		% (button state == 1)
		warning([mfilename ': TDT Hardware is not Initialized!'])
		handles.tdt.MaskEnable = 1;
		guidata(hObject, handles);
		
	elseif state == 0 && TDTInitStatus(handles)
		% HW is initialized, user clicked monitor button to OFF
		% (Button state == 0)
		disp('Turning off masker');
		handles.tdt.MaskEnable = 0;
		guidata(hObject, handles);
		% Button was pressed to stop Masker
		HPSearch_maskEnable(handles);
		
	elseif state && TDTInitStatus(handles)
		% HW is initialized and state == 1 (user turned on button)
		disp('Turning on masker');
		% Button was pressed to start masking noise
			% enable masker
		handles.tdt.MaskEnable = 1;
		guidata(hObject, handles);
		HPSearch_maskEnable(handles);
		
	else
		warning([mfilename ': unknown state!'])
		disp('Cancelling masker request...')
		handles.tdt.MaskEnable = 0;
		update_ui_val(hObject, 0);
		guidata(hObject, handles);
	end
%-------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%% sAM Controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sAM percent modulation (depth) ---------------------------------------
function sAMPercent_Callback(hObject, eventdata, handles)
	handles.stim.sAMPercent = slider_update(handles.sAMPercent, handles.sAMPercenttext, '%d');
	guidata(hObject, handles);
function sAMPercenttext_Callback(hObject, eventdata, handles)
	handles.stim.sAMPercent = text_update(handles.sAMPercenttext, ...
												handles.sAMPercent, handles.Lim.sAMPercent, '%d');
	guidata(hObject, handles);
%--------------------------------------------------------------------------

% sAM Freq ----------------------------------------------------------------
function sAMFreq_Callback(hObject, eventdata, handles)
	handles.stim.sAMFreq = slider_update(handles.sAMFreq, handles.sAMFreqtext, '%d');
	guidata(hObject, handles);
function sAMFreqtext_Callback(hObject, eventdata, handles)
	handles.stim.sAMFreq = text_update(handles.sAMFreqtext, handles.sAMFreq, ...
										handles.Lim.sAMFreq, '%d');
	guidata(hObject, handles);
%--------------------------------------------------------------------------

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks for front panel controls: DISPLAY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----- Executes on mouse press over axes background.    -------------------
function RespPlot_ButtonDownFcn(hObject, eventdata, handles)
	% Determine the clicked point
	Cp = get(gca,'CurrentPoint');
	clickpt = Cp(1, 1:2);
	disp(['Clicked Point: ' num2str(clickpt)])
% 	handles.analysis.spikeThreshold = clickpt(2);
% 
% 	axes(handles.RespPlot);
%  	handles.thresholdLine = line(xlim, [clickpt(2), clickpt(2)], 'Color', 'r');
% 	guidata(hObject, handles);
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
function ClearRaster_Callback(hObject, eventdata, handles)
	disp('Sorry! not working')
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function SpikeThreshold_Callback(hObject, eventdata, handles)
	% "erase" old line
	line(get(handles.RespPlot, 'XLim'), handles.analysis.spikeThreshold * [1 1], 'Color', [1 1 1]);
	% get new threshold
	handles.analysis.spikeThreshold = slider_update(handles.SpikeThreshold, handles.Threshtext, '%.3f');
	% draw new line
	line(get(handles.RespPlot, 'XLim'), handles.analysis.spikeThreshold * [1 1], 'Color', 'm');
	guidata(hObject, handles);
%--------------------------------------------------------------------------
function Threshtext_Callback(hObject, eventdata, handles)
	tmax = get(handles.SpikeThreshold, 'Max');
	tmin = get(handles.SpikeThreshold, 'Min');
	handles.analysis.spikeThreshold = text_update(handles.Threshtext, handles.SpikeThreshold, [tmin tmax]);
	guidata(hObject, handles);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function RespScale_Callback(hObject, eventdata, handles)
	handles.analysis.respscale = slider_update(handles.RespScale, handles.RespScaleText, '%.2f');
	if handles.analysis.respscale < abs(handles.analysis.spikeThreshold)
		handles.analysis.spikeThreshold = handles.analysis.respscale * sign(handles.analysis.spikeThreshold);
		update_ui_val(handles.SpikeThreshold, handles.analysis.spikeThreshold);
		update_ui_str(handles.Threshtext, handles.analysis.spikeThreshold);
	end
	set(handles.SpikeThreshold, 'Max', handles.analysis.respscale);
	set(handles.SpikeThreshold, 'Min', -1*handles.analysis.respscale);
	axes(handles.RespPlot);
	ylim(handles.analysis.respscale.*[-1 1]);
	guidata(hObject, handles);
%--------------------------------------------------------------------------
function RespScaleText_Callback(hObject, eventdata, handles)
	handles.analysis.respscale = abs(read_ui_str(hObject, 'n'));
	update_ui_str(hObject, handles.analysis.respscale);
	
	if handles.analysis.respscale < abs(handles.analysis.spikeThreshold)
		handles.analysis.spikeThreshold = handles.analysis.respscale * sign(handles.analysis.spikeThreshold);
		update_ui_val(handles.SpikeThreshold, handles.analysis.spikeThreshold);
		update_ui_str(handles.Threshtext, handles.analysis.spikeThreshold);
	end
	
	set(handles.SpikeThreshold, 'Max', handles.analysis.respscale);
	set(handles.SpikeThreshold, 'Min', -1*handles.analysis.respscale);
	
	axes(handles.RespPlot);
	ylim(handles.analysis.respscale.*[-1 1]);
	guidata(hObject, handles);
%--------------------------------------------------------------------------

%-------------------------------------------------------------------------
function DisplayChannelCtrl_Callback(hObject, eventdata, handles)
	handles.analysis.channelNum = read_ui_val(hObject);
	handles.tdt.MonitorChannel = handles.analysis.channelNum;
	guidata(hObject, handles);
%-------------------------------------------------------------------------

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILE Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function SaveData_Callback(hObject, eventdata, handles)
	if isfield(handles, 'curvedata')
		[curvefile, curvepath] = uiputfile('*.mat','Save experiment curve data in file');
		if curvefile ~= 0
			curvefile = fullfile(curvepath, curvefile);
			curvedata = handles.curvedata;
			save(curvefile, '-MAT', 'curvedata');
		end
		handles.DataSaved = 1;
	else
		warndlg('No curve data collected to save!','HPSearch Error');
	end
	guidata(hObject, handles);
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALIBRATION Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------
function LoadCal_Callback(hObject, eventdata, handles)
	% open a dialog box to get calibration data file name and path
	[filenm, pathnm] = uigetfile('*_cal.mat', ...
											'Load cal data...', ...
											[handles.caldatapath filesep]);
	
	% load the speaker calibration data if user doesn't hit cancel
	if filenm
		% try to load the calibration data
		try
			tmpcal = load_headphone_cal(fullfile(pathnm, filenm));
		catch errMsg
			% on error, tmpcal is empty
			tmpcal = [];
			disp errMsg
		end
		
		% if tmpcal is a structure, load of calibration file was
		% hopefully successful, so save it in the handles info
		if isstruct(tmpcal)
			handles.caldata = tmpcal;
			% update UI control limits based on calibration data
			handles.Lim.F = [handles.caldata.freq(1) handles.caldata.freq(end)];
			
			% update slider parameters
			slider_limits(handles.F, handles.Lim.F);
			slider_update(handles.F, handles.Ftext);
			
			% update calibration data path and filename settings
			handles.caldatapath = pathnm;
			handles.caldatafile = filenm;
			
			% update settings
			guidata(hObject, handles);
		else
			errordlg(['Error loading calibration file ' filenm], ...
						'LoadCal error'); 
		end
	end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function FlatCal_Callback(hObject, eventdata, handles)
	handles.caldata = fake_caldata;
	
	% update UI control limits based on calibration data
	handles.Lim.F = [handles.caldata.freq(1) handles.caldata.freq(end)];

	% update slider parameters
	slider_limits(handles.F, handles.Lim.F);
	slider_update(handles.F, handles.Ftext);

	% update settings
	guidata(hObject, handles);		
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROTOCOL Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------
function LoadProtocol_Callback(hObject, eventdata, handles)
	% check if the user's settings/protocol path is valid
	% if not, use the current directory
	if ~exist(handles.config.TYTOLOGY_PROTOCOL_PATH, 'dir')
		[protofile, protopath] = uigetfile('*_protocol.mat', 'Load experiment protocol from file');
	else
		current_dir = pwd;
		cd(handles.config.TYTOLOGY_PROTOCOL_PATH);
		[protofile, protopath] = uigetfile('*_protocol.mat', 'Load experiment protocol from file');
		cd(current_dir);
	end
	
	if protofile ~= 0
		protofilepath = fullfile(protopath, protofile);
		tmp = load(protofilepath, '-MAT');
		protocol = tmp.protocol;
		updateUIFromProtocol(handles, protocol);
		curve = curveUpdateFromUI(handles);
		handles.curve = curve;
		handles.protocol = protocol; 
		handles.ProtoDataLoaded = 1;
		guidata(hObject, handles)
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function SaveProtocol_Callback(hObject, eventdata, handles)
	% get an updated protocol by reading from the UI controls
	protocol = readProtocolFromUI(handles);

	% check if the user's settings/protocol path is valid
	% if not, use the current directory
	if ~exist(handles.config.TYTOLOGY_PROTOCOL_PATH, 'dir')
		[protofile, protopath] = uiputfile('*_protocol.mat', 'Save experiment protocol settings in file');
	else
		current_dir = pwd;
		cd(handles.config.TYTOLOGY_PROTOCOL_PATH);
		[protofile, protopath] = uiputfile('*_protocol.mat', 'Save experiment protocol settings in file');
		cd(current_dir);
	end
	
	if protofile ~= 0
		protocol.protofile = protofile;
		protocol.protopath = protopath;
		protofilepath = fullfile(protopath, protofile);
		save(protofilepath, '-MAT', 'protocol');
		handles.ProtoDataSaved = 1;
		handles.protocol = protocol;
		guidata(hObject, handles);	
	end
%-------------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCRIPT Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------
function LoadScript_Callback(hObject, eventdata, handles)
	% check if the user's settings/protocol path is valid
	% if not, use the current directory
	if ~exist(handles.config.TYTOLOGY_SCRIPT_PATH, 'dir')
		[scriptpath, scriptfile] = uigetfile('*_script.mat', 'Load experiment script from file');
	else
		current_dir = pwd;
		cd(handles.config.TYTOLOGY_PROTOCOL_PATH);
		[scriptpath, scriptfile] = uigetfile('*_script.mat', 'Load experiment script from file');
		cd(current_dir);
	end
	
	if script ~= 0
		scriptfilepath = fullfile(scriptpath, scriptfile);
		tmp = load(scriptfilepath, '-MAT');
		handles.script = tmp.script;
		handles.ScriptLoaded = 1;
		guidata(hObject, handles)
	end
%--------------------------------------------------------------------


%--------------------------------------------------------------------
function RunScript_Callback(hObject, eventdata, handles)
	HPSearch_RunScript;
%--------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTINGS Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% allows access to values in settings structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% General procedure for modifying settings:
% 	(1)	make a local copy of the structure to be changed
% 	(2)	retrieve limits information using 'LIMITS' option in HPSearch_init()
% 	(3)	retrieve the list of editable fields in the given structure
% 				- this is accessed through the HPSearch_SettingsMenuFields()
% 	(4)	allow user to modify settings via HPSearch_settingsUpdate() function
% 	(5)	update handles.<struct> to the local copy and commit changes
% 
% 	Easy, no?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%-------------------------------------------------------------------------
function AnimalSettings_Callback(hObject, eventdata, handles)
	% first, make local copy of the structure to be changed
	animal= handles.animal;
	% retrieve limits information
	limits = HPSearch_init('LIMITS');
	% retrieve editable fields in animal structure
	edfields = HPSearch_SettingsMenuFields('ANIMAL');
	% update settings, using current information and limit information
	animal= HPSearch_settingsUpdate(animal, limits, edfields);
	% if animal is non-empty, update the handles and commit changes
	if ~isempty(animal)
		handles.animal = animal;
		guidata(hObject, handles);	
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function StimulusSettings_Callback(hObject, eventdata, handles)
	stim = handles.stim;
	limits = HPSearch_init('LIMITS');
	edfields = HPSearch_SettingsMenuFields('STIM');
	stim = HPSearch_settingsUpdate(stim, limits, edfields);
	if ~isempty(stim)
		stim.type = handles.stim.type;
		handles.stim = stim;
		%%% major kludge - stimulus duration is set in both stimulus settings
		%%% and in TDT settings.  this is the simplest resolution at the
		%%% moment, however unpretty.  sorry.  really.  I'm sorry.
		handles.tdt.StimDuration = handles.stim.Duration;
		guidata(hObject, handles);	
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function TDTSettings_Callback(hObject, eventdata, handles)
	tdt = handles.tdt;
	limits = HPSearch_init('LIMITS');
	edfields = HPSearch_SettingsMenuFields('TDT');
	tdt = HPSearch_settingsUpdate(tdt, limits, edfields);
	if ~isempty(tdt)
		handles.tdt = tdt;
		%%% major kludge - stimulus duration is set in both TDT settings
		%%% and in stimulus settings.  this is the simplest resolution at the
		%%% moment, however unpretty.  sorry.  really.  I'm sorry.
		handles.stim.Duration = handles.tdt.StimDuration;
		guidata(hObject, handles);	
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function AnalysisSettings_Callback(hObject, eventdata, handles)
	analysis = handles.analysis;
	limits = HPSearch_init('LIMITS');
	edfields = HPSearch_SettingsMenuFields('ANALYSIS');
	analysis = HPSearch_settingsUpdate(analysis, limits, edfields);
	if ~isempty(analysis)
		handles.analysis = analysis;
		guidata(hObject, handles);	
	end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function DisplaySettings_Callback(hObject, eventdata, handles)
	display = handles.display;
	limits = HPSearch_init('LIMITS');
	edfields = HPSearch_SettingsMenuFields('DISPLAY');
	display = HPSearch_settingsUpdate(display, limits, edfields);
	if ~isempty(display)
		handles.display = display;
		guidata(hObject, handles);	
	end
%-------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEBUG Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some miscellaneous debugging things
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------------------
function DumpHandlesDebug_Callback(hObject, eventdata, handles)
	% save handles to mat file
	hfilename = ['HPSearch_handles_' date '.mat'];
	save(hfilename, 'handles', '-MAT');
	% write to screen
	disp('HPSearch: Handle information')
	disp('----------------------------')
	disp('hObject:')
	hObject
	disp('----------------------------')
	disp('eventdata:')
	eventdata
	disp('----------------------------')
	disp('handles:')
	handles
	disp('----------------------------')
	disp('handles.config:')
	handles.config
	disp('----------------------------')
	disp('handles.Lim:')
	handles.Lim
	disp('----------------------------')
	disp('handles.stim:')
	handles.stim
	disp('----------------------------')
	disp('handles.tdt:')
	handles.tdt
	disp('----------------------------')
	disp('handles.analysis:')
	handles.analysis
	disp('----------------------------')
	disp('handles.curve:')
	handles.curve
	disp('----------------------------')
	disp('handles.animal:')
	handles.animal
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function KeyboardDebug_Callback(hObject, eventdata, handles)
	disp('DEBUGGING!')
	keyboard
%-------------------------------------------------------------------------


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
function Latten_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function LAttentext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function ILD_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function ILDtext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function Ratten_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function RAttentext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function ITD_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function ITDtext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function ABI_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function ABItext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function BC_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function BCtext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function F_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function Ftext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function BW_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function BWtext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function SpikeThreshold_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function Threshtext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function RespScaleText_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function RespScale_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function FreqMaxtext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function FreqMintext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function cNreps_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function cITDrange_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function cILDrange_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function cABIrange_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function cFREQrange_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function cBCrange_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function DisplayChannelCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function cCurveTypeCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function cStimulusTypeCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function SearchStimulusTypeCtrl_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function sAMPercent_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function sAMPercenttext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function sAMFreq_CreateFcn(hObject, eventdata, handles)
	if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor',[.9 .9 .9]);
	end
function sAMFreqtext_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function csAMPCTrange_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function csAMFREQrange_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------





