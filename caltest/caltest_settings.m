% calsounds_noisetestsettings.m
%
%	Edit this file to set frequency range, amplitude, etc
%	for testing the earphone microphones with a reference
%	(e.g., Bruel & Kjaer / B&K) microphone
%

%--------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Revisions:
%
%	21 April, 2009:	Created from ref_caltestsettings.m
%
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% general constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 1;
R = 2;
REF = 3;
REFL = 3;
REFR = 4;
BOTH = 3;
NO = 0;
YES = 1;
FALSE = 0;
TRUE = 1;
MONO = 0;
STEREO = 1;
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fmin = 5000;
Fmax = 6000;	
BC = 100;
Nreps = 1;
spl_val = [50 50];
rad_vary = NO;
Nspeakers = 2;
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set this to wherever the circuits are stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iodev.Circuit_Path = 'C:\TytoLogy\Toolbox\TDTToolbox\Circuits\RZ6';
iodev.Circuit_Name = 'RZ6_CalibrateIO_softTrig';
iodev.REF = 0;
iodev.status = 0;
%------------------------------------------------------------
% Dnum = device number - this is for RZ6 (1)
%------------------------------------------------------------
iodev.Dnum=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some constants/conversion factors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DAscale = 1;
Gain_dB = [0 0 0];
Gain = invdb(Gain_dB);
% sensitivity of the calibration mic in V / Pa
CalMic_sense = 1;
% pre-compute the V -> Pa conversion factor
VtoPa = (CalMic_sense^-1);
RMSsin = 1/sqrt(2);
FRANGE = 1;
MAX_ATTEN = 120;
CLIPVAL = 2;		% clipping value	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the stimulus/acquisition settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Freqs = Fmin:Fmax;
Nchannels = 2;
	
% Stimulus Interval (ms)
StimInterval = 200;
% Stimulus Duration (ms)
StimDuration = 500;
% Duration of epoch (ms)
SweepDuration = 510;
% Delay of stimulus (ms)
StimDelay = 10;
% Total time to acquire data (ms)
AcqDuration = SweepDuration;
% Total sweep time = sweep duration + inter stimulus interval (ms)
SweepPeriod = SweepDuration + StimInterval;
% Stimulus ramp on/off time
StimRamp = 5;
TestRamp = 5;
SPLRamp = 1;
%Input Filter Fc
HiPassFc = 150;
LoPassFc = 40000;
%TTL pulse duration (msec)
TTLPulseDur = 1;
SpeakerChannel = R;
