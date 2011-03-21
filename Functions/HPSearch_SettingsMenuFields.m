function settingsfields = HPSearch_SettingsMenuFields(settings_struct_name)
%--------------------------------------------------------------------------
% settingsfields = HPSearch_SettingsMenuFields(settings_struct_name)
%--------------------------------------------------------------------------
% HPSearch Program
%--------------------------------------------------------------------------
% 
%	Returns the names of the user-editable fields in settings_struct_name.
% 
%--------------------------------------------------------------------------
% Input Arguments:
%	settings_struct_name		name of settings structure
% 		Permitted values:
% 			'STIM'		stimulus parameters (delay, duration, etc.)
% 			'TDT'			tdt I/O settings (gain, acq. duration)
% 			'ANALYSIS'	analysis information
% 			'ANIMAL'		animal ID, etc.
% 			'DISPLAY'	display information (UI)
% 
%--------------------------------------------------------------------------
% Output Arguments:
% 	settingsfields		structure with substruct text arrays
%
%--------------------------------------------------------------------------
% See Also: HPSearch_settingsUpdate, structdlg toolbox
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Revision History:
%	2 Nov 2009 (SJS): Created
%	3 Nov 2009 (SJS):	in progress
%	9 December, 2009 (SJS): added DISPLAY
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

% define the names of fields in each configuration structure that 
% will be allowed to be edited by users

switch upper(settings_struct_name)
	case 'STIM'
		settingsfields = {	'RadVary',
									'Duration',
									'Ramp',
									'Delay', 
									'freezeStim'	};

	case 'TDT'
		settingsfields = {	'StimInterval',
									'StimDuration',
									'AcqDuration',
									'SweepPeriod',
									'StimDelay',
									'HeadstageGain',
									'MonitorGain',
									'decifactor',
									'HPFreq',
									'LPFreq',
									'InputChannel',
									'OutputChannel',
									'TTLPulseDur'	};

	case 'ANALYSIS'
		settingsfields = {	'spikeWindow',
									'spikeStartTime',
									'spikeEndTime' };

	case 'ANIMAL'
		settingsfields =	{	'animalNumber',
									'expDate',
									'expTime',
									'penetration',
									'AP',
									'ML',
									'depth',
									'comments'	};

	case 'CURVE'
		settingsfields =	{	'nreps',
									'TempData',
									'saveStim',
									'RadVary',
									'freezeStim'	};
								
	case 'DISPLAY'
		settingsfields =	{	'RasterNumber'	};
								
	otherwise
		warning([mfilename ': unknown config structure ' settings_struct_name])
		settingsfields = {};
end
