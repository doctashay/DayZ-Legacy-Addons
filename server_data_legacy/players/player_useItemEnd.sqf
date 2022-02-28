private["_water","_thirst","_person","_calories","_hunger","_client","_name","_statusText","_itemType","_config","_scale","_actionName"];
/*
	Executed on completion of the use item action (animations)
*/
_itemType = _this select 0;
_person = 	_this select 1;
_scale = 	_this select 2;
_actionName =_this select 3;
_client = 	owner _person;

//pull config data
_config = 		configFile >> "CfgVehicles" >> _itemType;
_name = 		getText (_config >> "displayName");
_statusText = 	getText (_config >> "UserActions" >> _actionName >> "statusText");
_calories = 	(getNumber (_config >> "Resources" >> "calories")) * _scale;
_water = 		(getNumber (_config >> "Resources" >> "water")) * _scale;

if (_water != 0) then {
	_thirst = (_person getVariable["thirst",0]);
	_person setVariable ["thirst",(_thirst - _water)];
};
if (_calories != 0) then {
	_hunger = (_person getVariable["hunger",0]);
	_person setVariable ["hunger",(_hunger - _calories)];
};

//feedback to player
[_person,format[_statusText,_name],"colorAction"] call fnc_playerMessage;