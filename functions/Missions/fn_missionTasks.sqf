/*
	Author: Karel Moricky

	Description:
	Header function of local mission tasks.
	Automatically declares following variables:
		_taskID: STRING
		_taskState: STRING

	Parameter(s):
		0: STRING - unique mode
		1 (Optional): ANY - additional params

	Returns:
	BOOL
*/

private ["_taskID","_taskState"];
_taskID = [_this,0,"",[""]] call bis_fnc_param;
_this = [_this,1,[]] call bis_fnc_param;

_taskState = if (_taskID call bis_fnc_taskExists) then {toUpper (_taskID call bis_fnc_taskstate)} else {""};

switch _taskID do {
	_this call BIS_fnc_missionTasksLocal;
	default {
		["Task ID '%1' not defined in missionTasks.sqf",_taskID] call bis_fnc_error;
	};
};
true