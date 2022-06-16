private["_item","_itemType","_actionName","_itemDir","_config","_name","_statusText","_sounds","_action","_trashItem","_sound","_soundConfig","_distance","_string","_trashPos","_trash","_person","_used","_use"];
/*
	Executed when a player selects the "use" action from the actions interaction menu
	
	TODO: Remove broadcasting of variables, only added as UI tooltips not generated on server yet.
*/
//Define
_item = _this select 0;
_actionName = _this select 1;
_person = _this select 2;
_client = owner _person;
_itemDir = getDir _item;
_used = _item getVariable ["used",-1];
_itemType = typeOf _item;

//pull config data
_config = 		configFile >> "CfgVehicles" >> _itemType;
_name = 		getText (_config >> "displayName");
_sounds = 		getArray (_config >> "UserActions" >> _actionName >> "soundEffects");
_action = 		getText (_config >> "UserActions" >> _actionName >> "playerAction");
_trashItem = 	getText(_config >> "UserActions" >> _actionName >> "trashItem");
_use = 			getNumber (_config >> "UserActions" >> _actionName >> "useQuantity");

if (_used == -1) then {
	if(isClass (_config >> "Resources")) then {
		_item setVariable ["used",0];
	} else {
		_used = 0;
	};
};

if (_used >= 1) exitWith {
	[_person,format["The %1 is empty",_name],"colorStatusChannel"] call fnc_playerMessage;
};

//select sound effect
_sound = _sounds select (floor(random count _sounds));
_soundConfig = configFile >> "CfgSounds" >> _sound;
_distance = (getArray (_soundConfig >> "sound")) select 3;

//Use Item
_result = _used + _use;

//check disease
[_person,_item,"Direct"] call event_transferModifiers;

if(_use == 1)then {
	deleteVehicle _item;
	
	//create trash item
	_trashPos = [position _person,0.3] call fnc_randomPlacement;
	_trash = createVehicle [_trashItem, _trashPos, [], 0, "CAN_COLLIDE"];
	_trash enableSimulation false;
} else {
	_item setVariable ["used",_result];
};

//conduct action
_string = format["[%1,_this,%2,%3] call player_useItemEnd",str(_itemType),_use,str(_actionName)];
_person say [_sound, _distance];
_person playAction [_action,compile _string];