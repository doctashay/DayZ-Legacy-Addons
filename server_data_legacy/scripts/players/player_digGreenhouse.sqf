/*
This script handles players' interaction with a greenhouse. Digging, fertilizing and planting is handled here. Plant growth is handled in player_plantStages script.
*/

private["_greenhouse","_person","_playAnim","_animationLenght","_digToolsConfig","_greenhouseState","_toolParameters", "_isPlayerBusy", "_slotEnergy", "_greenhouseConfig"];

// Parameters
_greenhouse		= _this select 0;
_inHandObject	= _this select 1;
_person			= _this select 2;
_passedSlot		= _this select 3;
_isPlayerBusy 	= (_person getVariable ["isUsingSomething",0] == 1);

if (damage _inHandObject == 1) exitWith
{
	[_person, "The tool is ruined.", "colorImportant"] call fnc_playerMessage;
};

// SLOT VALUES
_slotEnergy = 0;
_greenhouseConfig = [];
_groundType = typeof _greenhouse;
_useRandomRotation = false;
_useTerrainHeight = false;

switch (_groundType) do
{
	case("Land_Misc_Greenhouse"): {
		_useRandomRotation = true;
		_useTerrainHeight = false;
		_slotEnergy = SLOTS_GREENHOUSE_ENERGY; // [water, nutrients] - water is not used properly yet
		_greenhouseConfig = 
		[
			//	[0-state, 1-digging progress in %, 2-[slot offset position], 3-seed type, 4-pile, 5-slot nutrients]
		
			// Back row
			[SLOT_EMPTY, 0, [0.75,	1.5,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [0.0,	1.52,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [-0.7,	1.5,	0.20], "", objNull, _slotEnergy],
			// Left side
			[SLOT_EMPTY, 0, [0.77,	0.9,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [0.77,	0.1,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [0.77,	-0.6,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [0.77,	-1.4,	0.20], "", objNull, _slotEnergy],
			// Right side
			[SLOT_EMPTY, 0, [-0.77,	0.9,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [-0.77,	0.1,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [-0.77,	-0.6,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [-0.77,	-1.4,	0.20], "", objNull, _slotEnergy]
		];
	};
	
	case("DiggedTile"): {
		_useRandomRotation = false;
		_useTerrainHeight = true;
		_slotEnergy = SLOTS_GREENHOUSE_ENERGY; // [water, nutrients] - water is not used properly yet
		_greenhouseConfig = 
		[
			//	[0-state, 1-digging progress in %, 2-[slot offset position], 3-seed type, 4-pile, 5-slot nutrients]
			// East column
			[SLOT_EMPTY, 0, [-1.2,	1.2,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [0,		1.25,	0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [1.3,	1.3,	0.23], "", objNull, _slotEnergy],
			// Middle column
			[SLOT_EMPTY, 0, [-1.3,	0,		0.20], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [0,		0,		0.22], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [1.1,	0,		0.23], "", objNull, _slotEnergy],
			// West column
			[SLOT_EMPTY, 0, [-1.2,	-1.2,	0.22], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [0,		-1.25,	0.24], "", objNull, _slotEnergy],
			[SLOT_EMPTY, 0, [1.1,	-1.1,	0.20], "", objNull, _slotEnergy]
		];
	};
};

_digToolsConfig = 
[
	// values: 0-tool id name, 1-toolEffectivity, 2-toolAnimation, 3-animationLength
	["Tool_Shovel",1.0, "digShovel", 12], //  "GestureMeleeFarmHoe", 0.05
	["FarmingHoe",1.0, "digHoe", 8],
	["Pickaxe",1.0, "digHoe", 8]
];

_seedsConfig = 
[
	// values: 0-seed id name, (can have more parameters)
	["Cultivation_TomatoSeedsPack"],
	["Cultivation_TomatoSeeds"],
	["Cultivation_PepperSeedsPack"],
	["Cultivation_PepperSeeds"],
	["Cultivation_PumpkinSeedsPack"],
	["Cultivation_PumpkinSeeds"]
];

_FertilizersConfig = 
[
	// values: 0-fertilizer id name, 1-Pile Name, 2-added energy to slots, 3-Consumed quantity
	["consumable_gardenLime", "FertilizedSoil", 0.5, 0.05]
	//["consumable_plantMaterial", "FertilizedSoil", 1.0, 0.5]
];

/*-----------------------------------
--------------FUNCTIONS--------------
-----------------------------------*/


// helper function: get parameters from table based on key
_fnc_getValue =
{
	private ["_table","_key","_ret","_i","_currentKey"];
	_table = _this select 0;  //source table
	_key = _this select 1;  //key to find
	_ret = []; //to be filled with return array
	
	for "_i" from 0 to (count _table - 1 ) do 
	{
		//[_person,format["variable i=%1",_i]] call fnc_playerMessage;
		_currentKey = (_table select _i)select 0;
		if (_currentKey == _key) exitWith
		{
			_ret = (_table select _i);
		};
	};
	_ret;
};

// helper function: check if element is defined in table based on key
_fnc_isDefinedInTable =
{
	private ["_table","_key","_ret","_i","_currentKey"];
	_table = _this select 0;  //source table
	_key = _this select 1;  //key to find
	_ret = false;
	
	for "_i" from 0 to (count _table -1) do 
	{
		_currentKey = (_table select _i)select 0;
		if (_currentKey == _key) exitWith
		{
			_ret = true;
		};
	};
	_ret;
};

// return SLOT_EMPTY or SLOT_INPROGRESS slot if it is available
_fnc_getFreeSlotId =
{
	//[_person, "_fnc_getFreeSlotId","colorAction"] call fnc_playerMessage;
	//private ["_slot","_slotState","_i","ret"];
	_ret = -1; //to be filled with return array
	_table = (_greenhouse getVariable ['config',objNull]);
	for "_i" from 0 to (count _table - 1 ) step 1 do 
	{
		_slot = _table select _i;
		_slotState = _slot select 0;
		//[_person,format["iterate slot %1 %2.",_i,_slotState],"colorAction"] call fnc_playerMessage;
		
		if ( _slotState == SLOT_INPROGRESS || _slotState == SLOT_EMPTY) exitWith 
		{	
			_ret = _i;
			//[_person,format["Slot %1 selected.",(_slot select 0)],"colorAction"] call fnc_playerMessage;
		};
	};
	_ret;
};

// return SLOT_READY slot id
_fnc_getSlotReadyId =
{
	_ret = -1;
	_table = (_greenhouse getVariable ['config',objNull]);
	for "_i" from 0 to (count _table - 1 ) do 
	{
		_slot = _table select _i;
		_slotState = _slot select 0;
		if ( _slotState == SLOT_READY ) exitWith 
		{	
			_ret = _i;
			//[_person,format["Ready Slot %1 selected.",(_slot select 0)],"colorAction"] call fnc_playerMessage;
		};
	};
	_ret;
};

// returns ID of some fertilized slot. If it cannot find any, it returns ID of some ready slot instead
_fnc_getSlotFertilizedOrReadyId =
{
	_ret = -1;
	_table = (_greenhouse getVariable ['config',objNull]);
	for "_i" from 0 to (count _table - 1 ) do 
	{
		_slot = _table select _i;
		_slotState = _slot select 0;
		if ( _slotState == SLOT_FERTILIZED ) exitWith 
		{	
			_ret = _i;
		};
	};
	if (_ret == -1) then
	{
		for "_i" from 0 to (count _table - 1 ) do 
		{
			_slot = _table select _i;
			_slotState = _slot select 0;
			if ( _slotState == SLOT_READY ) exitWith 
			{	
				_ret = _i;
			};
		};
	};
	_ret;
};

/*-----------------------------------
----------GREENHOUSE STATES----------
-----------------------------------*/

//if greenhouse is not initialized, then INITIALIZE it + all it's slots
_greenhouseState = (_greenhouse getVariable ['config',objNull]);
if ( typeName _greenhouseState == "OBJECT" ) then
{
	//[_person, "INITIALIZE GREENHOUSE","colorAction"] call fnc_playerMessage;
	_greenhouse setVariable ['config', _greenhouseConfig];
}
else
{
	_greenhouseConfig = (_greenhouse getVariable ['config',objNull]);
};

// FIND type of object in hands
_isTool = [_digToolsConfig, typeOf _inHandObject] call _fnc_isDefinedInTable;
_isSeed = [_seedsConfig, typeOf _inHandObject] call _fnc_isDefinedInTable;
_isFertilizer = [_FertilizersConfig, typeOf _inHandObject] call _fnc_isDefinedInTable;

// DIGGING
if ( _isTool && !_isPlayerBusy ) then
{	
	_toolParameters = [_digToolsConfig, typeOf _inHandObject] call _fnc_getValue;

	// get free slot if exists
	_freeSlotId = call _fnc_getFreeSlotId;
	
	// dig free slot
	if ( _freeSlotId > -1 ) then
	{
		_slot = _greenhouseConfig select _freeSlotId;
		
		// increase digged percentage
		_slotDiggedPercent = _slot select 1;
		_slotDiggedPercent = _slotDiggedPercent + (_toolParameters select 1);
		if (_slotDiggedPercent >= 1 ) then
		{	_slot set [0, SLOT_READY ];
			_slot set [1, 0 ];
		}
		else
		{	_slot set [0, SLOT_INPROGRESS ];
			_slot set [1, _slotDiggedPercent ];
		};

		// Play animation for digging and make him unable to do other actions
		_playAnim		= (_toolParameters select 2);
		_animationLenght	= (_toolParameters select 3);
		_person playAction [_playAnim, {}];
		_person setVariable ["isUsingSomething",1];
		
		//wait until animation finish and make him not busy
		sleep _animationLenght;
		_person setVariable ["isUsingSomething",0];
		_inHandObject setDamage (damage _inHandObject + 0.025);
		
		//Create pile on slot position
		_greenhousePos = getPosASL _greenhouse;
		_greenhouseASLHeight = _greenhousePos select 2;
		_soilPos = [_greenhousePos, _slot select 2, direction _greenhouse] call fnc_getRelativeXYPos;
		_obj = "DiggedSoil" createVehicle [_soilPos select 0, _soilPos select 1, (_slot select 2) select 2];
		_obj setObjectTexture [0,"DZ\plants2\farming\data\soil_cultivated_CO.paa"];
		_slot = [_slot select 0, _slot select 1, _slot select 2, _slot select 3, _obj, _slot select 5];
		_obj setVariable ["soil", _greenhouse];
		_obj setVariable ["slot", _freeSlotId];
		if (_useRandomRotation) then {
			_obj setDir random 360;
		};
		if (_useTerrainHeight) then {
			_obj setPosATL [_soilPos select 0, _soilPos select 1, (_slot select 2) select 2]; // Hack for raising the object off the ground
		}else{
			_obj setposASL [_soilPos select 0, _soilPos select 1, _greenhouseASLHeight + ((_slot select 2)select 2)]; // Hack for raising the object off the ground
		};
		
		// FEEDBACK to the player:
		if ( _slotDiggedPercent < 1 ) then
		{
			[_person,format["I have digged slot %1 for %2%% with %3.",(_freeSlotId+1),(_slotDiggedPercent*100),displayName _inHandObject],"colorAction"] call fnc_playerMessage;
		}
		else
		{
			[_person, "The slot is prepared.", "colorAction"] call fnc_playerMessage;
		};
		
		// update table
		_greenhouseConfig set [ _freeSlotId, _slot  ];
		_greenhouse setVariable ['config', _greenhouseConfig];
	}
	else
	{
		[_person, "There are no free slots for digging.", "colorAction"] call fnc_playerMessage;
	};
};

// PLANTING
if ( _isSeed && !_isPlayerBusy ) then
{
	_seedParameters = [_seedsConfig, typeOf _inHandObject] call _fnc_getValue;
	
	// get ready slot if exists
	_readySlotId = -1;
	if (isNil "_passedSlot") then
	{
		_readySlotId = call _fnc_getSlotFertilizedOrReadyId;
	}else{
		_readySlotId = _passedSlot;
	};
	
	if ( _readySlotId == -1 ) then
	{
		[_person, "There are no ready slots.", "colorAction"] call fnc_playerMessage
	}
	else
	{
		_slot = _greenhouseConfig select _readySlotId;
		[_inHandObject, -1] call fnc_addQuantity;

		deleteVehicle (_slot select 4);
		_isFertilized = (_slot select 0 == SLOT_FERTILIZED);
		if (_isFertilized) then {
			[_person, "I've planted a seed into the fertilized soil.", "colorAction"] call fnc_playerMessage;
		}else{
			[_person, "I've planted a seed.", "colorAction"] call fnc_playerMessage;
		};
		if (rain == 0) then{
			[_person, "However the soil is too dry for the plant to grow.","colorAction"] call fnc_playerMessage;
		};
		
		//_greenhousePos = getPosASL _greenhouse;
		//_soilPos = _slot select 2;
		
		_greenhouseASLHeight = (getPosASL _greenhouse) select 2;
		
		if (_useTerrainHeight) then {
			//_obj setPosATL [_soilPos select 0, _soilPos select 1, (_slot select 2) select 2]; // Hack for raising the object off the ground
			//[_soilPos select 0, _soilPos select 1, (_slot select 2) select 2]
			//_slotPosX = ((position _greenhouse) select 0) + (_slot select 0);
			//_slotPosY = ((position _greenhouse) select 1) + (_slot select 1);
			_slotPosZ = ((_slot select 2) select 2);
			//_greenhouseASLHeight = getTerrainHeightASL [_slotPosX + ((_slot select 2) select 0), _slotPosY + (_slot select 2) select 1]
			[
				_greenhouse, 
				_seedParameters select 0, 
				[(_slot select 2) select 0, (_slot select 2) select 1,  _slotPosZ], // TO DO: Solve terrain height
				_readySlotId, 
				_slot select 5, 
				_isFertilized
			] spawn player_plantStages;
		}else{
			//_obj setposASL [_soilPos select 0, _soilPos select 1, _greenhouseASLHeight + ((_slot select 2)select 2)]; // Hack for raising the object off the ground
			//[_soilPos select 0, _soilPos select 1, _greenhouseASLHeight + ((_slot select 2)select 2)]
			[_greenhouse, _seedParameters select 0, _slot select 2, _readySlotId, _slot select 5, _isFertilized] spawn player_plantStages; 
		};
		
		// set slot state to PLANTED
		_slot set [0, SLOT_PLANTED ];
		
		// update table
		_slot = [_slot select 0, _slot select 1, _slot select 2, _slot select 4, objNull, _slot select 5];
		_greenhouseConfig set [ _readySlotId, _slot  ];
		_greenhouse setVariable ['config', _greenhouseConfig];
	};
};

// Fertilization
if (_isFertilizer && !_isPlayerBusy ) then
{
	_FertilizerParams = [_FertilizersConfig, typeOf _inHandObject] call _fnc_getValue;
	// get ready slot if exists
	_readySlotId = -1;
	if (isNil "_passedSlot") then
	{
		_readySlotId = call _fnc_getSlotReadyId;
	}else{
		_readySlotId = _passedSlot;
	};
	
	if ( _readySlotId == -1 ) then
	{
		[_person, "There are no digged slots.", "colorAction"] call fnc_playerMessage
	}
	else
	{
		// Set the correct slot as FERTILIZED
		_slot = _greenhouseConfig select _readySlotId;
		_slot set [0, SLOT_FERTILIZED ];
		
		// Apply nutrients
		_slot set [5, (_slot select 5) + (_FertilizerParams select 2) ];
		// subtract quantity
		[_inHandObject, -(_FertilizerParams select 3)] call fnc_addQuantity;
		
		// User feedback
		[_person, "I've fertilized the ground.", "colorAction"] call fnc_playerMessage;
		
		// Change pile texture
		_diggedSoil = _slot select 4;
		_diggedSoil setObjectTexture [0,"DZ\plants2\farming\data\soil_cultivated_limed_CO.paa"];
		
		// update table
		_slot = [_slot select 0, _slot select 1, _slot select 2, _slot select 3, _diggedSoil, _slot select 5];
		_greenhouseConfig set [ _readySlotId, _slot ];
		_greenhouse setVariable ['config', _greenhouseConfig];
	};
};