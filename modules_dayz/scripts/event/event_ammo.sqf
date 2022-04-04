private ["_state","_item","_sound_sources"];

/*
	
	
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_item = _this select 1;  //additional params

//conditions
_min_temp_to_explode = 100; //degree Celsius
_max_update_time = 2; //seconds
_min_update_time = 0.5;

//sounds
_sound_sources = ["ammopops_1","ammopops_2","ammopops_3","ammopops_4","ammopops_5","ammopops_6"];

/*
	magazine info:
	_mag setMagazineAmmo _receiverQty;
	magazineAmmo _mag 
 */
_fnc_explode_fire = 
{
	private["_ammo","_fireplace","_index","_sound_source"];
	_ammo = _this;
	_fireplace = itemParent _ammo;
	
	//select random sound
	_index = floor (random (count _sound_sources));
	_sound_source = _sound_sources select _index;
	
	[_fireplace, _sound_source] call event_saySound;
	
	//update magazine ammo
	if (_ammo isKindOf "MagazineBase") then
	{
		_ammo_count = magazineAmmo _ammo;
		_ammo setMagazineAmmo (_ammo_count - 1);
	};
	
	if (_ammo isKindOf "AmmunitionItemBase") then
	{
		[_ammo, -1] call fnc_addQuantity;
	};
};

switch _state do
{	
	//killed (event)
	case 1:
	{
		private["_ammo_count_start","_temperature","_update_time"];
		//Debuglog
		//hint format["item = %1, ammo = %2, quantity = %3", displayname _item, magazineAmmo _item, quantity _item];
		
		_ammo_count_start = 0;
		//update magazine ammo
		if (_item isKindOf "MagazineBase") then
		{
			_ammo_count_start = magazineAmmo _item;
		};
		
		if (_item isKindOf "AmmunitionItemBase") then
		{
			_ammo_count_start = quantity _item;
		};
		
		//do exlosions
		_temperature = _item getVariable ['temperature', 20];
		if (_temperature >= _min_temp_to_explode) then
		{
			for [{_i = 0}, {_i < _ammo_count_start}, {_i = _i + 1}] do
			{
				_update_time = floor (random _max_update_time);	
				_update_time = _min_update_time max _update_time; //clamp
				sleep _update_time;
				
				if (_temperature >= _min_temp_to_explode) then
				{
					//start exploding
					_item call _fnc_explode_fire;
				};
				
				_temperature = _item getVariable ['temperature', 20];
			};			
		};
	};
	
	default {};
};
