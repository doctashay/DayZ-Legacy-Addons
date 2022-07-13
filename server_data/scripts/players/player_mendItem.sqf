private["_cfgType","_item","_kit","_itemType","_kitType","_damageItem","_damageKit"];
/*
	Clean/fix item with cleaning/fixing kit.
	
	Author: Peter Nespesny
*/
_cfgType = _this;
_item = _tool1;
_kit = _tool2;
_itemType = typeOf _item;
_kitType = typeOf _kit;

_repairItem = getNumber (configFile >> _cfgType >> _itemType >> "repairableWith");
_repairKit = getNumber (configFile >> "cfgVehicles" >> _kitType >> "repairKitType");

//hint format["repairItem: %1, repairKit: %2",_repairItem,_repairKit];

if (_repairItem != _repairKit) exitWith
{
	[_owner,format["%1 cannot be used to mend the %2",displayName _kit,displayName _item],'colorAction'] call fnc_playerMessage;
};

_damageItem = damage _item;
_damageKit = damage _kit;

if (_damageKit >= 1) exitWith
{
	[_owner,format["%1 is ruined and cannot be used to mend the %2",displayName _kit,displayName _item],'colorAction'] call fnc_playerMessage;
};

switch true do
{
	case (_damageItem >= 1):
	{
		[_owner,format["%1 is ruined and cannot be mended with %2",displayName _item,displayName _kit],'colorAction'] call fnc_playerMessage;
	};
	case (_damageItem > 0.3):
	{
		[_owner,format["I have mended %1.",displayName _item],'colorAction'] call fnc_playerMessage;
		_item setDamage 0.31;
		_kit setDamage (_damageKit + 0.1);
	};
	case (_damageItem <= 0.3):
	{
		[_owner,format["%1 is pristine and it doesn't need to be mended.",displayName _item],'colorAction'] call fnc_playerMessage;
	};
};