_cfgSpawns = configFile >> "CfgSpawns";
DZ_ZombieTypes = getArray(_cfgSpawns >> "types");
fnc_spawnZombie = 
{
	_rnd = floor(random(count DZ_ZombieTypes));
	_zombie = createAgent [(DZ_ZombieTypes select _rnd),_this,[],0,"CAN_COLLIDE"];
	_zombie addeventhandler ["HandleDamage",{_this call event_hitZombie} ];
	_zombie addeventhandler ["killed",{null = _this spawn event_killedZombie} ];
	_zombie setDir floor(random 360);
	_zombie
};

_totalAreas = ((count _cfgSpawns) - 1);
DZ_TotalZombies = 0;
_posZ = 0;
for "_areaNum" from 0 to _totalAreas do 
{
	if (isClass (_cfgSpawns select _areaNum)) then
	{
		_cfgArea = (_cfgSpawns select _areaNum);
		_posZ = _posZ + count getArray(_cfgArea >> "locations");
	};
};
hint str(_posZ);
_chance = DZ_MAX_ZOMBIES / _posZ;

for "_areaNum" from 0 to _totalAreas do 
{
	if (isClass (_cfgSpawns select _areaNum)) then
	{
		//Get data
		_cfgArea = (_cfgSpawns select _areaNum);
		_areaName = (configName _cfgArea);
		_areaPos = getArray(_cfgArea >> "position");
		_radius = getNumber(_cfgArea >> "radius");
		_locations = getArray(_cfgArea >> "locations");
		
		//Spawn Zombies
		{
			if ((random 1 < _chance) and (DZ_TotalZombies < DZ_MAX_ZOMBIES)) then
			{
				DZ_TotalZombies = DZ_TotalZombies + 1;
				_zombie = _x call fnc_spawnZombie;
			};
		} forEach _locations;
	};
};
diag_log format["SPAWNED %1 ZOMBIES",DZ_TotalZombies];
/*
_pos = [(position player select 0),(position player select 1) + 10,0];
zombie1 = createAgent ["zombieJacketBrownNew",_pos,[],0,"CAN_COLLIDE"];
zombie1 setDir floor(random 360);
zombie1 enableSimulation false;
zombie1 setVariable ["home",_pos];
*/