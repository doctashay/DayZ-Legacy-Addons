/*
	Author: Karel Moricky

	Description:
	Returns side color in RGBA format.

	Parameter(s):
	0: SIDE or NUMBER - either side or side ID

	Returns:
	ARRAY
*/

private ["_sideID","_sideColorClass","_sideColor"];
_sideID = [_this,0,sidelogic,[sidelogic,0]] call bis_fnc_param;
if (typename _sideID != typename 0) then {_sideID = _sideID call bis_fnc_sideID;};

_sideColorClass = [
	"colorEnemy",		//--- 0: OFPOR
	"colorCivilian",	//--- 1: BLUFOR
	"colorFriendly",	//--- 2: INDEPENDENT
	"colorNeutral",		//--- 3: CIVILIAN
	"colorCivilian",
	"colorCivilian",
	"colorCivilian",
	"colorCivilian",	//--- 7: LOGIC
	"colorUnknown",		//--- 8: EMPTY
	"colorCivilian"		//--- 9: AMBIENT
] select _sideID;
getarray (configfile >> "cfgingameui" >> "islandmap" >> _sideColorClass);