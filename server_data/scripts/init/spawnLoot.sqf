_cfgClasses = configFile >> "CfgVehicles";
_cfgBuildings = [];
_counted = 0;
_total = ((count _cfgClasses) - 1);
displayMe = "";
for "_i" from 0 to _total do 
{
	_config = (_cfgClasses select _i);
	if (isClass _config) then {	
		if (isClass (_config >> "spawns")) then {
			_addMe = false;
			_cfgSpawns = (_config >> "spawns");
			_countSpawns = ((count _cfgSpawns) - 1);
			for "_ii" from 0 to _countSpawns do 
			{
				_configSpawn = (_cfgSpawns select _ii);
				_locationCount = count(getArray(_configSpawn >> "locations"));
				if (_locationCount > 0) then {
					_addMe = true;
				};
			};
			if (_addMe) then {
				_name = configName _config;
				_cfgBuildings set [(count _cfgBuildings),_name];
			};
		};
	};
	if (!isDedicated) then {
		progressLoadingScreen (_i/_total);
	};
};
_cfgBuildings = _cfgBuildings - ["HouseBase"];
_nearby = nearestObjects [DZ_SpawnCenter,_cfgBuildings,2000];
_last = [];
{
	_x call building_spawnLoot;
} forEach _nearby;
