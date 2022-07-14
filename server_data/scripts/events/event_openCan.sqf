private["_player", "_opener","_item","_quantity","_damageType", "_sharpness", "_heaviness", "_leftover", "_range", "_newDmg"];

_player = _this select 0;
_opener = _this select 1;
_openerName = typeOf (_this select 1);
_item = _this select 2;
_itemName = typeOf (_this select 2);

if ( damage _opener >= 1 ) exitWith
{ 
	_newDmg = damage _item;
	_newItem = [_itemName,_player] call player_addInventory;
	_newItem setDamage _newDmg;
	[_player,format['I can not use %1, its completely damaged.',displayName _opener],'colorAction'] call fnc_playerMessage;
};

if ( damage _item >= 1 ) exitWith
{
	_newItem = [_itemName,_player] call player_addInventory;
	_newItem setDamage 1;
	[_player,format['I can not open %1, its completely damaged.',displayName _item],'colorAction'] call fnc_playerMessage;
};

_damageType = getText ( configFile >> "CfgVehicles" >> _openerName >> "Melee" >> "ammo");
_sharpness = getNumber ( configFile >> "CfgAmmo" >> _damageType >> "bleedChance");
_heaviness =  getNumber ( configFile >> "CfgAmmo" >> _damageType >> "hitShock");
_toolHP =  getNumber ( configFile >> "CfgVehicles" >> _openerName >> "armor");

//if ( _sharpness < 0.1 ) then {exitWith { statusChat ["It Can Not Be Opened By This Item",""]};};

//set numbers into right range
_heaviness = _heaviness * 0.01;
_heaviness = (1 - _heaviness);

//-----
_range = random ( _sharpness - _heaviness );
_quantity = _range + _heaviness;

//-----
if ( _quantity > 1 ) then { _quantity = 1 };

//-----
_leftover = random ( 0.1 * _range);
if ( _leftover < 0.05 ) then
{
	_leftover =  random (5);
	_leftover = _leftover * 0.01;
};

_rand = (round random 10) * 0.001;
_newDmg = ((damage _opener) + (_rand * _heaviness) - (_rand * _sharpness * 0.5) + 0.02);

_opener setDamage _newDmg;

_rand = random (_range);
if ( _rand >= 0.5) then
{
	_quantity = _quantity - _leftover;
}
else
{
	_quantity = _quantity + _leftover;
};

if ( _quantity < 0 ) then { _quantity = _leftover;};
if ( _quantity >= 1 ) then { _quantity = 1;};


//deleteVehicle _item;
_openedItem = _itemName + "_Open";
_newItem = [_openedItem,_player] call player_addInventory;
_newItem setQuantity _quantity;
_newItem setDamage damage _item;

[_owner,format['I have opened the %1 but I have dropped some when I was opening it.',displayName _item],'colorAction'] call fnc_playerMessage

