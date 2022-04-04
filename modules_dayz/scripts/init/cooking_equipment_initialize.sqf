private ["_state","_params","_item","_type"];

/*
	Manage cooking equipment states.
	
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
			_cooking_equipment = _params select 0; 	//cooking equipment
		
			//temperature
			_init_value = _cooking_equipment getVariable ["temperature", 0];
			_cooking_equipment setVariable ["temperature", _init_value];

			//modifiers
			_init_value = _cooking_equipment getVariable ["modifiers", []];
			_cooking_equipment setVariable ["modifiers", _init_value];
			
			//sync variables
			_this spawn 
			{
				((_this select 1) select 0) synchronizeVariable ["temperature", 1, {_this call event_fnc_cookingEquipmentState}];
				((_this select 1) select 0) synchronizeVariable ["quantity", 1];
				((_this select 1) select 0) synchronizeVariable ["liquidType", 1];
				((_this select 1) select 0) synchronizeVariable ["cooking_ready", 1];
				((_this select 1) select 0) synchronizeVariable ["is_cooking", 1];
			};
		};
		
		//refresh visual
		_cooking_equipment call event_fnc_cookingEquipmentState;
	};
	
	default {};
};
