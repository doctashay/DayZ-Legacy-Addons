/*
	Author: Karel Moricky

	Description:
	Measures how much time it takes to execute given expression

	Parameter(s):
	_this select 0: STRING - tested expression
	_this select 1 (Optional): ANY - Param(s) passed into code (default: [])
	_this select 2 (Optional): NUMBER -  Number of cycles (default: 10000)

	Returns:
	NUMBER - avarage time spend in code execution [ms]
*/
private ["_code","_params","_cycles","_codeText","_timeResult"];

_code = [_this,0,"",[""]] call bis_fnc_param;
_params = [_this,1,[]] call bis_fnc_param;
_cycles = [_this,2,10000,[0]] call bis_fnc_param;

//--- Compile code (calling the code would increase the time)
_timeResult = 0;
_codeText = compile format [
	"
		_time = diag_ticktime;
		for '_i' from 1 to %2 do {
			%1
		};
		_timeResult = ((diag_ticktime- _time) / _cycles) * 1000;
	",
	_code,
	_cycles
];

//--- Execute testing
"----------------------------------" call bis_fnc_log;
["Test Start. Code: %1",_code] call bis_fnc_log;
["Test Cycles: %1",_cycles] call bis_fnc_log;
_params call _codeText;
["Test End. Result: %1 ms",_timeResult] call bis_fnc_log;
"----------------------------------" call bis_fnc_log;

_timeResult