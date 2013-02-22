function out = HPSearch_init(stype)
%------------------------------------------------------------------------
% out = HPSearch_init(stype)
%------------------------------------------------------------------------
% 
% Sets initial values, limits, initialization, HW settings, etc. etc.
%
%------------------------------------------------------------------------
% Input Arguments:
% 	stype		string
% 					
% 		Value:				Type:		Description:
% 		DATAVERSION			string	version for data (important for reading)
%		LIMITS				struct	limits for ITD, ILD, etc.
% 		STIMULUS				struct	default stimulus settings
% 		TDT					struct	tdt hardware settings
% 		IODEV					struct	input/output settings for RX8 only
% 		MEDUSA				struct	input settings for RX5 + Medusa
% 		HEADPHONES			struct	output settings for RX8, headphones
% 		ANALYSIS				struct	analysis settings
% 		CURVE					struct	curve protocol settings
%		ANIMAL				struct	experiment animal, penetration, recording info
%		DISPLAY				struct	display preferences
% 
% 		TDT_SINGLECHANNEL		settings for single channel recording and
%									headphone output on ch. 17 and 18.
% 									Use in conjunction with IODEV
%		
% Output Arguments:
% 	out		struct containing settings for requested type
% 
%------------------------------------------------------------------------
% See also: HPSearch, HPSearch_tdtinit
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 6 August, 2008
%
% Revisions:
% 	27 January 2009 (SJS)
% 		-	added/made changes to code for use of headphones and recording
% 			with Medusa preamp
% 	6 March 2009 (SJS)
% 		- added nTrials element to curve structure init
% 	9 March 2009 (SJS)
% 		- added some documentation
%		- added some other settings for different setups
%	11 March 2009 (SJS)
%		- added code to specify TDT info path at top of file
%	2 November, 2009 (SJS)
%		- changed default bandwidth and frequency values for noise in
% 			"stimulus" settings
%	3 November, 2009 (SJS)
%		- changed default Monitor Channel and corresponding Input Channel
% 			in "tdt4"
% 		- moved the analysis, animal, etc. sections up top
% 		- added RadVary field to "curve"
% 		- added "display" as option, but doesn't do anything yet
%	5 November, 2009 (SJS)
% 		- added TempData and freezeStim to "curve"
%		- added freezeStim to "stimulus"
%	19 November, 2009 (SJS)
%		- sinusoid AM noise controls
%	24 November, 2009 (SJS): added DATAVERSION
%	9 December, 2009 (SJS): added RasterNumber to replace RASTERLIM
%	27 January, 2010 (SJS):	added code for masker
%	2 March, 2010 (SJS): added in code to use HPSearch_configuration for
%								path information
%	28 April, 2010 (SJS): changed Nreps upper limit from 100 to 500
%	26 July, 2010 (SJS): added section for RZ5 input and RX6 I/O
%	01 March, 2012 (SJS):	updated email address, some comments
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some global settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------
% Get Path Information set in HPSearch_configuration()
%----------------------------------------------------------------------
% 	gPath = 'H:\Code\TytoLogy\Toolbox';
% HPSearch_configuration returns a struct of configuration parameters
% so assign the output of HPSearch_Configuration to a temporary variable
% and save the global root path for TytoLogy project
tmpConfig = HPSearch_Configuration;
gPath = tmpConfig.TYTOLOGY_ROOT_PATH;

%----------------------------------------------------------------------
% global settings for stimulus delay and duration
%----------------------------------------------------------------------
gDelay = 50;
gDuration = 200;
gSpikeWindow = 200;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now, respond to input calls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%----------------------------------------------------------------------
% check input args
%----------------------------------------------------------------------
if ~nargin
	stype = 'Default';
end
stype = upper(stype);
out.type = stype;

%----------------------------------------------------------------------
% return desired information
%----------------------------------------------------------------------
switch stype

	%----------------------------------------------------------------------
	% DATAVERSION is version code for output binary file data
	%----------------------------------------------------------------------
	case 'DATAVERSION'
		out = 1.01;
	
	%----------------------------------------------------------------------
	% LIMITS are used for keeping different user-definable variables within
	% bounds, and are used  to set limits on the GUI controls
	%----------------------------------------------------------------------
	case {'LIMITS', 'DEFAULT'}		
		% stimulus limits
		out.ITD = [-1000 1000];
		out.ILD = [-40 40];
		out.Latten = [0 120];
		out.Ratten = out.Latten;
		out.ABI = [0 100];
		out.BC = [0 100];
		out.F = [1 35000];  % was [1 24000]
		out.BW = [1 17500]; % was [1 12500]
		% sinusoid AM noise controls, added 19 Nov 09, SJS
		out.sAMFreq = [0 200];
		out.sAMPercent = [0 100];
		
		% Stimulus & I/O limits
		out.StimInterval = [0 5000];
		out.StimDuration = [1 3000];
		out.AcqDuration = [1 3000];
		out.StimDelay = [0 1500];
		out.StimRamp = [0 10];
		
		% experiment limits
		out.Nreps = [1 500];
		out.nTrials = [1 200];
		
		% DAQ & TDT limits
		out.Channels = [1 4];		
		out.MonitorGain = [0 100000];
		out.HeadstageGain = [0 100000];
		out.HPFreq = [0.001 20000];
		out.LPFreq = [100 35000];
		out.TTLPulseDur = [1 100];
		out.DeciFactor = [1 20];

		% Display Limits
		out.RasterNumber = [1 70];
		
		% masker (added 27/1/2010)
		out.MaskAmp = [0 .3];
		out.MaskChannel = [20 22];
		out.MaskEnable = [0 1];
		
		return;
	
	%----------------------------------------------------------------------
	% DISPLAY settings used for GUI, plots, etc
	%----------------------------------------------------------------------
	case {'DISPLAY'}
% 		out.RASTERLIM = 30;
		out.RasterNumber = 30;
		
	%----------------------------------------------------------------------
	% STIMULUS are initial (default) stimulus parameters
	%----------------------------------------------------------------------
	case {'STIMULUS'}
		out.type = 'NOISE';
		out.ITD = 0;
		out.ILD = 0;
		out.Latten = 120;
		out.Ratten = 120;
		out.ABI = 50;
		out.BC = 100;
		out.F = 5000;
		out.BW = 9000;
		out.RadVary = 0;
		out.Duration = gDuration;
		out.Ramp = 2;
		out.Delay = gDelay;
		out.Flo = floor(out.F - out.BW/2);
		out.Fhi = ceil(out.F + out.BW/2);
		out.freezeStim = 1;
		% sinusoid AM noise controls, added 19 Nov 09, SJS
		out.sAMFreq = 0;
		out.sAMPercent = 0;
		% allows speakers to be turned on/off
		out.LSpeakerEnable = 1;
		out.RSpeakerEnable = 1;
		
		return;

	%----------------------------------------------------------------------
	% ANALYSIS are initial settings for spike thresholds, scaling factors
	% and such things
	%----------------------------------------------------------------------
	case {'ANALYSIS'}
		out.spikeThreshold = 1;
		out.spikeWindow = 1;
		out.respscale = 2;
		out.channelNum = 1;
		out.spikeStartTime = gDelay;
		out.spikeEndTime = out.spikeStartTime+gSpikeWindow;
		return;
	
	%----------------------------------------------------------------------
	% CURVE are initial settings for running a curve.  default is presently
	% set to be ITD curve
	%----------------------------------------------------------------------
	case {'CURVE'}
		out.curvetype = 'itd';
		out.stimtype = 'noise';
		out.nreps = 5;
		out.ITDrange = -100:50:100;
		out.ILDrange = 0;
		out.ABIrange = 50;
		out.FREQrange = [300 8000];
		out.BCrange = 100;
		out.ITDrangestr = '-100:50:100';
		out.ILDrangestr = '0';
		out.ABIrangestr = '50';
		out.FREQrangestr = '[300 8000]';
		out.BCrangestr = '100';
		out.nTrials = length(out.ITDrange);
		out.TempData = 0;
		out.saveStim = 0;
		out.RadVary = 1;
		out.freezeStim = 0;
		% sinusoid AM noise controls, added 19 Nov 09, SJS
		out.sAMPCTrange = 0;
		out.sAMFREQrange = 0;
		out.sAMPCTrangestr = 0;
		out.sAMFREQrangestr = 0;
		return;
	
	%----------------------------------------------------------------------
	% ANIMAL information
	%----------------------------------------------------------------------
	case {'ANIMAL'}
		out.animalNumber = '000';
		out.expDate = date;
		out.expTime = time;
		out.penetration = 1;
		out.AP = 0;
		out.ML = 0;
		out.depth = 0; 
		out.comments = '';
		return;
		
	%----------------------------------------------------------------------
	%--------------------------------------- TDT CONFIGURATION ------------
	% used to configure the TDT struct.  there are different settings for
	% different setups (# of input channels, input/output device, etc)
	% TDT struct information covers basic TDT settings that are not
	% necessarily device-specific.  The device specific setup is handled in
	% the sections below for INDEV and OUTDEV
	%----------------------------------------------------------------------
	case {'TDT'}
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1000;			% gain for headstage
		out.MonitorChannel = 1;				% monitor channel on RX5 (from medusa)
		out.MonitorGain = 1000;				% monitor channel gain
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 1;						% enable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 4;
		out.InputChannel = zeros(out.nChannels, 1);
		out.OutputChannel = [17 18];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		return;
		
	% TDT:SINGLECHANNEL is for recording from single channel
	case{'TDT:SINGLECHANNEL'}
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1;				% gain for headstage
		out.MonitorChannel = 1;				% monitor channel on RX5 (from medusa)
		out.MonitorGain = 1;					% monitor channel gain
		out.MonitorEnable = 1;				% enable monitor output
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 0;						% disable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 1;
		out.InputChannel = 1;			% has no effect for sgl channel input
		out.OutputChannel = [17 18];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		return;
		
	% TDT:SINGLECHANNEL is for recording from single channel of RX8
	% default is to record from channel 3 (channels 1 and 2 can be left
	% connected to the earphone microphones)
	case{'TDT:SINGLECHANNEL_RX8ACQ'}
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1;				% gain for headstage
		out.MonitorChannel = 3;				% monitor channel on RX5 (from medusa)
		out.MonitorGain = 1;					% monitor channel gain
		out.MonitorEnable = 1;				% enable monitor output
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 0;						% disable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 1;
		out.InputChannel = 3;			% has no effect for sgl channel input
		out.OutputChannel = [17 18];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		return;		

	% TDT:4 is for recording from 4 channels of spike input
	case {'TDT:4'}
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1000;			% gain for headstage
		out.MonitorChannel = 2;				% monitor channel on RX5 (from medusa)
		out.MonitorGain = 1000;			% monitor channel gain
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 1;						% enable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 4;
		out.InputChannel = zeros(out.nChannels, 1);
		out.InputChannel(2) = 1;
		out.OutputChannel = [17 18];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		return;

	% TDT:1CHANNEL+MASKER records from 1 channel and plays a masking noise
	% from output channel 3
	case {'TDT:1CHANNEL+MASKER'}
		% Configuration for 1 Channel acquisition from Medusa and
		% dichotic stimulation with option for Masking noise output
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1000;			% gain for headstage
		out.MonitorChannel = 2;				% monitor channel on RX5 (from medusa)
		out.MonitorGain = 1000;			% monitor channel gain
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 1;						% enable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 1;
		out.InputChannel = zeros(out.nChannels, 1);
		out.OutputChannel = [17 18];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		% masking settings
		out.MaskAmp = .1;						% masker amplitude
		out.MaskChannel = 20;				% masker output channel
		out.MaskEnable = 0;					% masker off/on (0/1)
		return;

	% TDT:4CHANNEL+MASKER records from 4 channels and plays a masking noise
	% from output channel 3
	case {'TDT:4CHANNEL+MASKER'}
		% Configuration for 4 Channel acquisition from Medusa and
		% dichotic stimulation with option for Masking noise output
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1000;			% gain for headstage
		out.MonitorChannel = 2;				% monitor channel on RX5 (from medusa)
		out.MonitorGain = 1000;			% monitor channel gain
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 1;						% enable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 4;
		out.InputChannel = zeros(out.nChannels, 1);
		out.InputChannel(2) = 1;
		out.OutputChannel = [17 18];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		% masking settings
		out.MaskAmp = .1;						% masker amplitude
		out.MaskChannel = 20;				% masker output channel
		out.MaskEnable = 0;					% masker off/on (0/1)
		return;
		
	% TDT:16 sets up recording from 16 channels of medusa on RX5
	case {'TDT:16'}
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1000;			% gain for headstage
		out.MonitorChannel = 1;				% monitor channel on RX5 (from medusa)
		out.MonitorGain = 1000;			% monitor channel gain
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 1;						% enable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 16;
		out.InputChannel = zeros(out.nChannels, 1);
		out.OutputChannel = [17 18];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		return;

	% TDT:RZ-MJR sets up recording from 16 channels of medusa on RZ5
	% and output from 2 channels on RZ6
	case {'TDT:RZ-MJR'}
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1000;			% gain for headstage
		out.ScopeChan = 1;					% d/a output channel for monitor
		out.MonitorChannel = 1;				% monitor channel on Rz5 (from medusa)
		out.MonitorGain = 1000;				% monitor channel gain
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 1;						% enable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 16;
		out.InputChannel = zeros(out.nChannels, 1);
		out.OutputChannel = [1 2];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		return;
		
	% TDT:RZ-MJR sets up recording from 1 channel of medusa on RZ5
	% and output from 2 channels on RZ6
	case {'TDT:RZ-MJR-SINGLE'}
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1000;			% gain for headstage
		out.ScopeChan = 1;					% d/a output channel for monitor
		out.MonitorChannel = 1;				% monitor channel on Rz5 (from medusa)
		out.MonitorGain = 1000;				% monitor channel gain
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 1;                   % enable HP filter
		out.HPFreq = 100;					% HP frequency (this was 200)
		out.LPEnable = 1;					% enable LP filter
		out.LPFreq = 35000;					% LP frequency (this was 10000)
		out.nChannels = 1;
		out.InputChannel = zeros(out.nChannels, 1);
		out.OutputChannel = [1 2];
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		return;

		
	% TDT:OWLSCILLATE is used during vestibular stimulation of the owl
	case{'TDT:OWLSCILLATE'}
		out.StimInterval = 100;
		out.StimDuration = gDuration;
		out.AcqDuration = 300;
		out.SweepPeriod = out.AcqDuration + 10;
		out.StimDelay = gDelay;
		out.HeadstageGain = 1;				% gain for headstage
		out.MonitorChannel = 1;				% monitor channel on RX5 (from medusa)
		out.MonitorGain = 1;					% monitor channel gain
		out.MonitorEnable = 1;				% enable monitor output
		out.decifactor = 1;					% factor to reduce input data sample rate
		out.HPEnable = 0;						% disable HP filter
		out.HPFreq = 200;						% HP frequency
		out.LPEnable = 1;						% enable LP filter
		out.LPFreq = 10000;					% LP frequency
		out.nChannels = 1;
		out.InputChannel = 1;				% has no effect for sgl channel input
		out.OutputChannel = [17 18];
		out.AcquisitionChannel = 2;
		out.AcquisitionGain = 1;
		%TTL pulse duration (msec)
		out.TTLPulseDur = 1;
		return;

	%----------------------------------------------------------------------
	%--------------------------------------- INDEV CONFIGURATION ----------
	% Configuration of input device TDT struct (see TDT Toolbox for methods
	% to open, run, configure, interface with TDT hardware)
	%
	% In all cases, a "dummy" sampling rate, Fs, is specified, mostly for 
	% initial launch of the program.  It is updated from the TDT circuit
	% once the hardware is initialized
	% 
	% Circuit_Path		location of the RPvD circuit file
	% Circuit_Name		name of the RPvD circuit
	% Dnum					hardware device number (mostly important in rigs where
	% 						there are multiple TDT devices)
	% C						field to hold ActiveX device structure
	% PA5L/R				used for PA5 attenuator ActiveX device handles 
	% 						(L)eft and (R)ight
	% status				placeholder for status, initialize to 0 (off)
	%----------------------------------------------------------------------
	
	% INDEV:IODEV is used where the RX8_2 is used for both recording and
	% stimulating.
	case {'INDEV:IODEV'}
		out.Fs = 50000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX8_2\50KHz'];
		out.Circuit_Name = 'RX8_2_BinauralStim_SglResponseFiltered';
		% Dnum = device number - this is for RX8 (2)
		out.Dnum=2;
		out.C = [];
		out.PA5L = [];
		out.PA5R = [];
		out.status = 0;
		return;

	% input device is Medusa
	case {'INDEV:MEDUSA'}
		out.Fs = 25000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX5'];
		% for recording from 4 channels
		out.Circuit_Name = 'RX5_1ChannelAcquire_zBus';
		% Dnum = device number - this is for RX5
		out.Dnum=1;
		out.C = [];
		out.status = 0;
		return;

	% input device is Medusa, 4 channel input
	case {'INDEV:MEDUSA4'}
		out.Fs = 25000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX5'];
		% for recording from 4 channels
		out.Circuit_Name = 'RX5_4ChannelAcquire_zBus';
		% Dnum = device number - this is for RX5
		out.Dnum=1;
		out.C = [];
		out.status = 0;
		return;
	
	% input (spike) device is Medusa, 16 channel input
	case {'INDEV:MEDUSA16'}
		out.Fs = 25000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX5'];
		% for recording from 16 Channels
		out.Circuit_Name = 'RX5_16ChannelAcquire_zBus';
		% Dnum = device number - this is for RX5
		out.Dnum=1;
		out.C = [];
		out.status = 0;
		return;
	
	% input is medusa, trigger acquisition from TTL pulse - used for
	% vestibular stimulation experiments
	case {'INDEV:RX5_OWLSCILLATE'}
		out.Fs = 25000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX5'];
		out.Circuit_Name = 'RX5_OwlscillatorAcquire_TTLtrig';
		% Dnum = device number - this is for RX8 (2)
		out.Dnum=1;
		out.C = [];
		out.status = 0;
		return;

	
	% input (spike) device is Medusa on RZ5, 1 channel input
	case {'INDEV:RZ5_MEDUSA1'}
		out.Fs = 25000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RZ5'];
		% for recording from 16 Channels
		out.Circuit_Name = 'RZ5_1ChannelAcquire_zBus';
		% Dnum = device number - this is for RZ5
		out.Dnum=1;
		out.C = [];
		out.status = 0;
		return;

		
	% input (spike) device is Medusa on RZ5, 16 channel input
	case {'INDEV:RZ5_MEDUSA16'}
		out.Fs = 25000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RZ5'];
		% for recording from 16 Channels
		out.Circuit_Name = 'RZ5_16ChannelAcquire_zBus';
		% Dnum = device number - this is for RZ5
		out.Dnum=1;
		out.C = [];
		out.status = 0;
		return;

	%----------------------------------------------------------------------
	%--------------------------------------- OUTDEV CONFIGURATION	--------
	% configuration section for output device
	%----------------------------------------------------------------------
	case {'OUTDEV:HEADPHONES'}
		out.Fs = 50000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX8_2\50KHz\'];
		out.Circuit_Name = 'RX8_2_BinauralOutput_zBus';
		% Dnum = device number - this is for RX8 (2)
		out.Dnum=2;
		out.C = [];
		out.status = 0;
		return;
		
	case {'OUTDEV:HEADPHONES+MASKER'}
		out.Fs = 50000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX8_2\50KHz\'];
		out.Circuit_Name = 'RX8_2_BinauralOutputMask_zBus';
		% Dnum = device number - this is for RX8 (2)
		out.Dnum=2;
		out.C = [];
		out.status = 0;
		return;		

	case {'OUTDEV:RX8_2_OWLSCILLATE'}
		out.Fs = 50000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX8_2\50KHz'];
		out.Circuit_Name = 'RX8_2_Owlscillator_VelTrigPosAcq';
		% Dnum = device number - this is for RX8 (2)
		out.Dnum=2;
		out.C = [];
		out.status = 0;
		return;

	case {'OUTDEV:HEADPHONES_RX6'}
		out.Fs = 50000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RX6\50KHz\'];
		out.Circuit_Name = 'RX6_BinauralOutput_zBus';
		% Dnum = device number - this is for RX6, device 1
		out.Dnum=1;
		out.C = [];
		out.status = 0;
		return;		

	case {'OUTDEV:LOUDSPEAKER_RZ6'}
		out.Fs = 50000;
		% set this to wherever the circuits are stored
		out.Circuit_Path = [gPath '\Toolbox\TDTToolbox\Circuits\RZ6\'];
		out.Circuit_Name = 'RZ6_SpeakerOutput_zBus';
		% Dnum = device number - this is for RZ6, device 1
		out.Dnum=1;
		out.C = [];
		out.status = 0;
		return;		

	%----------------------------------------------------------------
	% Initial PA% attenuator structs
	%----------------------------------------------------------------
	case {'ATTEN'}
		out.PA5L = [];
		out.PA5R = [];
		return;

	%----------------------------------------------------------------
	% Stimulus types
	%----------------------------------------------------------------
	case 'STIMULUS_TYPES'
		out = {'NOISE', 'TONE', 'NOISE_L', 'NOISE_R', 'TONE_L', 'TONE_R', 'NULL'}
	
	%----------------------------------------------------------------
	% Curve Types
	%----------------------------------------------------------------
	case 'CURVE_TYPES'
		out = {'ITD', 'ILD', 'Freq', 'BC', 'ABI', 'sAM_Percent', 'sAM_Freq'};

	%----------------------------------------------------------------
	% Protocol parameters
	%----------------------------------------------------------------
	case {'PROTOCOL_FIELDS'}
		out = {'curvetype', 'stimtype', 'nreps', ...
					'ITDrangestr', 'ILDrangestr', 'ABIrangestr', ...
					'FREQrangestr', 'BCrangestr', ...
					'sAMPCTrangestr', 'sAMFREQrangestr'	};

	case {'PROTOCOL_RANGES'}
		out = {'ITDrange', 'ILDrange', 'ABIrange', ...
					'FREQrange', 'BCrange', ...
					'sAMPCTrange', 'sAMFREQrange'	};

	%----------------------------------------------------------------
	% Trap unknown input
	%----------------------------------------------------------------
	otherwise
		disp([mfilename ': unknown information type ' stype '...']);
		dbstack
		out = [];
		return;
end


