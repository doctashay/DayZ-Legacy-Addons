/*
	Author: Karel Moricky

	Description:
	Send function for remote execution (and executes locally if conditions are met)

	Parameter(s):
		0: ANY - function params
		1: STRING - function name
		2 (Optional):
			OBJECT - function will be executed only where unit is local [default: everyone]
			BOOL - when true, function is executed on server only
		3 (Optional): BOOL - true for calling function using 'spawn' command (otherwise 'call' is used) [default: false]
		4 (Optional): BOOL - true for persistent call (will be called now and for every JIP client) [default: false]
	
	Returns:
	ARRAY - sent packet
*/

private ["_params","_functionName","_target","_isSpawn","_isPersistent"];

_params = 	[_this,0,[]] call bis_fnc_param;
_functionName =	[_this,1,"",[""]] call bis_fnc_param;
_target =	[_this,2,objnull,[objnull,true]] call bis_fnc_param;
_isSpawn =	[_this,3,false,[false]] call bis_fnc_param;
_isPersistent =	[_this,4,false,[false]] call bis_fnc_param;

//--- Target is TRUE, intended for server eyes only
if (typename _target == typename true) then {
	_target = if (_target) then {bis_functions_mainscope} else {objnull};
};

//--- Send
BIS_fnc_MP_packet = [_params,_functionName,_target,_isSpawn,_isPersistent];
publicvariable "BIS_fnc_MP_packet";

//--- Local execution
if (isnull _target || local _target) then {
	["BIS_fnc_MP_packet",BIS_fnc_MP_packet] call BIS_fnc_MPexec;
};

BIS_fnc_MP_packet