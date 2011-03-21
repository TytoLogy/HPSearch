function Fs = HPSearch_tdtsettings(tdt, indev, outdev)
% sets up TDT settings for HPSearch

% Query the sample rate from the circuit
inFs = RPsamplefreq(indev);
outFs = RPsamplefreq(outdev);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set the length of time to acquire data
	RPsettag(indev, 'AcqDur', ms2samples(tdt.AcqDuration, inFs));
	% Set the total sweep period time
	RPsettag(indev, 'SwPeriod', ms2samples(tdt.SweepPeriod, inFs));
	
	% set the HP filter
	if tdt.HPEnable == 1
		RPsettag(indev, 'HPFreq', tdt.HPFreq);
		RPsettag(indev, 'HPEnable', 1);
	else
		RPsettag(indev, 'HPEnable', 0);
	end
	% set the LP filter
	if tdt.LPEnable == 1
		RPsettag(indev, 'LPFreq', tdt.LPFreq);
		RPsettag(indev, 'LPEnable', 1);
	else
		RPsettag(indev, 'LPEnable', 0);
	end
	
	% set the HeadstageGain
	status = RPsettag(indev, 'mcGain', tdt.HeadstageGain);
	% get the buffer index
	index_in = RPgettag(indev, 'mcIndex');
	% Set the sweep count to 1
	RPsettag(indev, 'SwCount', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set the ttl pulse duration
	RPsettag(indev, 'PulseDur', ms2samples(tdt.TTLPulseDur, inFs));

	% Set up some of the buffer/stimulus parameters
	RPsettag(outdev, 'StimInterval', tdt.StimInterval);
	% Set the total sweep period time
	RPsettag(outdev, 'SwPeriod', ms2samples(tdt.SweepPeriod, outFs));
	% Set the sweep count to 1
	RPsettag(outdev, 'SwCount', 1);
	% Set the Stimulus Delay
	RPsettag(outdev, 'StimDelay', ms2samples(tdt.StimDelay, outFs));
	% Set the Stimulus Duration
	RPsettag(outdev, 'StimDur', ms2samples(tdt.StimDuration, outFs));
	% set the ttl pulse duration
	RPsettag(outdev, 'PulseDur', ms2samples(tdt.TTLPulseDur, outFs));

	% Set the monitor D/A channel on RX5 and monitor gain
	RPsettag(indev, 'MonChannel', tdt.MonitorChannel);
	RPsettag(indev, 'MonGain', tdt.MonitorGain);	
	% Turn on the monitor channel
	status = RPtrig(indev, 1);

Fs = [inFs outFs];