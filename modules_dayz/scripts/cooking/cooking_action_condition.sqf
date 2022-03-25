private ["_state","_player","_params"];

/*
	Manage cooking actions.
	
	Usage:
	[_state, _player, _fireplace] call cooking_manageActions
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_player = _this select 1;
_params = _this select 2;

_cooking_base_default = ["empty", 0, objNull];

switch _state do
{	
	//can be filled
	case 0:
	{
		private["_cooking_equipment","_source"];
		_cooking_equipment = _params select 0;
		_source = _params select 1;
		
		if ( _source isKindOf "BottleBase") then 
		{
			true
		};
	};
	
	//can be emptied
	case 3:
	{
		private["_cooking_equipment","_source"];
		_cooking_equipment = _params select 0;
		_source = _params select 1;
		_cooking_base = _cooking_equipment getVariable ['cooking_base', _cooking_base_default];
		_base_name = _cooking_base select 0;
		
		if (_base_name != "empty" and 
			_base_name != "fat") then 
		{
			true
		};
	};
	
	//portable stove inventory condition
	case 4:
	{
		_portable_stove = _params select 0;
		_is_pot_attached = [_portable_stove, 'CookwareBase'] call fnc_isItemAttached;
		_is_pan_attached = [_portable_stove, 'CookwareContainer'] call fnc_isItemAttached;
		
		if (_is_pot_attached or 
			_is_pan_attached) exitWith
		{
			false
		};
		
		true
	};
	
	default {};
};
