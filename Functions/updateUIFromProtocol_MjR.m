function out = updateUIFromProtocol_MjR(gui, protocol)
%--------------------------------------------------------------------------
% out = updateUIFromProtocol(handles)
%--------------------------------------------------------------------------
% utility function for updating UI curve and setting info from the 
% HPSearch protocol structure
%
% MjR 2013 changes:
% All saved parameters are updated into the GUI only.
% There's no reason to load any parameters into handles - all structs are
% rewritten when a new stimulus is generated, which happens automatically
% after loading a protocol.
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
%   20 February, 2013 (MjR):
%      - changed function to mesh with PresentStimCurve.m rather than HPSearch
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the curve type on pulldown menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch protocol.curvetype
    case 'tAM_RISEFALL'
        disp('tAM_RISEFALL protocol selected');
		update_ui_val(gui.curvetype, 1);
    case 'tAM_MODDEPTH'
        disp('tAM_MODDEPTH protocol selected');
		update_ui_val(gui.curvetype, 2);
    case 'tAM_MODFREQ '
        disp('tAM_MODFREQ protocol selected');
		update_ui_val(gui.curvetype, 3);
    case 'DURATION'
        disp('DURATION protocol selected');
		update_ui_val(gui.curvetype, 4);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% other settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% curve strings/settings
vars = {'nReps','SPL','CF','BW','RiseFall','tAMDepth','tAMFreq',...
    'StimDur','StimInt','AcqDur','StimDelay','freezeStim'};
for n = 1:length(vars)
	update_ui_str(gui.(vars{n}), protocol.([vars{n} 'str']));
% 	update_ui_val(gui.(vars{n}), protocol.(vars{n}));
end

