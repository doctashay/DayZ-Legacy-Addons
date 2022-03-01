/*
	Author: Karel Moricky, modified by Thomas Ryan

	Description:
	Ends mission with specific ending.

	Parameter(s):
	_this select 0: STRING - Next mission
	_this select 1 (Optional): NUMBER - end type
	_this select 2 (Optional): TEXT - completion text
	_this select 3 (Optional): BOOL - true to endmission, false to failmission
	_this select 4 (Optional): CODE - code executed right before mission ends successfuly
	_this select 5 (Optional): NUMBER - duration of fade out (set to 0 for instant)

	Returns:
	NOTHING
*/

private ["_mission","_end","_text","_win","_code","_fnc_scriptName","_fade"];
_mission =	[_this,0,worldname,[""]] call bis_fnc_param;
_end =		[_this,1,1,[0]] call bis_fnc_param;
_text =		[_this,2,"",[""]] call bis_fnc_param;
_win =		[_this,3,true,[true]] call bis_fnc_param;
_code =		[_this,4,{},[{}]] call bis_fnc_param;
_fade =		[_this,5,4,[0]] call bis_fnc_param;

[_mission,_end,_text,_win,_code,_fade] spawn {
	_mission = _this select 0;
	_end = _this select 1;
	_text = _this select 2;
	_win = _this select 3;
	_code = _this select 4;
	_fade = _this select 5;

	if (_fade > 0) then {
		_fade fadeSound 0;
		_fade fadeMusic 0;
		_fade fadeSpeech 0;
		titleCut [_text,"BLACK out",_fade];
		
		sleep _fade;
	};
	
	if (_win) then {
		_mission call _code;
		endmission format ["%1_%2",_mission,_end];
	} else {
		failmission format ["%1_%2",_mission,_end];
	};
};