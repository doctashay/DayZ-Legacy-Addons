private ["_state","_params","_item","_type"];

/*
	Manage fireplace states.
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_params = _this select 1;

switch _state do
{	
	//init/restore
	case 0: 
	{
		//server sync
		if (isServer) then
		{
			_fireplace = _params select 0; 	//fireplace
		
			//fire - is fire active?
			_init_value = _fireplace getVariable ["fire", false];
			_fireplace setVariable ["fire", _init_value]; 
			//is_fireplace - is fire active?
			_init_value = _fireplace getVariable ["is_fireplace", false];
			_fireplace setVariable ["is_fireplace", _init_value]; 
			//is_in_use - is using action on fireplace?
			_init_value = _fireplace getVariable ["is_in_use", false];
			_fireplace setVariable ["is_in_use", _init_value]; 
			//temperature
			_init_value = _fireplace getVariable ["temperature", 0];
			_fireplace setVariable ["temperature", _init_value];
			//temperature loss multiplier
			_init_value = _fireplace getVariable ["temperature_loss_mp", 1];
			_fireplace setVariable ["temperature_loss_mp", _init_value]; 
			//fuel burn rate multiplier
			_init_value = _fireplace getVariable ["fuel_burn_rate_mp", 1];
			_fireplace setVariable ["fuel_burn_rate_mp", _init_value]; 
			//point name for smoke particle
			_init_value = _fireplace getVariable ["smoke_particle_point", nil];
			if !(isNil "_init_value") then { _fireplace setVariable ["smoke_particle_point", _init_value]; };
			//indoor slot name
			_init_value = _fireplace getVariable ["indoor_slot_name", nil];
			if !(isNil "_init_value") then { _fireplace setVariable ["indoor_slot_name", _init_value]; }; 			
			//TODO
			//fuel max capacity multiplier
			_init_value = _fireplace getVariable ["fuel_max_capacity_mp", 1];
			_fireplace setVariable ["fuel_max_capacity_mp", _init_value];
			
			//Attachments
			//spending fuel - will be spent next
			_init_value = _fireplace getVariable ["spending_fuel", [objNull,0]];
			_fireplace setVariable ["spending_fuel", _init_value]; 
			//cooking equipment - is cooking equipment attached?
			_init_value = [_fireplace, "CookwareBase"] call fnc_getAttachment;
			_fireplace setVariable ["cooking_equipment", _init_value];  //cooking equipment is attached to the fireplace
			//fuel items attached
			_init_value = _fireplace getVariable ["fuel_items", [[objNull,0], [objNull,0], [objNull,0]]];  //wooden sticks[0], firewood[1], Book[2]
			_fireplace setVariable ["fuel_items", _init_value];
			//kindling items attached
			_init_value = _fireplace getVariable ["kindling_items", [[objNull,0], [objNull,0], [objNull,0], [objNull,0], [objNull,0]]];  //rags[0], bandage[1], paper[2], oak bark[3], birch bark[4]
			_fireplace setVariable ["kindling_items", _init_value];
			
			//sync variables
			_this spawn 
			{
				//TODO
				((_this select 1) select 0) synchronizeVariable ["fire", 1, {_this call event_fnc_fireplaceFire}];
				((_this select 1) select 0) synchronizeVariable ["is_fireplace", 1]; 
				((_this select 1) select 0) synchronizeVariable ["temperature", 10, {_this call event_fnc_fireplaceIntensity}];
				((_this select 1) select 0) synchronizeVariable ["smoke_particle_point", 1]; 
				((_this select 1) select 0) synchronizeVariable ["indoor_slot_name", 1]; 
				//*************************************************
				((_this select 1) select 0) synchronizeVariable ["fuel_items", 1, {[_this] call event_fnc_fireplaceState}];
				((_this select 1) select 0) synchronizeVariable ["kindling_items", 1, {[_this] call event_fnc_fireplaceState}];
				((_this select 1) select 0) synchronizeVariable ["cooking_equipment", 1, {[_this] call event_fnc_fireplaceState}];
				//*************************************************
			};
		};
		
		//refresh visual
		//[_fireplace] call event_fnc_fireplaceState;
	};
	
	default {};
};
