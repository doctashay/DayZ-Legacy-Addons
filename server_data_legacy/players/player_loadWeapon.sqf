private["_person","_parent","_sender","_mag","_config","_name","_max","_type","_senderQty","_receiverQty","_exchanged","_ammo","_parent"];
/*
	Load Weapon with rounds
	
	TODO: Don't allow magazine to be loaded while on weapon
	
	Author: Rocket
*/

_type = _this;

if(!isServer) exitWith {};

if (!isNull (_tool1 itemInSlot "magazine")) exitWith {
	[_owner,format["The %1 is already full",displayName _tool1],"colorStatusChannel"] call fnc_playerMessage;
};

//get magazine type
_mags = getArray (configFile >> "CfgWeapons" >> typeOf _tool1 >> "magazines");
if (count _mags == 0) exitWith {hint "mags"};
//_cfgMag = 	configFile >> "CfgMagazines" >> (_mags select 0);
_cfgMag = 	configFile >> "CfgMagazines" >> _type;
if (!isClass _cfgMag) exitWith {hint "notClass"};

//create mag
_mag = _tool1 createInInventory (configName _cfgMag);
if (isNull _mag) exitWith {hint "nothing"};

//set ammo
_v1 = quantity _tool2;
_v2 = (magazineAmmo _mag) min _v1;
_v1 = _v1 - _v2;
_mag setMagazineAmmo _v2;

_str = displayName _tool2;
if (_v1 > 0) then
{
	_tool2 setVariable ["quantity",_v1];
}
else
{
	deleteVehicle _tool2;
};
[_owner,"craft_loadMag"] call event_saySound;
[_owner,format["You have loaded the %1 with %2",displayName _tool1,_str],"colorAction"] call fnc_playerMessage;
