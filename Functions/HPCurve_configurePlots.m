%--------------------------------------------------------------------------
% HPCurve_configurePlots.m
%--------------------------------------------------------------------------
% 
% Script to consolidate code for setting up plots used in the HPCurve_*.m
% scripts
%--------------------------------------------------------------------------
% See Also: HPCurve_ILD, HPCurve_ITD, HPSearch
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Revision History
%
%	6 November, 2009 (SJS):
% 		- Created from HPCurve_ITD.m to modularize plot setup
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a figure window if an axes handle wasn't given
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(varargin)
	switch length(varargin)
		case 1
			axes(varargin{1});
			RespPlot = gca;
		case 2
			axes(varargin{1});
			RespPlot = gca;
			axes(varargin{2});
			RasterPlot = gca
		case 3
			axes(varargin{1});
			RespPlot = gca;
			axes(varargin{2});
			RasterPlot = gca
			feedbackText = varargin{3};
	end
else % create new figure window and axes
	CurveFig = figure;
	RespPlot = subplot(211);
	RasterPlot = subplot(212);
	feedbackText = uicontrol(CurveFig,	'Style',	'text', ...
													'String', 'feedbackText', ...
													'Position', [100 0 300 15]);
end

