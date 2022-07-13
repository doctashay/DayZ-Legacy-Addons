_cfgSpawns = configFile >> "CfgSpawns" >> "ServerEventsSpawns";

_event = "";
_events = [];
_eventsCount = 0;
_ranCnt = 0;
_rawCnt = count _cfgSpawns;
_position = [];

for "_i" from 0 to _rawCnt - 1 do
{
	_entry = _cfgSpawns select _i;
	if ( isClass _entry ) then
	{
		_eventsCount = _eventsCount + 1;
		_events set [ count _events, configName _entry];
	};
};

if ( _eventsCount > 0 ) then
{
	_eventRnd = floor ( random _eventsCount);
	_event = _events select _eventRnd;

	_cfgLoc = getArray (_cfgSpawns >> _event >> "locations");
	_cfgTypes = getArray (_cfgSpawns >> _event >> "types");

	_cfgMin = getNumber (_cfgSpawns >> _event >> "minSpawn");
	_cfgMax = getNumber (_cfgSpawns >> _event >> "maxSpawn");
	
	_ranCnt = floor random ( _cfgMax - _cfgMin);
	_ranCnt = _cfgMin + _ranCnt;
	
	if ( count _cfgLoc > 0 && count _cfgTypes > 0 && _ranCnt > 0 ) then
	{
		for "_s" from 0 to _ranCnt - 1 do 
		{
			_indexLoc = floor( random (count _cfgLoc));
			_position =_cfgLoc select _indexLoc;
			_type = _cfgTypes select ( floor( random count _cfgTypes));
			_sizeLoc = (count _cfgLoc ) - 1;

			if ( _sizeLoc >= 0 ) then 
			{
				DZ_TotalEvents = DZ_TotalEvents + 1;
				_spawnEvent = _type createVehicle [_position, 0.05, 0.2];
				//_spawnEvent addEventHandler ["init", { null = _this spawn init_wreck}];
				_text = format["Server Event: %1, Spawned At: %2, Vehicles No.: %3", _event, _position, _s ];
				diag_log _text;
				
				for "_int" from _indexLoc to _sizeLoc do
				{
					_cfgLoc set [ _int, _cfgLoc select (_int + 1) ];
				};

				_cfgLoc resize ( _sizeLoc );
			};
		};
	};
};

//_text = format["Server Event: %1, Spawned At: %2", _event, _position ];
//diag_log _text;
