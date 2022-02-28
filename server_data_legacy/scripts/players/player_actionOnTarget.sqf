private["_state"];
/*
	Generic function to process an action on a target

	Author: Rocket
*/
_state = _this select 0;

switch _state do 
{
	case 0:
	{
		private["_item","_inUse","_person","_actionName","_client","_target","_itemType","_config","_sounds","_action","_message","_nameTarget","_onStart","_namePerson","_string"];
		/*
			Initial state
			Occurs straight away once the action is selected
		*/
		_item = _this select 1;
		_person = _this select 2;
		_actionName = _this select 3;
		_client = owner _person;
		_quantity = quantity _item;
		_inUse = _person getVariable ["inUseItem",objNull];
		_target = playerTarget _client;
		_itemType = typeOf _item;
		_unlimited = getNumber(configFile >> "CfgVehicles" >> _itemType >> "UserActions" >> _actionName >> "unlimited") == 1;
		
		if (itemInHands _person != _item) exitWith
		{
			[_person,"The item must be in your hands to do this",""] call fnc_playerMessage;	//empty message
		};
		if (!isNull _inUse) exitWith
		{
			[_person,"You are already using something",""] call fnc_playerMessage;	//empty message
		};

		//load data
		_config = 	configFile >> "CfgVehicles" >> _itemType;
		_sounds = 	getText (_config >> "UserActions" >> _actionName >> "sound");
		_action = 	getText (_config >> "UserActions" >> _actionName >> "action");
		_message = 	getArray (_config >> "UserActions" >> _actionName >> "messages");
		_onStart = 	getText (_config >> "UserActions" >> _actionName >> "onStart");
		_allowDead = getNumber (_config >> "UserActions" >> _actionName >> "allowDead") == 1;
		_use = 		getNumber (_config >> "UserActions" >> _actionName >> "useQuantity");
		_interactionWeight = getNumber (_config >> "UserActions" >> _actionName >> "interactionWeight"); //load interaction weight from currently running action
		_scale=0;
		if (!_unlimited) then {
			_scale = _use / maxQuantity _item;
		};

		if (!alive _target and !_allowDead) exitWith
		{
			//target is dead
			[_person,_message select 0,_message select 1] call fnc_playerMessage;
		};
		
		//onStart
		call compile _onStart;
		
		//notify
		_nameTarget = name _target;
		_namePerson = name _person;
		[_target,format[_message select 2,_namePerson],_message select 3] call fnc_playerMessage;
		[_person,format[_message select 4,_nameTarget],_message select 5] call fnc_playerMessage;
		
		//check disease
		[_person,_item,"Direct",_interactionWeight] call event_transferModifiers;

		call player_fnc_useItemStart;
		
		//play action
		if (!_keepEmpty and !_unlimited) then
		{
			deleteVehicle _item;
		};
		[_person,_sounds] call event_saySound;
		_person setVariable ["actionTarget",_target];
		_string = format["[1,_this,%1,%2,%3] call player_actionOnTarget",str(_itemType),_scale,str(_actionName)];

		_person playAction [_action,compile _string];
	};
	case 1:
	{
		private["_person","_client","_target","_nameTarget","_namePerson","_itemType","_actionName","_config","_message","_onComplete"];
		/*
			Finished state
			Occurs after the action is finished
		*/		
		_person = _this select 1;
		_itemType = _this select 2;
		_scale = 	_this select 3;
		_actionName = _this select 4;
		_client = owner _person;
		_target = _person getVariable ["actionTarget",objNull];
		_nameTarget = name _target;
		_namePerson = name _person;
		
		_config = 		configFile >> "CfgVehicles" >> _itemType;
		_message = 		getArray (_config >> "UserActions" >> _actionName >> "messages");
		_onComplete = 	getText (_config >> "UserActions" >> _actionName >> "onComplete");
		_use = 			getNumber (_config >> "UserActions" >> _actionName >> "useQuantity");	
		_keepEmpty = 	getNumber (_config >> "UserActions" >> _actionName >> "keepEmpty") == 1;
		_allowDead = 	getNumber (_config >> "UserActions" >> _actionName >> "allowDead") == 1;

		if ((!alive _target and !_allowDead) or (isNull _target)) exitWith
		{
			//target is now dead
			[_person,_message select 0,_message select 1] call fnc_playerMessage;
			if (_use == 1) then
			{
				_item = createVehicle [_itemType, position _person, [], 0, "NONE"];
			};
			_person setVariable ["inUseItem",objNull];
		};	

		if (_target distance _person > 2) exitWith
		{
			//target moved away
			[_person,format[_message select 6,_nameTarget],_message select 7] call fnc_playerMessage;
			if (_use == 1) then
			{
				_item = createVehicle [_itemType, position _person, [], 0, "NONE"];
			};
			_person setVariable ["inUseItem",objNull];
		};
		
		//check disease
		[_person,_target,"Direct",_interactionWeight] call event_transferModifiers;
		
		//process nutrition
		[_target,_itemType,_scale] call player_fnc_processStomach; // process any nutritional benefits
		
		//conduct script
		call compile _onComplete;
		false call player_fnc_useItemEnd;

		//notify
		[_target,format[_message select 8,_namePerson],_message select 9] call fnc_playerMessage;
		[_person,format[_message select 10,_nameTarget],_message select 11] call fnc_playerMessage;

		//cleanup
		_person setVariable ["actionTarget",objNull];
	};
};