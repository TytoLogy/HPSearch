function curve = curveUpdateFromUI(handles, varargin)
%--------------------------------------------------------------------------
% curve = curveUpdateFromUI(handles, varargin)
%--------------------------------------------------------------------------
% utility function for updating curve structure from HPSearch UI 
% 
%--------------------------------------------------------------------------
% Input Arguments:
%	handles		handles from HPSearch 
% 
% Output Arguments:
%	curve			curve settings structure
%--------------------------------------------------------------------------
% See Also: HPSearch
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag 
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Revision History
% 	5 November, 2009 (SJS):
% 		- updated documentation
% 		- updated for new controls for Temp Data, radvary, 
% 			savestim and frozen noise 
%	19 November, 2009 (SJS):
% 		- changes to account for pull-down menu selection controls for
% 			curve type and stim type
%	1 December, 2009 (SJS):
% 		- added bits for sAM curves
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a local copy of curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve = handles.curve;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Curve range strings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve.ITDrangestr = read_ui_str(handles.cITDrange);
curve.ILDrangestr = read_ui_str(handles.cILDrange);
curve.ABIrangestr = read_ui_str(handles.cABIrange);
curve.FREQrangestr = read_ui_str(handles.cFREQrange);
curve.BCrangestr = read_ui_str(handles.cBCrange);
curve.sAMPCTrangestr = read_ui_str(handles.csAMPCTrange);
curve.sAMFREQrangestr = read_ui_str(handles.csAMFREQrange);

% numeric values from strings
curve.ITDrange = eval(curve.ITDrangestr);
curve.ILDrange = eval(curve.ILDrangestr);
curve.ABIrange = eval(curve.ABIrangestr);
curve.FREQrange = eval(curve.FREQrangestr);
curve.BCrange = eval(curve.BCrangestr);
curve.sAMPCTrange	= eval(curve.sAMPCTrangestr);
curve.sAMFREQrange = eval(curve.sAMFREQrangestr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # reps per stim value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve.nreps = round(read_ui_str(handles.cNreps, 'n'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Type of Curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the Curve Types String (cell array)
curveTypes = read_ui_str(handles.cCurveTypeCtrl);
% retrieve the curve type string that is selected
curvetype = upper(curveTypes{read_ui_val(handles.cCurveTypeCtrl)});

disp([mfilename ': curvetype = ' curvetype]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # of trials (# of stim values)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch curvetype   % Get Tag of selected object
	case 'ITD'
		curve.curvetype = 'ITD';
		curve.nTrials = length(curve.ITDrange);
	case 'ILD'
		curve.curvetype = 'ILD';
		curve.nTrials = length(curve.ILDrange);
	case 'FREQ'
		curve.curvetype = 'FREQ';
		curve.nTrials = length(curve.FREQrange);
	case 'BC'
		curve.curvetype = 'BC';
		curve.nTrials = length(curve.BCrange);
	case 'ABI'
		curve.curvetype = 'ABI';
		curve.nTrials = length(curve.ABIrange);
	case 'SAM_PERCENT'
		curve.curvetype = 'SAM_PERCENT';
		curve.nTrials = length(curve.sAMPCTrange);		
	case 'SAM_FREQ'
		curve.curvetype = 'SAM_FREQ';
		curve.nTrials = length(curve.sAMFREQrange);		
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimTypes = read_ui_str(handles.cStimulusTypeCtrl);
stimtype = upper(stimTypes{read_ui_val(handles.cStimulusTypeCtrl)});
switch stimtype
	case 'NOISE'
		curve.stimtype = 'NOISE';
	case 'TONE'
		curve.stimtype = 'TONE';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% other curve/stim parameters
% (added 5 Nov 09, SJS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve.TempData = read_ui_val(handles.TempDataCtrl);
curve.saveStim = read_ui_val(handles.SaveStimCtrl);
curve.RadVary = read_ui_val(handles.RadVaryCtrl);
curve.freezeStim = read_ui_val(handles.FreezeStimCtrl);
