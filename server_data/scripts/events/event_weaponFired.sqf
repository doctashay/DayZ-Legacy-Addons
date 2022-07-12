private["_unit","_ammo","_audible","_distance","_listTalk","_weapon"];
//[unit, weapon, muzzle, mode, ammo, magazine, projectile]
_unit = 		_this select 0;
_weapon = 		_this select 1;
_ammo = 		_this select 4;
_magazine = 		_this select 5;
_projectile = 	_this select 6;

//remove fake magazine
_destroy = getNumber (configFile >> "CfgMagazines" >> _magazine >> "destroyOnEmpty") == 1;
if (_destroy) then
{
	hint "destroy";
	_actual = ((itemInHands _unit) itemInSlot "magazine");
	if (magazineAmmo _actual == 0) then {deleteVehicle _actual};
};

_shot = getText (configFile >> "CfgWeapons" >> _weapon >> "shotAction");
if (_shot != "") then
{
	_qty = _unit ammo _weapon;
	if (_qty == 0 and !_destroy) exitWith {};
	_unit playAction _shot;
};