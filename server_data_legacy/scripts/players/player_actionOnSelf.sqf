private["_state"];
/*
	Generic function to process an action on self

	Author: Rocket
*/
_state = _this select 0;

switch _state do 
{
	case 0:
	{
		private["_item","_inUse","_itemType","_actionName","_config","_name","_statusText","_sounds","_action","_messages","_trashItem","_sound","_soundConfig","_distance","_resources","_string","_trashPos","_trash","_person","_used","_use"];
		/*
			Executed when a player selects the "use" action from the actions interaction menu
			
			TODO: Remove broadcasting of variables, only added as UI tooltips not generated on server yet.
		*/	
		//Define
		_item = _this select 1;
		_actionName = _this select 2;
		_person = _this select 3;
		_override = if (count _this > 4) then {true} else {false};
		_client = owner _person;
		_quantity = quantity _item;
		_inUse = _person getVariable ["inUseItem",objNull];
		_previous = _person getVariable ["inUseItem",objNull];
		_itemType = typeOf _item;
		_unlimited = getNumber(configFile >> "CfgVehicles" >> _itemType >> "UserActions" >> _actionName >> "unlimited") == 1;
		
		//ensure item is on player
		if ((!isNull _inUse) and !_override) exitWith
		{
			[_person,"You are already using something",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
		};
		if (_quantity <= 0 and !_unlimited) exitWith
		{
			[_person,"There is nothing left",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
		};
		
		//move item into hands
		_inHands = itemInHands _person;
		if (_inHands != _item) exitWith
		{
			_person setVariable ["inUseItem",_item];
			_person setVariable ["previousItem",_inHands];
			_string = format["null = [2,%1,_this] spawn player_actionOnSelf",str(_actionName)];
			_person playAction ["disarm",compile _string];
		};		

		//pull config data
		_config = 	configFile >> "CfgVehicles" >> _itemType;
		_name = 		getText (_config >> "displayName");
		_sounds = 	getText (_config >> "UserActions" >> _actionName >> "sound");
		_action = 	getText (_config >> "UserActions" >> _actionName >> "action");
		_messages = 	getArray (_config >> "UserActions" >> _actionName >> "messages");
		_trashItem = getText(_config >> "UserActions" >> _actionName >> "trashItem");
		_use = 		getNumber (_config >> "UserActions" >> _actionName >> "useQuantity");
		_interactionWeight = getNumber (_config >> "UserActions" >> _actionName >> "interactionWeight"); //load interaction weight from currently running action
		//_resources =	_config >> "Resources";
		_scale=0;
		if (!_unlimited) then {
			_scale = _use / maxQuantity _item;
		};
		call player_fnc_useItemStart;
		
		
		//check disease
		[_person,_item,"Direct",_interactionWeight] call event_transferModifiers;

		//conduct action
		_string = format["[1,%1,_this,%2,%3] call player_actionOnSelf",str(_itemType),_scale,str(_actionName)];
		[_person,_sounds] call event_saySound;
		_person playAction [_action,compile _string];
	};
	case 1:
	{
		private["_water","_thirst","_person","_calories","_hunger","_client","_name","_statusText","_itemType","_config","_scale","_actionName","_returnItem"];
		/*
			Executed on completion of the use item action (animations)
		*/
		_itemType = _this select 1;	//onComplete may depend on this variable name
		_person = 	_this select 2;
		_scale = 	_this select 3;
		_actionName =_this select 4;
		_client = 	owner _person;

		//pull config data
		_config = 	configFile >> "CfgVehicles" >> _itemType;
		_name = 		getText (_config >> "displayName");
		_keepEmpty = getNumber (_config >> "UserActions" >> _actionName >> "keepEmpty") == 1;
		_statusText = getText (_config >> "UserActions" >> _actionName >> "statusText");
		_messages = 	getArray (_config >> "UserActions" >> _actionName >> "messages");
		_onComplete = getText (_config >> "UserActions" >> _actionName >> "onComplete");
		//_configResources = _config >> "Resources";
		
		[_person,_itemType,_scale] call player_fnc_processStomach; // process any nutritional benefits
		
		//conduct script
		call compile _onComplete;		
		call player_fnc_useItemEnd;

		//feedback to player
		[_person,format[(_messages select 2),_name],(_messages select 3)] call fnc_playerMessage;
	};
	case 2:
	{
		_actionName = _this select 1;
		_person = _this select 2;
		_item = _person getVariable ["inUseItem",objNull];
		_person moveToHands _item;
		waitUntil {itemInHands _person == _item};
		[0,_item,_actionName,_person,true] call player_actionOnSelf;
	};
};