private ["_state","_params"];

/*
	Food
	
	Usage:
	
	
	Author: Lubos Kovac
*/

_state = _this select 0;
_params = _this select 1;  //additional params

switch _state do
{	
	//on item attached
	case 1:
	{
		_gascooker = _params select 0;
		_item = _params select 1; 

		if (_item isKindOf "CookwareBase") then 
		{
			_gascooker setVariable ['cooking_equipment', _item]; //attach cooking equipment
			
			//cooking equipment ready - true
			_item setVariable ['cooking_ready', true];
		};
		
		if (_item isKindOf "GasCanisterBase") then 
		{
			_gascooker setVariable ['fuel_item', _item]; //attach fuel
		};	
		
		//debugLog
		//hint format["Item attached '%1'", displayName _item];
	};
	
	//on item detached
	case 2:
	{
		_gascooker = _params select 0;
		_item = _params select 1; 
		
		if (_item isKindOf "CookwareBase") then 
		{
			_gascooker setVariable ['cooking_equipment', objNull]; //detach cooking equipment
			
			//cooking equipment ready - false
			_item setVariable ['cooking_ready', false];
		};
		
		if (_item isKindOf "GasCanisterBase") then 
		{
			_gascooker setVariable ['fuel_item', objNull]; //detach fuel
		};		
		
		//debugLog
		//hint format["Item detached '%1'", displayName _item];
	};
	
	//turn on (action) 
	case 3:
	{
		_gascooker = _params select 0;
		
		_gascooker say3D 'flashlight_switch_on';
		
		//turn on
		[5, [_gascooker]] call gascooker_manageActions;
	};
	
	//turn off (action)
	case 4:
	{
		_gascooker = _params select 0;
		
		_gascooker say3D 'flashlight_switch_off';
		
		//stop cooking
		_cooking_equipment = _gascooker getVariable ['cooking_equipment', objNull];
		if !(isNull _cooking_equipment) then
		{
			_cooking_equipment setVariable ['is_cooking', false];
		};
	
		//turn off
		[6, [_gascooker]] call gascooker_manageActions;
	};	
	
	//turn on (state)
	case 5:
	{
		_gascooker = _params select 0;
		_gascooker powerOn true;
		
		//start heating
		[1, [_gascooker]] spawn gascooker_manageFire;
		
		//change visual
		_config_flame = configFile >> "cfgVehicles" >> typeOf _gascooker >> "flame";
		_gascooker setObjectTexture [0, getText(_config_flame >> "texture")];
	};		
	
	//turn off (state)
	case 6:
	{
		_gascooker = _params select 0;
		_gascooker powerOn false;

		//start heating
		[2, [_gascooker]] spawn gascooker_manageFire;
		
		//change visual
		_gascooker setObjectTexture [0, ""];
	};	
	
	default {};
};