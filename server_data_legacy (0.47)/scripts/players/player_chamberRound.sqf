private["_person","_cfgAmmo","_cfgWeapon","_qty"];
/*
	Load Magazine with rounds
	
	TODO: Don't allow magazine to be loaded while on weapon
	
	Author: Rocket
*/
_person = _owner;
_cfgAmmo = configFile >> "CfgVehicles" >> typeOf _tool1;
_cfgWeapon = configFile >> "CfgWeapons" >> typeOf _tool2;
_type = _this;

//statusChat [format ["ammo: %1 // weapon: %2 // result: %3",getText(_cfgAmmo >> "chamberedRound"),getText(_cfgWeapon >> "chamberedRound"),(getText(_cfgAmmo >> "chamberedRound") isKindOf getText(_cfgWeapon >> "chamberedRound"))],""];

if (damage _tool1 >= 1) exitWith
{	
	[_person,"The ammunition is too badly damaged",""] call fnc_playerMessage;
};
if (damage _tool2 >= 1) exitWith
{	
	[_person,"The weapon is too badly damaged",""] call fnc_playerMessage;
};

//stop if error
if !(getText(_cfgAmmo >> "chamberedRound") isKindOf getText(_cfgWeapon >> "chamberedRound")) exitWith 
{
	//not same type
	[_person,"It doesn't fit in there",""] call fnc_playerMessage;
};
if (!isNull (_tool2 itemInSlot "magazine")) exitWith
{
	//has magazine
	[_person,"The weapon is full",""] call fnc_playerMessage;
};
if (quantity _tool1 < 1) exitWith
{
	//not enough ammo
	deleteVehicle _tool1;
};

//do it
_magazine = format["%1_%2",getText(_cfgAmmo >> "chamberedRound"),_type];
_maxQ = getNumber(configFile >> "CfgMagazines" >> _magazine >> "count");
_pileQ = quantity _tool1;
_qty = _pileQ min _maxQ;

//reduce pile
if (_pileQ == 1) then
{
	deleteVehicle _tool1;
}
else
{
	_tool1 addQuantity -_qty;
};

//create the magazine
_mag = _tool2 createInInventory _magazine;
if (_qty != _maxQ) then {_mag setMagazineAmmo _qty};
[_owner,format["I have chambered the %1",displayName _tool2],"colorAction"] call fnc_playerMessage;