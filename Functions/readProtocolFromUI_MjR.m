function out = readProtocolFromUI_MjR(gui, handles)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine the curve type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the Curve Types String (array of characters)
curveTypes = read_ui_str(gui.curvetype);
% retrieve the curve type string that is selected
selectedCurveString = curveTypes(read_ui_val(gui.curvetype),:);
switch selectedCurveString
    case 'tAM_RISEFALL'
        out.curvetype = 'tAM_RISEFALL';
    case 'tAM_MODDEPTH'
        out.curvetype = 'tAM_MODDEPTH';
    case 'tAM_MODFREQ '
        out.curvetype = 'tAM_MODFREQ';
    case 'DURATION    '
        out.curvetype = 'DURATION';
	otherwise
		out.curvetype = 'NO_IDEA_WHAT_CURVETYPE';
		warning('%s: no idea what type of curve %s is!!!!!', mfilename, selectedCurveString);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine the Stimulus type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% retrieve the stimulus type (determined by 1 or 2 values in CF)
selectedStimString = upper(handles.stim.type);
switch selectedStimString
	case 'NOISE'
		out.stimtype = 'NOISE';
	case 'TONE'
		out.stimtype = 'TONE';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%
% # of trials
%%%%%%%%%%%%%%%%%%%%%%%%%%
out.nTrials = handles.curve.nTrials;


%%%%%%%%%%%%%%%%%%%%%%%%%%
% other curve parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%
vars = {'nReps','SPL','CF','BW','RiseFall','tAMDepth','tAMFreq',...
    'StimDur','StimInt','AcqDur','StimDelay','freezeStim'};
for n = 1:length(vars)
	out.(vars{n}) = str2num(read_ui_str(gui.(vars{n})));    
	out.([vars{n} 'str']) = read_ui_str(gui.(vars{n}));
end


