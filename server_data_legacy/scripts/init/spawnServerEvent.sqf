_cfgSpawnGroups = configFile >> "CfgSpawns" >> "ServerEventsSpawns";
_rawCnt = count _cfgSpawnGroups;
_groupsCnt = 0;
_groups = [];

_event = "";
_events = [];
_eventsCnt = 0;
_ranCnt = 0;

_position = [];

//zjisti pocet group eventu
for "_i" from 0 to _rawCnt - 1 do
{
	_entry = _cfgSpawnGroups select _i;
	if ( isClass _entry ) then
	{
		_groupsCnt = _groupsCnt + 1;
		_groups set [ count _groups, configName _entry];
	};
};
_i = 0;

groupsEvents = _groups;

//if ( _groupsCnt > 0 ) then
{
	//diag_log format ["_forEachIndex = %1", _forEachIndex ];
	_events = [];
	_usedPositions = [];
	_cfgEventsCnt = 0;
	_cfgEventsRaw = (_cfgSpawnGroups >> _x );
	_i = 0;
	_s = 0;

	//zjisti pocet eventu
	for "_i" from 0 to (count _cfgEventsRaw) - 1 do
	{
		_entry = _cfgEventsRaw select _i;
		if ( isClass _entry ) then
		{
			_cfgEventsCnt = _cfgEventsCnt + 1;
			_events set [ count _events, configName _entry];
		};
	};
	
	if ( _cfgEventsCnt > 0 ) then 
	{
		_cfgMin = getNumber (_cfgSpawnGroups >> _x >> "minSpawn");
		_cfgMax = getNumber (_cfgSpawnGroups >> _x >> "maxSpawn");
	
		_ranCnt = floor random ( (_cfgMax + 1) - _cfgMin);
		_ranCnt = _cfgMin + _ranCnt;
	
		diag_log format ["eventGroup :: %1, _events :: %2, _ranCnt :: %3", _x, _events, _ranCnt];
		if ( _ranCnt > 0 ) then
		{
			for "_s" from 0 to _ranCnt - 1 do
			{
				_eventRnd = floor ( random _cfgEventsCnt);
				_event = _events select _eventRnd;

				diag_log format ["_event :: %1", _event];
				
				_cfgLoc = getArray (_cfgSpawnGroups >> _x >> _event >> "locations");
				_cfgTypes = getArray (_cfgSpawnGroups >> _x >> _event >> "types");
				
				_indexLoc = floor( random (count _cfgLoc));
				_selectedPos = _cfgLoc select _indexLoc;
				_arrayElements = count _selectedPos;

				_position = [_selectedPos select 0, _selectedPos select 1];
				_angle = random( 3.6 );
				_angle = _angle * 100;

				if ( _arrayElements > 2 ) then
				{
					_angle = _selectedPos select 2;
				};

				_type = _cfgTypes select ( floor( random count _cfgTypes));
				_positionStr = format [ "%1", _position];
				diag_log format ["_usedPositions :: %1", _usedPositions];
				diag_log format ["_positionStr :: %1", _positionStr];
				
				// if ( ! (_positionStr in _usedPositions) ) then 
				// {
				// 	DZ_TotalEvents = DZ_TotalEvents + 1;
				// 	_spawnType = getText (_cfgSpawnGroups >> _x >> _event >> "spawnType");
				// 	if ( _spawnType == "Loot") then
				// 	{
				// 		_spawnEvent = _type spawnProxyVehicle [_position, 0.05, 0.2, _angle];
				// 	};

				// 	if ( _spawnType == "Vehicle") then
				// 	{
				// 		_spawnEvent = _type createVehicle _position;
				// 		_spawnEvent setDir _angle;
				// 		_spawnEvent setFuel 0.2;
				// 	};					

				// 	_usedPositions set [ count _usedPositions, _positionStr ];
				// 	//*DON'T WORKING RIGHT NOW
				// 	//random from half hour to hour to delete vehicles
				// 	//_deleteTime = floor random (3);
				// 	//_deleteTime = _deleteTime + 3;
				// 	//_deleteTime = _deleteTime * 3600;
				// 	// _spawnEvent addeventhandler ["init",{sleep _deleteTime; deleteVehicle _this} ]; 
				// }
				// else
				// {
				// 	_s = _s - 1;
				// };
			};
			//------------
/* Nebo jinak
			_s = 0;
			diag_log "Test1";
			while { _ranCnt < _s } do
			{
				diag_log "Test2";
				_eventRnd = floor ( random _cfgEventsCnt);
				_event = _events select _eventRnd;

				diag_log format ["_event :: %1", _event];
				
				_cfgLoc = getArray (_cfgSpawnGroups >> _x >> _event >> "locations");
				_cfgTypes = getArray (_cfgSpawnGroups >> _x >> _event >> "types");
				
				_indexLoc = floor( random (count _cfgLoc));
				_selectedPos = _cfgLoc select _indexLoc;
				_arrayElements = count _selectedPos;

				//setting pos and angle
				_position = [_selectedPos select 0, _selectedPos select 1];
				_angle = random( 3.6 );
				_angle = _angle * 100;

				if ( _arrayElements > 2 ) then
				{
					_angle = _selectedPos select 2;
				};

				_type = _cfgTypes select ( floor( random count _cfgTypes));
				_positionStr = format [ "%1", _position];
				diag_log format ["_usedPositions :: %1", _usedPositions];
				diag_log format ["_positionStr :: %1", _positionStr];
				
				if ( ! (_positionStr in _usedPositions) ) then 
				{
					DZ_TotalEvents = DZ_TotalEvents + 1;
					_s = _s + 1;
					_spawnEvent = _type spawnProxyVehicle [_position, 0.05, 0.2, _angle];
					_usedPositions set [ count _usedPositions, _positionStr ];
				};
			};
*/
			
		};
	};
} forEach _groups;

_text = format["Server Event: %1, Spawned At: %2", _event, _position ];
diag_log _text;
