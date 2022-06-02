private["_person","_parent","_sender","_mag","_config","_name","_max","_type","_senderQty","_receiverQty","_exchanged","_ammo","_parent"];
/*
	Load Magazine with rounds
	
	TODO: Don't allow magazine to be loaded while on weapon
	
	Author: Rocket
*/

if(!isServer) exitWith {};

_person = _this select 0;
_sender = _this select 1;
_mag = 	_this select 2;
_parent = itemParent _mag;

if (isClass (configFile >> "CfgWeapons" >> typeOf _parent)) exitWith
{
	[_person,format["Cannot load %1 while attached to the %2",displayName _mag,displayName _parent],"colorStatusChannel"] call fnc_playerMessage;
};

if (damage _mag >= 1) exitWith
{	
	[_person,"The magazine is too badly damaged",""] call fnc_playerMessage;
};
if (damage _sender >= 1) exitWith
{	
	[_person,"The ammunition is too badly damaged",""] call fnc_playerMessage;
};

_config = 	configFile >> "CfgMagazines" >> typeOf _mag;
_max = 		getNumber (_config >> "count");
_receiverQty = 	magazineAmmo _mag;
_type = typeOf _mag;
_ammo = getText (configFile >> "CfgMagazines" >> _type >> "ammoItem");

if (_ammo != typeOf _sender) exitWith
{
	[_person,format["The %1 does not fit in the %2",displayName _mag,displayName _sender],"colorStatusChannel"] call fnc_playerMessage;
};

if (_receiverQty == _max) exitWith
{
	//Magazine is already full
	[_person,format["The %1 is already full",displayName _mag],"colorStatusChannel"] call fnc_playerMessage;
};

_name = 	getText (_config >> "displayName");
_nameAmmo = displayName _sender;
_senderQty = 	quantity _sender;

//deal with boxed ammo (no quantity)
if (_senderQty == 0) then
{
	_senderQty = getNumber (configFile >> "CfgVehicles" >> typeOf _sender >> "Resources" >> _ammo >> "value");
	deleteVehicle _sender;
};

//process changes
_exchanged = ((_receiverQty + _senderQty) min _max) - _receiverQty;
_receiverQty = _receiverQty + _exchanged;
_senderQty = _senderQty - _exchanged;

//save results
if (_senderQty > 0) then
{
	if (isNull _sender) then
	{
		_quantity = _senderQty;
		call player_fnc_roundsDistribute;
	}
	else
	{
		_sender setQuantity _senderQty;
		[_person,"craft_rounds"] call event_saySound;
	};
}
else
{
	deleteVehicle _sender;
};
_mag setMagazineAmmo _receiverQty;

//send response
[_person,"craft_loadMag"] call event_saySound;
[_person,format["I have loaded the %1 with %2",_name,_nameAmmo],"colorAction"] call fnc_playerMessage;