/*
	Author: Karel Moricky

	Description:
	Returns grid params and stores it into uiNameSpace

	Parameter(s):
	_this select 0: STRING - category name
	_this select 1: STRING - grid name

	Returns:
	ARRAY - format [[x,y,w,z],gridW,gridH]
*/

private ["_guiName","_gridName","_gridVar","_grid"];

_guiName = [_this,0,"GUI",[""]] call bis_fnc_param;
_gridName = [_this,1,"GRID",[""]] call bis_fnc_param;
_gridVar = _guiName + "_" + _gridName;
_grid = uinamespace getvariable _gridVar;

_grid = getarray (configfile >> "CfgUIDefault" >> _guiName >> "Grids" >> _gridName >> "position");
if (count _grid == 3) then {
	private ["_gridArea","_gridW","_gridH"];
	_gridArea = _grid select 0;
	{
		_gridArea set [_foreachindex,_x call bis_fnc_parsenumber];
	} foreach _gridArea;
	_gridW = (_grid select 1) call bis_fnc_parsenumber;
	_gridH = (_grid select 2) call bis_fnc_parsenumber;
	_grid = [_gridArea,_gridW,_gridH];
} else {
	["Grid '%1' not found in 'CfgUIDefault' >> '%2'",_gridName,_guiName] call bis_fnc_error;
	_grid = [];
};

_grid