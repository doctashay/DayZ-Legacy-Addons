/*
	Author: Karel Moricky

	Description:
	Modify givem counter (create it if doesn't exist yet)

	Parameter(s):
	_this select 0: STRING - variable name of counter
	_this select 1 (Optional):
		NUMBER - added value
		BOOL - true to remove existing variable
	_this select 2 (Optional): NUMBER - modulo value

	Returns:
	NUMBER - counter's value
*/

private ["_varName","_add","_mod","_var"];

_varName =	[_this,0,"",[""]] call bis_fnc_param;
_add =		[_this,1,0,[0,false]] call bis_fnc_param;
_mod =		[_this,2,-1,[0]] call bis_fnc_param;

//--- Get
_var = missionnamespace getvariable _varName;
if (isnil "_var") then {_var = 0};

//--- Modify
if (typename _add == typename false) then {
	if (_add) then {

		//--- Clean
		missionnamespace setvariable [_varName,nil];
		nil
	} else {

		//--- Return without modification
		missionnamespace setvariable [_varName,_var];
		_var
	};
} else {

	//--- Add
	_var = _var + _add;
	if (_mod > 0) then {_var = _var % _mod};
	missionnamespace setvariable [_varName,_var];
	_var
};