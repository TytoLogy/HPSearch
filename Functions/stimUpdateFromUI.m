function out = stimUpdateFromUI(handles, varargin)
%------------------------------------------------------------------------
% out = stimUpdateFromUI(handles, varargin)
%------------------------------------------------------------------------
% HPSearch Program
%------------------------------------------------------------------------
% updates stimulus values from user interface controls
% 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: ???
%
% Revisions:
%	12 June, 2009 (SJS): revised documentation/help header
% 	19 June, 2009 (SJS): reworked Flo and Fhi assignment to read from text
%	19 November, 2009 (SJS): added sAM bits
%	9 December, 2009 (SJS): added L/R speaker Enable
%------------------------------------------------------------------------

out = handles.stim;

out.ITD = read_ui_val(handles.ITD);
out.ILD = read_ui_val(handles.ILD);
out.Latten = read_ui_val(handles.Latten);
out.Ratten = read_ui_val(handles.Ratten);
out.ABI = read_ui_val(handles.ABI);
out.BC = read_ui_val(handles.BC);
out.F = read_ui_val(handles.F);
out.BW = read_ui_val(handles.BW);
out.Flo = read_ui_str(handles.FreqMintext, 'n');
out.Fhi = read_ui_str(handles.FreqMaxtext, 'n');
out.sAMFreq = read_ui_val(handles.sAMFreq);
out.sAMPercent = read_ui_val(handles.sAMPercent);

searchStimVal = read_ui_val(handles.SearchStimulusTypeCtrl);

if searchStimVal == 2
	out.type = 'TONE';
elseif searchStimVal == 3
	out.type = 'SAM';
else	
	out.type = 'NOISE';
end

% allows speakers to be turned on/off
out.LSpeakerEnable = read_ui_val(handles.LSpeakerEnable);
out.RSpeakerEnable = read_ui_val(handles.RSpeakerEnable);





