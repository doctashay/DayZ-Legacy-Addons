_objSoil = _this select 0;
_plantSeed = _this select 1;
_plantOffset = _this select 2;
_plantSlot = _this select 3;
_isFertilized = _this select 5;
_energy = _this select 4;
_position = getposASL _objSoil;
_aboveSeaHeight = _position select 2;
_objPlant = objNull;
_currentStage = -1;
_randomDir = random 360;

// variable definitions
_growthStagesCount = 6;
_plantType = "";
_fullMaturityTime = 0;
_spoilTimer = 0;
_spoiledRemoveTimer = 0;
_cropsCount = 0;

/*-----------------------------------
------------PLANT CONFIGS------------
-----------------------------------*/

// Plants configurations
switch (_plantSeed) do
{
	// TO DO: Solve issue with duplicit entries:
	case ("Cultivation_TomatoSeedsPack"):
	{
		_plantType = "plant_tomato"; // p3d class name
		_growthStagesCount = 6; // number of growth selections named as plantStage_## in the plant p3d file
		_fullMaturityTime = (60*15 + random 120) / _energy;
		_spoilTimer = (60*15 + random 120) * _energy;
		_spoiledRemoveTimer = 60*10 + random 120;
		_cropsCount = 7 * _energy;
	};
	case ("Cultivation_TomatoSeeds"):
	{
		_plantType = "plant_tomato"; // p3d class name
		_growthStagesCount = 6; // number of growth selections named as plantStage_## in the plant p3d file
		_fullMaturityTime = (60*15 + random 120) / _energy;
		_spoilTimer = (60*15 + random 120) * _energy;
		_spoiledRemoveTimer = 60*10 + random 120;
		_cropsCount = 7 * _energy;
	};
	
	case ("Cultivation_PepperSeedsPack"):
	{
		_plantType = "Plant_Pepper"; // p3d class name
		_growthStagesCount = 6; // number of growth selections named as plantStage_## in the plant p3d file
		_fullMaturityTime = (60*15 + random 120) / _energy;
		_spoilTimer = (60*15 + random 120) * _energy;
		_spoiledRemoveTimer = 60*10 + random 120;
		_cropsCount = 3 * _energy;
	};
	case ("Cultivation_PepperSeeds"):
	{
		_plantType = "Plant_Pepper"; // p3d class name
		_growthStagesCount = 6; // number of growth selections named as plantStage_## in the plant p3d file
		_fullMaturityTime = (60*15 + random 120) / _energy;
		_spoilTimer = (60*15 + random 120) * _energy;
		_spoiledRemoveTimer = 60*10 + random 120;
		_cropsCount = 3 * _energy;
	};
	
	case ("Cultivation_PumpkinSeedsPack"):
	{
		_plantType = "Plant_Pumpkin"; // p3d class name
		_growthStagesCount = 7; // number of growth selections named as plantStage_## in the plant p3d file
		_fullMaturityTime = (60*15 + random 120) / _energy;
		_spoilTimer = (60*15 + random 120) * _energy;
		_spoiledRemoveTimer = 60*10 + random 120;
		_cropsCount = 2;
	};
	case ("Cultivation_PumpkinSeeds"):
	{
		_plantType = "Plant_Pumpkin"; // p3d class name
		_growthStagesCount = 7; // number of growth selections named as plantStage_## in the plant p3d file
		_fullMaturityTime = (60*15 + random 120) / _energy;
		_spoilTimer = (60*15 + random 120) * _energy;
		_spoiledRemoveTimer = 60*10 + random 120;
		_cropsCount = 2;
	};
};

/*-----------------------------------
------------PLANT STAGES-------------
-----------------------------------*/


/* -----INITIALIZATION----- */


// Create the plant itself.
_objPlant = _plantType createVehicle _position;
_plantPos = [_position, _plantOffset, direction _objSoil] call fnc_getRelativeXYPos;
// Correct the plant's position
_objPlant setposASL [_plantPos select 0, _plantPos select 1, _aboveSeaHeight + (_plantOffset select 2)];

hint format["%1 Position:\n%2",_objPlant, getPosASL _objPlant ];

// Assign all variables to the plant object
_objPlant setVariable ["soil", _objSoil];
_objPlant setVariable ["plantSlot", _plantSlot];
_objPlant setVariable ["cropsCount", _cropsCount];
_objPlant setVariable ["state", PLANT_IS_DRY];
_objPlant setVariable ["currentStage", _currentStage];
_objPlant setVariable ["energy", _energy];

// update plant values
[_objPlant] call fnc_updatePlant;

if (_isFertilized) then {
	_objPlant animate["pile_02", 0]; // 0 means UNhide this selection!
	_objPlant animate["pile_01", 1]; // 1 means hide this selection!
}else{
	_objPlant animate["pile_01", 0]; // 0 means UNhide this selection!
	//_objPlant animate["pile_01", 1]; // 1 means hide this selection!
};

/* -----WATERING STAGE----- */


// Wait for watering
_waitingForWater = 0;
while {_objPlant getVariable "state" == PLANT_IS_DRY  and  !isnull _objPlant and rain == 0 } do
{
	_waitingForWater = _waitingForWater + 1;
	if ( _waitingForWater >= DELETE_DRY_PLANT_TIMER) then
	{	
		[_objSoil, _plantSlot] call fnc_resetSlotState;
		deleteVehicle _objPlant;
	};
	sleep 1;
};
// If the plant was removed, then stop the script
if (isnull _objPlant) exitWith {};

_objPlant setVariable ["state", PLANT_IS_GROWING];\

// By this point the plant is no longer dry


/* -----GROWTH STAGES----- */


// Growing up to the mature state
while {_currentStage < _growthStagesCount-2} do // -2 because the last spoiled stage has to be left out
{
	scopeName "loop";
	_currentStage = _currentStage + 1;
	
	// update plant variables
	_objPlant setVariable ["currentStage", _currentStage];
	_objPlant setVariable ["energy", _energy];
	[_objPlant] call fnc_updatePlant;
	
	if (_currentStage == _growthStagesCount-2) then { breakOut "loop" }; // -2 because the last spoiled stage has to be left out
	
	sleep (_fullMaturityTime / (_growthStagesCount-2) );
	
	if (isNull _objPlant) exitWith {};
};

_objPlant setVariable ["state", PLANT_IS_MATURE];

sleep _spoilTimer;


/* -----SPOILED STAGE----- */


if (!isNull _objPlant) then
{
	_currentStage = _currentStage + 1;
	_objPlant setVariable ["currentStage", _currentStage];
	_objPlant setVariable ["state", PLANT_IS_SPOILED];
	[_objPlant, _currentStage] call fnc_updatePlant;
	sleep _spoiledRemoveTimer;
	
	if (!isNull _objPlant) then
	{
		[_objSoil, _plantSlot] call fnc_resetSlotState;
		deleteVehicle _objPlant;
	};
};