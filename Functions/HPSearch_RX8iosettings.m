function Fs = HPSearch_RX8iosettings(indev, varargin)
%------------------------------------------------------------------------
%Fs = HPSearch_RX8iosettings(indev)
%------------------------------------------------------------------------
% sets up TDT settings for HPSearch using RX8 for input and output
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	indev			TDT device interface structure
% 	varargin		place holder, not used
% 
% Output Arguments:
%	Fs				[1 X 2] sampling rate for input (1) and output (1)
%------------------------------------------------------------------------
% See also: HPSearch, HPSearch_tdtinit
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 9 March 2009 (SJS)
%
% Revisions:
% 	23 March, 2010 (SJS)
% 		-	cleaned up some things, updated documentation
%------------------------------------------------------------------------

% Query the sample rate from the circuit
inFs = RPsamplefreq(indev);
outFs = inFs;


tdt = varargin{2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set the length of time to acquire data
	RPsettag(indev, 'AcqDur', ms2samples(tdt.AcqDuration, inFs));
	% Set the total sweep period time
	RPsettag(indev, 'SwPeriod', ms2samples(tdt.SweepPeriod, inFs));
	
	% set the HP filter
	if tdt.HPEnable == 1
		RPsettag(indev, 'HPEnable', 1);
		RPsettag(indev, 'HPFreq', tdt.HPFreq);
	else
		RPsettag(indev, 'HPEnable', 0);
	end
	% set the LP filter
	if tdt.LPEnable == 1
		RPsettag(indev, 'LPEnable', 1);
		RPsettag(indev, 'LPFreq', tdt.LPFreq);
	else
		RPsettag(indev, 'LPEnable', 0);
	end

	% Set the sweep count to 1
	RPsettag(indev, 'SwCount', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	% set the ttl pulse duration
% 	RPsettag(indev, 'PulseDur', ms2samples(tdt.TTLPulseDur, inFs));

% 	% Set up some of the buffer/stimulus parameters
% 	RPsettag(indev, 'StimInterval', tdt.StimInterval);
	% Set the total sweep period time
	RPsettag(indev, 'SwPeriod', ms2samples(tdt.SweepPeriod, inFs));
	% Set the sweep count to 1
	RPsettag(indev, 'SwCount', 1);
	% Set the Stimulus Delay
	RPsettag(indev, 'StimDelay', ms2samples(tdt.StimDelay, inFs));
	% Set the Stimulus Duration
	RPsettag(indev, 'StimDur', ms2samples(tdt.StimDuration, inFs));


	Fs = [inFs outFs];