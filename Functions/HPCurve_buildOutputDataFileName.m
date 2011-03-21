function [curvefile, curvepath, curvefilename] = HPCurve_buildOutputDataFileName(handles, exptime)
%--------------------------------------------------------------------------
% datafilename = HPCurve_buildOutputDataFileName(handles, exptime)
%--------------------------------------------------------------------------
% 
% generates the output data filename
%
%--------------------------------------------------------------------------
% Input Arguments:
% 
% 	handles				TDT HW structure for zBUS
%	exptime				matlab time value (from NOW matlab command)
%
% Output arguments:
%	curvefile			full data file path and filename string
% 	curvepath			path to data file
% 	curvefilename		data file name
%
%--------------------------------------------------------------------------
% See Also: HPCurve, HPSearch, HPSearch_Run
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Created: 2 March, 2010 (SJS)
% 
% Revision History:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get data filename info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if temp file box is checked
if read_ui_val(handles.TempDataCtrl)
	disp('will save to temporary (temp.dat) file');
	% write to temp file instead
	curvepath = pwd;
	curvefilename = 'temp.dat';
else
	% build proposed file name
	curvefilename = sprintf('%s_%s_%s.dat', ... 
				handles.animal.animalNumber, ...
				datestr(exptime, 'ddmmyy-ss'), ...
				handles.curve.curvetype);			
	% get a data file name
	[curvefilename, curvepath] = uiputfile('*.dat', 'Save experiment curve data in file', curvefilename);
	% if curvefilename == 0 , user selected 'cancel', so cancel 
	% the running of curve and return from function
	if curvefilename == 0
		curvefile = 0;
		curvepath = 0;
		return
	end
end

% create the .dat file name for writing the binary data to disk
curvefile = fullfile(curvepath, curvefilename);

