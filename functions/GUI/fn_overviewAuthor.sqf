private ["_display","_config","_ctrlAuthor","_author"];
_display = [_this,0,displaynull,[displaynull]] call bis_fnc_param;
_config = [_this,1,configfile,[configfile]] call bis_fnc_param;

_ctrlAuthor = _display displayctrl 1102;

//--- No control found - terminate
if (isnull _ctrlAuthor) exitwith {["Control %1 not found",_idcHTML] call bis_fnc_error};

//--- Load author
_author = gettext (_config >> "author");

if (_author != "") then {

	//--- Check if author fields links to CfgMods
	_authorMod = gettext (configfile >> "cfgmods" >> _author >> "author");
	if (_authorMod != "") then {_author = _authorMod};

	//--- Display the author
	_ctrlAuthor ctrlsetstructuredtext parsetext format [
		"<t color='#99ffffff' align='left'>%2</t><t align='right'>%1</t>",
		_author,
		localize "STR_LIB_INFO_AUTHOR"
	];
} else {

	//--- No author found - clear the field
	_ctrlAuthor ctrlsetstructuredtext parsetext "";
};