function outFlag = stimChanged(oldstim, newstim)
%------------------------------------------------------------------------
% outFlag = stimChanged(oldstim, newstim)
%------------------------------------------------------------------------
%	
% check to see if the stimulus specs are different
% 
%------------------------------------------------------------------------
% Input Arguments:
% 
% Output Arguments:
%
%------------------------------------------------------------------------
% See also: 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: ?????????????
%
% Revisions:
%	13 Oct, 2009 (SJS)
% 		- added comments and documentation
%------------------------------------------------------------------------
% To Do:
%------------------------------------------------------------------------


% d(1) = oldstim.ITD - newstim.ITD;
% d(2) = oldstim.ILD - newstim.ILD;
% d(3) = oldstim.Latten - newstim.Latten;
% d(4) = oldstim.Ratten - newstim.Ratten;
% d(5) = oldstim.ABI - newstim.ABI;
% d(6) = oldstim.BC - newstim.BC;
% d(7) = oldstim.F - newstim.F;
% d(8) = oldstim.BW - newstim.BW;
% d(9) = oldstim.Flo - newstim.Flo;
% d(10) = oldstim.Fhi - newstim.Fhi;
% d(11) = ~strcmp(oldstim.type, newstim.type);
% d(12) = oldstim.sAMFreq - newstim.sAMFreq;
% d(13) = oldstim.sAMPercent - newstim.sAMPercent;

% stim struct strings
fields = fieldnames(oldstim);
d = zeros(length(fields), 1);

for n = 1:length(fields)
	if ischar(oldstim.(fields{n}))
		d(n) = ~strcmp(oldstim.(fields{n}), newstim.(fields{n}));
	else
		d(n) = oldstim.(fields{n}) - newstim.(fields{n});
	end
end

if sum(d) == 0
	outFlag = 0;
else 
	outFlag = 1;
end
