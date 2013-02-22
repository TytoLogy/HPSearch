calfile = ['C:\TytoLogy\Calibration\CalibrationData\' username ...
						'\test.cal'];

%----------------------------------------------------------------
%% load settings
%----------------------------------------------------------------
caltest_settings

%----------------------------------------------------------------
%% load calibration data
%----------------------------------------------------------------
caldata = load_headphone_cal(calfile);
caldata = calchancopy(caldata, 2, 1);
iodev.Fs = 100000;

%----------------------------------------------------------------
%% TDT init
%----------------------------------------------------------------
tdtinit;

%----------------------------------------------------------------
%% Synthesize noise and get rms values for attenuator
%----------------------------------------------------------------
[Sn, rmsval] = syn_headphone_noise(StimDuration, iodev.Fs, Fmin, Fmax, 0, 100, caldata);
spl_val = 20*[1 1];
figure(100);
plot(Sn(R, :), 'r')
fprintf('\n\nSntest RMS: %f\n', rmsval(R));
fprintf('spl desired: %d\n', spl_val(R));
fprintf('Predicted, zeroatten db SPL: %f\n', dbspl(VtoPa * rmsval(R)));
fprintf('atten (db): %f\n', caldata.mindbspl(R) + db(rmsval(R)) - spl_val(R));
fprintf('atten (db SPL): %f\n', caldata.mindbspl(R) + dbspl(VtoPa*rmsval(R)) - spl_val(R));
fprintf('atten2 (db SPL): %f\n', dbspl(VtoPa*rmsval(R)) - spl_val(R));
atten = figure_headphone_atten(spl_val, rmsval, caldata);
fprintf('figure atten (db): %f\n', atten(R));

%----------------------------------------------------------------
%% set the start and end bins for the data acquisition
%---------------------------------------------------------------- 
zerostim = syn_null(StimDuration, iodev.Fs, MONO);
% get the # of points to send out and to collect
acqpts = ms2samples(AcqDuration, iodev.Fs);
outpts = length(zerostim);
% time vector for plots
dt = 1/iodev.Fs;
tvec = 1000*dt*(0:(acqpts-1));
stim_start = ms2samples(StimDelay, iodev.Fs);
stim_end = stim_start + ms2samples(StimDuration, iodev.Fs);
start_bin = stim_start + ms2samples(StimRamp, iodev.Fs);
end_bin = stim_end - ms2samples(StimRamp, iodev.Fs);

%---------------------------------------------------------------- 
%% setup storage for data
%---------------------------------------------------------------- 
% data.mags = zeros(Nchannels, Nspeakers);
% 	data.phis = cell(Nchannels, Nspeakers);
% 	data.stim = cell(Nreps, 1);
% 	data.resp = cell(Nreps, 2);
% 	
% 	for channel = 1:Nchannels
% 		for spkr = 1:Nspeakers
% 			data.mags{channel, spkr} = zeros(Nreps);
% 			data.phis{channel, spkr} = zeros(Nreps);
% 		end
% 	end
% 	data.atten = zeros(Nreps, Nspeakers);
% 	data.rmsvals = zeros(Nreps, Nspeakers);
	
%---------------------------------------------------------------- 
%% setup plots
%---------------------------------------------------------------- 
figure(10)
nplots = 2;
h.stimplot = subplot(nplots, 1, 1);
h.micplot = subplot(nplots, 1, 2);	
% figure(11)
% h.PSDL = subplot(211);
% h.PSDR = subplot(212);
	
%---------------------------------------------------------------- 
%% Now initiate sweeps
%---------------------------------------------------------------- 
spl_val = 45*[1 1];
Fmin = 1000;
Fmax = 14000;
atten = [120 120];


% loop through reps
for rep = 1:Nreps

	% Synthesize tone and get rms values for attenuator
	[Sn, rmsval] = syn_headphone_noise(StimDuration, iodev.Fs, Fmin, Fmax, 0, 100, caldata);
	% ramp the sound on and off (important!)
	Sn = sin2array(Sn, StimRamp, iodev.Fs);
	plot(h.stimplot, Sn(R, :), 'r');

% 	data.rmsvals(rep, :) = rmsval;
% 	data.stim{rep} = Sn;

	% get the attenuator settings for the desired SPL
	% 	atten = figure_headphone_atten(spl_val, rmsval, caldata);

	predicted_spl = dbspl(VtoPa*rmsval(R));
	atten(R) = predicted_spl - spl_val(R);
	if atten(R) <= 0
		atten(R) = 0;
		fprintf('requested rspl too high\n')
	end
	atten(L) = MAX_ATTEN;
	% set the attenuators
	PA5setatten(PA5L, atten(L));
	PA5setatten(PA5R, atten(R));

	% play the sound and return the response
	[resp, rate] = headphone_io(iodev, Sn, acqpts);

	% determine the magnitude of the response
	lmagraw = rms(resp{L}(stim_start:stim_end));
	rmagraw = rms(resp{R}(stim_start:stim_end));
	lmag = lmagraw / Gain(L);
	rmag = rmagraw / Gain(R);

% 	data.mags{L, L}(rep) = lmag;
% 	data.mags{R, L}(rep) = rmag;
% 	data.mags{REF, L}(rep) = refmag;
% 	data.atten(rep, L) = atten(1);
% 	data.resp{rep, L} = cell2mat(resp');

	% display some things
	fprintf('-------------------------------------------------------\n')
	fprintf('-------------------------------------------------------\n')
	fprintf('REP %d:\n\n', rep);
	fprintf('\tDesired dB: %d \t Ratten: %.2f \t Stim rms: %.4f \n', spl_val(R), atten(R), rmsval(R));
	fprintf('\tPredicted dB SPL: %.2f\n', dbspl(VtoPa*rmsval(R)))
	fprintf('\tActual mic dB SPL: %.2f\n', dbspl(VtoPa*rmag))
	fprintf('\tError from desired: %.2f\n', dbspl(VtoPa*rmag) - spl_val(R))
	fprintf('\tPrediction Error: %.2f\n',  dbspl(VtoPa*rmsval(R)) - dbspl(VtoPa*rmag))
	fprintf('-------------------------------------------------------\n')
	fprintf('-------------------------------------------------------\n\n\n')
	
	plot(h.micplot, tvec, resp{R}, 'r');

	[St, Smag, Sphi, F] = fftdbplot(resp{2}, iodev.Fs, figure(20));
	figure(21)
	plot(F, Smag)
	
	% pause for the stimulus interval (stim.Delay)
	pause(0.001*StimInterval);

end

% data.f = Freqs;

%---------------------------------------------------------------- 
%% Exit gracefully (close TDT objects, etc)
%---------------------------------------------------------------- 
tdtexit;
	
%---------------------------------------------------------------- 
%% Process data
%---------------------------------------------------------------- 
% 	data.Ldb_refmic = dbspl(VtoPa*mean(data.mags{REF, L}'));
% 	data.Ldb_lmic = dbspl(VtoPa * mean(data.mags{L, L}')./frdata.lmagadjval);
% 	data.Ldb_rmic = dbspl(VtoPa * mean(data.mags{R, L}')./frdata.rmagadjval);
% 	data.Rdb_refmic = dbspl(VtoPa*mean(data.mags{REF, R}'));
% 	data.Rdb_rmic = dbspl(VtoPa * mean(data.mags{R, R}')./frdata.rmagadjval);
% 	data.Rdb_lmic = dbspl(VtoPa * mean(data.mags{L, R}')./frdata.lmagadjval);
% 	data.Lphase_refmic = unwrap(mean(data.phis{REF, L}'));
% 	data.Lphase_lmic = unwrap(mean(data.phis{L, L}') - frdata.lphiadjval);
% 	data.Lphase_rmic = unwrap(mean(data.phis{R, L}') - frdata.rphiadjval);
% 
% 	data.Rphase_refmic = unwrap(mean(data.phis{REF, R}'));
% 	data.Rphase_rmic = unwrap(mean(data.phis{R, R}') - frdata.rphiadjval);
% 	data.Rphase_lmic = unwrap(mean(data.phis{L, R}') - frdata.lphiadjval);
% 	data.ILD_refmic = data.Rdb_refmic - data.Ldb_refmic;
% 	data.ILD_lmic = data.Rdb_lmic - data.Ldb_lmic;
% 	data.ILD_rmic = data.Rdb_rmic - data.Ldb_rmic;
% 	data.ITD_refmic = (data.Rphase_refmic - data.Lphase_refmic)./data.f;
% 	data.ITD_lmic = (data.Rphase_lmic - data.Lphase_lmic)./data.f;
% 	data.ITD_rmic = (data.Rphase_rmic - data.Lphase_rmic)./data.f;

%---------------------------------------------------------------- 
%% PLOTS
%---------------------------------------------------------------- 
% 	rep = 1;
% 	axes(h.PSDL)
% 	pwelch(data.resp{rep, L}(L, :), length(data.resp{rep, L}(L, :)), [], [], iodev.Fs)
% 	axes(h.PSDR)
% 	pwelch(data.resp{rep, R}(R, :), length(data.resp{rep, R}(R, :)), [], [], iodev.Fs)
% 	data
	
%---------------------------------------------------------------- 
%% save handles and data and temp file
%---------------------------------------------------------------- 	
% 	if exist('calsoundfilename', 'var')
% 		if ischar(calsoundfilename)
% 			save(calsoundfilename, 'data', 'caldata', 'frdata', '-mat');
% 			save([mfilename '.mat'], 'data', 'caldata', 'frdata', '-mat');
% 		end
% 	else
% 		save([mfilename '.mat'], 'data', 'caldata', 'frdata', '-mat');	
% 	end
% 	
% 	saveas(gcf, 'calsounds_test.fig')
