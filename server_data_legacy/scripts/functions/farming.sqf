// All global variables, constants and functions are defined in this script
// Local variables for each plant are handled in player_plantStages.sqf

/*=============================
		PLANTS SETTINGS
=============================*/

// Plant fruits [fresh, spoiled]
// Variables are concatenated like this: *plant_name*_cropsTypes
plant_tomato_cropsTypes = ["fruit_tomatoFresh", "fruit_tomatoRotten"];
plant_pepper_cropsTypes = ["Fruit_GreenBellPepperFresh", "Fruit_GreenBellPepperRotten"];
plant_pumpkin_cropsTypes = ["Fruit_PumpkinFresh", "Fruit_PumpkinRotten"];
//plant_Zucchini_cropsTypes = ["Fruit_ZucchiniFresh", "Fruit_ZucchiniRotten"];
//plant_potato_cropsTypes = ["Fruit_PotatoFresh", "Fruit_PotatoRotten"];

/*===========================
		SOIL SETTINGS
===========================*/

SLOTS_GREENHOUSE_ENERGY = 1; // Base energy value
//SLOTS_TILE_hlina = [0,0.5]; // To do: for future digged tiles. This parameter name will be concatenated like this: "SLOTS_TILE_" + "surface_name"

/*======================
		CONSTANTS		
======================*/

// PLANT PARAMETERS
PLANT_WATER_USAGE = 2.0; // Value is in deciliters
DELETE_DRY_PLANT_TIMER = (60*10) + random (120); // For how long in seconds can an unwatered plant exist before it disappears

// SLOT STATES
SLOT_EMPTY		 = 1;
SLOT_INPROGRESS	 = 2;
SLOT_READY		 = 3;
SLOT_FERTILIZED  = 4;
SLOT_PLANTED	 = 5;

// Plant states
PLANT_IS_DRY = 		0;
PLANT_IS_GROWING = 	1;
PLANT_IS_MATURE = 	2;
PLANT_IS_SPOILED = 	3;


/*-----------------------------------
--------------FUNCTIONS--------------
-----------------------------------*/

// returns true or false if the given item (_this) can be used as a farming tool
fnc_isFarmingTool = {
	(_this isKindOf "Tool_Shovel" || _this isKindOf "FarmingHoe" || _this isKindOf "pickaxe")
};

// Frees the slot for another plant
fnc_resetSlotState =
{
	// Define variables
	_greenhouse = _this select 0;
	_slotId = _this select 1;
	_greenhouseConfig = (_greenhouse getVariable ['config',objNull]);
	_slot = _greenhouseConfig select _slotId;
	
	// set slot state to EMPTY state
	_slot set [0, SLOT_EMPTY ]; // Free the slot for another plant
	_slot set [5, SLOTS_GREENHOUSE_ENERGY ]; // Reset water and energy level
	
	// update table
	_greenhouseConfig set [ _slotId, _slot ];
	_greenhouse setVariable ['config', _greenhouseConfig];
};

// Updates plant's visuals and some local variables
fnc_updatePlant = {
	_plant = _this select 0;
	_plantStage = _plant getVariable "currentStage";
	
	// SHOW / HIDE SELECTIONS
	if ( _plantStage > 0 ) then 
	{
		// TO DO: Function for converting "1" to "01"
		// HIDING PREVIOUS PLANT STATE AND SHOWING THE CURRENT ONE
		_showSelection = format ["plantStage_0%1", _plantStage]; // Which selection needs to be showed
		_hideSelection = format ["plantStage_0%1", _plantStage-1]; // Which selections needs to be hidden
		_plant animate[_showSelection, 0]; // 0 means UNhide this selection!
		_plant animate[_hideSelection, 1]; // 1 means hide this selection!
		
		// HIDING PREVIOUS CROPS STATE AND SHOWING THE CURRENT ONE
		_showSelection = format ["plantStage_0%1_crops", _plantStage]; // Which crops selection needs to be showed
		_hideSelection = format ["plantStage_0%1_crops", _plantStage-1]; // Which crops selections needs to be hidden
		_plant animate[_showSelection, 0]; // 0 means UNhide this selection!
		_plant animate[_hideSelection, 1]; // 1 means hide this selection!
		
		// HIDING PREVIOUS SHADOW STATE AND SHOWING THE CURRENT ONE
		_showSelection = format ["plantStage_0%1_shadow", _plantStage]; // Which selection needs to be showed
		_hideSelection = format ["plantStage_0%1_shadow", _plantStage-1]; // Which selections needs to be hidden
		_plant animate[_showSelection, 0]; // 0 means UNhide this selection!
		_plant animate[_hideSelection, 1]; // 1 means hide this selection!
	};
	// SHOWING CORRECT PILE
	//_showSelection = "pile_01"; // TO DO: Show correct fertilized pile, not just the default one!
	//_plant animate[_showSelection, 0]; // 0 means UNhide this selection!
	
	// UPDATING INVENTORY ITEMS
	_harvestedMaterialQuantity = 0.15*_plantStage;
	_plant setVariable ["harvestedMaterialQuantity", _harvestedMaterialQuantity];
};

// Adds plant material to the user's inventory and deletes the plant
fnc_harvestPlant = {
	_user = _this select 0;
	_plant = _this select 1;
	_materialQuantity = _plant getVariable "harvestedMaterialQuantity";
	
	// Plant material
	if ( _materialQuantity > 0 ) then
	{
		_item = ["Consumable_PlantMaterial", _user] call player_addInventory;
		_item setQuantity _materialQuantity;
	};
	
	// Reset plant's slot
	_objSoil = _plant getVariable "soil";
	_plantSlot = _plant getVariable "plantSlot";
	[_objSoil, _plantSlot] call fnc_resetSlotState;
	
	deleteVehicle _plant;
};

// Adds fresh/spoiled crops to the user's inventory + calls fnc_harvestPlant
fnc_harvestCropsAndPlant = {
	_user = _this select 0;
	_plant = _this select 1;
	_cropsType = "";
	_cropsCount = _plant getVariable "cropsCount";
	
	// Crops
	if (_plant getVariable "state" == PLANT_IS_SPOILED) then 
	{
		_cropsType = (_plant call fnc_getCropsTypes) select 1; // select rotten crops
		_cropsCount = _cropsCount * 0.5;
	}else{
		_cropsType = (_plant call fnc_getCropsTypes) select 0; // select fresh crops
	};
	
	[_cropsType, _cropsCount, _user] call fnc_addItemCount;
	[_user, _plant] call fnc_harvestPlant;
};

// Returns fresh and spoiled crops types in an array like this: ["fresh_crops", "rotten_crops"]
// Example: _crops = _objPlant call fnc_getCropsTypes;
fnc_getCropsTypes = {
	_plantType = typeOf (_this);
	_cropsTypes = objNull;
	_spoiledCrops = objNull;
	
	call compile format["_cropsTypes = %1_cropsTypes", _plantType];
	_cropsTypes;
};

// handles watering of a selected plant
fnc_waterPlant = {
	_plant = _this select 0;
	_user = _this select 1;
	_bottle = itemInHands _user;
	
	// Fail cases
	if ( quantity _bottle < PLANT_WATER_USAGE  and  quantity _bottle > 0 ) exitWith {
		[_user, "There is not enough water in this bottle for it to have any effect.", "colorAction"] call fnc_playerMessage;};
	if ( quantity _bottle == 0 ) exitWith {
		[_user, "The bottle is empty.", "colorAction"] call fnc_playerMessage;};
	if ( damage _bottle == 1 ) exitWith {
		[_user, "The bottle is ruined.", "colorAction"] call fnc_playerMessage;};
	
	// Water the plant now
	_plant setVariable["state", PLANT_IS_GROWING]; // Allows the growing process
	
	// Bottle quantity control
	_bottle setQuantity (quantity _bottle - PLANT_WATER_USAGE);
	if ( quantity _bottle < 0 ) then 
	{
		_bottle setQuantity 0; 
	};
	
	[_user, "I've watered the plant.", "colorAction"] call fnc_playerMessage;
};