diag_log "Arrived at redirected dbLoadPlayer";
dbLoadHost;	//loads the hostname

DZ_spawnparams = [
  1 / 7.0,      // SPT_gridDensity
  35.0,         // SPT_gridWidth
  35.0,         // SPT_gridHeight
   4.0,         // SPT_minDist2Water
  20.0,         // SPT_maxDist2Water
  30.0,         // SPT_minDist2Zombie
  70.0,         // SPT_maxDist2Zombie
  25.0,         // SPT_minDist2Player
  70.0,         // SPT_maxDist2Player
   0.5,         // SPT_minDist2Static
  30.0,         // SPT_maxDist2Static
  -0.785398163, // SPT_minSteepness
  +0.785398163  // SPT_maxSteepness
];

DZ_spawnQuad0 = 
  [ [13608.1,   6062.31,    0.0014],
    [13587.1,   6095.31,   -0.27]  ,
    [13556.5,   6071.73,    0.0014],
    [13570.5,   6036.73,    0.0014]
  ];

DZ_posbubbles = [
  [ 9765.67 , 1749.21 , 0.00176013]  ,
  [ 10544.3 , 2003.19 , 0.000682116] ,
  [ 11076.8 , 2619.9  , 0.0010798]   ,
  [ 11998   , 3400.88 , 0.00117755]  ,
  [ 13502.3 , 3905.05 , 0.000827312] ,
  [ 13417.7 , 5449.19 , 0.00129318]  ,
  [ 7118.22 , 7652.72 , 0.00143433]  ,
  DZ_spawnQuad0,
  [ 13314.1 , 7041.18 , 0.00136793]  ,
  [ 13115.5 , 7638.63 , 0.00145864]  ,
  [ 13526.9 , 5096.7  , 0.00142241]  ,
  [ 11569   , 3144.31 , 0.00150204]  ,
  [ 11998.6 , 3780.79 , 0.00128365]  ,
  [ 13362.8 , 5900.33 , 0.00143862]  ,
  [ 13460.8 , 6598.57 , 0.001423]    ,
  [ 12947.5 , 8593.1  , 0.00133133]  ,
  [ 12900.6 , 9051.97 , 0.0013895]   ,
  [ 13018.1 , 9465.4  , 0.00140357]  ,
  [ 13312.2 , 5422.35 , 0.00149441]
];
 
_createPlayer = 
{
	//check database
	_savedChar = dbFindCharacter _uid;
	_isAlive = _savedChar select 0;
	_pos = [_savedChar select 1,_savedChar select 2,_savedChar select 3];
	_idleTime = _savedChar select 4;
	
	//process client
	[_id,_isAlive,_pos,overcast,rain] spawnForClient {
		titleText ["","BLACK FADED",10e10];
		diag_log str(_this);
		playerQueueVM = _this call player_queued;


		0 setOvercast (_this select 4);
		simulSetHumidity (_this select 4);
		0 setRain (_this select 5);
	};
};

//DISCONNECTION PROCESSING
_disconnectPlayer =
{
	if ((lifeState _agent == "ALIVE") and (not captive player)) then
	{
		_agent call dbSavePlayerPrep;
		dbServerSaveCharacter _agent;
		deleteVehicle _agent;
	}
	else
	{
		dbKillCharacter _uid;
	};
};

// Create player on connection
onPlayerConnecting _createPlayer;
onPlayerDisconnected _disconnectPlayer;

"clientReady" addPublicVariableEventHandler
{
	_id = _this select 1;
	_uid = getClientUID _id;
	diag_log format["Player %1 ready to load previous character",_uid];
	_handler = 
	{ 
		if (isNull _agent) then 
		{ 
			//this should never happen!
			diag_log format["Player %1 has no agent on load, kill character",_uid];
			_id statusChat ["Your character was unable to be loaded and has been reset. A system administrator has been notified. Please reconnect to continue.","ColorImportant"];
			dbKillCharacter _uid;
		}
		else
		{
			call init_newBody;
		};
	}; 
	_id dbServerLoadCharacter _handler;		
};

"respawn" addPublicVariableEventHandler
{
	_agent = _this select 1;
	
	diag_log format ["CLIENT request to respawn %1 (%2)",_this,lifeState _agent];
	
	if (lifeState _agent != "ALIVE") then
	{
		//get details
		_id = owner _agent;
		_uid = getClientUID _id;
		_agent setDamage 1;
		
		//process client
		[_id,false,[0,0,0]] spawnForClient {
			titleText ["Respawning... Please wait...","BLACK FADED",10e10];
			diag_log str(_this);
			playerQueueVM = _this call player_queued;
		};
	};
};

"clientNew" addPublicVariableEventHandler
{
	_array = _this select 1;
	_id = _array select 2;
	diag_log format ["CLIENT %1 request to spawn %2",_id,_this];
	///_id spawnForClient {statusChat ['testing 1 2 3','']};
	
	_savedChar = dbFindCharacter (getClientUID _id);

	// if (_savedChar select 0) exitWith {
	// 	diag_log format ["CLIENT %1 spawn request rejected as already alive character",_id];
	// };
		
	_charType = _array select 0;
	_charInv = _array select 1;
    //_pos = findCachedSpawnPoint [ DZ_spawnpointsfile, DZ_spawnpass3params ];
	_pos = [2260.8, 5083.73, 0.0003];
	
	//load data
	_top = getArray(configFile >> "cfgCharacterCreation" >> "top");
	_bottom = getArray(configFile >> "cfgCharacterCreation" >> "bottom");
	_shoe = getArray(configFile >> "cfgCharacterCreation" >> "shoe");
	
	_myTop = _top select (_charInv select 0);
	_myBottom = _bottom select (_charInv select 1);
	_myShoe = _shoe select (_charInv select 2);
	_mySkin = DZ_SkinsArray select _charType;
	
	_uid = getClientUID _id;
	_res1 = dbCreateCharacter _uid;
	
	diag_log format["SERVER: Creating %1 at %2 for clientId %3 (DB result %4)",_mySkin,_pos,_id,_res1];
	
	_agent = createAgent [_mySkin,  _pos, [], 0, "NONE"];
	{null = _agent createInInventory _x} forEach [_myTop,_myBottom,_myShoe];
	_v = _agent createInInventory "tool_flashlight";
	_v = _agent createInInventory "Medical_Bandage";_v setVariable ["quantity",100];
	_v = _agent createInInventory "M4A1";
	_v = _agent createInInventory "TentMedium_Packed";
	_v = _agent createInInventory "BagHunting";
	_v = _agent createInInventory "BallisticHelmet_Black";
	_v = _agent createInInventory "M_STANAG_30Rnd";
	_v = _agent createInInventory "M_STANAG_30Rnd";
	_v = _agent createInInventory "M_STANAG_30Rnd";
	_v = _agent createInInventory "TTsKO_Jacket_Camo";
	_v = _agent createInInventory "TTsKO_Pants_Camo";
	_v = _agent createInInventory "UKAssVest_Black";
	_v = _agent createInInventory "Att_Buttstock_M4MP_Black";
	_v = _agent createInInventory "Att_Handguard_MP";
	_v = _agent createInInventory "Att_Optic_ACOG";
	_v = _agent createInInventory "Attachment_Suppressor_556";
	_v = _agent createInInventory "CombatKnife";
	_v = _agent createInInventory "Consumable_GasCanisterLarge";_v setVariable ["quantity",100];
	_v = _agent createInInventory "Consumable_Roadflare";_v setVariable ["quantity",100];
	_v = _agent createInInventory "Container_FirstAidKit";
	_v = _agent createInInventory "Cooker_PortableStove";
	_v = _agent createInInventory "Cookware_FryingPan";
	_v = _agent createInInventory "TentMedium_Packed";
	_v = _agent createInInventory "Consumable_Matchbox";_v setVariable ["quantity",100];
	_v = _agent createInInventory "Magnum";
	_v = _agent createInInventory "Ammo_357_20Rnd";
	_agent call init_newPlayer;
	call init_newBody;
};
