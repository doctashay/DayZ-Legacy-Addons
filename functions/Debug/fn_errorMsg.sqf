/*
	Author: Karel Moricky

	Description:
	Display error window

	Parameter(s):
	_this select 0: STRING - Formatted message
	_this select n (Optional): ANY - additional parameters

	Returns:
	NOTHING
*/

//--- End loading sceen to prevent freezing the game
endloadingscreen;

//--- Display message
private ["_this","_scriptName"];
_this = _this call bis_fnc_error;
_scriptName = if (isnil "_fnc_scriptName") then {""} else {format ["%1 ",_fnc_scriptName]};
[
	format _this,
	"ERROR: " + _scriptName
] call BIS_fnc_guiMessage;