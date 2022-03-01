if (false) then {}; //--- ToDo: Check when hub is not initialized

_mode = [_this,0,"",[""]] call bis_fnc_param;

_meta = [] call bis_fnc_hubmissionMeta;
_hub = _meta select 1;
_skirmish = _meta select 2;

switch _mode do {

	//--- Create hub area
	case "INIT": {
		private ["_initPos","_area","_areaBuffer","_areaPresence","_buggerCoef"];

		//--- Neither hub nor skirmish - ignore
		if (!_hub && !_skirmish) exitwith {
			bis_fnc_hubSkirmish_player = nil;
			savevar "bis_fnc_hubSkirmish_player";
		};

		//--- Mission is hub
		if (_hub) then {
			waituntil {!isnull player};
			_initPos = [_this,1,position player] call bis_fnc_param;
			_area = [_this,2,[200,200,0,false],[[]]] call bis_fnc_param;
			_bufferCoef = [_this,3,0.9,[0]] call bis_fnc_param;
			_initPos = _initPos call bis_fnc_position;

			//--- Set buffer and end zone sizes
			_areaBuffer = [
				(_area select 0) * _bufferCoef,
				(_area select 1) * _bufferCoef,
				_area select 2,
				_area select 3
			];
			_areaPresence = "NOT PRESENT";

			//--- Save pos and area to be used in actual skirmish later
			bis_fnc_hubSkirmish_pos = _initPos;
			savevar "bis_fnc_hubSkirmish_pos";
			bis_fnc_hubSkirmish_area = _area;
			savevar "bis_fnc_hubSkirmish_area";
			bis_fnc_hubSkirmish_bufferCoef = _bufferCoef;
			savevar "bis_fnc_hubSkirmish_bufferCoef";
		} else {

			//--- Mission is skirmish
			if (_skirmish) then {
				_initPos = bis_fnc_hubSkirmish_pos;
				_area = bis_fnc_hubSkirmish_area;
				_bufferCoef = bis_fnc_hubSkirmish_bufferCoef;

				//--- Set buffer and end zone sizes
				_areaBuffer = _area;
				_area = [
					(_area select 0) * _bufferCoef,
					(_area select 1) * _bufferCoef,
					_area select 2,
					_area select 3
				];
				_areaPresence = "PRESENT";
			};
		};

		//--- Error - no variables
		if (isnil "bis_fnc_hubSkirmish_pos") exitwith {"Variable 'bis_fnc_hubSkirmish_pos' does not exist. Hub mission has to be played before Skirmish is started." call bis_fnc_error;};
		if (isnil "bis_fnc_hubSkirmish_area") exitwith {"Variable 'bis_fnc_hubSkirmish_area' does not exist. Hub mission has to be played before Skirmish is started." call bis_fnc_error;};
		if (isnil "bis_fnc_hubSkirmish_bufferCoef") exitwith {"Variable 'bis_fnc_hubSkirmish_bufferCoef' does not exist. Hub mission has to be played before Skirmish is started." call bis_fnc_error;};

		//--- Mark the area in map
		_marker = createmarker ["bis_fnc_hubSkirmish_area",_initPos];
		_marker setmarkersize [_area select 0,_area select 1];
		_marker setmarkerdir (_area select 2);
		_shape = if (_area select 3) then {"rectangle"} else {"ellipse"};
		_marker setmarkershape _shape;
		_marker setmarkerbrush "border";
		_marker setmarkercolor "colororange";

		//--- Create trigger where mission ends
		_trig = createtrigger ["emptydetector",_initPos];
		_trig settriggerarea _area;
		_trig triggerattachvehicle [player];
		_trig settriggeractivation ["VEHICLE",_areaPresence,true];
		_trig settriggerstatements ["this","['END'] call bis_fnc_hubSkirmish",""];

		//--- Create trigger where player is warned about leaving the hub
		_trigBuffer = createtrigger ["emptydetector",_initPos];
		_trigBuffer settriggerarea _areaBuffer;
		_trigBuffer triggerattachvehicle [player];
		_trigBuffer settriggeractivation ["VEHICLE",_areaPresence,true];
		_trigBuffer settriggerstatements ["this","['WARN'] call bis_fnc_hubSkirmish",""];

		//--- Set player's position and delete it afterwards
		if (isnil "bis_fnc_hubSkirmish_player") then {
			if (_skirmish) then {
				_playerPos = [_initpos,_areaBuffer select 1,0] call bis_fnc_relpos;
				_playerDir = [_initPos,_playerPos] call bis_fnc_dirto;
				vehicle player setpos _playerPos;
				vehicle player setdir _playerDir;

			};
		} else {
			vehicle player setpos (bis_fnc_hubSkirmish_player select 0);
			vehicle player setdir (bis_fnc_hubSkirmish_player select 1);
		};

		//--- Once player is moved, initiate the triggers
		//bis_fnc_hubSkirmish_player = nil;
		//savevar "bis_fnc_hubSkirmish_player";
	};

	//--- Warn player about leaving the area
	case "WARN": {
		if (_hub) then {
			hint "You're about to leave the base and start skirmish. If it's not your intention, return back to base.";
		} else {
			hint "You're about to enter the base and end skirmish. If it's not your intention, return back.";
		};
	};

	//--- End the mission when leaving the area
	case "END": {
		_links = getarray ((_meta select 0) >> "links");
		_endMission = "";
		_endMissionType = if (_hub) then {2} else {1};
		{
			if ((_x call bis_fnc_hubmissionMeta) select _endMissionType) exitwith {_endMission = _x;};
		} foreach _links;
		_endMission call bis_fnc_endmission;

		bis_fnc_hubSkirmish_player = [position vehicle player,direction vehicle player];
		savevar "bis_fnc_hubSkirmish_player";
	};
};