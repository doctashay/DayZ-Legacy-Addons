// _cfgSpawnGroups = configFile >> "CfgSpawns" >> "ServerEventsSpawns";
// _rawCnt = count _cfgSpawnGroups;
// _groupsCnt = 0;
// _groups = [];

// _event = "";
// _events = [];
// _eventsCnt = 0;
// _ranCnt = 0;

// _position = [];

// //zjisti pocet group eventu
// for "_i" from 0 to _rawCnt - 1 do
// {
// 	_entry = _cfgSpawnGroups select _i;
// 	if ( isClass _entry ) then
// 	{
// 		_groupsCnt = _groupsCnt + 1;
// 		_groups set [ count _groups, configName _entry];
// 	};
// };
// _i = 0;

// groupsEvents = _groups;

// //if ( _groupsCnt > 0 ) then
// {
// 	diag_log format ["_forEachIndex = %1", _forEachIndex ];
// 	_events = [];
// 	_usedPositions = [];
// 	_cfgEventsCnt = 0;
// 	_cfgEventsRaw = (_cfgSpawnGroups >> _x );
// 	_i = 0;
// 	_s = 0;

// 	//zjisti pocet eventu
// 	for "_i" from 0 to (count _cfgEventsRaw) - 1 do
// 	{
// 		_entry = _cfgEventsRaw select _i;
// 		if ( isClass _entry ) then
// 		{
// 			_cfgEventsCnt = _cfgEventsCnt + 1;
// 			_events set [ count _events, configName _entry];
// 		};
// 	};
	
// 	if ( _cfgEventsCnt > 0 ) then 
// 	{
// 		_cfgMin = getNumber (_cfgSpawnGroups >> _x >> "minSpawn");
// 		_cfgMax = getNumber (_cfgSpawnGroups >> _x >> "maxSpawn");
	
// 		_ranCnt = floor random ( _cfgMax - _cfgMin);
// 		_ranCnt = _cfgMin + _ranCnt;
	
// 		if ( _ranCnt > 0 ) then
// 		{
// 			for "_s" from 0 to _ranCnt - 1 do 
// 			{
// 				_eventRnd = floor ( random _cfgEventsCnt);
// 				_event = _events select _eventRnd;

// 				_cfgLoc = getArray (_cfgSpawnGroups >> _x >> _event >> "locations");
// 				_cfgTypes = getArray (_cfgSpawnGroups >> _x >> _event >> "types");
				
// 				_indexLoc = floor( random (count _cfgLoc));
// 				_position =_cfgLoc select _indexLoc;
// 				_type = _cfgTypes select ( floor( random count _cfgTypes));
// 				//_sizeLoc = (count _cfgLoc ) - 1;
				
// 				_positionStr = format [ "%1", _position];
				
// 				if ( ! (_positionStr in _usedPositions) ) then 
// 				{
// 					DZ_TotalEvents = DZ_TotalEvents + 1;
// 					_spawnEvent = _type spawnProxyVehicle [_position, 0.05, 0.2, 0];
// 					//_spawnEvent addEventHandler ["init", { null = _this spawn init_wreck}];
// 					_text = format["Event Group: %4, Server Event: %1, Spawned At: %2, Vehicles No.: %3", _event, _position, _s, _x ];
// 					diag_log _text;
// 					_usedPositions set [ count _usedPositions, format [ "%1", _position] ];
// 				}
// 				else
// 				{
// 					_s = _s - 1;
// 				};
// 			};
// 		};
// 	};
// } forEach _groups;

// //_text = format["Server Event: %1, Spawned At: %2", _event, _position ];
// //diag_log _text;
