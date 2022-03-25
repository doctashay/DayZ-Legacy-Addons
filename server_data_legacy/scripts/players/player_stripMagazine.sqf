private["_mag","_person","_client","_quantity","_config","_name","_ammo","_pile","_exchanged","_receiverQty","_qty","_parent","_type"];
/*
	Removes rounds from a magazine
	
	Author: Rocket
*/
if(!isServer) exitWith {};

_mag = _this select 0;
_name = displayName _mag;
_type = typeOf _mag;
_person = _this select 1;
_client = owner _person;
_parent = itemParent _mag;
_config = configFile >> "CfgMagazines" >> _type;
_quantity = 0;
_magdmg = 0;

//to transfer damage from ammo box to pile o rounds
if(_mag isKindOf "AmmunitionBoxItemBase")then{
	_magdmg = damage _mag;
};

//statusChat [format["parent: %1, item: %2",displayName _parent,_name],""];

//check disease
//[_person,_mag,"Direct"] call event_transferModifiers;	//mags not supported (yet)
/*
if (isClass (configFile >> "CfgWeapons" >> typeOf _parent)) exitWith
{
	[_person,format["Cannot strip %1 while attached to the %2",_name,displayName _parent],"colorStatusChannel"] call fnc_playerMessage;
	[_person,_parent,"Direct"] call event_transferModifiers;
};
*/
if (isClass _config) then
{
	//deal with magazine
	_quantity = MagazineAmmo _mag;	
	_ammo = getText (_config >> "ammoItems");
	if (getNumber (_config >> "destroyOnEmpty") == 1) then
	{
		_parent removeFromInventory _mag;
		deleteVehicle _mag;
	}
	else
	{
		_mag setMagazineAmmo 0;
	};
}
else
{
	//deal with object (such as ammo box)
	_config = configFile >> "CfgVehicles" >> _type;
	_ammo = configName ((_config >> "Resources") select 0);
	_quantity = getNumber (((_config >> "Resources") select 0) >> "value");
	deleteVehicle _mag;
};

if (_quantity <= 0) exitWith
{
	[_person,format["The %1 is empty",_name],"colorStatusChannel"] call fnc_playerMessage;
};

//get base data

//distribute to existing piles
if (!isNull _parent) then
{
	_magdmg call player_fnc_roundsDistribute;
};
//send feedback
if (isClass (configFile >> "CfgWeapons" >> typeOf _parent)) then 
{	
	[_person,format["I have emptied the rounds out of the %1",displayName _parent],"colorAction"] call fnc_playerMessage;
}
else
{
	[_person,format["I have emptied the rounds out of the %1",_name],"colorAction"] call fnc_playerMessage;
};
