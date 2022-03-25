private ["_state","_params","_item","_parent"];
	
/*
	Manage fireplace states.
	
	Usage:
	[X, _params] call fireplace_manageState
	X =  0 -> init
	X =  1 -> on item attached
	X =  2 -> on item detached
	
	Author: Lubos Kovac
*/
#include "fireplace_common.sqf";

//input
_state = _this select 0;
_params = _this select 1;
_item = _params select 0;
_parent = _params select 1;

switch _state do
{	
	//Atttach condition 
	case 1:
	{
		switch true do
		{
			//Fireplace (Basic)
			case (_parent isKindOf 'Fireplace'): {[3, [_item, _parent]] call fireplace_state_condition;};
			//Barrel with holes
			case (_parent isKindOf 'BarrelHolesBase'): {[5, [_item, _parent]] call fireplace_state_condition;};
			//Fireplace (Indoor)
			case (_parent isKindOf 'FireplaceIndoor'): {[7, [_item, _parent]] call fireplace_state_condition;};
			//Gas Cooker
			case (_parent isKindOf 'CookerBase'): {[9, [_item, _parent]] call fireplace_state_condition;};
			
			default {false};
		};
	};
	//Detach condition
	case 2:
	{
		switch true do
		{
			//Fireplace (Basic)
			case (_parent isKindOf 'Fireplace'): {[4, [_item, _parent]] call fireplace_state_condition;};
			//Barrel with holes
			case (_parent isKindOf 'BarrelHolesBase'): {[6, [_item, _parent]] call fireplace_state_condition;};
			//Fireplace (Indoor)
			case (_parent isKindOf 'FireplaceIndoor'): {[8, [_item, _parent]] call fireplace_state_condition;};
			//Gas Cooker
			case (_parent isKindOf 'CookerBase'): {[10, [_item, _parent]] call fireplace_state_condition;};
			
			default {false};
		};
	};
	
	//=====================================================================
	//FIREPLACE (BASIC)
	//=====================================================================
	//attach condition
	case 3:
	{
		//hint format["attach condition [item = %1, parent = %2]", _item, _parent];
		
		//check book
		if (_item isKindOf "ItemBook") exitWith
		{
			if (_parent call _is_in_safe_position) exitWith //check safe position
			{
				true
			};
		};
		
		//firewood/wooden stick
		_fuel_items_count = [_parent] call _get_fuel_count;
		if (_item isKindOf "Crafting_WoodenStick" or 
			_item isKindOf "Consumable_Firewood") exitWith
		{
			if !(isNull (itemParent _parent)) then
			{
				if ( _fuel_items_count == 0) then
				{
					true
				}
				else
				{
					false
				};
			}
			else
			{
				true
			};
		};
		 
		//check cooking equipment
		if (_item isKindOf "Cookware_Pot") exitWith
		{
			_stones_attached = [_parent, "Consumable_Stone", 8] call fnc_isItemAttached; //oven
			
			if ([_parent, "Cooking_Tripod"] call fnc_isItemAttached or
				_stones_attached) then
			{
				true
			};
		};
		
		//check kindling items
		_kindling_items_count = [_parent] call _get_kindling_count;
		if ( _item isKindOf "Consumable_Rags" or 
			 _item isKindOf "Medical_BandageDressing" or 
			 _item isKindOf "Medical_Bandage" or 
			 _item isKindOf "Consumable_Paper" or 
			 _item isKindOf "Consumable_Bark_Oak" or 
			 _item isKindOf "Consumable_Bark_Birch" ) exitWith
		{
			if !(isNull (itemParent _parent)) then
			{
				if ( _kindling_items_count == 0) then
				{
					true
				}
				else
				{
					false
				};
			}
			else
			{
				true
			};
		};	
		
		//check fireplace attachments
		//fireplace with stones
		if (_item isKindOf "Consumable_Stone" and 
			!(_item isKindOf "Consumable_SmallStone")) exitWith
		{
			if ( !(_parent call _is_in_safe_position) ) exitWith
			{
				false
			};
			
			_tripod_attached = [_parent, "Cooking_Tripod"] call fnc_isItemAttached;
			
			if ((quantity _item >= 4 and 					//fireplace with stones 
				 quantity _item < 8)
				or
				( quantity _item >= 8 and 					//oven
				!(_tripod_attached) and
				!(_parent getVariable ['fire', false])) ) exitWith 
			{
				true
			};
		};
		
		//fireplace with tripod
		if (_item isKindOf "Cooking_Tripod") exitWith
		{
			_stones_attached = [_parent, "Consumable_Stone", 8] call fnc_isItemAttached; //oven
			
			if (_parent call _is_in_safe_position and
			    !(_stones_attached)) exitWith
			{
				true
			};	
		};	
	};
	
	//detach condition
	case 4:
	{
		//hint format["Fireplace | detach condition [item = %1, parent = %2]", _item, _parent];
		
		//get fuel/kindling count
		_fuel_items_count = [_parent] call _get_fuel_count;
		_kindling_items_count = [_parent] call _get_kindling_count;
		
		//get cargo count
		_cargo_count = (count (itemsInCargo _parent));
	    _attachment_count = (count (_parent call fnc_getAttachments));
		
		//is fireplace burning?
		_is_fire = _parent getVariable ['fire', false];
		
		//is fireplace (not in fireplace kit form) ?
		_is_fireplace = _parent getVariable ['is_fireplace', false];
		
		//is oven?
		_is_oven = [_parent, "Consumable_Stone", 8] call fnc_isItemAttached; //oven
		
		//is last?
		_is_last_fuel = false;
		if ((_fuel_items_count == 1 and _kindling_items_count == 0) or
			(_fuel_items_count == 0 and _kindling_items_count == 1)) then
		{
			_is_last_fuel = true;
		};			
		
		//DEBUG
		//hint format['_cargo_count = %1, _attachment_count = %2, _is_last_fuel = %3', _cargo_count, _attachment_count, _is_last_fuel];
				
		//check fuel items
		if ((_item isKindOf "Consumable_Firewood" or 
			 _item isKindOf "Crafting_WoodenStick" or
			 _item isKindOf "ItemBook") and 
			 !_is_fire ) exitWith
		{
			//hint format ["[fuel check] _fuel_items_count = %1, _kindling_items_count = %2", _fuel_items_count, _kindling_items_count];
			
			//last fuel/kindling item
			if ( _is_last_fuel and
				!_is_fireplace ) then
			{
				//hint format ["[fuel check] _cargo_count = %1", _cargo_count];
				if ( _cargo_count > 0 or
					 _attachment_count > 1 ) then
				{
					false	//is last item, it is safe to remove it (fireplace will be destroyed)
				}
				else
				{
					true	//it is not safe to remove it (fireplace contains some items in it)
				};
			}
			//not last fuel/kindling
			else
			{
				true
			};
		};	
		
		//check kindling items
		if ((_item isKindOf "Consumable_Rags" or 
			 _item isKindOf "Medical_BandageDressing" or 
			 _item isKindOf "Medical_Bandage" or 
			 _item isKindOf "Consumable_Paper" or 
			 _item isKindOf "Consumable_Bark_Oak" or 
			 _item isKindOf "Consumable_Bark_Birch") and 
			 !_is_fire ) exitWith
		{
			//hint format ["[kindling check] _fuel_items_count = %1, _kindling_items_count = %2", _fuel_items_count, _kindling_items_count];
			
			//last fuel/kindling item
			if ( _is_last_fuel and
				 !_is_fireplace ) then
			{
				//hint format ["[kindling check] _cargo_count = %1", _cargo_count];
				
				if ( _cargo_count > 0 or
					 _attachment_count > 1) then
				{
					false	//is last item, it is safe to remove it (fireplace will be destroyed)
				}
				else
				{
					true	//it is not safe to remove it (fireplace contains some items in it)
				};
			}
			//not last fuel/kindling
			else
			{
				true
			};
		};	
		
		//check cooking equipment
		if (_item isKindOf "Cookware_Pot") exitWith
		{
			true
		};
		
		//check fireplace attachments
		//fireplace with stones
		if (_item isKindOf "Consumable_Stone" and 
			!(_item isKindOf "Consumable_SmallStone")) exitWith
		{
			if !( _is_fire and
				 !_is_oven ) then
			{
				true
			};
		};
		
		//fireplace with tripod
		if (_item isKindOf "Cooking_Tripod") exitWith
		{
			if (isNull (_parent getVariable ['cooking_equipment', objNull])) then
			{
				true
			};	
		};
	};
	
	//=====================================================================
	//BARREL WITH HOLES 
	//=====================================================================
	//attach condition
	case 5:
	{
		//hint format["attach condition [item = %1, parent = %2]", _item, _parent];
		
		//check fuel items
		if ((_item isKindOf "Consumable_Firewood" or 
			 _item isKindOf "Crafting_WoodenStick" or 
			 _item isKindOf "ItemBook") and 
			 _parent animationPhase 'LidOff' == 0) exitWith
		{
			true
		};	
		
		//check kindling items
		if ((_item isKindOf "Consumable_Rags" or 
			 _item isKindOf "Medical_BandageDressing" or 
			 _item isKindOf "Medical_Bandage" or 
			 _item isKindOf "Consumable_Paper" or 
			 _item isKindOf "Consumable_Bark_Oak" or 
			 _item isKindOf "Consumable_Bark_Birch") and 
			 _parent animationPhase 'LidOff' == 0) exitWith
		{
			true
		};	
		
		//check cooking equipment
		if (_item isKindOf "Cookware_Pot") exitWith
		{
			if (_parent animationPhase 'LidOn' == 0) then
			{
				true
			};
		};
	};
	
	//detach condition
	case 6:
	{
		//hint format["Barrel | detach condition [item = %1, parent = %2]", _item, _parent];
		
		//check fuel items
		if ((_item isKindOf "Consumable_Firewood" or 
			 _item isKindOf "Crafting_WoodenStick" or
			 _item isKindOf "ItemBook") and
			 !(_parent getVariable ['fire', false]) and
			 _parent animationPhase 'LidOff' == 0) exitWith
		{
			true
		};	
		
		//check kindling items
		if ((_item isKindOf "Consumable_Rags" or 
			 _item isKindOf "Medical_BandageDressing" or 
			 _item isKindOf "Medical_Bandage" or 
			 _item isKindOf "Consumable_Paper" or 
			 _item isKindOf "Consumable_Bark_Oak" or 
			 _item isKindOf "Consumable_Bark_Birch") and 
			 !(_parent getVariable ['fire', false]) and
			 _parent animationPhase 'LidOff' == 0) exitWith
		{
			true
		};	
		
		//check cooking equipment
		if (_item isKindOf "Cookware_Pot") exitWith
		{
			true
		};
	};
	
	//=====================================================================
	//FIREPLACE (INDOOR)
	//=====================================================================	
	//attach condition
	case 7:
	{
		//hint format["attach condition [item = %1, parent = %2]", _item, _parent];
		true
	};
	
	//detach condition
	case 8:
	{
		//hint format["Fireplace | detach condition [item = %1, parent = %2]", _item, _parent];
		
		//check fuel items
		if ((_item isKindOf "Consumable_Firewood" or 
			 _item isKindOf "Crafting_WoodenStick" or
			 _item isKindOf "ItemBook") and 
			 !(_parent getVariable ['fire', false]) ) exitWith
		{
			_fuel_items_count = [_parent] call _get_fuel_count;
			_kindling_items_count = [_parent] call _get_kindling_count;
			_cargo_count = (count (itemsInCargo _parent));
			//hint format ["[fuel check] _fuel_items_count = %1, _kindling_items_count = %2", _fuel_items_count, _kindling_items_count];
			
			//last fuel/kindling item
			if (_fuel_items_count == 1 and 
				_kindling_items_count == 0 and
				!(_parent getVariable ['is_fireplace', false]) ) then
			{
				//hint format ["[fuel check] _cargo_count = %1", _cargo_count];
				
				if ( _cargo_count > 0) then
				{
					false	//it is not safe to remove it (fireplace will be destroyed)
				}
				else
				{
					true	//it is safe to remove it (fireplace contains some items in it)
				};
			}
			//not last fuel/kindling
			else
			{
				true
			};
		};	
		
		//check kindling items
		if ((_item isKindOf "Consumable_Rags" or 
			 _item isKindOf "Medical_BandageDressing" or 
			 _item isKindOf "Medical_Bandage" or 
			 _item isKindOf "Consumable_Paper" or 
			 _item isKindOf "Consumable_Bark_Oak" or 
			 _item isKindOf "Consumable_Bark_Birch") and 
			 !(_parent getVariable ['fire', false]) ) exitWith
		{
			_fuel_items_count = [_parent] call _get_fuel_count;
			_kindling_items_count = [_parent] call _get_kindling_count;
			_cargo_count = (count (itemsInCargo _parent));
			//hint format ["[kindling check] _fuel_items_count = %1, _kindling_items_count = %2", _fuel_items_count, _kindling_items_count];
			
			//last fuel/kindling item
			if ( _kindling_items_count == 1 and 
				 _fuel_items_count == 0 and
				 !(_parent getVariable ['is_fireplace', false]) ) then
			{
				//hint format ["[kindling check] _cargo_count = %1", _cargo_count];
				if ( _cargo_count > 0) then
				{
					false	//it is not safe to remove it (fireplace will be destroyed)
				}
				else
				{
					true	//it is safe to remove it (fireplace contains some items in it)
				};
			}
			//not last fuel/kindling
			else
			{
				true
			};
		};	
		
		//check cooking equipment
		if (_item isKindOf "Cookware_Pot") exitWith
		{
			true
		};
	};

	//=====================================================================
	//CANISTER ITEMS
	//=====================================================================	
	//attach condition
	case 9:
	{
		//hint format["attach condition [item = %1, parent = %2]", _item, _parent];
		
		//check gas canister
		if (_item isKindOf "CookwareBase" or
			_item isKindOf "CookwareContainer") exitWith
		{
			if (isNull (itemParent _parent)) then
			{
				true
			}
			else
			{
				false
			};
		};

		true
	};	
	
	//detach condition
	case 10:
	{
		//hint format["detach condition [item = %1, parent = %2]", _item, _parent];
		
		//check gas canister
		if (_item isKindOf "GasCanisterBase") exitWith
		{
			if ( !(_parent getVariable ['fire',false]) and
				 !(isOn _parent) ) exitWith
			{
				true
			};
		};
		
		//default
		true
	};	
	
	default {};
};

