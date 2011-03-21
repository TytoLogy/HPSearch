function Sout = HPSearch_settingsUpdate(Sin, Slim, Sfields)
%------------------------------------------------------------------------
% Sout = HPSearch_settingsUpdate(Sin, Slim, Sfields)
%------------------------------------------------------------------------
% 
% 	Used by HPSearch to administer user-configurable settings in the
% 	SETTINGS menu.  Uses structdlg toolbox from Mathworks downloads site
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	Sin		input structure
%	Slim		limits structure with same fieldnames as 
%					instruct and corresponding limits as [minval maxval].
%					If no matching name for field in instruct exists, 
%					no limits will be specified for that field in outstruct
%					output structure
%	Sfields	cell array
%------------------------------------------------------------------------
% Output Arguments:
% 	Sout		output structure 
% 
%------------------------------------------------------------------------
% See also: structdlg toolbox (StructDlg, StructDlg_buildInput), 
%				HPSearch, HPSearch_tdtinit, HPSearch_SettingsMenuFields
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sharad.shanbhag@einstein.yu.edu
%------------------------------------------------------------------------
% Created: 20 July, 2009
%
% Revisions:
%	2 Nov, 2009 (SJS): 
%		-	added Sfields input variable,	reworked code a bit
% 	3 Nov, 2009 (SJS):
% 		- the code inside the if ~exist(...) statement is identical to the
% 			original HPSearch_settingsUpdate.m function
% 		- accounted for Sfields by adding the if... else... statement
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if Sfields was given as input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('Sfields', 'var')
	% first, check if there is a type field
	if isfield(Sin, 'type')
		% if so, save it for later and delete it from the structure.  This is
		% done because structdlg barfs on it.  which is not good.
		type = Sin.type;
		Sin = rmfield(Sin, 'type');
	else
		% otherwise, do nothing, assign empty vector to it
		type = [];
	end

	% build the Sdlg input
	Sdlg = StructDlg_buildInput(Sin, Slim);

	% call the structDlg with the constructed struct S and a string for the 
	% dialog box title
	Sout = StructDlg(Sdlg, [type ' Settings:']);

	if isempty(Sout)
		% return the unchanged input if Sout == []
		disp([mfilename ': is empty Sout'])
		disp('returning Sin')
		Sout = Sin;
	else
		% add back the type if necessary, then return to sender
		if ~isempty(type)
			Sout.type = type;
		end
		return
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% need to control for the elements that are ok to edit by user
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
	% get # of fields to edit
	Nedit = length(Sfields);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% check if there are any fields to edit
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if Nedit
		% yes, there are editable fields!
		
		% First, build Sedit that has only fields that are editable
		% (as indicated by having field name in the Sfields cell array)
		% loop through the fields that are editable 
		% (again as noted in Sfields argument)
		for k = 1:length(Sfields)
			% is Sfields{k} a field in the the Sin struct?
			if isfield(Sin, Sfields{k})
				% if so, add it to the Sedit structure that will be sent on
				% to the structdlg GUI utility
				Sedit.(Sfields{k}) = Sin.(Sfields{k});
			end
		end

		% Second, loop through the Sin fields in order to store the
		% non-editable fields that are not in Sfields...
		% get the names of the fields in Sin
		Sinfields = fieldnames(Sin);
		% loop...
		for k = 1:length(Sinfields)
			% check that  Sinfields{k} isn't in Sin... meaning that there is
			% no field with the name in Sinfields{k} cell array in the Sin
			% structure... understand?
			if ~isfield(Sedit, Sinfields{k})
				% since Sinfields{k}  isn't in Sedit, save it in Snoedit so
				% that we can add it back at the end
				Snoedit.(Sinfields{k}) = Sin.(Sinfields{k});
			end
		end

		% GUI edit the edited edit structure for editing
		Sout = HPSearch_settingsUpdate(Sedit, Slim);

		% add in the edited out fields
		noedfields = fieldnames(Snoedit);
		N = length(noedfields);
		if length(noedfields)
			for k = 1:N
				Sout.(noedfields{k}) = Sin.(noedfields{k});
			end
		end

		% reorder fields to match original order
		Sout = orderfields(Sout, Sinfields);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% nope, nothing to edit
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	else
		Sout = Sin;
	end
end
