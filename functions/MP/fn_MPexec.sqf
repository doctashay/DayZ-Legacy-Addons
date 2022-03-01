/*
	Author: Karel Moricky

	Description:
	Execute received remote execution

	Parameter(s):
	_this select 0: STRING - Packet variable name (always "BIS_fnc_MP_packet")
	_this select 1: ARRAY - Packet value (sent by BIS_fnc_MP function; see it's description for more details)
	
	Returns:
	BOOL - true if function was executed successfuly
*/

private ["_params","_functionName","_target","_isSpawn","_isPersistent","_varName","_varValue","_function"];

_varName = _this select 0;
_varValue = _this select 1;

_params = 	[_varValue,0,[]] call bis_fnc_param;
_functionName =	[_varValue,1,"",[""]] call bis_fnc_param;
_target =	[_varValue,2,objnull,[objnull]] call bis_fnc_param;
_isSpawn =	[_varValue,3,false,[false]] call bis_fnc_param;
_isPersistent =	[_varValue,4,false,[false]] call bis_fnc_param;

//--- Persistent call
if (isserver && _isPersistent) then {
	private ["_queue"];
	_queue = bis_functions_mainscope getvariable ["BIS_fnc_MP_queue",[]];
	_queue set [
		count _queue,
		[
			_params,
			_functionName,
			_target,
			_isSpawn,
			_isPersistent
		]
	];
	bis_functions_mainscope setvariable ["BIS_fnc_MP_queue",_queue,true];
};

//--- Execute
_function = missionnamespace getvariable _functionName;
if (!isnil "_function") then {
	if (local _target || isnull _target) then {
		if (_isSpawn) then {
			_params spawn _function;
		} else {
			//--- Delete local variables so they cannot be accessed
			private ["_functionName","_target","_isSpawn","_isPersistent","_varName","_varValue"];
			_params call _function;
		};
		true
	} else {
		false
	};
} else {
	["Function '%1' does not exist",_functionName] call bis_fnc_error;
	false
};