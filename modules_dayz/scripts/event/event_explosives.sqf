private ["_state","_item"];

/*
	
	
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_item = _this select 1;  //additional params

//conditions
_min_butane_to_explode = 30; //grams
_min_temp_to_explode = 100; //degree Celsius
_min_spray_quantity_to_explode = 0.5; //perc

_fnc_explode_fire = 
{
	private["_item","_explosion_pos"];
	
	_item = _this;
	
	//get explosion position 
	_explosion_pos = getPosATL _item;
	if !(isNull (itemParent _item)) then
	{
		_explosion_pos = getPosATL (itemParent _item);
	};
	
	//spawn explosion
	_explosion = 'Land_A_FuelStation_Feed' createVehicle _explosion_pos;
	_explosion setPosATL _explosion_pos;
	_explosion setDamage 1;
	
	//delete both
	deleteVehicle _explosion;
	deleteVehicle _item;
};

switch _state do
{	
	//killed (event)
	case 1:
	{
		//gas canisters
		if (_item isKindOf 'GasCanisterBase') exitWith
		{
			_remaining_fuel = _item getVariable ['butane', 0];
			_temperature = _item getVariable ['temperature', 20];
			
			//debugLog
			//hint format["item = %1, temperature = %2, butane = %3", displayName _item, _temperature, _remaining_fuel];
			
			if (_remaining_fuel >= _min_butane_to_explode and
				_temperature >= _min_temp_to_explode) then
			{
				_item call _fnc_explode_fire;
			};
		};
		
		//grenade
		if (_item isKindOf 'Consumable_Grenade' or 
			_item isKindOf 'Grenade' or 
			_item isKindOf 'GrenadeRGD5') exitWith
		{
			_temperature = _item getVariable ['temperature', 20];
			
			if (_temperature >= _min_temp_to_explode) then
			{
				_item call _fnc_explode_fire;
			};			
		};
		
		//trap mine
		if (_item isKindOf 'Trap_LandMine') exitWith
		{
			_temperature = _item getVariable ['temperature', 20];
			
			if (_temperature >= _min_temp_to_explode) then
			{
				_item call _fnc_explode_fire;
			};			
		};		
		
		//spray canister(s)
		if (_item isKindOf 'SpraycanBase') exitWith
		{
			_quantity = _item getVariable ['quantity', 0];
			_temperature = _item getVariable ['temperature', 20];
			
			if (_quantity >= _min_spray_quantity_to_explode and
				_temperature >= _min_temp_to_explode) then
			{
				_item call _fnc_explode_fire;
			};			
		};
	};
	
	default {};
};
