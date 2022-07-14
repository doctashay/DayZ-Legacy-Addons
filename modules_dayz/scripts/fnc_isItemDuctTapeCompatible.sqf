/*
This function returns true when:
-The given item is sufficiently damaged but not ruined
-and the item is compatible with duct tape repairs
-and the duct tape is not ruined

Otherwise it returns false
*/

_tapeItem = _this select 0;
_damageditem = _this select 1;
_allowRepair = true;

if (damage _damageditem > ductTapeRepairDamage+0.001 && damage _damageditem < 1 && damage _tapeItem < 1) then
{
	//By default every item is included, except these kinds:
	_excludedKinds = [
		//Weapons
		"GrenadeBase", "grenade", "Consumable_Grenade", "cfgWeapons", "AttachmentBase", 
		//Melee weapons
		"MeleeItemBase",
		//Ammo
		"ChamberedRound",
		//Crafting
		"CraftingItemBase",
		//Tools
		"ToolBase", "Consumable_DuctTape", "Consumable_Stone", "Consumable_Firewood", "Consumable_Battery9V",
		//Food and drinks
		"FoodItemBase", "DrinksItemBase",
		//Medical
		"MedicalItemBase",
		//Consumable
		"Consumable_Chemlight_Base", "Consumable_Hook", "Consumable_Bait",
		//Horticulture
		"SeedItemBase", "Consumable_PlantMaterial"
	];
	
	//These kinds are exceptions to the previous array and are forcefully included:
	_includedKinds = [
		//Weapons
		"FlareSprayBomb", "WeaponLightBase",
		//Tools
		"Tool_Transmitter", "Tool_Flashlight",
		//Medical
		"Medical_BandageBase", "Medical_Epinephrine", "BloodBase", "Medical_Splint", "Medical_Thermometer", "Medical_Defibrillator",
		//Seeds pack
		"Cultivation_TomatoSeedsPack", "Cultivation_PepperSeedsPack", "Cultivation_PumpkinSeedsPack", "Cultivation_ZucchiniSeedsPack"
	];
	
	{
		scopeName "exclusions";
		if (_damageditem isKindOf _x) then {_allowRepair = false; breakOut "exclusions"};
	} forEach _excludedKinds;

	if !(_allowRepair) then
	{
		{
			scopeName "inclusions";
			if (_damageditem isKindOf _x) then {_allowRepair = true; breakOut "inclusions"};
		} forEach _includedKinds;
	};

	_allowRepair
}else{
	false
}
