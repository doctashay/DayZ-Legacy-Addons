dbLoadHost;	//loads the hostname

DZ_spawnpass3params = [
  30.0,         // S3T_minDist2Zombie
  70.0,         // S3T_maxDist2Zombie
  25.0,         // S3T_minDist2Player
  70.0,         // S3T_maxDist2Player
   0.5,         // SPT_minDist2Static
   2.0          // SPT_maxDist2Static
];
DZ_spawnpointsfile = "spawnpoints_players.bin";

_createPlayer = 
{
	//check database
	
	diag_log format["CONNECTION: _id: %1 _uid: %2 _name: %3",_id,_uid,_name];
	
	_savedChar = dbFindCharacter _uid;
	_isAlive = _savedChar select 0;
	_isOnline = _savedChar select 1;
	_pos = [_savedChar select 2,_savedChar select 3,_savedChar select 4];
	_idleTime = _savedChar select 5;
	
	if (!_isOnline) then
	{
		diag_log format["WARNING: No connection to HIVE. Player %1 could not be loaded.",_uid];
	};
	
	//process client
	[_id,_isAlive,_pos,overcast,rain,_isOnline,_idleTime] spawnForClient {
		titleText ["","BLACK FADED",10e10];
		diag_log str(_this);
		playerQueueVM = _this call player_queued;
	};
};

//DISCONNECTION PROCESSING
_disconnectPlayer =
{
	if (!isNull _agent) then
	{
		call dbSavePlayer;
		_vm = [_uid,_agent] spawn 
		{
			_uid = _this select 0;
			_agent = _this select 1;
			_connected = diag_tickTime - (_agent getVariable ["starttime",diag_tickTime]);
			diag_log format ["DISCONNECT: Player %1 agent %2 after %3 seconds",_uid,_agent,_connected];
			_hands = itemInHands _agent;
			_vs = DBSetQueue [_uid,33]; // 33 sec default queue for disconnecting
			sleep 1;
			_agent playAction "SitDown";		
			sleep 30;		
			call dbSavePlayer;
			if (alive _agent) then
			{
				/*
				if (!isNull _hands) then
				{
					moveToGround _hands;
					deleteVehicle _hands;
				};
				*/
				deleteVehicle _agent;
			};
		};
	};
};

// Create player on connection
onPlayerConnecting _createPlayer;
onPlayerDisconnected _disconnectPlayer;
/*
"CLIENT request to respawn ["respawn",SurvivorPartsMaleWhite:2:11874] (UNCONSCIOUS)"
WARNING: Function 'name' - Hicks_206 is dead
WARNING: Function 'name' - Hicks_206 is dead
"Player Hicks_206 was killed by Hicks_206"
Saving array to database: type Any is not supported
"CLIENT 3 request to spawn ["clientNew",[7,[1,0,0],3]]"
"CLIENT 3 spawn request rejected as already alive character"

*/


"clientReady" addPublicVariableEventHandler
{
	_vm = _this spawn {
		_id = _this select 1;
		_uid = getClientUID _id;
		_wait = (dbFindCharacter _uid) select 5;
		_wait = (-_wait) max 0;
		diag_log format["Player %1 ready to load previous character, waiting %2 seconds",_uid,_wait];
		sleep _wait;
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
		dbKillCharacter _uid;
		
		diag_log format ["CLIENT killed character %1 (clientId %2 / Unit %2)",_uid,_id,lifeState _agent];
		
		//process client
		[_id,false,position _agent,overcast,rain,true,-30] spawnForClient {
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
	_id spawnForClient {statusChat ['testing 1 2 3','']};
	
	_savedChar = dbFindCharacter (getClientUID _id);
	if (_savedChar select 0) exitWith {
		diag_log format ["CLIENT %1 spawn request rejected as already alive character",_id];
	};
		
	_charType = _array select 0;
	_charInv = _array select 1;
    _spawnPos = DZ_posbubbles select (floor (random (count DZ_posbubbles))); 
    _pos = [_spawnPos select 0, _spawnPos select 1, _spawnPos select 2]; 
	//_pos = [3590.96,8492.23,0];
	
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
	_v = _agent createInInventory "consumable_battery9V";_v setVariable ["power",30000];
	_agent call init_newPlayer;
	call init_newBody;
	
	diag_log format["SERVER: Created %1 for clientId %2",_agent,_id];
};