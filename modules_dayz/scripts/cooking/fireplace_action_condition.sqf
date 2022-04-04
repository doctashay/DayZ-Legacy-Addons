private ["_player","_state","_fireplace"];

/*
	Manage fireplace actions.
	
	Usage:
	[_player, _state, _fireplace] call fireplace_manageActions
	
	Author: Lubos Kovac
*/
#include "fireplace_common.sqf";

//input
_state = _this select 0;
_player = _this select 1;
_params = _this select 2;

//conditions
_min_temp_to_reignite = 200;

switch _state do
{	
	//can craft fireplace
	case 0:
	{
		_tool1 = _params select 0;
		_tool2 = _params select 1;
		
		if  (
				(_player getVariable ['isUsingSomething',0] == 0) and
				!((itemParent _tool1) isKindOf "Fireplace") and
				!((itemParent _tool2) isKindOf "Fireplace") 			
			) then
		{
			true
		};
	};

	//can be ignited by match
	case 1:
	{
		_fireplace = _params select 0;
		
		if ( !(_fireplace getVariable ['fire', false]) and 
			 (itemInHands _player) isKindOf 'Consumable_Matchbox' and
			 (_fireplace call _is_in_safe_position) and
			 !(_fireplace getVariable ['is_in_use', false]) ) then
		{
			true
		};
	};
	
	//can be ignited by flare
	case 11:
	{
		_fireplace = _params select 0;
		
		if ( !(_fireplace getVariable ['fire', false]) and 
			 (itemInHands _player) isKindOf 'Consumable_Roadflare' and
			 (_fireplace call _is_in_safe_position) and
			 !(_fireplace getVariable ['is_in_use', false]) ) then
		{
			true
		};
	};	
	
	//can be ignited by hand drill
	case 12:
	{
		_fireplace = _params select 0;
		
		if ( !(_fireplace getVariable ['fire', false]) and 
			 (itemInHands _player) isKindOf 'Crafting_HandDrillKit' and
			 (_fireplace call _is_in_safe_position) and 
			 !(_fireplace getVariable ['is_in_use', false]) ) then
		{
			true
		};
	};
	
	//can be ignited by torch
	case 13:
	{
		_fireplace = _params select 0;
		
		if ( !(_fireplace getVariable ['fire', false]) and 
			 (itemInHands _player) isKindOf 'Crafting_Torch' and
			 (_fireplace call _is_in_safe_position) and
			 !(_fireplace getVariable ['is_in_use', false]) ) then
		{
			true
		};
	};

	//can be ignited by petrol lighter
	case 14:
	{
		_fireplace = _params select 0;
		
		if ( !(_fireplace getVariable ['fire', false]) and 
			 (itemInHands _player) isKindOf 'Light_PetrolLighter' and
			 (_fireplace call _is_in_safe_position) and
			 !(_fireplace getVariable ['is_in_use', false]) ) then
		{
			true
		};
	};
	
	//can be reignited
	case 2:
	{
		_fireplace = _params select 0;
		
		if (
			!(_fireplace getVariable ['fire', false]) and 
			  _fireplace getVariable ['temperature',20] >= _min_temp_to_reignite and 
			  !(_fireplace getVariable ['is_in_use', false])) then
		{
			true
		};
	};
	
	//can be extinguished
	case 3: 
	{ 
		_fireplace = _params select 0;
		
		if (
			((itemInHands _player) isKindOf 'Drink_WaterBottle' or 
			 (itemInHands _player) isKindOf 'Drink_Canteen' or 
			 (itemInHands _player) isKindOf 'Tool_FireExtinguisher') and
			 !(_fireplace getVariable ['is_in_use', false]) and
			_fireplace getVariable ['fire', false] ) then
		{
			true
		};
	};
	
	//inventory	condition
	case 4: 
	{ 
		_fireplace = _params select 0;
		_fuel_items_count = [_fireplace] call _get_fuel_count;
		_kindling_items_count = [_fireplace] call _get_kindling_count;
		_num_of_cargo_items = count (itemsInCargo _fireplace);
		
		if (!(_fireplace getVariable ['is_fireplace', false]) and
			!(_fireplace getVariable ['fire', false]) and
			!(_fireplace getVariable ['is_in_use', false]) and
			_fireplace animationPhase 'Oven' == 1 and 
			_fireplace animationPhase 'Tripod' == 1 and 
			_fireplace animationPhase 'Stones' == 1 and
			_fuel_items_count <= 1 and 
			_kindling_items_count <= 1 and 
			_num_of_cargo_items == 0) exitWith
		{
			true
		};
	};	
	
	//can pose wooden stick towards fire
	case 5: 
	{ 
		_fireplace = _params select 0;
		
		if (
			(_player getVariable ['isUsingSomething',0] == 0) and 
			((itemInHands _player) isKindOf 'Crafting_LongWoodenStick') and
			[_player, _fireplace] call _is_facing_towards_fireplace ) then
		{
			true
		};
	};
	
	//is facing fireplace
	case 6:
	{
		_fireplace = _params select 0;
		[_player, _fireplace] call _is_facing_towards_fireplace;
	};
	
	//is posing stick towards fireplace
	case 7:
	{
		[_player] call _is_posing_stick;
	};
	
	//can be buried
	case 8: 
	{ 
		_fireplace = _params select 0;
		
		if (
			(_fireplace getVariable ['is_fireplace', false]) and
			!(_fireplace getVariable ['fire', false]) and
			!(_fireplace getVariable ['is_in_use', false]) and
			(_player getVariable ['isUsingSomething',0] == 0) and 
			((itemInHands _player) isKindOf 'Tool_Shovel') or 
			((itemInHands _player) isKindOf 'FarmingHoe') or 
			((itemInHands _player) isKindOf 'pickaxe') ) then
		{
			true
		};
	};
	
	//can be put into fireplace point
	case 9:
	{
		_house = _params select 0;
		_slot_name = _params select 1;
		
		_slot_in_use = _house getVariable [_slot_name, 0];
	
		//diag_log format["House |%1| slot name |%2| value |%3|", _house, _slot_name, (_house getVariable _slot_name)];
		//hint format["House |%1| slot name |%2| slot in use = |%3| is fireplace? = |%4|", _house, _slot_name, _slot_in_use, ((itemInHands _player) isKindOf 'Fireplace')];
	
		if ((_player getVariable ['isUsingSomething',0] == 0) and 
			((itemInHands _player) isKindOf 'Fireplace') and
			(_slot_in_use != 1) ) then
		{
			true
		};
	};
	
	//can be put into hands
	case 10:
	{
		_fireplace = _params select 0;
		
		_has_cooking_pot = [_fireplace, "Cookware_Pot"] call fnc_isItemAttached;
		_has_firewood =    [_fireplace, "Consumable_Firewood"] call fnc_isItemAttached;
		_num_of_cargo_items = count (itemsInCargo _fireplace);
		
		if ((_player getVariable ['isUsingSomething',0] == 0) and 
			!(_fireplace getVariable ['fire', false]) and 
			!(_fireplace getVariable ['is_fireplace', false]) and 
			!(_fireplace getVariable ['is_in_use', false]) and
			isNull (itemInHands _player) and
			(!_has_cooking_pot and !_has_firewood) and 
			_num_of_cargo_items == 0) then
		{
			true
		};
	};

	//can be placed on the ground
	case 15:
	{
		_fireplace = _params select 0;
		
		if ( (_player getVariable ['isUsingSomething',0] == 0) and 
			!(_fireplace getVariable ['is_in_use', false]) and
			 //((itemInHands _player) == _fireplace) ) then
			 ((itemInHands _player) isKindOf 'Fireplace') ) then
		{
			true
		};
	};
	
	default {};
};
