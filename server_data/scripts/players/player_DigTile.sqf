// /*
// This script handles digging tiles on surfaces.
// TO DOs: 
// 	-Solve how to handle "isUsingSomething" on the user when the action is done
// 	-Add damage to the used tool

// */

// _state = _this select 0;
// switch _state do 
// {
// 	// Check the collisions, water, tool damage, and if everything is valid then start playing animation
// 	case 0:
// 	{
// 		_person = _this select 1;
// 		_tool = _this select 2;
// 		_surface = _this select 3;
		
// 		// Check the tool's damage
// 		if (damage _tool == 1) 
// 		exitWith{
// 			[_person, "The tool is ruined.", "colorImportant"] call fnc_playerMessage;
// 		};
		
// 		_dist = 2;
// 		_dir = direction _person;
// 		_xPos = (getPos _person select 0) + (sin _dir * _dist);
// 		_yPos = (getPos _person select 1) + (cos _dir * _dist);
// 		_zPos = (getPosASL _person select 2);
// 		_pos = [_xPos, _yPos, 0];
		
// 		//check slope
// 		_terrainNormal = RoadWayNormalAsl [_xPos, _yPos, _pos select 2];
// 		_terrainSlope = atg(sqrt((_terrainNormal select 0)*(_terrainNormal select 0) + (_terrainNormal select 1)*(_terrainNormal select 1))/(_terrainNormal select 2) );
// 		if (_terrainSlope > 10)
// 		exitWith{
// 			[_person, "The terrain is too steep in here.", "colorImportant"] call fnc_playerMessage;
// 		};
		
// 		// Everything is checked, now start digging
// 		_result = format["[1, ""%1"", %2, %3, %4] call player_DigTile", _surface, round _xPos, round _yPos, direction _person];	
// 		_person playAction ["digHoe", compile _result];
// 		_tool setDamage (damage _tool + 0.05);
// 	};
	
// 	// Called when the action has ended
// 	case 1:
// 	{
// 		_surfaceType = _this select 1;
// 		_xPos = _this select 2;
// 		_yPos = _this select 3;
// 		_dir = _this select 4;
// 		_pos = [_xPos, _yPos, 0];
// 		_energy = 0.3;
// 		switch(_surfaceType) do {
// 			case ("CRForest1"	): {	_energy =	0.3 };
// 			case ("CRForest2"	): {	_energy =	0.3 };
// 			case ("CRGrass1"	): {	_energy =	0.7 };
// 			case ("CRGrass2"	): {	_energy =	0.7 };
// 			case ("CRGrit1"		): {	_energy =	0.2 };
// 		};

// 		//player globalChat format["%1: %2", _surfaceType, _energy];
		
// 		_tileObj = "DiggedTile" createVehicle _pos;
// 		//_tileObj setpos _pos; //Set position precisely
// 		//_tileObj setDir _dir;
		
// 		_grassRemoval = "Tent_ClutterCutter" createVehicle _pos; // Removes the grass around the spot
// 		//_grassRemoval setDir _dir;
		
// 		//hint format["Obj: %1\nposition: %2\nDesired pos: %3", _tileObj, getpos _tileObj, _pos];

		
// 		_person setVariable ["isUsingSomething",0];
// 	};
// }
