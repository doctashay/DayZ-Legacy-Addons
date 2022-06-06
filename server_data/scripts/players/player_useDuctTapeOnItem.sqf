/*
DUCT TAPE REPAIR SCRIPT

Allows the user to repair some of its items with the duct tape to a certain degree. Check fnc_isItemDuctTapeCompatible for the list of compatible items.
Item's size and damage affect the required amount of tape
Duct tape's damage affect its efficiency
*/


//Parameters
_minTapeUsage = 0.10; //How much of the tape we need to repair "badly damaged", 1x1 sized item with pristine tape
_tapeMinEfficiency = 0.5; //Minimal efficiency for "badly damaged" tape

//Input variables
_ductTape = _this select 0;
_tapedItem = _this select 1;
_user = _this select 2;

//Repair calculations
_tapedItemXYSize = getArray (configFile >> "CfgVehicles" >> typeOf _tapedItem >> "itemSize");
_repairRequired = damage _tapedItem - ductTapeRepairDamage;
_tapeRequired = (_tapedItemXYSize select 0) * (_tapedItemXYSize select 1) * _minTapeUsage * (_repairRequired / ductTapeRepairDamage) * (1 + damage _ductTape * _tapeMinEfficiency);

//Solving the issue with insufficient duct tape material
_repairCoefficient = 1;
if (Quantity _ductTape < _tapeRequired) then
{
	_repairCoefficient = Quantity _ductTape / _tapeRequired;
};

//Apply repairs
_repairApplied = _repairRequired*_repairCoefficient;
_tapedItem setDamage damage _tapedItem - _repairApplied;
_remainingTape = [_ductTape, -_tapeRequired] call fnc_addQuantity;

//Feedback to the user
_itemIsFullyRepaired = (damage _tapedItem <= ductTapeRepairDamage);
_itemIsNOTFullyRepaired = !(damage _tapedItem <= ductTapeRepairDamage);
switch (true) do 
	{
		// Cases for when the item is effectively repaired.
		case (_itemIsFullyRepaired and _remainingTape > 0):
		{
			[_user,format["I've restored the item's condition as much as I could while using %1%% of the duct tape.", ceil(_tapeRequired*100-0.5)],"colorStatusChannel"] call fnc_playerMessage;
		};
		case (_itemIsFullyRepaired and _remainingTape <= 0):
		{
			[_user,"I've restored the item's condition as much as I could while using all of the duct tape.","colorStatusChannel"] call fnc_playerMessage;
		};
		
		// Cases for when the item is partially repaired
		case (_itemIsNOTFullyRepaired and _repairApplied <= 0.075):
		{
			[_user,"I've slightly reinforced the item while using all of the duct tape.","colorStatusChannel"] call fnc_playerMessage;
		};
		case (_itemIsNOTFullyRepaired and _repairApplied > 0.075 and _repairApplied <= 0.2):
		{
			[_user,"I've reinforced the item a bit while using all of the duct tape.","colorStatusChannel"] call fnc_playerMessage;
		};
		case (_itemIsNOTFullyRepaired and _repairApplied > 0.2 and _repairApplied <= 0.35):
		{
			[_user,"I've moderately reinforced the item while using all of the duct tape.","colorStatusChannel"] call fnc_playerMessage;
		};
		case (_itemIsNOTFullyRepaired and _repairApplied > 0.35 and _repairApplied <= 0.5):
		{
			[_user,"I've reinforced the item quite well while using all of the duct tape.","colorStatusChannel"] call fnc_playerMessage;
		};
	};
	
	
/*hintSilent format["
_tapedItemXYSize = %1 , %2\n
_tapeRequired = %3\n
_repairRequired = %4\n
_repairCoefficient = %5\n
_tapedItem damage = %6\n
_ductTape quantity = %7
", _tapedItemXYSize select 0, _tapedItemXYSize select 1, _tapeRequired, _repairRequired, _repairCoefficient, damage _tapedItem, quantity _ductTape];*/
