function out = HPSearch_Configuration
%------------------------------------------------------------------------
% out = HPSearch_Configuration
%------------------------------------------------------------------------
% 
% Sets initial configuration for the HPSearch program
% 
% Comment out/in the settings for your configuration!
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	none
% 
% Output Arguments:
% 	out		struct containing settings for requested type
%------------------------------------------------------------------------
% See also: HPSearch, HPSearch_tdtinit
%------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	2 December, 2009 (SJS):
% 		-	added variables
% 				TYTOLOGY_ROOT_PATH
% 				TYTOLOGY_SETTINGS_PATH,
%				TYTOLOGY_PROTOCOL_PATH
% 				TDT_LOCK_FILE
%	3 Feb 2010 (SJS)
% 		- changed TDT_LOCK_FILE to TDTLOCKFILE
% 		- changed TytosettingsPath to TytoLogySettingsPath
%--------------------------------------------------------------------------
% TO DO: there's gotta be a better way to manage different hardware 
% 			setups.  
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNCOMMENT SECTION THAT WILL BE USED & 
% COMMENT OUT THE INAPPROPRIATE BITS!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is for using RX_8(2) for output (headphones) 
% and RX5 + medusa for spike input.
% used for single-channel recording
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out.CONFIGNAME = 'MEDUSA+HEADPHONES';
out.TDT = 'TDT:1CHANNEL+MASKER';
out.INDEV = 'INDEV:MEDUSA'; 
out.OUTDEV = 'OUTDEV:HEADPHONES+MASKER';
out.IOFUNCTION = @headphonestim_medusarec_1chan;
out.TDTSETFUNCTION = @HPSearch_medusasettings;
out.DATAPATH = pwd;
out.CALDATAPATH = 'C:\TytoLogy\Calibration\CalibrationData';
out.TYTOLOGY_ROOT_PATH = 'C:\TytoLogy';
out.TYTOLOGY_SETTINGS_PATH = TytoLogySettingsPath;
out.TYTOLOGY_PROTOCOL_PATH = [out.TYTOLOGY_SETTINGS_PATH 'Protocols\'];
out.TDTLOCKFILE = [out.TYTOLOGY_SETTINGS_PATH '.tdtlock.mat'];
%------------------------------------------------------------------------


