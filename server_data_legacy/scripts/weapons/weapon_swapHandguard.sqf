private["_person","_tool1","_tool2","_isDirect","_source","_parent","_slot","_hasFlashlight","_r"];
_person = _this select 0;
_tool1 = _this select 1;
_tool2 = _this select 2;
_isDirect = _this select 3;

_source = itemParent _tool1;	//origin parent
_parent = itemParent _tool2;	//delivery parent

if (!_isDirect) then
{
	_parent = _tool2;
	_slot = 	getText (configFile >> "CfgVehicles" >> typeOf _tool1 >> "inventorySlot");
	_tool2 = _parent itemInSlot _slot;
};

//check attachment conditions
_hasFlashlight = !isNull(_parent itemInSlot 'weaponFlashlight');
if (_hasFlashlight) exitWith
{
	//cant attach
	[_person,format["You must remove attachments to the %1 first",displayName _tool2],"colorAction"] call fnc_playerMessage;
};

// using NoCheck variant, because you have condition set to 'false' on the handle.
// normal swap would not be performed because of this.
//_tool1 swapItemsNoCheck _tool2;

/*
//move old one to old position	
if (!isNull _source) then
{
	_r = _person moveToInventory _tool2;
	if (!_r) then
	{
		_r = moveToGround _tool2;
	};
}
else
{
	_r = moveToGround _tool2;
};

//try move new one on
_r = _parent moveToInventory _tool1;	
if (!_r) exitWith
{
	//failed
	[_person,format["Failed to attach the %1",displayName _tool2],"colorImportant"] call fnc_playerMessage;
	_r = _parent moveToInventory _tool2;
};
*/

