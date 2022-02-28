private["_state"];
/*
	Generic function to process an action on an item
	Generally invoked via crafting

	Author: Rocket
*/
_state = _this select 0;

switch _state do 
{
	case 0:
	{
		private["_item","_inUse","_itemType","_actionName","_itemDir","_config","_name","_statusText","_sounds","_action","_messages","_trashItem","_sound","_soundConfig","_distance","_resources","_string","_trashPos","_trash","_person","_used","_use"];
		/*
			Executed when a player selects the "use" action from the actions interaction menu
			
			TODO: Remove broadcasting of variables, only added as UI tooltips not generated on server yet.
		*/
		
		//Define
		_tools = _this select 1;
		_item = _tools select 0;
		_tool2 = _tools select 1;
		
		_actionName = _this select 2;
		_person = _this select 3;
		_override = if (count _this > 4) then {true} else {false};
		_client = owner _person;
		_itemDir = getDir _item;
		_quantity = quantity _item;
		_inUse = _person getVariable ["inUseItem",objNull];
		_itemType = typeOf _item;
				
		//ensure item is on player
		if ((!isNull _inUse) and !_override) exitWith
		{
			[_person,"You are already using something",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_tool2 = _person getVariable ["inUseTool",objNull];
		};
		if (_quantity <= 0) exitWith
		{
			[_person,"There is nothing left",""] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
			_tool2 = _person getVariable ["inUseTool",objNull];
		};
		
		//pull config data
		_config = 		configFile >> "CfgRecipes" >> _actionName;
		_sounds = 		getText (_config >> "sound");
		_action = 		getText (_config >> "playerAction");
		_messages = 	getArray (_config >> "messages");
		_onComplete = 	getText (_config >> "onComplete");
		_use = 			getNumber (_config >> "useQuantity") * maxQuantity _item;
		_keepEmpty = 	getNumber(_config >> "keepEmpty") == 1;
		_interactionWeight = getNumber (_config >> "interactionWeight"); //load interaction weight from currently running action
		_allowDead = 	getNumber (_config >> "allowDead") == 1;
		_resources =	_config >> "Resources";

		//Error Messages		
		if (_quantity <= 0) exitWith {
			[_person,format[(_messages select 0),displayName _item],(_messages select 1)] call fnc_playerMessage;	//empty message
			_person setVariable ["inUseItem",objNull];
		};
		if (damage _item >= 1) exitWith {
			[_person,format[(_messages select 2),displayName _item],(_messages select 3)] call fnc_playerMessage;	//damage tool1
			_person setVariable ["inUseItem",objNull];
		};		
		if (damage _tool2 >= 1 and !_allowDead) exitWith {
			[_person,format[(_messages select 4),displayName _tool2],(_messages select 5)] call fnc_playerMessage;	//damage tool2
			_person setVariable ["inUseItem",objNull];
		};
		
		//move item into hands
		_inHands = itemInHands _person;
		if (_inHands != _item) exitWith
		{
			_person setVariable ["inUseItem",_item];
			_person setVariable ["inUseTool",_tool2];
			_person setVariable ["previousItem",_inHands];
			_string = format["null = [1,%1,_this] spawn player_actionOnItem",str(_actionName)];
			//_string = format["null = [1,%3,_this] spawn player_actionOnItem",str(_item),str(_tool2),str(_actionName)];
			_person playAction ["disarm",compile _string];
		};		
		
		//check disease
		[_person,_item,"Direct",_interactionWeight] call event_transferModifiers;
		[_item,_tool2,"Direct",_interactionWeight] call event_transferModifiers;
		
		//check clear disease (disinfection)
		if (_item isKindOf "Medical_DisinfectantSpray")  then
		{
			[_item,_tool2,"Direct"/*,_interactionWeight*/] call event_clearModifiers;
		};
		
		//Use Item		
		call player_fnc_useItemStart;

		//conduct action
		[_person,_sounds] call event_saySound;
		_person playAction _action;
		
		//conduct script
		call compile _onComplete;	//[_item,_tool2,_person]
		call player_fnc_useItemEnd;
		
		//send success
		[_person,format[(_messages select 6),displayName _item,displayName _tool2],(_messages select 7)] call fnc_playerMessage;	//empty message
	};
	case 1:
	{
		_actionName = _this select 1;
		_person = _this select 2;
		
		_item = _person getVariable ["inUseItem",objNull];
		_tool2 = _person getVariable ["inUseTool",objNull];
		
		_person moveToHands _item;
		waitUntil {itemInHands _person == _item};
		[0,[_item,_tool2],_actionName,_person,true] call player_actionOnItem;
	};
};