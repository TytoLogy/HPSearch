function outval = checkCurveLimits(val, lim)
% outval = checkCurveLimits(val, lim)
%
% returns 1 if lim(1) <= val <= lim(2), 0 otherwise
%
% Examples:
% 
% 		>> checklim(1, [0 10])
%		ans =
%			 1
% 
% 		>> checklim([0 99], [-1 10])
% 
% 		ans =
% 
% 			 0
% 
% Input Arguments:
% val		value to test
% lim		[min max] limit vector
% 
% Output Arguments:
% 	0		val is out of bounds or invalid val or lim 
% 	1		in bounds
%
% See Also: between,  range

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbha@aecom.yu.edu
%--------------------------------------------------------------------------
% Created:
%	9 Mar 2009 2009 (SJS): adapted from checklim()
% 
% Revision History
%--------------------------------------------------------------------------
% TO DO:
%	* what to about case where length(val) == 2 and val(1) > val(2)????
%--------------------------------------------------------------------------

outval = 0;


if ~isnumeric(val) | ~isnumeric(lim)
	% return 0 if inputs are not numeric
	warning([mfilename ': val & lim must be numeric!']);
	return
elseif length(lim) ~= 2
	% invalid limits, return 0
	warning([mfilename ': lim must be of form [min max]']);
	return
end

if length(val) == 1
	% if val is a single number, use between
	outval = between(val, lim(1), lim(2));
	return
elseif length(val) == 2
	% val is a range, so check high and low limits
	outval =  between(val(1), lim(1), lim(2)) & between(val(2), lim(1), lim(2));
else
	% val is an array, check max and min
	outval = (min(val) >= lim(1)) & (max(val) <= lim(2));
end

