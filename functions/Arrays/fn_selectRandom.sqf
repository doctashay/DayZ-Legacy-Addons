scriptName "Functions\arrays\fn_selectRandom.sqf";
/************************************************************
	Random Select
	By Andrew Barron / Rewritten by Warka

Parameters: array

This returns a randomly selected element from the passed array.

Example: [1,2,3] call BIS_fnc_selectRandom
Returns: 1, 2, or 3
************************************************************/

private ["_ret","_i"];

if(count _this > 0) then
{
	_i = floor random (count _this);           //random index

	_ret = _this select _i;           //get the element, return it
};
_ret
