/*
	Author: Karel Moricky

	Description:
	Header function of local mission conversations

	Parameter(s):
		0: STRING - unique mode
		1 (Optional): ANY - additional params

	Returns:
	BOOL
*/

private ["_mode"];
_mode = [_this,0,"",[""]] call bis_fnc_param;
_this = [_this,1,[]] call bis_fnc_param;

switch _mode do {
	_this call BIS_fnc_missionConversationsLocal;
	default {
		["Mode '%1' not defined in missionConversations.sqf",_mode] call bis_fnc_error;
	};
};
true