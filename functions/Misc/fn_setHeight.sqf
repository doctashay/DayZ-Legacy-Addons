/*
	Author: Joris-Jan van 't Land

	Description:
	Set a unit's height.

	Parameter(s):
	_this select 0:
		OBJECT - object
		NUMBER - heigth applied to 'this' (for use in init fields). Other params are ignored.
	_this select 1: NUMBER - height in meters
	_this select 2 (Optional): ARRAY - position (default: object's position)

	Returns:
	Bool
*/

private ["_obj", "_height", "_pos"];
_obj = [_this, 0, player, [objNull,0]] call BIS_fnc_Param;

if (typename _obj == typename objnull) then {

	//--- Set height to an object
	_height = [_this, 1, 0, [-1]] call BIS_fnc_Param;
	_pos = [_this, 2, position _obj, [[]]] call BIS_fnc_Param;

	_pos set [2, _height];
	_obj setPos _pos;
} else {

	//--- Set height to 'this' in init line
	this setpos [position this select 0,position this select 1,_obj];
};

true