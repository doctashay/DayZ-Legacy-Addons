/*
	Author: Karel Moricky

	Description:
	Display debug message

	Parameter(s):
	_this select 0: STRING - Formatted message or first param
	_this select n (Optional): ANY - additional parameters

	Returns:
	BOOL - true when done
*/

private ["_scriptName","_text"];

//--- Insert function name where available
_scriptName = if (isnil "_fnc_scriptName"/* || isnil "_fnc_scriptNameParent"*/) then {
	""
} else {
	_fnc_scriptName
};
_scriptName = if (_scriptName != "") then {" [" + _scriptName + "] "} else {" "};


//--- Display
if (typename _this != typename []) then {_this = [_this]};
if (count _this == 0) then {_this = ["<EMPTY ARRAY>"]};
_text = _this select 0;
if (typename _text != typename "") then {_text = str _this;};
_thisLocal = +_this;
_thisLocal set [0,"BIS_fnc_log:" + _scriptName + _text];
textlogformat _thisLocal;

true