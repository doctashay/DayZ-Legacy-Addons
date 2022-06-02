private["_inv","_person","_item","_cargoinv","_container"];
/*
	Takes item object and returns _item reference
	Will create on ground below player, if no space
	
	Author: Jan Tomasik
*/
_item = _this select 0;
_person = _this select 1;
_container = _this select 1;
_inv = false;

if (count _this == 2) then {
	_inv = _person moveToInventory _item;
}
else
{
	_person = _this select 2;
	_container = _this select 1;
	_inv = _container moveToCargo _item;
	if (!_inv) then
	{
		_inv = _person moveToInventory _item;
	};
};

if (!_inv) then
{
	_inv = moveToGround _item;
};

[_person,_inv,"Direct"] call event_transferModifiers;
_inv