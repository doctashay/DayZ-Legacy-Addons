//DayZ Legacy 0.44
//initServer.sqf - Initializes server events and functions.
//This script has been redirected from dz\modulesDayz and dz\server_data to provide better ability to add or extend functionality.

diag_log "Arrived at redirected initServer.sqf";

DZ_MAX_ZOMBIES = 1000;
DZ_MAX_ANIMALS =1000;

DZ_TotalZombies = 0;
DZ_TotalAnimals = 0;
DZ_TotalEvents = 0;

playerBodies = [];

windChill = 0;
worldLightScale = 0;
windSpeed = 0;

debug = false;

DZ_PlayerHitpoints = [];
_hitPoints = configfile >> "CfgVehicles" >> "ManBase" >> "HitPoints";
for "_i" from 0 to (count _hitPoints - 1) do { 
	DZ_PlayerHitpoints set [count DZ_PlayerHitpoints,configName(_hitPoints select _i)];
};

//events
event_saySound =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_saySound.sqf";
event_weaponFired =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_weaponFired.sqf";
event_craftMessage = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_craftMessage.sqf";
event_modifier = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_modifier.sqf";
event_assessDamage = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_assessDamage.sqf";
event_transferModifiers = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_transferModifiers.sqf";
event_igniteObject = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_igniteObject2.sqf";
event_clearModifiers = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_clearModifiers.sqf";
event_playerKilled = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_playerKilled.sqf";
event_hitZombie =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_hitZombie.sqf";
event_bloodTransfusion = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_bloodTransfusion.sqf";
event_killedWildAnimal = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_killedWildAnimal.sqf";
event_killedZombie = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_killedZombie.sqf";
event_gasLight = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_gasLight.sqf";
event_openCan = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\events\event_openCan.sqf";

//players
//player_checkStealth = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_checkStealth.sqf";
player_combineQuantity = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_combineQuantity.sqf";
player_splitQuantity = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_splitQuantity.sqf";
player_useItem =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_useItem.sqf";
player_useItemEnd =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_useItemEnd.sqf";
player_fillBottle =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_fillBottle.sqf";
player_stripMagazine = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_stripMagazine.sqf";
player_loadMagazine = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_loadMagazine.sqf";
player_addInventory = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_addInventory.sqf";
player_actionOnTarget = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_actionOnTarget.sqf";
player_actionOnSelf = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_actionOnSelf.sqf";
player_actionOnItem = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_actionOnItem.sqf";
player_combineMoney = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_combineMoney.sqf";
player_applyBandage = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_applyBandage.sqf";
player_chamberRound = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_chamberRound.sqf";
player_loadWeapon = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_loadWeapon.sqf";
player_pickBerry =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_pickBerry.sqf";
player_applyDefibrillator = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_applyDefibrillator.sqf";
player_moveToInventory =	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_moveToInventory.sqf";

player_mendItem = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_mendItem.sqf";
player_igniteFireplace = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_igniteFireplace.sqf";
player_RabbitSnareTrap = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_RabbitSnareTrap.sqf";
player_plantStages = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_plantStages.sqf";
player_digGreenhouse=		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_digGreenhouse.sqf";
player_dryClothes = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_dryClothes.sqf";
player_gutDeadBodyCheck = compile preprocessFileLineNumbers "dzlegacy\server_data\scripts\players\player_gutDeadBodyCheck.sqf";
player_gutDeadBodyStart = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_gutDeadBodyStart.sqf";
player_gutDeadBodyEnd = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_gutDeadBodyEnd.sqf";
player_gutDeadBodyCancel = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_gutDeadBodyCancel.sqf";
player_useDuctTapeOnItem = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_useDuctTapeOnItem.sqf";
player_DigTile = compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_DigTile.sqf";

//weapons
weapon_swapHandguard =compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\weapons\weapon_swapHandguard.sqf";

//server
building_spawnLoot =	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\server\building_spawnLoot.sqf";
init_spawnLoot = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\spawnLoot.sqf";
init_spawnZombies = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\spawnZombies.sqf";
init_spawnWildAnimals = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\spawnWildAnimals.sqf";
init_spawnServerEvent = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\spawnServerEvent.sqf";
player_queued = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\players\player_queued.sqf";

//functions

fnc_generateTooltip = compile preprocessFileLineNumbers "\dzlegacy\modulesDayZ\scripts\fn_generateTooltip.sqf";
fnc_inString = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\fn_inString.sqf";
fnc_inAngleSector =  	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\fn_inAngleSector.sqf";
fnc_isMaxQuantity = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\isMaxQuantity.sqf";
BIS_fnc_findSafePos =	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\fn_findSafePos.sqf";
fnc_generateQuantity =compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\fn_generateQuantity.sqf";
dayz_losCheck =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\dayz_losCheck.sqf";
dayz_losChance = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\dayz_losChance.sqf";
dayz_bulletHit = 		compile preprocessFileLineNumbers "\dzlegacy\modulesDayZ\scripts\dayz_bulletHit.sqf";
fnc_playerMessage =	compile preprocessFileLineNumbers "\dzlegacy\modulesDayZ\scripts\fn_playerMessage.sqf";
runZombieBrain =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\runZombieBrain.sqf";
tick_modifiers =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\tick_modifiers.sqf";
tick_states =		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\tick_states.sqf";
tick_environment = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\tick_environment.sqf";
randomValue =		compile preprocessFileLineNumbers "\dzlegacy\modulesDayZ\scripts\randomValue.sqf";
dbLoadPlayer = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\dbLoadPlayer.sqf";
world_surfaceNoise = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\functions\fn_surfaceNoise.sqf";
farmingFunctions =		[] execVM "\dzlegacy\server_data\scripts\functions\farming.sqf";

//initialize
zombie_initialize = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\zombie_initialize.sqf";
player_initialize = 	compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\player_initialize.sqf";
init_battery = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\battery_initialize.sqf";
init_cooker = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\cooker_initialize.sqf";
init_fireplace = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\fireplace_initialize.sqf";
init_kindling = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\kindling_initialize.sqf";
init_flare = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\flare_initialize.sqf";
init_wreck = 		compile preprocessFileLineNumbers "\dzlegacy\server_data\scripts\init\wreck_initialize.sqf";
init_lamp =
{
	if (isServer) then
	{
		_this spawn {
			//_this synchronizeVariable ["light",1,{_this call event_fnc_gasLight}];	//not needed
		};
	};
};

init_newPlayer =
{
	//establish default variables
	_this setVariable ["health",DZ_HEALTH];
	_this setVariable ["blood",DZ_BLOOD];
	_this setVariable ["energy",DZ_ENERGY];
	_this setVariable ["water",DZ_WATER];
	_this setVariable ["stomach",DZ_STOMACH];
	_this setVariable ["diet",DZ_DIET];
	_this setVariable ["bodytemperature",DZ_TEMPERATURE];
	_this setVariable ["heatComfort",DZ_HEATCOMFORT];
	_this setVariable ["wet",0];
	_this setVariable ["musclecramp",DZ_MUSCLECRAMP];
	
	//get blood type
	_bloodTypes = getArray (configFile >> "cfgSolutions" >> "bloodTypes"); 
	_rand = random 1; 
	_newType = ""; 
	{ 
		_chance = getNumber (configFile >> "cfgSolutions" >> _x >> "probabilityScale"); 
		if (_rand < _chance) exitWith  
		{ 
			_newType = _x; 
		}; 
	} forEach _bloodTypes;	
	_this setVariable ["bloodtype",_newType];
};

init_newBody =
{
	//manage player body
	playerBodies set [count playerBodies,_agent];
	_agent setVariable ["UID",_uid];
	diag_log format["Recording player %1 with %2",name _agent,_uid];
	
	//move player into body
	_id selectPlayer _agent;
	_agent call player_initialize;	
	[_id] spawnForClient compile "player execFSM '\dzlegacy\modulesDayZ\fsm\brain_player_client.fsm'";
	_agent addEventHandler ["HandleDamage",{_this call event_assessDamage} ];
	myNotifiers = _agent getVariable ["myNotifiers",[]];
	_id publicVariableClient "myNotifiers";
};

dbSavePlayerPrep = 
{
	private["_array"];
	_agent = _this;
	//save lifestate
	switch (lifeState _agent) do
	{
		case "UNCONSCIOUS": {
			_agent setVariable ["unconscious",true];
		};
		case "ALIVE": {
			_agent setVariable ["unconscious",false];
		};
		default {
			_agent setVariable ["unconscious",false];
		};
	};
	//save damage
	//diag_log format ["Using %1",DZ_PlayerHitpoints];
	_array = [];
	{
		_v = _agent getHitPointDamage _x;
		//diag_log format ["Saving hitpoint %1 with %2",_x,_v];
		if (_v > 0) then
		{
			_array set [count _array,[_x,_v]];
		};
	} forEach DZ_PlayerHitpoints;
	_agent setVariable ["damageArray",_array];
	//diag_log format ["Saved %1",_array];
};

player_warningMessage = {
	private["_messages","_color","_client","_output"];
	_messages = _this select 0;
	_color = _this select 1;
	_client = _this select 2;
	_output = (_messages select floor(random(count _messages)));
	if (isDedicated) then {
		_client statusChat [_output,_color];
	} else {
		statusChat [_output,_color];
	};
};

player_checkPulse = 
{
	_target = _this select 0;
	_person = _this select 1;
	/*
	_blood = _target getVariable ["blood",DZ_BLOOD];
	_pressure = switch (true) do
	{
		case (_blood < (DZ_BLOOD * 0.2)): {"very fast and "};
		case (_blood < (DZ_BLOOD * 0.4)): {"fast and "};
		case (_blood < (DZ_BLOOD * 0.8)): {"regular and "};
		default {""};
	};
	*/
	_health = _target getVariable ["health",DZ_HEALTH];
	_state = switch (true) do
	{
		case (_health < (DZ_HEALTH * 0.1)): {"extremely weak"};
		case (_health < (DZ_HEALTH * 0.2)): {"very weak"};
		case (_health < (DZ_HEALTH * 0.4)): {"weak"};
		case (_health < (DZ_HEALTH * 0.8)): {"steady"};
		default {"strong"};
	};
	
	switch (true) do
	{
		case (!alive _target): //dead
		{
			_time = diag_tickTime - (_target getVariable ["timeOfDeath",diag_tickTime]);
			_state = switch (true) do
			{
				case (_time > 600): {"cold"};
				case (_time > 400): {"lukewarm"};
				default {"warm"};
			};
			[_person,format["%1 has no pulse and is %2 to touch",name _target,_state],""] call fnc_playerMessage;
		};
		case (_target getVariable["fibrillation",false]): //fibrillation
		{
			[_person,format["%1 has a %2 but irregular pulse",name _target,_state],""] call fnc_playerMessage;
		};		
		default //others
		{
			[_person,format["%1 has a %2 pulse",name _target,_state],""] call fnc_playerMessage;
		};
	};
};

player_coverHead = {
	_agent = _this select 0;
	_hide = _this select 1;
	if (_hide) then
	{
		_agent spawnForPlayer compile "setAperture 10000;1 fadeSound 0.4;1 fadeSpeech 0.4;";
	}
	else
	{
		_agent spawnForPlayer compile "setAperture -1;1 fadeSound 1;1 fadeSpeech 1;";
	};
};

fnc_generateRscQuantity = {
	private["_object","_resource","_qty ","_max","_str"];
	_object = _this select 0;
	_resource = _this select 1;
	_qty = _object getVariable [_resource,1];
	_max = getNumber (configFile >> "CfgVehicles" >> typeOf _object >> "Resources" >> _resource);
	_qty = round ((_qty / _max) * 100);
	_str = format ["%1%%",_qty];
	_str
};

player_suicide = {
	_fsm = [_person,_this] execFSM "\dz\server\scripts\fsm\player_suicide.fsm";
	_person setVariable ["fsm_suicide",_fsm];
};

event_animHook =
{
	//[SurvivorPartsFemaleWhite:0:0,3,"fired"]
	_agent = _this select 0;
	_value = _this select 1;
	_type = _this select 2;
	
	hint "test!";
	
	switch (_type) do
	{
		case "fired":
		{
			_fsm = _agent getVariable ["fsm_suicide",-1];
			hint "bang!";
			if (_fsm < 0) exitWith {};
			hint "bang bang!";
			_fsm setFSMVariable ["_fired",true];
		};
	};
};

player_transferWater = {
	_receiverQty = quantity _tool2;
	_senderQty = quantity _tool1;
	_name1 = displayName _tool2;
	
	if (_receiverQty >= maxQuantity _tool2) exitWith 
	{
		[_owner,format["The %1 is already full",_name1],""] call fnc_playerMessage;
	};
	if (damage _tool2 >= 1 || damage _tool1 >= 1) exitWith 
	{
		[_owner,format["The %1 is too badly damaged",_name1],""] call fnc_playerMessage;
	};
	
	_exchanged = ((_receiverQty + _senderQty) min (maxQuantity _tool2)) - _receiverQty;
	_receiverQty = _receiverQty + _exchanged;
	_senderQty = _senderQty - _exchanged;
	_tool2 setQuantity _receiverQty;
	_tool1 setQuantity _senderQty;
	
	[_owner,format["You have poured the %2 into the %1",_name1,displayName _tool1],"colorAction"] call fnc_playerMessage;
};

player_paintItem = {
	_baseClass = _this select 0;
	_type = _this select 1;
	_name = displayName _tool1;
	_damage = damage _tool1;
	if (quantity _tool2 < 0.25) exitWith 
	{
		[_owner,format["Not enough paint left in the %1",displayName _tool2],""] call fnc_playerMessage;
	};

	//make new weapon
	_parent = itemParent _tool1;
	_color = getText(configFile >> "cfgVehicles" >> typeOf _tool2 >> "color");
	_newItemType = format ["%1_%2",_baseClass,_color];
	_newItemCfg = configFile >> _type >> _newItemType;
	
	if (!isClass _newItemCfg) exitWith
	{
		_msg = "You cannot paint the %1 to %2";
		if (_baseClass == typeOf _tool1) then {_msg = "You cannot add %2 paint to the %1"};
		[_owner,format[_msg,_name,_color],""] call fnc_playerMessage;
	};
	
	_qty = _tool1 getVariable ["quantity",-1];	//LEAVE THIS, TO DETECT NULL
	if (_tool1 isKindOf "DefaultMagazine") then
	{
		_qty = magazineAmmo _tool1;
	};
	
	_newItem = _tool1;
	
	//check if has attachments, if not just create inside
	if (count itemsInInventory _tool1 > 0)  then
	{	
		_oldItem = moveToGround _tool1;
		_newItem = [_newItemType,_parent,_owner] call player_addInventory;
		_newItem setDamage _damage;
		_light = nil;
		_hasLight = false;
		//move attachments to new weapon
		_array = getArray(_newItemCfg >> "attachments");
		{
			//prevents removing of flashlight on m4
			if ((_tool1 itemInSlot _x) isKindOf "Attachment_Light_Universal") then {
				_light = (_tool1 itemInSlot _x);
				_hasLight = true;
			} else {
				_newItem moveToInventory (_tool1 itemInSlot _x);
			};
		} forEach _array;
		if (_hasLight) then {
			_newItem moveToInventory _light;
		};
		_newItem moveToInventory (_tool1 itemInSlot "magazine");
		//remove old
		deleteVehicle _tool1;
		//switch in new
		//_parent moveToInventory _newItem;	
	} 
	else
	{	
		deleteVehicle _tool1;
		_newItem = [_newItemType,_parent,_owner] call player_addInventory;
		_newItem setDamage _damage;
	};
	
	//set quantities
	if (_qty >= 0) then
	{
		if (_newItem isKindOf "DefaultMagazine") then
		{
			_qty = _newItem setMagazineAmmo _qty;
		}
		else
		{
			_newItem setQuantity _qty;
		};
	};
	_tool2 addQuantity -0.25;
	
	[_owner,format["You have painted the %1 %2",_name,_color],"colorAction"] call fnc_playerMessage;
};

doZombieHit = {
	private["_agent","_fsm"];
	_agent = _this;
	_fsm = _agent getVariable["fsm",-1];
	if (_fsm < 0) exitWith{};
	_fsm setFSMVariable["_attacking",false];
};

building_getProxyName = {
	//Take string and return truncated proxy name
	_array = toArray(_this);
	_newArray = [];
	for "_i" from 17 to ((count _array) - 1) do 
	{
		_newArray set[(_i - 17),(_array select _i)];
	};
	_string = toString _newArray;
	_string
};

fnc_randomPlacement = {
	private["_pos","_max","_val"];
	_pos = _this select 0;
	_max = _this select 1;
	_val = 0;
	
	for "_i" from 0 to 1 do 
	{	
		_val = _max - (random (_max * 2));
		_pos set [_i,((_pos select _i) + _val)];
	};
	_pos
};

/*
ENVIRONMENT FUNCTIONS
*/
fnc_processItemWetness = {

	/*
		Processes wetness change for an item
		_this refers to whether item is parented to player or not
	*/
	
	//if there are no clothes on that part of body, dry/wet player instead
	if (isNull _item)exitWith{
		_playerWet = ((_playerWet + (_delta * 0.1 * _scale)) min 1) max 0;
	};
	
	//if clothes are already dry, dry player instead
	_wetness = _item getVariable ["wet",0];
	if(_wetness == 0 and _isDrying)exitWith{
	_playerWet = ((_playerWet + (_delta * 0.01 * _scale)) min 1) max 0;
	};
	
	//if clothes are already soaked, wet player instead
	_absorbancy = getNumber(configFile >> "cfgVehicles" >> typeOf _item >> "absorbency");
	if((_wetness == _absorbancy or _absorbancy == 0) and !_isDrying)exitWith{
		//if player has waterproof clothes and is in water he gets wet, if its just raining, then not
		if(_isWater)then{
_playerWet = ((_playerWet + (_delta * (_absorbancy+0.1) * _scale)) min 1) max 0;
		};

	};
	
	//dry/wet clothes
	//_wetness = (((_wetness + (_delta * _scale)) min 1) max 0) * _absorbancy;
	_wetness = ((_wetness + (_delta * _scale)) min _absorbancy) max 0;
	_item setVariable ["wet",_wetness];
};

/*
DAMAGE CAlC
*/
damage_fnc_generateSlots =
{
	_slots = getArray (_config >> "inventorySlots");
	{
		private["_item"];
		//find out what is on the player
		_item = _agent itemInSlot _x;
		if (!isNull _item) then
		{
			_items set [count _items,_item];
		};
	} forEach _slots;
};
damage_fnc_applyStateChange =
{
	private["_v","_i"];
	_v = getNumber(_ammoConfig >> format["hit%1",_this]);
	//statusChat[format["Result: %1",_v],""];
	_i = _agent getVariable [_this,0];
	_agent setVariable [_this,(_i + _v)];
};
damage_unconscious = 
{
	private["_agent","_case"];
	_agent = _this select 0;
	_case = _this select 1;
	if _case then {
		_agent playAction "KnockDownStayB";
		_agent setUnconscious true;
	}
	else
	{
		//null = _agent spawn {sleep 1;_this playAction "KnockUp"};
		_agent setUnconscious false;
	};
};
damage_publishBleeding =
{
	// don't do damage for dead bodies
	if(!alive _person) exitWith {};
	
	_chance = getNumber(_ammoConfig >> "bleedChance");
	if (_isMelee) then
	{
		{
			_i = _agent itemInSlot _x;
			_chance = _chance * (1 - (getNumber(configFile >> "cfgVehicles" >> typeOf _i >> "DamageArmor" >> "bleed") * (1 - damage _i)));
		} forEach _slots;
	};
	
	_doBleed = (random 1) < _chance;
	if (_doBleed) then 
	{
		_bleeding = call compile (_agent getVariable ["bleedingsources","[]"]);
		_bleeding set [count _bleeding,_this select 5];
		_agent setVariable ["bleedingsources",str(_bleeding)];
	};
	//statusChat [format["chance: %1 // result: %2 // bone: %3 // damage: %4",_chance,_doBleed,_bone,_damage],""];
};
medical_playerBandage =
{
	_agent = _this select 1;
	if (_this select 0) then
	{
		_infectionChance = random 1;
		_wounds = _agent getVariable ['bleedingLevel',0];
		if (_wounds > 0) then {
			_item = _agent getVariable ['inUseItem',objNull];
			_condition = damage _item;
			if ((_condition >= 0.5) and (_infectionChance < 0.3)) then 
			{
				[0,_agent,'WoundInfection'] call event_modifier;
			};
		};
		_agent setVariable ['bleedingsources','[]'];
		_agent setVariable ['bleedingLevel',0];
		//_agent setDamage 0; //commented out as we dont want to fix broken leg by bandaging
	}
	else
	{
		_agent setVariable ['bleedingsources','[]'];
		_agent setVariable ['bleedingLevel',0];
		//_agent setDamage 0; //commented out as we dont want to fix broken leg by bandaging
	};
};
/*
EVENT MANAGEMENT
*/
fnc_speedVector = {
	private["_speed"];
	_speed = [0,0,0] distance (velocity _this);
	_speed
};

weapon_toggleOptics = {
//[(_this select 0),0] call 
	_optic = _this select 0;
	_powerOn = _this select 1;
	
	switch (_powerOn) do
	{
		case 0:
		{
			_optic setObjectTexture [0,"#(rgb,8,8,3)color(1,0,0,0)"];
		};
		case 1:
		{
			//set scope texture if required
			_opticTexture = getText (configFile >> "CfgVehicles" >> typeOf _optic >> "OpticsInfo" >> "opticSightTexture");
			if (_opticTexture != "") then
			{
				_optic setObjectTexture [0,_opticTexture];
			};
		};
	};
};

player_fnc_useItemStart =
{
	_person setVariable ["inUseItem",_item];
	if (_quantity > 0) then
	{
		//Use part of stack
		_item addQuantity -_use;
	};
};

player_fnc_useItemEnd =
{
	_oldItem = _person getVariable ["previousItem",objNull];
	_item = _person getVariable ["inUseItem",objNull];
	if (!_keepEmpty) then
	{		
		if (quantity _item <= 0) exitWith
		{
			deleteVehicle _item;
		};
	};
	if (_oldItem != _item) then 
	{
		_person moveToHands _oldItem;
	};
	_person setVariable ["inUseItem",objNull];
	_person setVariable ["previousItem",objNull];
};

event_fnc_sendActvMessage = {
	//send an activation message
	private["_messages","_style","_output","_statement"];
	//_stages = _cfgModifier >> "Stages";
	//_cfgStage = _stages select _stage;

	// don't do damage for dead bodies
	if(!alive _person) exitWith {};

	_postpone = getNumber (_cfgStage >> "postponeMessageUntilCooldown");
	
	if(_postpone == 0) then {
	
		_messages = getArray (_cfgStage >> "messages");
		if (count _messages > 0) then
		{
			_style = getText (_cfgStage >> "messageStyle");
			_output = (_messages select (floor random(count _messages)));
			[_person,_output,_style] call fnc_playerMessage;
		};
		
	};
	
	_myNotifiers = _person getVariable ["myNotifiers",[]];
	_publishNotifiers = false;
	
	if (count _oldNotifier > 0) then	//blank old notifier
	{
		_myNotifiers set [_oldNotifier select 0,[]];
		_publishNotifiers = true;
	};
	
	_notifier = getArray (_cfgStage >> "notifier");
	if (count _notifier > 0) then	//send new notifier
	{		
		_myNotifiers set [_notifier select 0,[_notifier select 1,_notifier select 2]];
		_person setVariable ["myNotifiers",_myNotifiers];
		_publishNotifiers = true;
	};
	
	if (_publishNotifiers) then
	{
		myNotifiers = _myNotifiers;
		(owner _person) publicVariableClient "myNotifiers";
	};
	
	//execute entry statement
	_statement = getText(_cfgStage >> "statementEnter");
	call compile _statement;
};

event_fnc_endModifier = {	
	private["_statement"];
	//end the modifier
	_modifiers set [_i,0];
	_modstates set [_i,0];
	_cleanup = true;
	_skipSave = true;
	
	//send a state exit message
	private["_messages","_style","_output"];
	_messages = getArray (_cfgModifier >> "messagesExit");
	if (count _messages > 0) then
	{
		_style = getText (_cfgModifier >> "messageExitStyle");
		_output = (_messages select (floor random(count _messages)));
		[_person,_output,_style] call fnc_playerMessage;
	};
	
	_notifier = getArray (_cfgStage >> "notifier");
	if (count _notifier > 0) then
	{
		_myNotifiers = _person getVariable ["myNotifiers",[]];
		_myNotifiers set [_notifier select 0,[]];
		myNotifiers = _myNotifiers;
		(owner _person) publicVariableClient "myNotifiers";
	};
	
	//run ending statement
	_statement = getText (_cfgStage >> "statementExit");	//_person
	call compile _statement;
};

event_fnc_addModifier = {
	/*
		important! this must not have its variables set to private!
		
		This script is used within others, parenting off their variables, to
		allow the addition of a modifier to the mod array
	*/
	//check if allowed to add
	private["_stages","_cfgStage"];
	_stages = _cfgModifier >> "Stages";
	_cfgStage = _stages select _stage;
	_condition = getText (_cfgStage >> "condition");
	
	//save old notifier
	_oldNotifier = [];
	
	_runEvent = _person call compile _condition;
	if (!_runEvent) exitWith {};
	
	//load additional variables			
	_remaining = getArray (_cfgStage >> "duration") call randomValue;
	_reminder = getArray (_cfgStage>> "cooldown") call randomValue;
	
	//send an activation message
	call event_fnc_sendActvMessage;
	
	//save results
	_modifiers set [count _modifiers,_modifier];
	if (_person isKindOf "SurvivorBase") then
	{
		_stageArray = [_stage];
		_modstates set [count _modstates,[_stageArray,_remaining,_reminder]];
	};
	//call event_fnc_saveModifiers;
};

event_fnc_saveModifiers = {
	/*
	important! don't declare these values as private, as it uses its
	parents variables
	
	This function processes an array save for modifiers where needed
	*/
	if (_cleanup) then 
	{
		_modifiers = _modifiers - [0];
		_modstates = _modstates - [0];
	};
	_person setVariable["modifiers",_modifiers];
	if (_person isKindOf "SurvivorBase") then
	{
		_person setVariable["modstates",_modstates];
	};
};

event_fnc_attachFireplace = {
	_fireplace = _this select 0;
	_item = _this select 1;
	_type = _this select 2;
	_stage = 0;
	if(_fireplace animationPhase "Wood" == 0) then {_stage = 1};
	if(_fireplace animationPhase "BurntWood" == 0) then {_stage = 2};
	
	switch (ToLower(_type)) do {
		case "firewood": {
			if(_stage == 0) then {
				_fireplace animate['Wood',0];
				if(_item getVariable ["fuel",0] <= 0) then {
					_item setVariable ["fuel",500];
				};
			};
		};
		case "stones": {
			_master = _fireplace itemInSlot "Stones";
			if(quantity _master >= 8) then {
				_fireplace animate["Stones",0];
				_master addQuantity -8;
				if(quantity _master == 0) then {
					deleteVehicle _master;
				};
			}
		}
	};
};

event_fnc_detachFireplace = {
	_fireplace = _this select 0;
	_item = _this select 1;
	_type = _this select 2;
	_stage = 0;
	if(_fireplace animationPhase "Wood" == 0) then {_stage = 1};
	if(_fireplace animationPhase "BurntWood" == 0) then {_stage = 2};
	
	if(isOn _fireplace) then {
		_fireplace powerOn false;
		_fireplace setVariable ['fire',false];
	};
	
	switch (ToLower(_type)) do {
		case "firewood": {
			if(_stage == 1) then {
				_fireplace animate ["Wood",1];
			};
			if(_stage == 2) then {
				_fireplace animate ["BurntWood",1];
			};
		};
	};
};

event_fnc_powerOutFireplace = {
	_fireplace = _this select 0;
	_firewood = _fireplace itemInSlot "firewood";
	if(!isNull _firewood and (_fireplace getVariable ["fire",false])) then {
		_firewood addQuantity -1;
		if(quantity _firewood == 0) then {
			deleteVehicle _firewood;
			_fireplace switchLight 'OFF';
			_fireplace setVariable ['fire',false];
		} else {
			_firewood setVariable ["fuel",500];
			_fireplace powerOn true;
		};
	} else {
		_fireplace switchLight 'OFF';
		_fireplace setVariable ['fire',false];
	}
};

event_fnc_advanceModifier = {
	private["_newStage"];
	_newStage = _checkStages select _cStage;
	/*
	important! don't declare these values as private, as it uses its
	parents variables
	*/
	//is condition met?
	_condition = getText (_newStage >> "condition");
	_runEvent = _person call compile _condition;
	if (_runEvent) then
	{
		//save old notifier
		_oldNotifier = getArray (_cfgStage >> "notifier");
		
		//load new stage
		_cfgStage = _newStage;
		_cfgStages = _checkStages;
		//statusChat[format["Advancing too...%1 in ; %2",configName _cfgStage,_cfgStages],"colorFriendly"];
		//diag_log format["Stage change to: %1; duration: %2",(_cfgStage),getArray (_cfgStage >> "duration")];
		_remaining = getArray (_cfgStage >> "duration") call randomValue;
		_reminder = getArray (_cfgStage >> "cooldown") call randomValue;
		_stage = _cStage;
		_stageArray set [_cSerial,_stage];
		_modstates set [_i,[_stageArray,_remaining,_reminder]];
		
		//send an activation message
		call event_fnc_sendActvMessage;
		
		//save
		//call event_fnc_saveModifiers;
	};
	_runEvent
};

/*
	PLAYER FUNCTIONS
*/

player_fnc_roundsDistribute = {
	/*
	Used when distributing rounds amongst piles
	uses the _quantity , _person , _ammo, _parent parent variables
	*/
	private["_pile","_receiverQty","_exchanged","_max"];
	/*
	_max = 	getNumber (configFile >> "CfgVehicles" >> _ammo >> "stackedMax");
	if (_quantity <= 0) exitWith {};
	_pile = objNull;
	{
		if (_x isKindOf _ammo) then
		{
			//has a pile
			if (!(_x call fnc_isMaxQuantity)) then
			{
				_pile = _x;
				_receiverQty = quantity _pile;
				//process changes
				_exchanged = ((_receiverQty + _quantity) min _max) - _receiverQty;
				_receiverQty = _receiverQty + _exchanged;
				
				_pile addQuantity _exchanged;				
			};
		};
	} forEach itemsInCargo _parent;
	if (_quantity > 0) then 
	{
		_pile = [_ammo,_parent,_person] call player_addInventory;
		_pile setQuantity _quantity;
	};
	*/
	_magdmg = _this;
	_max = 	getNumber (configFile >> "CfgVehicles" >> _ammo >> "stackedMax");
	_sound = getText (configFile >> "CfgVehicles" >> _ammo >> "emptySound");
	if (_quantity > _max)then{
		_amam = floor (_quantity/_max);
		if(_amam < 8)then{
			for [{_x=0},{_x<_amam},{_x=_x+1}] do{
				_pile = [_ammo,_parent,_person] call player_addInventory;
				_pile setQuantity _max;
			};
			if(_amam*_max != _quantity)then{
				_pile = [_ammo,_parent,_person] call player_addInventory;
				_pile setQuantity (_quantity-(_amam*_max));
			};
			[_person,_sound] call event_saySound;
		};
	}else{
		_pile = [_ammo,_parent,_person] call player_addInventory;
		_pile setQuantity _quantity;
		[_person,_sound] call event_saySound;
	};
	//if unpacked ammo box is damaged pass it to ammo
	if(_magdmg != 0)then{
		_pile setDamage _magdmg;
	};
};

player_fnc_knockdown = {
	/*
		Used within the damage functionality to knock a player down
		can be easily commented out to be disabled
	*/
	private["_agent","_source","_pos1","_pos2"];
	_agent = _this select 0;
	_source = _this select 1;
	_pos1 = getPos _agent;
	_pos2 = getPos _source;
	_dir = ((_pos2 select 0) - (_pos1 select 0)) atan2 ((_pos2 select 1) - (_pos1 select 1));
	//_dir = _dir % 360;
	_dir = _dir - (getdir _agent); //subtract direction of unit
	
	if (_dir < 0) then {_dir = _dir + 360};
	if (_dir > 360) then {_dir = _dir - 360};
	
	_dir = _dir + 45;

	switch true do 
	{
		case (_dir < 90):
		{
			_agent playAction "KnockDownF";
		};
		case (_dir < 180):
		{
			_agent playAction "KnockDownR";
		};
		case (_dir < 270):
		{
			_agent playAction "KnockDownB";
		};
		case (_dir < 360):
		{
			_agent playAction "KnockDownL";
		};
	};
};
 
player_fnc_tickBlood = {
	private["_regen","_hungerOk","_thirstOk","_result"];
	/*
	_regen = _this;
	_hungerOk = _person getVariable ["hunger",0] < 0;
	_thirstOk = _person getVariable ["thirst",0] < 0;
	_result = 0;
	
	if (_hungerOk and _thirstOk) then
	{
		_result = (_person getVariable ["blood",5000]) + _regen;
		_result = _result min (_person getVariable ["health",5000]);
		_result = _result - (_person getVariable ["blood",5000]);
	};
	_result
	*/
};

player_fnc_tickHealth = {
	private["_regen","_hungerOk","_thirstOk","_result","_bloodOk"];
	/*
		Calculates how much health the player should regen
	*/
	_regen = _this;
	_hungerOk = _person getVariable ["hunger",0] < 0;
	_thirstOk = _person getVariable ["thirst",0] < 0;
	_health = _person getVariable ["health",5000];
	_bloodOk = _person getVariable ["blood",5000] >= _health;
	_result = 0;
	
	if (_hungerOk and _thirstOk and _bloodOk) then
	{
		_result = _regen;
	};
	_result
};

player_fnc_tickExposure = {
	private["_wci","_result","_items","_situations","_situation"];
	/*
		Calculates how much exposure should change
	*/	
	_result = 0;
	
	_items = itemsInInventory _agent;
	_damper = 0;
	_situations = ["heatReduction","coldReduction"];
	_situation = switch true do
	{
		case (windChill <= DZ_COOLING_POINT):	{1};		//cooling
		case (windChill):	{0};		//warming
	};
	
	//tally up damper based on clothing
	{
		private["_isClothing","_wetness","_change"];
		_isClothing = _x isKindOf "ClothingBase";
		if (_isClothing) then
		{
			_wetness = _x getVariable ["wet",0];
			
			_change = getNumber(configFile >> "cfgVehicles" >> typeOf _x >> (_situations select _situation));
			_damper = _damper + _change;
		};
	} forEach _items;
	
	_damper = 1 - ((_damper min 1) max 0);
	_wci = (windChill * _damper);
	
	//diag_log format["WCI: %1",(_wci)];
	//hintSilent str(_wci);
	_result
};

player_fnc_processStomach = {
	private["_person","_itemCfg","_itemClass","_energy","_water","_stomach","_scale"];
	/*
		Calculates how much total volume in the stomach should change based on energy/water used by player for actions or food/drink consumed by player
	*/	
	_person = _this select 0;
	_itemClass = _this select 1;
	_itemCfg = configFile >> "CfgVehicles" >> _itemClass;
	if (count _this > 2) then
	{
		_scale = _this select 2;
	}
	else
	{
		_scale = 1;
	};
	
	if (!isClass _itemCfg) exitWith {};
	
	//if (isNil "_scale") then {_scale = 1;hint "bing!";};
	
	_energy = _person getVariable ["energy",DZ_ENERGY]; // actual energy from all food and drink consumed
	_water = _person getVariable ["water",DZ_WATER]; // actual water from all food and drink consumed
	_stomach = _person getVariable ["stomach",DZ_STOMACH]; // actual volume in stomach
	_diet = _person getVariable ["diet",DZ_DIET]; // actual diet 
	
	_isFood = _itemClass isKindOf "FoodItemBase";
	_isDrink = _itemClass isKindOf "DrinksItemBase";
	_isMedicine = _itemClass isKindOf "MedicalItemBase";
	
	switch true do
	{
		case (_isFood or _isDrink):
		{
			// pull food and drink nutritions parameters from Nutrition class
			_nutritionConfig = _itemCfg >> "Nutrition";
			_totalVolume = getNumber (_nutritionConfig >> "totalVolume");
			_consumableWater = getNumber (_nutritionConfig >> "water");
			_consumableEnergy = getNumber (_nutritionConfig >> "energy");
			_consumableNutriIndex = getNumber (_nutritionConfig >> "nutritionalIndex");
			
			//statusChat [format ["D> energy:%1, water:%2, stomach:%3, scale:%4 (%5)",_energy,_water,_stomach,_scale,isNil "_scale"],""]; // debug: actual values of states
			
			// volume of portion actually eaten/drunk/used
			_portionVolume = _totalVolume * _scale; // ??Am I sure to get proper scale from actionOnSelf??
			
			// change energy
			_energyGathered = _consumableEnergy * _scale; // energy actually gathered from serving		
			_energy = _energy + _energyGathered;
			_person setVariable ["energy",_energy];
			
			// change water
			_waterGathered = _consumableWater * _scale; // water actually gathered from serving
			_water = _water + _waterGathered;
			_person setVariable ["water",_water];
			
			// change diet
			_dietGathered = _consumableNutriIndex * _scale * 0.01; // nutrients actually gathered from serving	
			_diet = (((9 * _diet) + _dietGathered) / 10) min 1; // diet formula (will be probably changed)
			_person setVariable ["diet",_diet];
			
			// change stomach volume
			_stomach = _stomach + _portionVolume;
			_person setVariable ["stomach",_stomach];
		};
		case _isMedicine:
		{
			_medicineConfig = _itemCfg >> "Medicine";
			_consumablePrevention = getNumber (_medicineConfig >> "prevention");
			
			// change diet
			_dietGathered = _consumablePrevention; // nutrients actually gathered from medicine
			_diet = (((4 * _diet) + _dietGathered) / 5) min 1; // diet formula (will be probably changed)
			_person setVariable ["diet",_diet];
		};
	};
};

player_vomit = {
	_agent = _this;
	if (_agent getVariable["vomiting",false]) exitWith {};
	_agent playAction ["PlayerCrouch",{_agent setVariable["vomiting",true]}];
	waitUntil {_agent getVariable["vomiting",true]};
	_agent playAction ["PlayerVomit",{_agent setVariable["vomiting",false]}];
	_energy = _agent getVariable ["energy",DZ_ENERGY]; // actual energy from all food and drink consumed
	_water = _agent getVariable ["water",DZ_WATER]; // actual water from all food and drink consumed
	_stomach = _agent getVariable ["stomach",DZ_STOMACH]; // actual volume in stomach
	
	if (_stomach > 100) then
	{
		_agent setVariable ["vomit",diag_tickTime];	//broadcasts vomit
		
		[_agent,"action_vomit"] call event_saySound;
		
		//remove contents
		
		_energy = (_energy - 600) max -1;

		_agent setVariable ["energy",_energy];	
		_stomach = 0;
		_agent setVariable ["stomach",_stomach];	
			
		_water = (_water - 1000);
		_agent setVariable ["water",_water];
	}
	else
	{
		//dry wretch
		
		//remove contents
		_agent setVariable ["stomach",0];
	};
};

/*

FISHING 

*/
//Checks whether player left fishing place and stops fishing minigame
fishing_event_add={
	_owner = _this select 0;
	fishingpos =  _this select 1;
	_owner addEventHandler ['AnimChanged','_owner=_this select 0;if(abs (((getPosATL _owner) select 0) - fishingpos) > 0.1)then{_owner call fishing_event_remove;itemInHands _owner powerOn false;}'];
};

fishing_event_remove={
	[_this,'You have moved and pulled the bait out of the water.','colorImportant'] call fnc_playerMessage;
	_this playAction 'cancelAction';
	_this removeAllEventHandlers 'AnimChanged';
};

// build_TentContainer = 
// {
// 	if ( isServer ) then
// 	{
// 		_tent = (_this select 0);
// 		_person = (_this select 1);
// 		_tentType = (_this select 2) select 0;
// 		_tentOri = (_this select 2) select 1;
// 		_dist = (_this select 2) select 2;
// 		_tentSize = (_this select 3);
// 		_tentX = (_tentSize select 0) * 0.5;
// 		_tentY = (_tentSize select 1) * 0.5;
// 		_tentZ = (_tentSize select 2) * 0.5;

// 		_hp = damage (_this select 0);

// 		_pos = getPosASL _person;
// 		_ori = direction _person;
// 		_cosOri = cos _ori;
// 		_sinOri = sin _ori; 
// 		_xPos = (_pos select 0) + (sin _ori * _dist);
// 		_yPos = (_pos select 1) + (cos _ori * _dist);
// 		_zPos = (_pos select 2);
		
// 		_waterCheck = true;
// 		_heightCheck = true;

// 		_posTentX = _xPos + _cosOri * _tentX - _sinOri * _tentY;
// 		_posTentY = _yPos + _cosOri * _tentY + _sinOri * _tentX;
		
// 		_height = surfaceHeightASL [_posTentX, _posTentY, _zPos + 0.2];
// 		_sur = surfaceTypeASL [_posTentX, _posTentY, _zPos + 0.2];

// 		if ( _height > 1.5 || _height < -0.2 ) then
// 		{
// 			_heightCheck = false;
// 		};

// 		if ( _sur == "FreshWater" || _sur == "sea") then
// 		{
// 			_waterCheck = false;
// 		};

// 		if ( _heightCheck && _waterCheck ) then
// 		{
// 			_posTentX = _xPos + _cosOri * _tentX - _sinOri * -_tentY;
// 			_posTentY = _yPos + _cosOri * -_tentY + _sinOri * _tentX;
			
// 			_height = surfaceHeightASL [_posTentX, _posTentY, _zPos + 0.2];
// 			_sur = surfaceTypeASL [_posTentX, _posTentY, _zPos + 0.2];
			
// 			if ( _height > 1.5 || _height < -0.2 ) then
// 			{
// 				_heightCheck = false;
// 			};

// 			if ( _sur == "FreshWater" || _sur == "sea") then
// 			{
// 				_waterCheck = false;
// 			};	
// 		};

// 		if ( _heightCheck && _waterCheck ) then
// 		{
// 			_posTentX = _xPos + _cosOri * -_tentX - _sinOri * -_tentY;
// 			_posTentY = _yPos + _cosOri * -_tentY + _sinOri * -_tentX;
			
// 			_height = surfaceHeightASL [_posTentX, _posTentY, _zPos + 0.2];
// 			_sur = surfaceTypeASL [_posTentX, _posTentY, _zPos + 0.2];
			
// 			if ( _height > 1.5 || _height < -0.2 ) then
// 			{
// 				_heightCheck = false;
// 			};
			
// 			if ( _sur == "FreshWater" || _sur == "sea") then
// 			{
// 				_waterCheck = false;
// 			};	
// 		};

// 		if ( _heightCheck && _waterCheck ) then
// 		{
// 			_posTentX = _xPos + _cosOri * -_tentX - _sinOri * _tentY;
// 			_posTentY = _yPos + _cosOri * _tentY + _sinOri * -_tentX;
			
// 			_height = surfaceHeightASL [_posTentX, _posTentY, _zPos + 0.2];
// 			_sur = surfaceTypeASL [_posTentX, _posTentY, _zPos + 0.2];

// 			if ( _height > 1.5 || _height < -0.2 ) then
// 			{
// 				_heightCheck = false;
// 			};

// 			if ( _sur == "FreshWater" || _sur == "sea") then
// 			{
// 				_waterCheck = false;
// 			};	
// 		};
		
// 		//boundingBox
// 		//_bCenter = boundingCenter TentMedium_Pitched;

// 		if ( _heightCheck ) then
// 		{
// 			if ( _waterCheck ) then
// 			{
// 				//check slope
// 				_terrainNormal = RoadWayNormalAsl [_xPos, _yPos, _pos select 2];
// 				_terrainSlope = atg(sqrt((_terrainNormal select 0)*(_terrainNormal select 0) + (_terrainNormal select 1)*(_terrainNormal select 1))/(_terrainNormal select 2) );

// 				if ( _terrainSlope < 20 ) then
// 				{
// 					 //test collision
// 					 _bbox = (collisionBox [[_xPos, _yPos, _zPos + _tentZ + 0.2 ], _tentSize ,[vectorDir _person, RoadWayNormalAsl [_xPos, _yPos, _zPos]], [_person, _tent]]);
// 					 if ( !_bbox ) then
// 					 {
// 						_tent = _tentType createVehicle [_xPos, _yPos];
// 						_tent setPosASL [_xPos, _yPos, _pos select 2];
// 						_tent setDir _ori - _tentOri;
// 						_tent setDamage _hp;
						
// 						_cutter = objNull;
// 						if (_tentType == "TentLarge_Pitched" ) then
// 						{
// 							_cutter = "Tent_Large_ClutterCutter" createVehicle [_xPos, _yPos]; // it can be better always on a ground 
// 						};
// 						if (_tentType == "TentMedium_Pitched" ) then
// 						{
// 							_cutter = "Tent_ClutterCutter" createVehicle [_xPos, _yPos]; // it can be better always on a ground 
// 						};

// 						_cutter setDir getDir _tent;

// 						deleteVehicle (_this select 0);
// 					 }
// 					 else
// 					 {
// 						[_person,'I can not pitch the tent, there is not enough space!','colorImportant'] call fnc_playerMessage;
// 					 };
// 				}
// 				else
// 				{
// 					[_person,'I can not pitch the tent, the slope is too steep!','colorImportant'] call fnc_playerMessage;		
// 				};
// 			}
// 			else
// 			{
// 				[_person,'I can not pitch the tent in the water!','colorImportant'] call fnc_playerMessage;
// 			};
// 		}
// 		else
// 		{
// 			[_person,'I can not pitch the tent on place like this!','colorImportant'] call fnc_playerMessage;		
// 		};
// 	};
// };

pack_TentContainer = 
{
	if ( isServer ) then
	{
		deleteVehicle nearestobject [_this select 0, "Tent_ClutterCutter"]; // delete cutter

		_hp = damage (_this select 0);
		deleteVehicle (_this select 0);

		_person = (_this select 1);
		_tent = [(_this select 2),_person] call player_addInventory;
		_tent setDamage _hp;
	};
};

player_drown = {
	_agent = _this select 0;
	_branch = _this select 1;
	_dmg = _agent getVariable ["underwater",0];
	if(_branch == 0)then{
		if(_dmg > 0)then{
			_agent setVariable ["underwater",0];
		};
	}else{
		_dmg = _dmg + 1;
		if(_dmg > 30)then{_agent setDamage 1;}else{
			if(_dmg > 27)then{[_agent,"I am drowning","colorImportant"] call fnc_playerMessage;
				if (isPlayer _agent) then
				{
					effectDazed = true;
					(owner _agent) publicVariableClient "effectDazed";
				};
			}else{
				if(_dmg > 23)then{[_agent,"I am going to drown","colorImportant"] call fnc_playerMessage;}else{
					if(_dmg > 15)then{[_agent,"I am running out of air",""] call fnc_playerMessage;};
				};
			};
		};
		_agent setVariable ["underwater",_dmg];
	};
};


//Returns global X,Y pos according to given offset and direction
fnc_getRelativeXYPos = {
	_x = (_this select 0) select 0;
	_y = (_this select 0) select 1;
	_offsetX = (_this select 1) select 0;
	_offsetY = (_this select 1) select 1;
	_dir = _this select 2;
	
	_xPos = _x + (sin _dir * _offsetX);
	_yPos = _y + (cos _dir * _offsetX);
	_xPos = _xPos + (sin (_dir+90) * _offsetY);
	_yPos = _yPos + (cos (_dir+90) * _offsetY);
	[_xPos, _yPos];
};

/*
	Adds quantity to given item and keeps it within its limits.
	Negative parameter is supported and the item is automatically deleted when its quantity is <= 0
	Return value is resulted quantity
	[_item, _addedQuantity] call fnc_addQuantity
*/
fnc_addQuantity = {
	_item = _this select 0;
	_amount = _this select 1;
	_resultedQuantity = quantity _item + _amount;
	if (_resultedQuantity > 0) then {
		if (_resultedQuantity > maxQuantity _item) then {
			_resultedQuantity = maxQuantity _item;
		};
		_item setQuantity _resultedQuantity;
		_resultedQuantity;
	}else{ //Delete empty items
		deleteVehicle _item;
		_resultedQuantity;
	};
};

/*
	Adds multiple items of the same type into the user's inventory
	[_itemType, _itemCount, _user] call fnc_addItemCount;
*/
fnc_addItemCount = {
	_itemType = _this select 0;
	_itemCount = _this select 1;
	_user = _this select 2;
	while {_itemCount > 0} do
	{
		_itemCount = _itemCount - 1;
		_item = [_itemType, _user] call player_addInventory;
		_item setQuantity maxQuantity _item;
	};
};
