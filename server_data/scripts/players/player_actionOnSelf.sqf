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
		_parent = itemParent _item;
		_override = if (count _this > 4) then {true} else {false};
		_client = owner _person;
		_quantity = quantity _item;
		_inUse = _person getVariable ["inUseItem",objNull];
		_previous = _person getVariable ["previousItem",objNull];
		_itemType = typeOf _item;
		_unlimited = getNumber(configFile >> "CfgVehicles" >> _itemType >> "UserActions" >> _actionName >> "unlimited") == 1;
		
		//diag_log [format ["case0 -- _this contains: %1",_this],""]; // DEBUG
			
		//_person setVariable ["isUsingSomething",1];
		
		if (damage _item == 1) exitWith
		{
			[_person,format["The %1 is completely ruined",displayName _item],""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];
		};		
		if ((!isNull _inUse) and !_override) exitWith
		{
			[_person,"You are already using something",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];
		};
		if (_quantity <= 0 and !_unlimited) exitWith
		{
			[_person,"There is nothing left",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];
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
		
		if (!_override) then	//runs only if not needed to swap something into hands
		{
			_person setVariable ["previousItem",_inHands];
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
		_onStart = 	getText (_config >> "UserActions" >> _actionName >> "onStart");
		//_resources =	_config >> "Resources";
		
		_scale = 0;
		
		if (!_unlimited) then 
		{
			if (_quantity >= _use) then
			{
				_scale = _use / maxQuantity _item;
			} 
			else
			{
				_scale = _quantity / maxQuantity _item;
			}
		}
		else
		{
			_scale = 1;
		};
		
		if (_use < 0) then // note: just hotfix for 'catch rain action' - will be fixed properly after talk with programmers about synchronized variables
		{
			_scale = 0;
		};
		
		//call player_fnc_useItemStart;		
		//call compile _onStart;
		_person setVariable ["inUseItem",_item];
		
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
		_onStart = 	getText (_config >> "UserActions" >> _actionName >> "onStart");
		_onComplete = getText (_config >> "UserActions" >> _actionName >> "onComplete");
		_interactionWeight = getNumber (_config >> "UserActions" >> _actionName >> "interactionWeight");
		_unlimited = getNumber(configFile >> "CfgVehicles" >> _itemType >> "UserActions" >> _actionName >> "unlimited") == 1;
		//_configResources = _config >> "Resources";
		
		_oldItem = _person getVariable ["previousItem",objNull];
		//_item = _person getVariable ["inUseItem",objNull];
		_item = itemInHands _person;
		_quantity = quantity _item;
		_use = 	getNumber (_config >> "UserActions" >> _actionName >> "useQuantity");
		
		/*				
		_actionCanceled = _person getVariable ["isUsingSomething",0];
		
		if (_actionCanceled == 2) exitWith
		{
			[_person,"Current action was canceled",""] call fnc_playerMessage;	// empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];				
		};
		*/
		
		//call player_fnc_useItemStart;	
				
		// Conduct onStart script
		call compile _onStart;
		
		// Process modifiers transfers and stomach
		[_person,_item,"Direct",_interactionWeight] call event_transferModifiers; // check disease
		[_person,_itemType,_scale] call player_fnc_processStomach; // process any nutritional benefits		
					
		_switchItems = false;
		if (_oldItem != _item) then 
		{
			_switchItems = true;
		};		
		
		//_debugText = format ["DBG>> _quantity:%1 VS. quantity _item:%2",_quantity,(quantity _item)];
		//statusChat [_debugText,""];
		
		// Use part of stack and delete item when desired (formerly splitted between player_fnc_useItemStart and player_fnc_useItemEnd)
		if (!_unlimited) then 
		{	
			_item addQuantity - _use;			
			if (!_keepEmpty and quantity _item <= 0) then 
			{
				deleteVehicle _item;
			};
		}
		else
		{			
			if (!_keepEmpty and quantity _item <= 0) then
			{
				deleteVehicle _item;
			};
		};		
		
		//call player_fnc_useItemEnd;
		
		// Conduct onComplete script
		call compile _onComplete;
		
		if (_switchItems) then 
		{
			_person moveToHands _oldItem;
			_switchItems = false;
		};		
		
		//	Clean necessary variables (formerly in player_fnc_useItemEnd)
		_person setVariable ["inUseItem",objNull];
		_person setVariable ["previousItem",objNull];
		_person setVariable ["isUsingSomething",0];
						
		// Feedback to player
		[_person,format[(_messages select 2),_name],(_messages select 3)] call fnc_playerMessage;
	};
	case 2:
	{
		_actionName = _this select 1;
		_person = _this select 2;
		_item = _person getVariable ["inUseItem",objNull];
				
		_parent = itemParent _item;
		_result = true;
		
		//find the top parent
		while {true} do {
			_parent = itemParent _parent;
			if (isNull itemParent _parent) exitWith {};
		};
		
		//is the object on the player?
		if (_parent != _person) then
		{
			//no, take in hands
			_person moveToHands objNull;
			_result = _person takeInHands _item;	
			
			//record what to do
			_previous = _person getVariable ["previousItem",objNull];
			if (isNull _previous) then
			{
				_person setVariable ["previousItem",_item];
			};
		}
		else
		{
			//within player inventory
			_person moveToHands _item;
		};
		
		if (!_result) exitWith	//occurs when unable to place the object in the inventory (via takeInHands or inventory)
		{
			[_person,"Unable to pickup item",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];
		};
		
		_result = false;_i = 0;
		while {true} do {
			if (itemInHands _person == _item) exitWith {_result = true};
			if (_i > 20) exitWith {_result = false};	//will stop trying after 10 seconds
			_i = _i + 1;
			sleep 0.5;
		};
		
		if (_result) then {
			[0,_item,_actionName,_person,true] call player_actionOnSelf;
		}
		else
		{
			[_person,"Error putting item in your hands",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];
		};
	};
};