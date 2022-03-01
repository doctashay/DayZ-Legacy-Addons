/*
	Author: Karel Moricky

	Description:
	Opens ORBAT style credits

	Parameter(s): None

	Returns:
	BOOL
*/

//--- Initialize global variables
if (isnil {missionnamespace getvariable "bis_fnc_init"}) then {
	3 call (uinamespace getvariable "bis_fnc_recompile");
};

disableserialization;
_fadeTime = 0.3;
cuttext ["","black out",_fadeTime];
uisleep _fadeTime;

_cfgCredits = configfile >> "CfgCredits";
_mods = [];
for "_c" from 0 to (count _cfgCredits - 1) do {
	_class = _cfgCredits select _c;
	if (isclass _class) then {_mods = _mods + [_class]};
};
_parentDisplay = [] call bis_fnc_displayMission;
if (isnull _parentDisplay) then {_parentDisplay = finddisplay 0;};

if (count _mods == 1) then {
	[_mods select 0,_parentDisplay] call bis_fnc_ORBATopen;
} else {
	[_cfgCredits,_parentDisplay] call bis_fnc_ORBATopen;
};

cuttext ["","white in",_fadeTime];
true