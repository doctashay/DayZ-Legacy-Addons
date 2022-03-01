/*
	Author: Thomas Ryan
	
	Description:
	Initialize Hub systems.
*/

[] spawn {
	scriptName "BIS_fnc_hubInit: hub init";
	
	private ["_isEnabled"];
	_isEnabled = getNumber (campaignConfigFile >> "campaign" >> "enableHub") > 0;
	if (!(_isEnabled)) exitWith {};
	
	if (isMultiplayer) exitWith {"Hub systems are not multiplayer compatible" call BIS_fnc_error};
	
	// Player returns null in intros/outros
	if (isNull player) exitWith {};
	
	// Build list of all missions with states
	if (isNil "BIS_missions") then {
		BIS_missions = [];
		
		private ["_missionsCfg"];
		_missionsCfg = campaignConfigFile >> "campaign" >> "missions";
		
		for "_i" from 0 to (count _missionsCfg - 1) do {
			private ["_mission"];
			_mission = _missionsCfg select _i;
			
			if (isClass _mission) then {
				private ["_missionName"];
				_missionName = configName _mission;
				
				BIS_missions set [count BIS_missions, _missionName];
				
				missionNamespace setVariable [_missionName, false];
				saveVar _missionName;
			};
		};
		
		saveVar "BIS_missions";
	};
	
	// Set date
	if (!(isNil "BIS_PER_date")) then {setDate BIS_PER_date};
	
	// Set position & direction
	private ["_missionMeta", "_isSkirmish"];
	_missionMeta = [] call BIS_fnc_hubMissionMeta;
	_isSkirmish = _missionMeta select 2;
		
	if (!(_isSkirmish)) then {
		if (!(isNil "BIS_PER_position")) then {vehicle BIS_player setPosATL BIS_PER_position};
		if (!(isNil "BIS_PER_direction")) then {vehicle BIS_player setDir BIS_PER_direction};
	} else {
		if (isNil "BIS_PER_direction") then {
			// Use first marker if defined
			private ["_marker"];
			_marker = "BIS_skirmish_spawn1";
			
			if (markerType _marker != "") then {
				vehicle BIS_player setPos markerPos _marker;
				vehicle BIS_player setDir markerDir _marker;
			} else {
				if (!(isNil "BIS_PER_direction")) then {vehicle BIS_player setDir BIS_PER_direction};
			};
		} else {
			// Compile array of markers
			private ["_markers"];
			_markers = [];
			
			for "_i" from 1 to 8 do {
				private ["_marker"];
				_marker = "BIS_skirmish_spawn" + str _i;
				
				// Add to array if it exists
				if (markerType _marker != "") then {_markers = _markers + [_marker]};
			};
			
			if (count _markers > 0) then {
				// Find marker that is the shortest distance from saved position
				private ["_marker"];
				_marker = "";
				
				{
					private ["_evalMarker", "_evalMarkers"];
					_evalMarker = _x;
					_evalMarkers = _markers - [_evalMarker];
					
					{
						if ({markerPos _evalMarker distance BIS_PER_position < markerPos _x distance BIS_PER_position} count _evalMarkers == count _evalMarkers) then {
							_marker = _evalMarker;
						};
					} forEach _evalMarkers;
				} forEach _markers;
				
				// If a marker was found
				if (markerType _marker != "") then {
					vehicle BIS_player setPos markerPos _marker;
					vehicle BIS_player setDir markerDir _marker;
				} else {
					if (!(isNil "BIS_PER_direction")) then {vehicle BIS_player setDir BIS_PER_direction};
				};
			} else {
				vehicle BIS_player setPosATL BIS_PER_position;
				if (!(isNil "BIS_PER_direction")) then {vehicle BIS_player setDir BIS_PER_direction};
			};
		};
	};
};