function out = updateUIfromStim(handles, stim)
%--------------------------------------------------------------------------
% out = updateUIfromStim(handles, stim)
%--------------------------------------------------------------------------
% HPSearch Program
%--------------------------------------------------------------------------
%	Input:
% 		handles		UI handles
% 		stim			stimulus settings struct
% 	
% 	Output:
% 		out			updated stimulus settings (in stim struct format)
%--------------------------------------------------------------------------
% See Also: updateUIFromProtocol, readProtocolFromUI
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	3 Feb 2009 (SJS): updated help/comments section that you are reading...
%	22 June, 2009 (SJS): added Freq min & max text updating
%	19 November, 2009 (SJS):
% 		- added sAM bits
%	2 December, 2009 (SJS): some documentation updates
%	9 December, 2009 (SJS): added L/R speaker Enable
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

% make a copy of the stim struct
out = stim;

% update values from stim
update_ui_val(handles.ITD, stim.ITD);
update_ui_val(handles.ILD, stim.ILD);
update_ui_val(handles.Latten, stim.Latten);
update_ui_val(handles.Ratten, stim.Ratten);
update_ui_val(handles.ABI, stim.ABI);
update_ui_val(handles.BC, stim.BC);
update_ui_val(handles.F, stim.F);
update_ui_val(handles.BW, stim.BW);
update_ui_str(handles.FreqMaxtext, stim.Fhi);
update_ui_str(handles.FreqMintext, stim.Flo);
switch upper(stim.type)
	case 'NOISE'
		update_ui_val(handles.SearchStimulusTypeCtrl, 1);
		out.type = 'NOISE';
	case 'TONE'
		update_ui_val(handles.SearchStimulusTypeCtrl, 2);
		out.type = 'TONE';
	case 'SAM'
		update_ui_val(handles.SearchStimulusTypeCtrl, 3);
		out.type = 'SAM';
end
update_ui_val(handles.sAMFreq, stim.sAMFreq);
update_ui_val(handles.sAMPercent, stim.sAMPercent);
% change UI to suit type of stim
sAMhandles = get(handles.sAMPanel, 'Children');
switch upper(stim.type)
	case {'NOISE', 'TONE'}
		for n = 1:length(sAMhandles)
			hide_uictrl(sAMhandles(n));
		end
		set(handles.sAMPanel, 'Visible', 'off');
		set(handles.lsAMPercent, 'Visible', 'off');
		set(handles.lsAMFreq, 'Visible', 'off');
	case 'SAM'
		for n = 1:length(sAMhandles)
			show_uictrl(sAMhandles(n));
		end
		set(handles.sAMPanel, 'Visible', 'on');
		set(handles.lsAMPercent, 'Visible', 'on');
		set(handles.lsAMFreq, 'Visible', 'on');
end

% L/R enable
update_ui_val(handles.LSpeakerEnable, stim.LSpeakerEnable);
update_ui_val(handles.RSpeakerEnable, stim.RSpeakerEnable);

out.ITD = slider_update(handles.ITD, handles.ITDtext);
out.ILD = slider_update(handles.ILD, handles.ILDtext);
out.Latten = slider_update(handles.Latten, handles.LAttentext);
out.Ratten = slider_update(handles.Ratten, handles.RAttentext);
out.ABI = slider_update(handles.ABI, handles.ABItext);
out.BC = slider_update(handles.BC, handles.BCtext);
out.F = slider_update(handles.F, handles.Ftext);
out.BW = slider_update(handles.BW, handles.BWtext);
out.Flo = read_ui_str(handles.FreqMintext, 'n');
out.Fhi = read_ui_str(handles.FreqMaxtext, 'n');
out.sAMFreq = slider_update(handles.sAMFreq, handles.sAMFreqtext);
out.sAMPercent = slider_update(handles.sAMPercent, handles.sAMPercenttext);
out.LSpeakerEnable = read_ui_val(handles.LSpeakerEnable);
out.RSpeakerEnable = read_ui_val(handles.RSpeakerEnable);

