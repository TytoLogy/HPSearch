% tdtinit.m
%
% sets up TDT parameters
%

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Revisions:
%
%	20 April, 2009:	Created from CalibrateHeadphoneMic_settings.m
%
%--------------------------------------------------------------------------

disp('...starting TDT hardware...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the TDT devices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize RZ6
tmpdev = RZ6init('GB', iodev.Dnum);
iodev.C = tmpdev.C;
iodev.handle = tmpdev.handle;
iodev.status = tmpdev.status;
iodev.REF = 0;
% Initialize PA5 attenuators (left = 1 and right = 2)
PA5L = PA5init('GB', 1);
PA5R = PA5init('GB', 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loads circuits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iodev.rploadstatus = RPload(iodev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Starts Circuit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RPrun(iodev);

%---------------------------------------------------------------
%---------------------------------------------------------------
% get the tags and values for the circuit
% (added 5 Mar 2010 (SJS)
%---------------------------------------------------------------
%---------------------------------------------------------------
tmptags = RPtagnames(iodev);
iodev.TagName = tmptags;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iodev.status = RPcheckstatus(iodev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Query the sample rate from the circuit and set up the time vector and 
% stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iodev.Fs = RPsamplefreq(iodev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up some of the buffer/stimulus parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% size of the Serial buffer
npts=150000;  
dt = 1/iodev.Fs;
mclock=RPgettag(iodev, 'mClock');

% Set the total sweep period time
RPsettag(iodev, 'SwPeriod', ms2samples(SweepPeriod, iodev.Fs));
% Set the sweep count (may not be necessary)
RPsettag(iodev, 'SwCount', 1);
% Set the Stimulus Delay
RPsettag(iodev, 'StimDelay', ms2samples(StimDelay, iodev.Fs));
% Set the Stimulus Duration
RPsettag(iodev, 'StimDur', ms2samples(StimDuration, iodev.Fs));
% Set the length of time to acquire data
RPsettag(iodev, 'AcqDur', ms2samples(AcqDuration, iodev.Fs));
% set the ttl pulse duration
RPsettag(iodev, 'TTLPulseDur', ms2samples(TTLPulseDur, iodev.Fs));

RPsettag(iodev, 'HPFreq', HiPassFc);
RPsettag(iodev, 'LPFreq', LoPassFc);


TDTINIT = 1;
