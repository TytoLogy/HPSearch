function randomSequence = HPCurve_randomSequence(nReps, nTrials)
%--------------------------------------------------------------------------
% randomSequence = HPCurve_randomSequence(nReps, nTrials)
%--------------------------------------------------------------------------
% 
% generate the randomized trial sequence
% randomize across nTrials (# of different values for varying
% stimulus parameter) for nReps
% 
% Example:
% 
% 	I'd like to test ITDs from -100 to 100 in steps of 100,
% 	so ITDs = [-100 0 100] & I want 5 repetitions of each ITD value.
% 	
% 	so, 
% 		nReps = 5
% 		nTrials = length(ITDs) = 3;
% 		
% 	and I call HPCurve_randomSequence() as follows:
% 
% 		>> rSeq = HPCurve_randomSequence(5, 3)
% 
% 		rSeq =
% 			  2     1     3
% 			  3     1     2
% 			  2     3     1
% 			  2     3     1
% 			  1     3     2
% 		  
% 	So each row of rSeq corresponds to a "rep" of the block stimulus presentation
% 	and columns are each "trial".  calling ITDs with rSeq gives:
% 	
% 		>> ITDs(rSeq)
% 
% 		ans =
% 			  0  -100   100
% 			100  -100     0
% 			  0   100  -100
% 			  0   100  -100
% 		  -100   100     0
%--------------------------------------------------------------------------
% Input Arguments:
%	nReps		# reps per stimulus type
%	nTrials	# trials (# stimulus types)
%
% Output Arguments:
%	randomSequence	[nReps X nTrials] sequence of randomized indices
%--------------------------------------------------------------------------
% See Also: HPCurve_buildStimCache, HPSearch
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sharad.shanbhag@einstein.yu.edu
%--------------------------------------------------------------------------
% Revision History
%	6 November, 2009 (SJS): Created
%	13 November, 2009 (SJS): some documentation fixes
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate the randomized trial sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% randomize across nTrials (# of different values for varying
% stimulus parameter)

% create array of zeros
randomSequence = zeros(nReps, nTrials);

% create a random sequence 
for m = 1:nReps
	randomSequence(m, :) = randperm(nTrials);
end

	