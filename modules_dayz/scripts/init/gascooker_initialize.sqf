private ["_state","_params","_init_value"];

/*
	Manage gascooker init.
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_params = _this select 1;

switch _state do
{	
	//init
	case 0: 
	{
		//server sync
		if (isServer) then
		{
			_gascooker = _params select 0; 	//gas cooker
		
			//fire - is fire active?
			_init_value = _gascooker getVariable ["fire", false];
			_gascooker setVariable ["fire", _init_value]; 
		
			//fuel item (gas source)
			_init_value = [_gascooker, "GasCanisterBase"] call fnc_getAttachment;
			_gascooker setVariable ["fuel_item", _init_value]; 
			
			//cooking equipment
			_init_value = [_gascooker, "CookwareBase"] call fnc_getAttachment;
			_gascooker setVariable ["cooking_equipment", _init_value]; 
			
			//temperature loss multiplier
			_init_value = _gascooker getVariable ["temperature_loss_mp", 1];
			_gascooker setVariable ["temperature_loss_mp", _init_value]; 
			
			//sync variables
			_this spawn 
			{
				((_this select 1) select 0) synchronizeVariable ["fire", 1, {_this call event_fnc_gascookerFire}];
				((_this select 1) select 0) synchronizeVariable ["fuel_item", 1];
				((_this select 1) select 0) synchronizeVariable ["cooking_equipment", 1];
				((_this select 1) select 0) synchronizeVariable ["temperature", 0.2];
			};
		};
	};
	
	default {};
};
