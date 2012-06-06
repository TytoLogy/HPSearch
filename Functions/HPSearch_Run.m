% HPSearch_Run.m
%------------------------------------------------------------------------
% 
% Script that runs the HPSearch "RUN" routine.
%
% When user clicks the RUN button on the HPSearch GUI, the value of the
% button is toggled; we can then determine the desired action by the status
% of the button.  If the button is "lo" (value == 0), the user wants to
% stop the run.  If the button is "hi" (value == 1), the user wishes to
% start the run.
%
% If start is desired, also need to check to make sure the TDT hardware is
% enabled
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 28 January, 2009
%
% Revisions:
%	19 June, 2009 (SJS):
%		-	added comments, cleaned some things up
%	13 Oct, 2009 (SJS)
% 		- some more documentation, misc. cleanup
%	19 Nov, 2009 (SJS):
% 		-	beginnings of sAM
%	2 March, 2010 (SJS)
% 		-	added code to deal with situation in which 1 channel of 
% 			data is being recorded from medusa (and hence iofunction() 
% 			returns a vector and not a matrix)
%	5 Jun 2012 (SJS): updated email address
%------------------------------------------------------------------------
% To Do:
%	- display channel - only shows channel 1 at the moment!
%------------------------------------------------------------------------

% some constants used as shorthand
L = 1;
R = 2;
SPIKECHAN = handles.analysis.channelNum;

RASTERLIM = handles.display.RasterNumber;

% Determine run state from value of button - need to do this in order to be
% able to stop/start 
state = read_ui_val(hObject);

% if user wants to start run, check if tdt hardware is initialized
if state && ~TDTInitStatus(handles)
	warning([mfilename ': TDT Hardware is not Initialized!'])
	disp('Cancelling run...')
	update_ui_str(hObject, 'Run');
	set(hObject, 'ForegroundColor', [0.0 0.5 0.0]);
	update_ui_val(hObject, 0);
	enable_ui(handles.CurveButton);
	guidata(hObject, handles);

% if state of button is 0 and TDT hardware is started, stop run
elseif state == 0 && TDTInitStatus(handles)
	% Terminate the Run
	disp('Run ending...');
	% Button was pressed to stop Run
	update_ui_str(hObject, 'Run')
	set(hObject, 'ForegroundColor', [0.0 0.5 0.0]);
	enable_ui(handles.CurveButton);
	guidata(hObject, handles);

else
	% Start running I/O...
	disp('Run starting...');
	
	% change string on the button and change color to red
	update_ui_str(hObject, 'Stop');
	set(hObject, 'ForegroundColor', [1.0 0.0 0.0]);
	
	% Disable the Curve button to avoid bad stuff happening
	disable_ui(handles.CurveButton);

	% update the channel number (SJS, 22 Jun 09)
	handles.analysis.channelNum = read_ui_val(handles.DisplayChannelCtrl);
	handles.tdt.MonitorChannel = handles.analysis.channelNum;
	
	% set TDT values using tdtsettingsfunction function handle - a handle is
	% used in order to be able to use different hardware setups.
	Fs = handles.tdtsettingsfunction(handles.indev, handles.outdev, handles.tdt);
	% assign sampling freqs to IO device structs
	handles.indev.Fs = Fs(1);
	handles.outdev.Fs = Fs(2);
	
	% get the number of points to acquire - needed to know sampling rate to
	% do this, which is why it's done here
	handles.tdt.AcquirePoints = handles.tdt.nChannels * ms2samples(handles.tdt.AcqDuration, handles.indev.Fs);
	% store handles
	guidata(hObject, handles);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% make some local copies of config structs to simplify
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% stimulus settings
	stim = handles.stim
	% TDT things
	tdt = handles.tdt;
	indev = handles.indev;
	outdev = handles.outdev;
	PA5 = {handles.PA5L handles.PA5R};
	zBUS = handles.zBUS;
	
	% calibration data and analysis options (thresholds)
	caldata = handles.caldata;
	analysis = handles.analysis;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% scope/audio monitor for spike data
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	SPIKECHAN = handles.analysis.channelNum;
	RPsettag(indev, 'MonChan', SPIKECHAN);
	RPsettag(indev, 'MonitorEnable', 1);
	RPsettag(indev, 'MonGain', handles.tdt.MonitorGain);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% turn on masking noise if supported
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if strcmp(handles.config.OUTDEV, 'OUTDEV:HEADPHONES+MASKER')
		HPSearch_maskEnable(handles);
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Plotting/display setup
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% get the # of points to send out and to collect
	acqpts = ms2samples(tdt.AcqDuration, indev.Fs);
	outpts = ms2samples(tdt.StimDuration, outdev.Fs);
	% stimulus start and end bins used for analyzing input data
	stim_start = ms2samples(tdt.StimDelay, indev.Fs);
	stim_end = stim_start + ms2samples(tdt.StimDuration, indev.Fs);
	% time vector for plots
	dt = 1/indev.Fs;
	tvec = 1000*dt*(0:(acqpts-1));
	% set up the plot figure
	axes(handles.RespPlot);
	Raxes = gca;
	% clear axes and set RespPlot options
	cla(Raxes);
	set(Raxes, 'YLimMode', 'manual');
	set(Raxes, 'NextPlot', 'replacechildren');
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%play sound
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% new stimulus, so set the flag 
	newstimFlag = 1;
	% counter for # of stims
	stimulusCount = 0;
	
	% reset RasterIndex for rasterplot
	RasterIndex = RASTERLIM;

	while get(hObject, 'Value')
		% get updated stimulus parameters
		stim = stimUpdateFromUI(handles);
		
		% check to see if the stimulus has changed - handles.stim will 
		% be different from stim if a front panel control has moved
		newstimFlag = stimChanged(handles.stim, stim);
		if stimulusCount == 0
			newstimFlag = 1;
		end
		
		% check if user has changed medusa channel to display
		if	SPIKECHAN ~= read_ui_val(handles.DisplayChannelCtrl)
			SPIKECHAN = read_ui_val(handles.DisplayChannelCtrl);
			handles.analysis.channelNum = SPIKECHAN;
			handles.tdt.MonitorChannel = SPIKECHAN;
			guidata(hObject, handles);
			% update the spike channel monitor
			% Set the monitor D/A channel on RX5 and monitor gain
			RPsettag(indev, 'MonChan', SPIKECHAN);
		end
		
		% synthesize the sound wave;
		switch upper(stim.type)
			case 'NOISE'
				[S, rms_val] = syn_headphone_noise(stim.Duration, outdev.Fs, ...
											stim.Flo, stim.Fhi, ...
											stim.ITD, stim.BC, caldata);
				
			case 'TONE'
				[S, rms_val] = syn_headphone_tone(stim.Duration, outdev.Fs, ...
											stim.F, stim.ITD, stim.RadVary, caldata);
				
			case 'SAM'
				% build noisef vector
				NoiseF = [stim.Flo stim.Fhi];
				[S, rms_val, rms_mod, modPhi]  = syn_headphone_amnoise(stim.Duration, outdev.Fs, NoiseF, ...
																stim.ITD, stim.BC, ...
																stim.sAMPercent, stim.sAMFreq, [], ...
																caldata);
		end
		% apply the sin^2 amplitude envelope to the stimulus
		S = sin2array(S, stim.Ramp, outdev.Fs);

		% compute new spl values from the desired ILD and ABI
		spl_val = computeLRspl(stim.ILD, stim.ABI);

		% check if we need to reset the attenuators 
		% (Freq, BW, ILD or ABI has changed)
 		if newstimFlag
			% compute attenuator settings
			if ~strcmp(stim.type, 'SAM')
				[atten, spl_val] = figure_headphone_atten(spl_val, rms_val, caldata, ...
												[stim.LSpeakerEnable stim.RSpeakerEnable]);
			else
				[atten, spl_val] = figure_headphone_atten(spl_val, rms_mod, caldata, ...
												[stim.LSpeakerEnable stim.RSpeakerEnable]);
			end
			
			% update stim struct from computed atten values
			stim.Latten = atten(L);
			stim.Ratten = atten(R);
			
			% update the controls for attenuators
			control_update(handles.LAttentext, handles.Latten, atten(L));
			control_update(handles.RAttentext, handles.Ratten, atten(R));
			% set the attenuators
			PA5setatten(PA5{L}, atten(L));
			PA5setatten(PA5{R}, atten(R));
			% store the new values
			handles.stim = stim;
			guidata(hObject, handles);
 		end

		% play the sound and return the response
		[resp, rate] = handles.iofunction(S, handles.tdt.AcquirePoints, indev, outdev, zBUS);

		% de-multiplex the data if more than 1 channel was collected
		% mcDeMux returns an array that is [nChannels, nPoints]
		if tdt.nChannels > 1
			resp = mcDeMux(resp, tdt.nChannels);
			% decimate the data for plotting
			presp = decimate(resp(:, SPIKECHAN), tdt.decifactor);
		else
			resp = resp';
			% decimate the data
			presp = decimate(resp, tdt.decifactor);
		end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% ideally, this would display with all 16 channels, but for now, just
		% use the selected channel (single electrode)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% select the respplot axes
		axes(handles.RespPlot);		
		% build time vector and plot
		t = (1000 * (0:length(presp)-1) ./ (indev.Fs ./ tdt.decifactor))';
		plot(t, presp);
		% set Y axis scaling from UI control 
		% (convert to number using 'n' option)
		handles.analysis.respscale = read_ui_str(handles.RespScaleText, 'n');
		ylim(handles.analysis.respscale.*[-1 1]);

		% plot a raster of detected spikes on the top of the plot
		th = read_ui_val(handles.SpikeThreshold);
		handles.thresholdLine = line(xlim, [th th], 'Color', 'm');
		handles.analysis.spikeThreshold = th;

		if tdt.nChannels > 1
			spiketimes = spikeschmitt2(resp(:, SPIKECHAN), handles.analysis.spikeThreshold, analysis.spikeWindow, indev.Fs);
		else
			spiketimes = spikeschmitt2(resp, handles.analysis.spikeThreshold, analysis.spikeWindow, indev.Fs);
		end
		spiketimes = 1000 * spiketimes / indev.Fs;
		hold on
			yl = ylim;
			plot(spiketimes, yl(2)*ones(size(spiketimes)), 'm.')
		hold off
		% draw lines to show start and stop of analysis window
		respv1 = line(handles.analysis.spikeStartTime*[1 1], ylim, 'Color', 'g');
		respv2 = line(handles.analysis.spikeEndTime*[1 1], ylim, 'Color', 'r');		

		% draw line to show sound
		soundline = line([stim.Delay stim.Delay+stim.Duration], min(ylim)*[1 1], 'Color', 'k');
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% rasterplot
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% select the raster axes
		axes(handles.RasterPlot);
		if RasterIndex < 1
			RasterIndex = RASTERLIM;
		end
		% is RasterIndex == RASTERLIM?
		if RasterIndex == RASTERLIM
			% first, plot a "dummy" point to set Left hand scale
			xlim([0 max(t)])
			plot(xlim, RASTERLIM.*[1 1], '.', 'Color', [1 1 1]);
			% then plot the spike "ticks"
			hold on
				plot(spiketimes, RasterIndex*ones(size(spiketimes)), 'b.')
			hold off
			ylim('manual');
			ylim([0 RASTERLIM + 1]);
			set(handles.RasterPlot, 'YTickLabel', []);
			rasterv1 = line(handles.analysis.spikeStartTime*[1 1], ylim, 'Color', 'g');
			rasterv2 = line(handles.analysis.spikeEndTime*[1 1], ylim, 'Color', 'r');		
		else
			hold on
				plot(spiketimes, RasterIndex*ones(size(spiketimes)), 'b.')
			hold off
		end
		% decrement RasterIndex to move next plot down a row
		RasterIndex = RasterIndex - 1;

		% pause for ISI
		pause(0.001*handles.StimInterval);
		
		% increment counter
		stimulusCount = stimulusCount + 1;
	end		% end of while loop
end		% end of IF statement

