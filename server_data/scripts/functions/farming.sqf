// All global variables, constants and functions are defined in this script
// Local variables for each plant are handled in player_plantStages.sqf

/*=============================
		PLANTS SETTINGS
=============================*/

// Plant fruits [fresh, spoiled]
// The names of these arrays must be concatenated like this: "plant_name" + "_cropsTypes"
// TO DO: Revise these arrays due to duplicated entries.
plant_tomato_cropsTypes =		["fruit_tomato", "fruit_tomato"];
plant_pepper_cropsTypes =		["Fruit_GreenBellPepper", "Fruit_GreenBellPepper"];
plant_pumpkin_cropsTypes =		["Fruit_Pumpkin", "Fruit_Pumpkin"];
plant_Zucchini_cropsTypes =	["Fruit_Zucchini", "Fruit_Zucchini"];
plant_potato_cropsTypes =		["Fruit_Potato", "Fruit_Potato"];
plant_cannabis_cropsTypes =	["Fruit_Cannabis", "Fruit_Cannabis"];

// Plant healthy/infested textures and materials
// PEPPER
plant_pepper_infestationTextureFilename = 	"pepper_plant_insect_co.paa";
plant_pepper_infestationMaterialFileName = 	"";
plant_pepper_healthyTextureFilename = 		"pepper_plant_co.paa";
plant_pepper_healthyMaterialFileName = 		"pepper_plant.rvmat";

// TOMATO
plant_tomato_infestationTextureFilename = 	"tomato_plant_insect_co.paa";
plant_tomato_infestationMaterialFileName = 	"";
plant_tomato_healthyTextureFilename = 		"tomato_plant_co.paa";
plant_tomato_healthyMaterialFileName = 		"tomato_plant.rvmat";

// ZUCCHINI
plant_Zucchini_infestationTextureFilename = "zucchini_plant_insect_co.paa";
plant_Zucchini_infestationMaterialFileName =	"";
plant_Zucchini_healthyTextureFilename = 	"zucchini_plant_co.paa";
plant_Zucchini_healthyMaterialFileName = 	"zucchini_plant.rvmat";

// POTATO
plant_potato_infestationTextureFilename = 	"potato_plant_insect_co.paa";
plant_potato_infestationMaterialFileName = 	"potato_plant_insect.rvmat";
plant_potato_healthyTextureFilename = 		"potato_plant_co.paa";
plant_potato_healthyMaterialFileName = 		"potato_plant.rvmat";

// PUMPKIN
plant_pumpkin_infestationTextureFilename = 	"pumpkin_plant_insect_co.paa";
plant_pumpkin_infestationMaterialFileName = "";
plant_pumpkin_healthyTextureFilename = 		"pumpkin_plant_co.paa";
plant_pumpkin_healthyMaterialFileName = 	"pumpkin_plant.rvmat";

// CANNABIS
plant_cannabis_infestationTextureFilename = 	"cannabis_plant_insect_co.paa";
plant_cannabis_infestationMaterialFileName = 	"cannabis_plant_insect.rvmat";
plant_cannabis_healthyTextureFilename = 		"cannabis_plant_co.paa";
plant_cannabis_healthyMaterialFileName = 		"cannabis_plant.rvmat";

/*======================
		CONSTANTS		
======================*/

// PLANT PARAMETERS
PLANT_WATER_USAGE = 185; // How much water is needed to water a plant from a bottle. Value is in millilitres
DELETE_DRY_PLANT_TIMER = (60*10) + random (120); // For how long in seconds can an unwatered plant exist before it disappears

// SLOT STATES
SLOT_EMPTY		= 1;
SLOT_INPROGRESS	= 2;
SLOT_READY		= 3;
SLOT_FERTILIZED	= 4;
SLOT_PLANTED	 	= 5;

// Plant states
PLANT_IS_DRY 	= 0;
PLANT_IS_GROWING 	= 1;
PLANT_IS_MATURE 	= 2;
PLANT_IS_SPOILED 	= 3;

/*==========================
		FERTILIZERS		
==========================*/

fertilizersConfigs = 
[
	// values: 0-fertilizer item name, 1-texture ID, 2-added energy to slot, 3-Consumed quantity
	["consumable_gardenLime", 1, 0.5, 0.05],
	["consumable_plantMaterial", 2, 0.25, 0.35]
];


/*-----------------------------------
--------------FUNCTIONS--------------
-----------------------------------*/

/* 	
	Returns shortened string. Examples:
	_message1 = ["QWERTY", 3] call fnc_shortenString; 
	_message2 = ["QWERTY", 10] call fnc_shortenString;
	hint _message1; // prints 'QWE'
	hint _message2; // prints ''
*/
fnc_shortenString = {
	_string = _this select 0;
	_removeCharacters = _this select 1;
    _arr = toArray _string;
	_arrSize = count _arr;
	if (_arrSize < _removeCharacters) exitWith {""}; // Fail case for removing more letters than string length
    _arr resize (_arrSize - _removeCharacters);
    toString _arr;
};

// Converts numbers like 3 to "03". It always returns string.
fnc_convertNumber = {
	_returnString = str(_this);
	if (_this < 10) then {
		_returnString = format["0%1",_this];
	};
	_returnString;
};

// returns true or false if the given item (_this) can be used as a farming tool
fnc_isFarmingTool = {
	(_this isKindOf "Tool_Shovel" || _this isKindOf "FarmingHoe" || _this isKindOf "pickaxe")
};

fnc_isFertilizer = {
	_typeOfitem = _this;
	_returnValue = false;
	{
		if ( (_x select 0) == _typeOfitem ) then
		{
			_returnValue = true;
		}
	} forEach fertilizersConfigs;
	
	_returnValue;
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
	if (TypeOF _greenhouse == "land_misc_greenhouse") then {
		_slot set [5, 1 ]; // Reset fertility value
	} else {
		_slot set [5, _greenhouse getVariable "baseFertility" ]; // Reset fertility value
	};
	
	// Hide digged selection on this slot
	_greenhouse animate[ ( "slotDigged_" + ((_slotId+1) call fnc_convertNumber) ) , 1]; // 1 means hide!
	
	// update table
	_greenhouseConfig set [ _slotId, _slot ];
	_greenhouse setVariable ['config', _greenhouseConfig];
};

// Returns fertility coefficient for that type of surface. If the surface is not recognized, then default value is returned.
// Maybe to do: When a position is send as an argument, use surfaceTypeASL to get the surface type of that position.
fnc_getSurfaceFertility = {
	_surface = _this;
	_returnFertility = 0.8;
	switch (_surface) do
	{
		case ("hlina"): 	{ _returnFertility = 0.8	};
		case ("CRGrass1"): 	{ _returnFertility = 0.8	};
		case ("CRGrass2"): 	{ _returnFertility = 0.8	};
		case ("CRForest1"): { _returnFertility = 0.8	};
		case ("CRForest2"): { _returnFertility = 0.8	};
		case ("CRGrit1"): 	{ _returnFertility = 0.8	};
	};
	hint format["Surface: %1 \nValue: %2", _surface, _returnFertility];
	_returnFertility;
};

// Updates plant's visuals and some local variables
fnc_updatePlant = {
	_plant = _this select 0;
	_plantStage = _plant getVariable "currentStage";
	
	// SHOW / HIDE SELECTIONS
	if ( _plantStage > 0 ) then 
	{
		_currentPlantStage = _plantStage call fnc_convertNumber; 
		_previousPlantStage = (_plantStage-1) call fnc_convertNumber;
		
		// HIDING PREVIOUS PLANT STATE AND SHOWING THE CURRENT ONE
		_showSelection = "plantStage_" + _currentPlantStage; // Which selection needs to be showed
		_hideSelection = "plantStage_" + _previousPlantStage; // Which selections needs to be hidden
		_plant animate[_showSelection, 0]; // 0 means UNhide this selection!
		_plant animate[_hideSelection, 1]; // 1 means hide this selection!
		
		// HIDING PREVIOUS CROPS STATE AND SHOWING THE CURRENT ONE
		_showSelection = "plantStage_" + _currentPlantStage + "_crops"; // Which crops selection needs to be showed
		_hideSelection = "plantStage_" + _previousPlantStage + "_crops"; // Which crops selections needs to be hidden
		_plant animate[_showSelection, 0]; // 0 means UNhide this selection!
		_plant animate[_hideSelection, 1]; // 1 means hide this selection!
		
		// HIDING PREVIOUS SHADOW STATE AND SHOWING THE CURRENT ONE
		_showSelection = "plantStage_" + _currentPlantStage + "_shadow"; // Which selection needs to be showed
		_hideSelection = "plantStage_" + _previousPlantStage + "_shadow"; // Which selections needs to be hidden
		_plant animate[_showSelection, 0]; // 0 means UNhide this selection!
		_plant animate[_hideSelection, 1]; // 1 means hide this selection!
	};
	// SHOWING CORRECT PILE
	//_showSelection = "pile_01"; // TO DO: Show correct fertilized pile, not just the default one!
	//_plant animate[_showSelection, 0]; // 0 means UNhide this selection!
	
	// UPDATING INVENTORY ITEMS
	_harvestedMaterialQuantity = 0.10*_plantStage;
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
		_fruits = [_cropsType, _cropsCount, _user] call fnc_addItemCount;
		{
			[_x, "Rotten"] call fnc_changeFoodStage;
		} forEach _fruits;
	}else{
		_cropsType = (_plant call fnc_getCropsTypes) select 0; // select fresh crops
		_fruits = [_cropsType, _cropsCount, _user] call fnc_addItemCount;
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
	_user = _this select 0;
	_plant = _this select 1;
	_bottle = itemInHands _user;
	
	// Fail cases
	if ( quantity _bottle < PLANT_WATER_USAGE  and  quantity _bottle > 0 ) exitWith {
		[_user, format["There is not enough liquid in the %1 for it to have any effect.", toLower displayName _bottle], "colorImportant"] call fnc_playerMessage;};
	if ( quantity _bottle == 0 ) exitWith {
		[_user, format["The %1 is empty.", toLower displayName _bottle], "colorImportant"] call fnc_playerMessage;};
	if ( damage _bottle == 1 ) exitWith {
		[_user, format["The %1 is ruined.", toLower displayName _bottle], "colorImportant"] call fnc_playerMessage;};
	// Liquid type check. Disabled due to DAYZ-12143
	/*if !( _bottle getVariable "LiquidType" == "Water" ) exitWith {
		[_user, format["The %1 is not filled with water.", displayName _bottle], "colorImportant"] call fnc_playerMessage;};*/
	if !( _bottle getVariable "LiquidType" == "Water" ) exitWith 
	{
		// Reset plant's slot
		_objSoil = _plant getVariable "soil";
		_plantSlot = _plant getVariable "plantSlot";
		[_objSoil, _plantSlot] call fnc_resetSlotState;
		deleteVehicle _plant;
		[_user, format["The %1 contained some liquid which poisoned the plant.", toLower displayName _bottle], "colorImportant"] call fnc_playerMessage;
		
		// Bottle quantity control
		_bottle setQuantity (quantity _bottle - PLANT_WATER_USAGE);
		if ( quantity _bottle < 0 ) then
		{
			_bottle setQuantity 0;
		};
	};
	
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

// Gives the user 1 worm. 
// Returned variable is objNull or the given item.
fnc_giveWorms = {
	_user = _this select 0;
	_getItemOds = _this select 1;
	_item = objNull;
	if (random 1 < _getItemOds) then {
		_item = ["Food_Worm", _user] call player_addInventory;
		_item setQuantity 1;
	};
	_item;
};

// returns position of a slot in a greenhouse/garden plot
fnc_getSlotPosition = {
	_soilObj = _this select 0;
	_slotNum = _this select 1;
	_alignToTerrain = _this select 2;
	
	if (_alignToTerrain) then {
		_slotPosInModel = _soilObj selectionPosition ("slot_" + ((_slotNum+1) call fnc_convertNumber));
		_slotPosInWorld = _soilObj modelToWorld _slotPosInModel;
		_returnSlotPos = [_slotPosInWorld select 0, _slotPosInWorld select 1, _slotPosInModel select 2];
		
		_returnSlotPos;
	} else {
		_slotPosInModel = _soilObj selectionPosition ("slot_" + ((_slotNum+1) call fnc_convertNumber));
		_slotPosInWorld = _soilObj modelToWorld _slotPosInModel;
		_returnSlotPos = _slotPosInWorld;
		
		_returnSlotPos;
	};
};

// Returns true if the given item is a suitable pesticide spray. Otherwise it returns false.
fnc_isGardeningSpray = {
	_plant = _this select 0;
	_user = _this select 1;
	_item = itemInHands _user;
	
	(// main condition
		typeOf _item == "Medical_DisinfectantSpray" 	and // TO DO: Use proper pesticide instead when some is created!
		_plant getVariable 'state' == PLANT_IS_GROWING 	and
		(_user getVariable "isUsingSomething" == 0)
	)
};

// Stops the infestation on the given plant
fnc_stopInfestation = {
	_user = _this select 0;
	_plant = _this select 1;
	_item = itemInHands _user;
	
	if (damage _item == 1) exitWith	{[_user, "The spray is ruined.", "colorImportant"] call fnc_playerMessage};
	if (quantity _item == 0) exitWith	{[_user, "The spray is empty.", "colorImportant"] call fnc_playerMessage};
	
	[_item, -0.03] call fnc_addQuantity;
	_plant setVariable ["isInfested", false];
	_plant setVariable ["infestationChance", 0];
	_infestationScript = _plant getVariable "infestationScript";
	terminate _infestationScript;
	[_plant, false] call fnc_enableInfestation;
	[_plant] call fnc_updatePlant;
	[_user, "I've sprayed the plant.", "colorAction"] call fnc_playerMessage;
};

// Changes visual on the plant to make it look infested
// [_objPlant, _isInfested] call fnc_enableInfestation;
fnc_enableInfestation = {
	_objPlant = _this select 0;
	_startInfestation = _this select 1;
	_plantType = typeOf _objPlant;
	_newTexture = [];
	_newMaterial = "";
	
	_objPlant setVariable ["isInfested", _startInfestation];
	
	if (_startInfestation) then
	{
		0 call compile format["_newTexture = %1_infestationTextureFilename; ", _plantType];
		if !(_newTexture == "") then
		{
			_objPlant setObjectTexture [0, "dz\plants2\farming\data\" + _newTexture];
		};
		
		0 call compile format["_newMaterial = %1_infestationMaterialFileName; ", _plantType];
		if !(_newMaterial == "") then {
			_objPlant setObjectMaterial [0, "dz\plants2\farming\data\" + _newMaterial];
		};
	
	}else{
	
		0 call compile format["_newTexture = %1_healthyTextureFilename; ", _plantType];
		if !(_newTexture == "") then
		{
			_objPlant setObjectTexture [0, "dz\plants2\farming\data\" + _x];
		};
		
		0 call compile format["_newMaterial = %1_healthyMaterialFileName; ", _plantType];
		if !(_newMaterial == "") then {
			_objPlant setObjectMaterial [0, "dz\plants2\farming\data\" + _newMaterial];
		};
	};
};

// Dilutes Disinfectant Spray with water and creates an anti-pests spray
fnc_diluteDisinfectantSpray = {
	_user = _this select 0;
	_spray = _this select 1;
	_bottle = _this select 2;
	_disinfectantToWaterRatio = 0.1; // How much disinfectant we are going to mix with 1 liter of water
	
	// Conditions
	if (damage _spray == 1 ) exitWith {
		[_user, format["The %1 is ruined.", displayName _spray], "colorImportant"] call fnc_playerMessage;
	};
	if (damage _bottle == 1) exitWith {
		[_user, format["The %1 is ruined.", displayName _bottle], "colorImportant"] call fnc_playerMessage;
	};
	if (quantity _bottle == 0) exitWith {
		[_user, format["The %1 is empty.", displayName _bottle], "colorImportant"] call fnc_playerMessage;
	};
	if (quantity _spray == 0) exitWith {
		[_user, format["The %1 is empty.", displayName _spray], "colorImportant"] call fnc_playerMessage;
	};
	if !(_bottle getVariable "LiquidType" == "water") exitWith {
		[_user, format["The %1 must be filled with water.", displayName _bottle], "colorImportant"]	call fnc_playerMessage;
	};
	
	// Everything is checked, proceed with calculation of liquid distribution
	// Get values of containers
	_disinfQuantityInML = quantity _spray * 1000;
	_waterQuantityInML = quantity _bottle;
	if (_waterQuantityInML > maxQuantity _spray * 1000) then{
		_waterQuantityInML = maxQuantity _spray * 1000; // Limit the amount of water we really need
	};
	
	// Get requirements
	_disinfRequiredInML = _waterQuantityInML * _disinfectantToWaterRatio; // How much disinfectant liquid we need
	_finalCoefficient = 1;
	if (_disinfRequiredInML > _disinfQuantityInML) then {
		_finalCoefficient = _disinfQuantityInML / _disinfRequiredInML; // Not enough disinfectant, so lower the result
	};
	
	// Calculate diluted disinfectant quantity
	_dilutedQuantity = (_waterQuantityInML + _disinfRequiredInML) * _finalCoefficient;
	_dilutedQuantity = _dilutedQuantity * 0.001; // This converts the result value to %'s. This line will have to be removed when the garden spray will be a normal liquid container.
	
	// Crafting result
	deleteVehicle _spray;
	_antiPestsSpray = ["Cultivation_AntiPestsSpray", _user] call player_addInventory;
	_antiPestsSpray setQuantity _dilutedQuantity;
	_bottle setQuantity (quantity _bottle - (_waterQuantityInML * (_finalCoefficient)));
	
	if (_dilutedQuantity > maxQuantity _antiPestsSpray) then {
		_excessiveLiquid = _dilutedQuantity - (maxQuantity _antiPestsSpray);
		_antiPestsSpray setQuantity maxQuantity _antiPestsSpray;
		_bottle setQuantity (quantity _bottle + _excessiveLiquid);
	};
	
	[_user, "I have diluted the disinfectant with water.", "colorAction"]	call fnc_playerMessage;
};

// Deletes the given seed pack and gives the user a pile of seeds instead
// The type of seeds are written in the config of each seed pack item
fnc_emptySeedsPack = {
	// Main definitions
	_user = _this select 0;
	_package = _this select 1;
	_packageDamage = damage _package;
	_config = configfile >> "CfgVehicles" >> typeOf _package;
	_seedsType = getText (_config >> "Resources" >> "ContainsSeedsType");
	_gainedSeedsMaxQuantity = getNumber (_config >> "Resources" >> "ContainsSeedsQuantity");
	deleteVehicle _package;
	
	// Adjustable definitions
	_packageDamageTolerance = 0.5; // Package which is damaged more than this value will contain less seeds.
	
	// Ruined package case
	if (_packageDamage == 1) exitWith
	{
		[_user, "I've opened the ruined package, but it was already empty.", "colorImportant"] call fnc_playerMessage;
	};
	
	// Pile of seeds item creation and calculating of its quantity
	_gainedSeeds = [_seedsType, _user] call player_addInventory;
	_seedsQuantity = _gainedSeedsMaxQuantity;
	
	// Damaged packages give less seeds
	if ( _packageDamage >= _packageDamageTolerance ) then 
	{
		_seedsQuantity = ( round ( (_gainedSeedsMaxQuantity) * ( 1-((_packageDamage-_packageDamageTolerance) / _packageDamageTolerance )) ) );
	};
	
	// Make sure the item does not have quantity of 0
	if (_seedsQuantity <= 1) then { _seedsQuantity = 1 };
	
	_gainedSeeds setQuantity _seedsQuantity;
	
	// Show status message
	_gainedSeedsName = toLower displayName _gainedSeeds;
	_message = "";
	switch (true) do 
	{
		case (_seedsQuantity == _gainedSeedsMaxQuantity): 
		{
			_message = format["I've emptied the package. It contained %1 %2.",_seedsQuantity, _gainedSeedsName];
		};
		case (_seedsQuantity < _gainedSeedsMaxQuantity/3  and  _seedsQuantity > 1): 
		{
			_message = format["I've emptied the ruptured package and it contained only %1 %2.",_seedsQuantity, _gainedSeedsName];
		};
		case (_seedsQuantity == 1): 
		{
			// Since the player gained only 1 seed, it's needed to remove the plural sense from the message.
			// This is a temporal solution because it works only for English language!
			_message = format["I've emptied the ruptured package and it contained only 1 %1", _gainedSeedsName];
			_message = [_message, 1] call fnc_shortenString;
			_message = _message + "." // Adds period at the end of the sentence
		};
		default
		{
			_message = format["I've opened the ruptured package and it contained %1 %2.",_seedsQuantity, _gainedSeedsName];
		};
	};
	
	[_user, _message, "colorAction"] call fnc_playerMessage;
};
