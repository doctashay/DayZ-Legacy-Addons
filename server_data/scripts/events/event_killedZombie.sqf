private["_agent","_uid"];
_agent = _this select 0;
_killer = _this select 1;

_type = typeOf _agent;
_last_pos = getPosATL _agent;

//cleanup
_cleanup_delay = floor(random(60));
sleep _cleanup_delay;
deleteVehicle _agent;

_Z_spawnparams = [
  1 / 25.0,     // SPN_gridDensity
  400.0,        // SPN_gridWidth
  400.0,        // SPN_gridHeight
   4.0,         // SPN_minDist2Water
  20.0,         // SPN_maxDist2Water
   0.5,         // SPN_minDist2Static
  30.0,         // SPN_maxDist2Static
  -0.785398163, // SPN_minSteepness
  +0.785398163, // SPN_maxSteepness
  50.0,         // SPN_minDist2Zombie
 170.0,         // SPN_maxDist2Zombie
 125.0,         // SPN_minDist2Player
 270.0          // SPN_maxDist2Player
];

_pos = RespawnDeadNPC [ _last_pos, _Z_spawnparams ];

_types = getArray( configFile >> "CfgSpawns" >> "types");
_rnd = floor(random(count _types));

_zombie = createAgent [_types select _rnd, _pos, [], 1, "NONE"];
_zombie addeventhandler ["HandleDamage",{_this call event_hitZombie} ];
_zombie addeventhandler ["killed",{null = _this spawn event_killedZombie} ];
_zombie setDir floor(random 360);

if ((itemInHands _killer) isKindOf "DefaultWeapon") then
{
	_zombie reveal [_killer, 4];
};

diag_log format ["ZOMBIE DIED: %1, %2 spawned",_type,_zombie];
