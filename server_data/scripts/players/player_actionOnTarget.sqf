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
		

		
		//_person setVariable ["isUsingSomething",1];
		_person setVariable ["inUseItem",_item];
		
		//check if player is able to do action (if he isn't on ladder or swimming etc.)
		_anim =  animationState _person; 
		_skeleton = getText (configFile >> "CfgVehicles" >> typeOf _person >> "moves"); 
		_canUseActions = getNumber (configFile >> _skeleton >> "states" >> _anim >> "canUseActions");
		
		if (_canUseActions == 0) exitWith
		{
			[_person,"I'm unable to do that now",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];

		};
		
		if (_person distance _target > 2) exitWith
		{
			[_person,"I am too far away",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];			
		};
		
		if (damage _item == 1) exitWith
		{
			[_person,format["The %1 is completely ruined",displayName _item],""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];

		};	
		if (itemInHands _person != _item) exitWith
		{
			[_person,"The item must be in my hands to do this",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];

		};
		if (!isNull _inUse) exitWith
		{
			[_person,"I am already using something",""] call fnc_playerMessage;	//empty message
			_person setVariable ["isUsingSomething",0];

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
		
		if (_quantity <= 0 and !_unlimited) exitWith
		{
			[_person,"There is nothing left",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["actionTarget",objNull];
			_person setVariable ["isUsingSomething",0];

		};
		
		
		if (!_unlimited) then {
			if (_quantity >= _use) then {
				_scale = _use / maxQuantity _item;
			} else {
				_scale = _quantity / maxQuantity _item;
			};
		};

		if (!alive _target and !_allowDead) exitWith
		{
			//target is dead
			[_person,_message select 0,_message select 1] call fnc_playerMessage;
			_person setVariable ["isUsingSomething",0];

		};
				
		//notify
		_nameTarget = name _target;
		_namePerson = name _person;
		[_target,format[_message select 2,_namePerson],_message select 3] call fnc_playerMessage;
		[_person,format[_message select 4,_nameTarget],_message select 5] call fnc_playerMessage;
		
		/*
		//since the only way player can use an object on a target is by placing it in his hand, we don't need functionality that provides this function.  Moreover I don't want this script to lower the object's quantity because at this moment we don't know whether the action on target will be sucesful or not.
		call player_fnc_useItemStart; 
		
		//I want to delete object only when the action was succesful. So we don't have to create new copy of the object (and syncing all nescessary variables) when other player cancels the action.
		if (!_keepEmpty and !_unlimited) then 
		{
			deleteVehicle _item;
		};
		*/
		
		//play action
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
		_target = _person getVariable ["actionTarget",objNull];
		
		_allowDead = getNumber (_config >> "UserActions" >> _actionName >> "allowDead") == 1;
		_itemType = _this select 2;
		_scale = 	_this select 3;
		_actionName = _this select 4;
		_client = owner _person;
		_nameTarget = name _target;
		_namePerson = name _person;
		_config = 		configFile >> "CfgVehicles" >> _itemType;
		_onComplete = 	getText (_config >> "UserActions" >> _actionName >> "onComplete");
		_use = 			getNumber (_config >> "UserActions" >> _actionName >> "useQuantity");	
		_keepEmpty = 	getNumber (_config >> "UserActions" >> _actionName >> "keepEmpty") == 1;
		_message = getArray (_config >> "UserActions" >> _actionName >> "messages");
		_unlimited = getNumber(configFile >> "CfgVehicles" >> _itemType >> "UserActions" >> _actionName >> "unlimited") == 1; //NEW VAR
		_oldItem = itemInHands _person; //NEW VAR
		
		//_inUse = _person getVariable ["inUseItem",objNull];
		
		_item = _person getVariable ["inUseItem",objNull];
		//_item = itemInHands _person;
		
		
		if (_target distance _person > 2) exitWith
		{
			//target moved away
			[_person,format[_message select 6,_nameTarget],_message select 7] call fnc_playerMessage;
			// I removed creation of the object on the ground, because now it's still in player's inventory.  (so there's no need to add sync for many other varibles that should new object have)
			/*
			if (_use == 1) then
			{
				_item = createVehicle [_itemType, position _person, [], 0, "NONE"];
			};
			_person setVariable ["inUseItem",objNull];
			*/
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["actionTarget",objNull];
			_person setVariable ["isUsingSomething",0];

		};
		
		if ((!alive _target and !_allowDead) or (isNull _target)) exitWith
		{
			//target is now dead
			[_person,_message select 0,_message select 1] call fnc_playerMessage;
			/*
			if (_use == 1) then
			{
				_item = createVehicle [_itemType, position _person, [], 0, "NONE"];
			};
			_person setVariable ["inUseItem",objNull];
			*/
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["actionTarget",objNull];
			_person setVariable ["isUsingSomething",0];

		};	
		
		/*
		_actionCanceled = _person getVariable ["isUsingSomething",0];
		
		if (_actionCanceled == 2) exitWith
		{
			[_person,"Current action was canceled",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_person setVariable ["isUsingSomething",0];
		};
		*/
		
		//onStart
		call compile _onStart;
		
		//check disease
		[_person,_item,"Direct",_interactionWeight] call event_transferModifiers;
		[_person,_target,"Direct",_interactionWeight] call event_transferModifiers;
		
		//process nutrition
		[_target,_itemType,_scale] call player_fnc_processStomach; // process any nutritional benefits
		
		//conduct script
		call compile _onComplete;
		/*
		//I don't use useItemStart, I delete the object bellow instead, so either this function call is redundant. 
		false call player_fnc_useItemEnd; 
		*/
		if(!_unlimited) then {
			_oldItem addQuantity - _use;
			if (!_keepEmpty and quantity _oldItem <= 0) then {
				deleteVehicle _oldItem;
			};
		} else {
			if (!_keepEmpty and quantity _oldItem <= 0) then {
				deleteVehicle _oldItem;
			};
		};		
		//notify
		[_target,format[_message select 8,_namePerson],_message select 9] call fnc_playerMessage;
		[_person,format[_message select 10,_nameTarget],_message select 11] call fnc_playerMessage;

		//cleanup
		_person setVariable ["inUseItem",objNull];
		_person setVariable ["actionTarget",objNull];
		_person setVariable ["isUsingSomething",0];

	};
};
