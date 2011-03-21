function out = updateUIFromProtocol(handles, protocol)
%--------------------------------------------------------------------------
% out = updateUIFromProtocol(handles)
%--------------------------------------------------------------------------
% utility function for updating UI curve and setting info from the 
% HPSearch protocol structure
%
%--------------------------------------------------------------------------
% Input Arguments:
% 	handles		handles structure from UI
% 	protocol		HPSearch protocol structure
% 	
% Output Arguments:
% 	out			curve structure
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	3 Feb 2009 (SJS): file created
%	5 November, 2009 (SJS): updated for new controls for Temp Data, radvary
%									savestim and frozen noise
%	21 November, 2009 (SJS):
% 		- added sAM % and frequency (sAMPCTrange, sAMFREQrange), etc.
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the curve type on pulldown menu
% CITD, CILD, etc are for legacy protocols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch upper(protocol.curvetype)
	case {'ITD', 'CITD'}
		disp('ITD protocol selected');
		update_ui_val(handles.cCurveTypeCtrl, 1);
	case {'ILD', 'CILD'}
		disp('ILD protocol selected');
		update_ui_val(handles.cCurveTypeCtrl, 2);
	case {'FREQ', 'CFREQ'}
		disp('FREQ protocol selected');
		update_ui_val(handles.cCurveTypeCtrl, 3);
	case {'BC', 'CBC'}
		disp('BC protocol selected');
		update_ui_val(handles.cCurveTypeCtrl, 4);
	case {'ABI', 'CABI'}
		disp('ABI protocol selected');
		update_ui_val(handles.cCurveTypeCtrl, 5);
	case 'SAM_PERCENT'
		disp('sAM Percent protocol selected');
		update_ui_val(handles.cCurveTypeCtrl, 6);
	case 'SAM_FREQ'
		disp('sAM Frequency protocol selected');
		update_ui_val(handles.cCurveTypeCtrl, 7);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the Stimulus type
% CNOISE, CTONE are for legacy protocols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% then set the proper stimulus type
switch upper(protocol.stimtype)
	case {'NOISE', 'CNOISE'}
		disp('Noise protocol');
		update_ui_val(handles.cStimulusTypeCtrl, 1);
	case {'TONE', 'CTONE'}
		disp('Tone protocol');
		update_ui_val(handles.cStimulusTypeCtrl, 2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% other settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # of reps
update_ui_str(handles.cNreps, protocol.nreps);
% curve strings/settings
vars = {'ITDrange', 'ILDrange', 'ABIrange', 'FREQrange', 'BCrange', 'sAMPCTrange', 'sAMFREQrange'};
ctrls = {'cITDrange', 'cILDrange', 'cABIrange', 'cFREQrange', 'cBCrange', 'csAMPCTrange', 'csAMFREQrange'};
for n = 1:length(vars)
	update_ui_str(handles.(ctrls{n}), protocol.([vars{n} 'str']));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create an updated curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% OLD 
% out.curvetype = protocol.curvetype;				% type of curve
% out.stimtype = protocol.stimtype					% type of stimulus
% out.nreps = protocol.nreps;						% # of reps
% out.ITDrangestr = protocol.ITDrangestr;		% ITD range	(usec)
% out.ILDrangestr = protocol.ILDrangestr;		% ILD range	(dB SPL)
% out.ABIrangestr = protocol.ABIrangestr;		% ABI range	(dB SPL)
% out.FREQrangestr = protocol.FREQrangestr;		% FREQ range	(Hz)
% out.BCrangestr = protocol.BCrangestr;			% BC range (%)
% out.sAMPCTrangestr = protocol.sAMPCTrangestr;			% sAM Percent range (%)
% out.sAMFREQrangestr = protocol.sAMFREQrangestr;			% sAM Frequency range Hz)
%%%%%%%%%%%%% NEW
protfields = HPSearch_init('PROTOCOL_FIELDS');
for n = 1:length(protfields)
	out.(protfields{n}) = protocol.(protfields{n});
end

%%%%%%%%%%% OLD 
% out.ITDrange = eval(out.ITDrangestr);
% out.ILDrange = eval(out.ILDrangestr);
% out.ABIrange = eval(out.ABIrangestr);
% out.FREQrange = eval(out.FREQrangestr);
% out.BCrange = eval(out.BCrangestr);
% out.sAMPCTrange = eval(out.sAMPCTrangestr);
% out.sAMFREQrange = eval(out.sAMFREQrangestr);
%%%%%%%%%%%%% NEW
protranges = HPSearch_init('PROTOCOL_RANGES');
for n = 1:length(protranges)
	out.(protranges{n}) = eval( out.([protranges{n} 'str']) );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% other curve parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vars = {'TempData', 'saveStim', 'RadVary', 'freezeStim'};
ctrls = {'TempDataCtrl', 'SaveStimCtrl', 'RadVaryCtrl', 'FreezeStimCtrl'};	
for n = 1:length(vars)
	update_ui_val(handles.(ctrls{n}), protocol.(vars{n}));
	out.(vars{n}) = read_ui_val(handles.(ctrls{n}));
	update_checkbox(handles.(ctrls{n}));
end
