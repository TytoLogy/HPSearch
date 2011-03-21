function out = readProtocolFromUI(handles)
%--------------------------------------------------------------------------
% out = readProtocolFromUI(handles)
%--------------------------------------------------------------------------
%	utility function for reading curve and setting info from the HPSearch
%	GUI control objects
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% 
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	3 Feb 2009 (SJS): file created
%	5 November, 2009 (SJS):
% 		- added code for TempData, saveStim, RadVary, freezeStim variables
% 		- modified code to dynamically address struct fields
%	21 Nov, 2009 (SJS):
%		- re-did code for reading curve type and stimulus type due to change
%			from buttons to pull-down menu
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize an empty curve struct... this is more to keep track of things
% than for any funtional reason
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out.curvetype = [];			% type of curve
out.stimtype = [];			% type of stimulus
out.nreps = [];				% # of reps
out.ITDrangestr = [];		% ITD range
out.ITDrange = [];
out.ILDrangestr = [];		% ILD range
out.ILDrange = [];
out.ABIrangestr = [];		% ABI range
out.ABIrange = [];
out.FREQrangestr = [];		% FREQ range
out.FREQrange = [];
out.BCrangestr = [];			% BC range (%)
out.BCrange = [];
out.nTrials = [];
out.TempData = [];
out.saveStim = [];
out.RadVary = [];
out.freezeStim = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine the curve type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% OLD METHOD FOR BUTTONS 
% H_CurveType = get(handles.cCurveType, 'Children');
% valFlags = zeros(size(H_CurveType));
% for hIndex = 1:length(H_CurveType)
% 	valFlags(hIndex) = get(H_CurveType(hIndex), 'Value');
% 	valTags{hIndex} = get(H_CurveType(hIndex), 'Tag');
% end
% [typeIndex] = find(valFlags > 0);
% if ~isempty(typeIndex)
% 	curvetype = get(H_CurveType(typeIndex), 'Tag');
% else
% 	warning([mfilename ': curvetype is undefined!'])
% 	return
% end
% out.curvetype = curvetype;
%%%%%%%%%%%% NEW METHOD 
% get the Curve Types String (cell array)
curveTypes = read_ui_str(handles.cCurveTypeCtrl);
% retrieve the curve type string that is selected
selectedCurveString = upper(curveTypes{read_ui_val(handles.cCurveTypeCtrl)});
switch selectedCurveString
	case 'ITD'
		out.curvetype = 'ITD';
	case 'ILD'
		out.curvetype  = 'ILD';
	case 'FREQ'
		out.curvetype = 'FREQ';
	case 'BC'
		out.curvetype = 'BC';
	case 'ABI'
		out.curvetype = 'ABI';
	case 'SAM_PERCENT'
		out.curvetype = 'SAM_PERCENT';
	case 'SAM_FREQ'
		out.curvetype = 'SAM_FREQ';
	otherwise
		out.curvetype = 'NO_IDEA_WHAT_CURVETYPE';
		warning('%s: no idea what type of curve %s is!!!!!', mfilename, selectedCurveString);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine the Stimulus type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% OLD METHOD FOR BUTTONS 
% H_StimType = get(handles.cStimType, 'Children');
% for hIndex = 1:length(H_StimType)
% 	if get(H_StimType(hIndex), 'Value')
% 		stimtype = get(H_StimType(hIndex), 'Tag');
% 	end
% end
% out.stimtype = stimtype;
%%%%%%%%%%%% NEW METHOD 
% get the Stimulus Types String (cell array)
stimTypes = read_ui_str(handles.cStimulusTypeCtrl);
% retrieve the stimulus type string that is selected
selectedStimString = upper(stimTypes{read_ui_val(handles.cStimulusTypeCtrl)});
switch selectedStimString
	case 'NOISE'
		out.stimtype = 'NOISE';
	case 'TONE'
		out.stimtype = 'TONE';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% # of reps
%%%%%%%%%%%%%%%%%%%%%%%%%%
out.nreps = round(read_ui_str(handles.cNreps, 'n'));

%%%%%%%%%%%%%%%%%%%%%%%%%%
% ranges/values
%%%%%%%%%%%%%%%%%%%%%%%%%%
% vars = {'ITDrange', 'ILDrange', 'ABIrange', 'FREQrange', 'BCrange'};
% ctrls = {'cITDrange', 'cILDrange', 'cABIrange', 'cFREQrange', 'cBCrange'};	
vars = HPSearch_init('PROTOCOL_RANGES');
ctrls = vars;
for n = 1:length(vars)
	ctrls{n} = ['c' ctrls{n}];
	out.([vars{n} 'str']) = read_ui_str(handles.(ctrls{n}));
	out.(vars{n}) = eval(out.([vars{n} 'str']));
end	

% ITD range
% 	out.ITDrangestr = read_ui_str(handles.cITDrange);
% 	out.ITDrange = eval(out.ITDrangestr);
% ILD range
% 	out.ILDrangestr = read_ui_str(handles.cILDrange);
% 	out.ILDrange =  eval(out.ILDrangestr);
% ABI range
% 	out.ABIrangestr = read_ui_str(handles.cABIrange);
% 	out.ABIrange = eval(out.ABIrangestr);
% FREQ range
% 	out.FREQrangestr = read_ui_str(handles.cFREQrange);
% 	out.FREQrange = eval(out.FREQrangestr);
% BC range (%)
% 	out.BCrangestr = read_ui_str(handles.cBCrange);
% 	out.BCrange = eval(out.BCrangestr);

switch out.curvetype   % Get Tag of selected object
	case 'ITD'
		out.nTrials = length(out.ITDrange);
	case 'ILD'
		out.nTrials = length(out.ILDrange);
	case 'FREQ'
		out.nTrials = length(out.FREQrange);
	case 'BC'
		out.nTrials = length(out.BCrange);
	case 'ABI'
		out.nTrials = length(out.ABIrange);
	case 'SAM_PERCENT'
		out.nTrials = length(out.sAMPCTrange);
	case 'SAM_FREQ'
		out.nTrials = length(out.sAMFREQrange);
	otherwise
		warning([mfilename ': curvetype is undefined! ' out.curvetype])
		return		
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
% other curve parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%
vars = {'TempData', 'saveStim', 'RadVary', 'freezeStim'};
ctrls = {'TempDataCtrl', 'SaveStimCtrl', 'RadVaryCtrl', 'FreezeStimCtrl'};	
for n = 1:length(vars)
	out.(vars{n}) = read_ui_val(handles.(ctrls{n}));
end
