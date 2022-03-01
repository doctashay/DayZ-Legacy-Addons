/*
DUCT TAPE REPAIR SCRIPT

Allows the user to repair some of its items with the duct tape to a certain degree. Check fnc_isItemDuctTapeCompatible for the list of compatible items.
Item's size and damage affect the required amount of tape
Duct tape's damage affect its efficiency
*/


//Parameters
_minTapeUsage = 0.10; //How much of the tape we need to repair [1,1] sized item with 100% efficiency (pristine tape)
_tapeMinEfficiency = 0.5; //Minimal efficiency for damaged (almost ruined) tape

//Input variables
_ductTape = _this select 0;
_tapedItem = _this select 1;
_user = _this select 2;

//Repair calculations
_tapedItemXYSize = getArray (configFile >> "CfgVehicles" >> typeOf _tapedItem >> "itemSize");
_repairRequired = damage _tapedItem - ductTapeRepairDamage;
_tapeRequired = (_tapedItemXYSize select 0) * (_tapedItemXYSize select 1) * _minTapeUsage * (_repairRequired / ductTapeRepairDamage) * (1 + damage _ductTape * _tapeMinEfficiency);

//Solving the issue with insufficient duct tape material
_repairCoeficient = 1;
if (Quantity _ductTape < _tapeRequired) then
{
	_repairCoeficient = Quantity _ductTape / _tapeRequired;
};

//Apply repairs
_tapedItem setDamage damage _tapedItem - _repairRequired*_repairCoeficient;
[_ductTape, -_tapeRequired] call fnc_addQuantity;

//Feedback to the user
if (damage _tapedItem <= ductTapeRepairDamage) then {
	[_user,"I've managed to reinforce the item with the tape quite well.","colorStatusChannel"] call fnc_playerMessage;
}else{
	[_user,"I've reinforced the item but it could still use more tape.","colorStatusChannel"] call fnc_playerMessage;
};

hintSilent format["
_tapedItemXYSize = %1 , %2\n
_tapeRequired = %3\n
_repairRequired = %4\n
_repairCoeficient = %5\n
_tapedItem damage = %6\n
_ductTape quantity = %7
", _tapedItemXYSize select 0, _tapedItemXYSize select 1, _tapeRequired, _repairRequired, _repairCoeficient, damage _tapedItem, quantity _ductTape];