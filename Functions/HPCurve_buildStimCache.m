function [c, stimseq] = HPCurve_buildStimCache(curve, stim, tdt, caldata, indev, outdev)
%--------------------------------------------------------------------------
% [c, stimseq] = HPCurve_buildStimCache(curve, stim, tdt, caldata, indev, outdev)
%--------------------------------------------------------------------------
% HPSearch program
%--------------------------------------------------------------------------
% 
% Generates stimulus cache 
% 
%--------------------------------------------------------------------------
% Input Arguments:
% 	curve				curve data structure
% 	stim				stimulus data structure
% 	tdt				tdt data structure
% 	caldata			calibration data
% 	indev				input device structure
% 	outdev			output TDT device structure
%
% Output Arguments:
%	c					stimulus cache
%	stimseq			stimulus sequence in block format
%--------------------------------------------------------------------------
% See Also: writeStimData, fopen, fwrite, BinaryFileToolbox, HPSearch
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	18 November, 2009 (SJS): file created
% 	3 December, 2009 (SJS): fixed c.radvary error (was c.rad_vary, so it was
%									never defined before use 
%--------------------------------------------------------------------------
% TO DO: more curve types
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% get string for type of stimulus
c.stimtype = lower(curve.stimtype);
% get string for type of curve
c.curvetype = upper(curve.curvetype);
% frozen stimulus setting
c.freezeStim = curve.freezeStim;
% # of reps (reps per stim)
c.nreps = curve.nreps;
% # of trials == # of stim values (ITDs, ILDs, etc.)
c.ntrials = curve.nTrials;

% allocate some arrays for storage
c.nstims = c.nreps * c.ntrials;
c.repnum = zeros(c.nstims, 1);
c.trialnum = zeros(c.nstims, 1);
sindex = 0;
for rep = 1:c.nreps
	for trial = 1:c.ntrials
		sindex = sindex + 1;
		c.repnum(sindex) = rep;
		c.trialnum(sindex) = trial;
	end
end
		
c.Sn = cell(c.nstims, 1);
c.splval = cell(c.nstims, 1);
c.rmsval = cell(c.nstims, 1);
c.atten = cell(c.nstims, 1);

c.ITD = zeros(c.nstims, 1);
c.ILD = zeros(c.nstims, 1);
c.BC = zeros(c.nstims, 1);
c.FREQ = cell(c.nstims, 1);
c.ABI= zeros(c.nstims, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings for Type of stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch c.curvetype
	
	% ITD, ILD, ABI curves can use either noise or tones
	case {'ITD', 'ILD', 'ABI'}
		switch c.stimtype
			case 'noise'
				% low freq for bandwidth of noise (Hz)
				FREQ(1) = curve.FREQrange(1);
				% high freq. for BB noise (Hz)
				FREQ(2) = curve.FREQrange(end);
			case 'tone'
				FREQ = curve.FREQrange(1);	% freq. for tone (Hz)'
				% vary phase randomly from stim to stim 1 = yes, 0 = no
				% (consistent phase each time)
				c.radvary = curve.RadVary;	
			otherwise
				warning([mfilename ': unsupported stimtype ' c.stimtype ' for curvetype ' c.curvetype])
				c = [];
				return
		end
		
	% BW, BC and SAMNOISE (sine amplitude-mod noise) only use noise
	case {'BW', 'BC', 'SAM_PERCENT', 'SAM_FREQ'}
		switch c.stimtype
			case 'noise'
				% low freq for bandwidth of noise (Hz)
				FREQ(1) = curve.FREQrange(1);
				% high freq. for BB noise (Hz)
				FREQ(2) = curve.FREQrange(end);
			otherwise
				warning([mfilename ': unsupported stimtype ' c.stimtype ' for curvetype ' c.curvetype])
				c = [];
				return
		end

	% freq tuning is tones-only
	case {'FREQ'}
		switch c.stimtype
			case 'tone'
				% freq. for tone (Hz)
				FREQ = curve.FREQrange;	
				% vary phase randomly from stim to stim 1 = yes, 0 = no
				% (consistent phase each time)
				c.radvary = curve.RadVary;	
			otherwise
				warning([mfilename ': unsupported stimtype ' c.stimtype ' for curvetype ' c.curvetype])
				c = [];
				return
		end
	
	otherwise
		warning([mfilename ': unsupported curvetype ' c.curvetype])
		c = [];
		return
end		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Randomize trial presentations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimseq = HPCurve_randomSequence(curve.nreps, curve.nTrials);
c.trialRandomSequence = stimseq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run through the dependent variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([mfilename ' is building stimuli for ' c.curvetype ' curve...'])
switch c.curvetype
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% ITD Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'ITD'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(curve.curvetype);
		c.vrange = curve.ITDrange;
		
		% for ITD curves, these parameters are fixed:
		ILD = curve.ILDrange(1);
		ABI = curve.ABIrange(1);
		BC = curve.BCrange(1);
		
		% spl_val sets the L and R channel db levels, and the ILD
		spl_val = computeLRspl(ILD, ABI);

		% If noise is frozen, generate zero ITD spectrum or tone
		if curve.freezeStim
			switch c.stimtype
				case 'noise'
					% get ITD = 0 Smag and Sphase
					[c.S0, c.Scale0, c.Smag0, c.Sphase0] = ...
						syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), 0, BC, caldata);
				case 'tone'
					% enforce rad_vary = 0
					[c.S0, c.Scale0] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), 0, 0, caldata);
			end
		end

		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:curve.nreps
			for trial = 1:curve.nTrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indexes stored in c.trialRandomSequence
				ITD = c.vrange(c.trialRandomSequence(rep, trial));

				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				if ~curve.freezeStim % stimulus is unfrozen
					switch c.stimtype
						case 'noise'
							[Sn, rmsval] = syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), ITD, BC, caldata);
						case 'tone'
							[Sn, rmsval] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), ITD, c.radvary, caldata);
					end
				else	% stimulus is frozen
					switch c.stimtype
						case 'noise'
							[Sn, rmsval] = syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), ITD, BC, caldata, c.Smag0, c.Sphase0);
						case 'tone'
							% enforce rad_vary = 0
							[Sn, rmsval] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), ITD, 0, caldata);
					end
				end

				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, stim.Ramp, outdev.Fs);

				% get the attenuator settings for the desired SPL
				atten = figure_headphone_atten(spl_val, rmsval, caldata);
% 				[atten, spl_val] = figure_headphone_atten(spl_val, rms_val, caldata, ...
% 												[stim.LSpeakerEnable stim.RSpeakerEnable]);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = ITD;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = spl_val;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.ITD(sindex) = ITD;
				c.ILD(sindex) = ILD;
				c.BC(sindex) = BC;
				c.FREQ{sindex} = FREQ;
				c.ABI(sindex) = ABI;

			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% ILD Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'ILD'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(curve.curvetype);
		c.vrange = curve.ILDrange;
		
		% for ITD curves, these parameters are fixed:
		ITD = curve.ITDrange(1);
		ABI = curve.ABIrange(1);
		BC = curve.BCrange(1);

		% If noise is frozen, generate zero ITD spectrum or tone
		if curve.freezeStim
			switch c.stimtype
				case 'noise'
					% get ITD = 0 Smag and Sphase
					[c.S0, c.Scale0, c.Smag0, c.Sphase0] = ...
						syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), 0, BC, caldata);
				case 'tone'
					% enforce rad_vary = 0
					[c.S0, c.Scale0] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), 0, 0, caldata);
			end
		end

		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:curve.nreps
			for trial = 1:curve.nTrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				ILD = c.vrange(c.trialRandomSequence(rep, trial));

				% compute new spl values from the desired ILD and ABI
				spl_val = computeLRspl(ILD, ABI);
			
				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				if ~curve.freezeStim % stimulus is unfrozen
					switch c.stimtype
						case 'noise'
							[Sn, rmsval] = syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), ITD, BC, caldata);
						case 'tone'
							[Sn, rmsval] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), ITD, c.radvary, caldata);
					end
				else	% stimulus is frozen
					switch c.stimtype
						case 'noise'
							[Sn, rmsval] = syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), ITD, BC, caldata, c.Smag0, c.Sphase0);
						case 'tone'
							% enforce rad_vary = 0
							[Sn, rmsval] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), ITD, 0, caldata);
					end
				end

				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, stim.Ramp, outdev.Fs);

				% get the attenuator settings for the desired SPL
				atten = figure_headphone_atten(spl_val, rmsval, caldata);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = ILD;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = spl_val;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.ITD(sindex) = ITD;
				c.ILD(sindex) = ILD;
				c.BC(sindex) = BC;
				c.FREQ{sindex} = FREQ;
				c.ABI(sindex) = ABI;
				
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% FREQ Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'FREQ'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(curve.curvetype);
		c.vrange = curve.FREQrange;
		
		% for FREQ curves, these parameters are fixed:
		ITD = curve.ITDrange(1);
		ILD = curve.ILDrange(1);
		ABI = curve.ABIrange(1);
		BC = curve.BCrange(1);

		% If noise is frozen, generate zero ITD  tone
		if curve.freezeStim
			% enforce rad_vary = 0
			[c.S0, c.Scale0] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), 0, 0, caldata);
		end

		% compute spl values from the desired ILD and ABI
		spl_val = computeLRspl(ILD, ABI);

		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:curve.nreps
			for trial = 1:curve.nTrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				FREQ = c.vrange(c.trialRandomSequence(rep, trial));

				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				if ~curve.freezeStim % stimulus is unfrozen
					[Sn, rmsval] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ, ITD, c.radvary, caldata);
				else	% stimulus is frozen
					% enforce rad_vary = 0, this fixes the starting phase at 0
					[Sn, rmsval] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ, ITD, 0, caldata);
				end

				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, stim.Ramp, outdev.Fs);

				% get the attenuator settings for the desired SPL
				atten = figure_headphone_atten(spl_val, rmsval, caldata);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = FREQ;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = spl_val;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.ITD(sindex) = ITD;
				c.ILD(sindex) = ILD;
				c.BC(sindex) = BC;
				c.FREQ{sindex} = FREQ;
				c.ABI(sindex) = ABI;
				
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% ABI Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'ABI'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(curve.curvetype);
		c.vrange = curve.ABIrange;
		
		% for ABI curves, these parameters are fixed:
		ITD = curve.ITDrange(1);
		ILD = curve.ILDrange(1);
		BC = curve.BCrange(1);

		% If noise is frozen, generate zero ITD spectrum or tone
		if curve.freezeStim
			switch c.stimtype
				case 'noise'
					% get ITD = 0 Smag and Sphase
					[c.S0, c.Scale0, c.Smag0, c.Sphase0] = ...
						syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), 0, BC, caldata);
				case 'tone'
					% enforce rad_vary = 0
					[c.S0, c.Scale0] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), 0, 0, caldata);
			end
		end

		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:curve.nreps
			for trial = 1:curve.nTrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				ABI = c.vrange(c.trialRandomSequence(rep, trial));

				% spl_val sets the L and R channel db levels, and the ILD
				spl_val = computeLRspl(ILD, ABI);

				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				if ~curve.freezeStim % stimulus is unfrozen
					switch c.stimtype
						case 'noise'
							[Sn, rmsval] = syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), ITD, BC, caldata);
						case 'tone'
							[Sn, rmsval] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), ITD, c.radvary, caldata);
					end
				else	% stimulus is frozen
					switch c.stimtype
						case 'noise'
							[Sn, rmsval] = syn_headphone_noise(stim.Duration, outdev.Fs, FREQ(1), FREQ(2), ITD, BC, caldata, c.Smag0, c.Sphase0);
						case 'tone'
							% enforce rad_vary = 0
							[Sn, rmsval] = syn_headphone_tone(stim.Duration, outdev.Fs, FREQ(1), ITD, 0, caldata);
					end
				end

				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, stim.Ramp, outdev.Fs);

				% get the attenuator settings for the desired SPL
				atten = figure_headphone_atten(spl_val, rmsval, caldata);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = ABI;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = spl_val;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.ITD(sindex) = ITD;
				c.ILD(sindex) = ILD;
				c.BC(sindex) = BC;
				c.FREQ{sindex} = FREQ;
				c.ABI(sindex) = ABI;
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% sAM % depth modulation Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'SAM_PERCENT'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(curve.curvetype);
		c.vrange = curve.sAMPCTrange;
		
		% for sAMPCT curves, these parameters are fixed:
		ITD = curve.ITDrange(1);
		ILD = curve.ILDrange(1);
		BC = curve.BCrange(1);
		ABI = curve.ABIrange(1);
		sAMFREQ = curve.sAMFREQrange(1);
		FREQ = [curve.FREQrange(1) curve.FREQrange(end)];
		
		% If noise is frozen, generate zero ITD spectrum or tone
		if curve.freezeStim
			% get ITD = 0 Smag and Sphase
			[c.S0, c.Scale0, c.ScaleMod0, c.ModPhi0, c.Smag0, c.Sphase0]  = ...
						syn_headphone_amnoise(stim.Duration, outdev.Fs, ...
														FREQ, 0, BC, ...
														50, sAMFREQ, 0, ...
														caldata);
		end

		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:curve.nreps
			for trial = 1:curve.nTrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				sAMPCT = c.vrange(c.trialRandomSequence(rep, trial));

				% spl_val sets the L and R channel db levels, and the ILD
				spl_val = computeLRspl(ILD, ABI);

				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				if ~curve.freezeStim % stimulus is unfrozen
					[Sn, rmsval, rms_mod, modPhi] = ...
						syn_headphone_amnoise(stim.Duration, outdev.Fs, ...
														FREQ, ITD, BC, ...
														sAMPCT, sAMFREQ, [], ...
														caldata);
				else	% stimulus is frozen
					[Sn, rmsval, rms_mod, modPhi] = ...
						syn_headphone_amnoise(stim.Duration, outdev.Fs, ...
														FREQ, ITD, BC, ...
														sAMPCT, sAMFREQ, 0, ...
														caldata, c.Smag0, c.Sphase0);
				end

				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, stim.Ramp, outdev.Fs);

				% get the attenuator settings for the desired SPL
				atten = figure_headphone_atten(spl_val, rms_mod, caldata);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = sAMPCT;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = spl_val;
				c.rmsval{sindex} = rms_mod;
				c.atten{sindex} = atten;
				c.ITD(sindex) = ITD;
				c.ILD(sindex) = ILD;
				c.BC(sindex) = BC;
				c.FREQ{sindex} = FREQ;
				c.ABI(sindex) = ABI;
				c.sAMPCT(sindex) = sAMPCT;
				c.sAMFREQ(sindex) = sAMFREQ;
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% sAM FREQ modulation Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'SAM_FREQ'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(curve.curvetype);
		c.vrange = curve.sAMFREQrange;
		
		% for sAMPCT curves, these parameters are fixed:
		FREQ = [curve.FREQrange(1) curve.FREQrange(end)];
		ITD = curve.ITDrange(1);
		ILD = curve.ILDrange(1);
		BC = curve.BCrange(1);
		ABI = curve.ABIrange(1);
		sAMPCT = curve.sAMPCTrange(1);
		
		% If noise is frozen, generate zero ITD spectrum or tone
		if curve.freezeStim
			% get ITD = 0 Smag and Sphase
			[c.S0, c.Scale0, c.ScaleMod0, c.ModPhi0, c.Smag0, c.Sphase0]  = ...
						syn_headphone_amnoise(stim.Duration, outdev.Fs, ...
														FREQ, 0, BC, ...
														sAMPCT, 0, 0, ...
														caldata);
		end

		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:curve.nreps
			for trial = 1:curve.nTrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				sAMFREQ = c.vrange(c.trialRandomSequence(rep, trial));

				% spl_val sets the L and R channel db levels, and the ILD
				spl_val = computeLRspl(ILD, ABI);

				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				if ~curve.freezeStim % stimulus is unfrozen
					[Sn, rmsval, rms_mod, modPhi] = ...
						syn_headphone_amnoise(stim.Duration, outdev.Fs, ...
														FREQ, ITD, BC, ...
														sAMPCT, sAMFREQ, [], ...
														caldata);
				else	% stimulus is frozen
					[Sn, rmsval, rms_mod, modPhi] = ...
						syn_headphone_amnoise(stim.Duration, outdev.Fs, ...
														FREQ, ITD, BC, ...
														sAMPCT, sAMFREQ, 0, ...
														caldata, c.Smag0, c.Sphase0);
				end

				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, stim.Ramp, outdev.Fs);

				% get the attenuator settings for the desired SPL
				atten = figure_headphone_atten(spl_val, rms_mod, caldata);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = sAMFREQ;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = spl_val;
				c.rmsval{sindex} = rms_mod;
				c.atten{sindex} = atten;
				c.ITD(sindex) = ITD;
				c.ILD(sindex) = ILD;
				c.BC(sindex) = BC;
				c.FREQ{sindex} = FREQ;
				c.ABI(sindex) = ABI;
				c.sAMPCT(sindex) = sAMPCT;
				c.sAMFREQ(sindex) = sAMFREQ;
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
	
	
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Unsupported
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	otherwise
		warning([mfilename ': that type of curve is not fully implemented... sorry.']);
		c = [];
		return
end
