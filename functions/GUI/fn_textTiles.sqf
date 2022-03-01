/*
	Author: Karel Moricky

	Description:
	Show animated text

	Parameter(s):
	0: Content
		STRING - Picture
		STRUCTURED TEXT - Text
	1: ARRAY - Position in format [x,y,w,h]
	2: NUMBER - Duration


	Returns:
	BOOL - true
*/

private ["_content","_","_pos","_size","_duration","_posX","_posY","_posW","_posH","_sizeX","_sizeY","_sizeW","_sizeH","_display","_xList","_yList","_gridsDef","_grids","_index","_ix","_iy","_group","_groupContent","_color","_alpha"];

disableserialization;
_content = [_this,0,"#(argb,8,8,3)color(1,0,1,1)",["",parsetext ""]] call bis_fnc_param;
_pos = [_this,1,[0,0,1,1],[[]],4] call bis_fnc_param;
_size = [_this,2,10,[0,[]]] call bis_fnc_param;
_duration = [_this,3,5,[0]] call bis_fnc_param;
if (typename _size == typename 0) then {_size = [_size,_size]};

_posX = _pos select 0;
_posY = _pos select 1;
_posW = _pos select 2;
_posH = _pos select 3;

_sizeX = _size select 0;
_sizeY = _size select 1;
_sizeW = _posW / (_size select 0);
_sizeH = _posH / (_size select 1);

cutrsc ["RscTilesGroup","plain"];
_display = uinamespace getvariable "RscTilesGroup";

_xList = [0,1,2,3,4,5,6,7,8,9];
_yList = [0,1,2,3,4,5,6,7,8,9];
_xList resize _sizeX;
_yList resize _sizeY;
_gridsDef = [];
for "_x" from 0 to (_sizeX - 1) do {
	for "_y" from 0 to (_sizeY - 1) do {
		_gridsDef = _gridsDef + [[_x,_y]];
	};
};
_grids = +_gridsDef;

while {count _grids > 0} do {

	_index = floor random (count _grids - 1);
	_grid = _grids select _index;
	_grids set [_index,-1];
	_grids = _grids - [-1];

	_ix = _grid select 0;
	_iy = _grid select 1;

	//--- Group
	_group = _display displayctrl (1000 + _ix * 10 + _iy);
	_group ctrlsetposition [
		_posX + _ix * _sizeW,
		_posY + _iy * _sizeH,
		_sizeW,
		_sizeH
	];
	_group ctrlcommit 0;


	//--- Content
	if (typename _content == typename "") then {
		_groupContent = _display displayctrl (1200 + _ix * 10 + _iy);
		_groupContent ctrlsettext _content;
	} else {
		_groupContent = _display displayctrl (1100 + _ix * 10 + _iy);
		_groupContent ctrlsetstructuredtext _content;
	};
	_groupContent ctrlsetposition [
		- _ix * _sizeW,
		- _iy * _sizeH - 0.1 + random 0.2,
		_posW,
		_posH
	];
	_color = random 0.5;
	_alpha = if (random 1 > 0.1) then {0.3} else {0};
	_groupContent ctrlsetbackgroundcolor [_color,_color,_color,_alpha];
	_groupContent ctrlsetfade 1;
	_groupContent ctrlcommit 0;

	//--- Animate
	_groupContent ctrlsetposition [
		- _ix * _sizeW,
		- _iy * _sizeH,
		_posW,
		_posH
	];
	_groupContent ctrlsetfade 0;
	_groupContent ctrlcommit (random 0.3);
	sleep 0.01;
};


sleep _duration;


_grids = +_gridsDef;
while {count _grids > 0} do {

	_index = floor random (count _grids - 1);
	_grid = _grids select _index;
	_grids set [_index,-1];
	_grids = _grids - [-1];

	_ix = _grid select 0;
	_iy = _grid select 1;

	if (typename _content == typename "") then {
		_groupContent = _display displayctrl (1200 + _ix * 10 + _iy);
	} else {
		_groupContent = _display displayctrl (1100 + _ix * 10 + _iy);
	};

	_groupContent ctrlsetposition [
		- _ix * _sizeW,
		- _iy * _sizeH - 0.1 + random 0.2,
		_posW,
		_posH
	];
	_groupContent ctrlsetbackgroundcolor [0,0,0,0];
	_groupContent ctrlsetfade 1;
	_groupContent ctrlcommit (random 0.3);
	sleep 0.01;
};
true