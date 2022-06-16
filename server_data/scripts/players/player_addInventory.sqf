private["_itemType","_person","_item","_container"];
/*
	Takes item type and returns _item reference
	Will create on ground below player, if no space
	
	[type,person] OR
	[type,container,person]
	
	Author: Rocket
*/
_itemType = _this select 0;
_person = _this select 1;
_container = _this select 1;

if (count _this == 2) then {
	_item = _person createInInventory _itemType;
}
else
{
	_person = _this select 2;
	_container = _this select 1;
	_item = _container createInCargo _itemType;
	if (isNull _item) then
	{
		_item = _person createInInventory _itemType;
	};
};
if (isNull _item) then
{
	_item = _itemType createVehicle (getPosATL _person);
	_item setPosATL (getPosATL _person);
};
//check disease
[_person,_item,"Direct"] call event_transferModifiers;
_item