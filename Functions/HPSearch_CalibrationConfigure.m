% HPSearch_CalibrationConfigure.m
%------------------------------------------------------------------------
% 
% Script that sets up Calibration
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 2 December, 2009
%
% Revisions:
%	10 March, 2010 (SJS):	added some disp() statements to give more user 
%									feedback about what's being loaded
%------------------------------------------------------------------------
% To Do:
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set default calibration file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.caldatafile = 'ear_cal.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first, check if the current directory has calibration data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
current_path = pwd;
if exist(fullfile(current_path, handles.caldatafile), 'file')
	% if so, use current directory as the calibration data path
	handles.caldatapath = current_path;
	disp(sprintf('ear_cal.mat found in current path (%s)', handles.caldatapath));

else
	% otherwise, use the default value set in handles.config.CALDATAPATH
	disp(sprintf('Could not find ear_cal.mat in current directory (%s).', ...
						current_path));
	disp(sprintf('...using default path (%s)', handles.config.CALDATAPATH));
	handles.caldatapath = handles.config.CALDATAPATH;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build the full path+filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
calfile = fullfile(handles.caldatapath, handles.caldatafile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open the file if it exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist(calfile, 'file')
	handles.caldata = load_headphone_cal(calfile);
	handles.Lim.F = [handles.caldata.freq(1) handles.caldata.freq(end)];
	set(handles.F, 'Min', handles.Lim.F(1));
	set(handles.F, 'Max', handles.Lim.F(2));
	update_ui_val(handles.F, handles.Lim.F(1));
else
	% otherwise, reveal error and leave caldata empty
	tmptxt = ['ear_cal.mat calibration file not found in directory '...
					handles.caldatapath];
	errordlg(tmptxt, 'HPSearch error...')
	handles.caldata = [];
end
