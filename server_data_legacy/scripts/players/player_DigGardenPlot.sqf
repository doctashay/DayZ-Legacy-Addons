/*
This script handles digging garden plots on surfaces.
*/

_state = _this select 0;
switch _state do 
{
	// Check the collisions, water, tool damage, and if everything is valid then start playing animation
	case 0:
	{
		_person = _this select 1;
		_tool = _this select 2;
		_surface = _this select 3;
		
		// Check the tool's damage
		if (damage _tool == 1) 
		exitWith{
			[_person, format["The %1 is ruined.", displayName _tool], "colorImportant"] call fnc_playerMessage;
		};
		
		// The tool is valid. Now this calculates the garden plot's position in front of the player.
		_dist = 2;
		_dir = direction _person;
		_xPos = round ( (getPos _person select 0) + (sin _dir * _dist) );
		_yPos = round ( (getPos _person select 1) + (cos _dir * _dist) );
		_zPos = (getPosASL _person select 2);
		_pos = [_xPos, _yPos, 0];
		
		//check slope
		_terrainNormal = RoadWayNormalAsl [_xPos, _yPos, _pos select 2];
		_terrainSlope = atg(sqrt((_terrainNormal select 0)*(_terrainNormal select 0) + (_terrainNormal select 1)*(_terrainNormal select 1))/(_terrainNormal select 2) );
		if (_terrainSlope > 10)
		exitWith{
			[_person, "The terrain is too steep here.", "colorImportant"] call fnc_playerMessage;
		};
		
		// Check if there isn't water here
		_sur = surfaceTypeASL [_xPos, _yPos, _zPos];
		if ( _sur == "FreshWater" || _sur == "sea")
		exitWith{
			[_person, "I cannot dig near water.", "colorImportant"] call fnc_playerMessage;
		};
		
		// Check if the selected area is not interrupted by another surface type
		_checkDistance = 1.75;
		_suitableArea = true;
		
		_surfaceToCheck = "";
		_suitableArea = true;
		// Checking corners of the garden plot
		if (_suitableArea) then{_surfaceToCheck = surfaceTypeASL [_xPos-_checkDistance, _yPos-_checkDistance, _zPos]; _suitableArea = _surfaceToCheck call fnc_isSoftSurface;};
		if (_suitableArea) then{_surfaceToCheck = surfaceTypeASL [_xPos+_checkDistance, _yPos-_checkDistance, _zPos]; _suitableArea = _surfaceToCheck call fnc_isSoftSurface;};
		if (_suitableArea) then{_surfaceToCheck = surfaceTypeASL [_xPos-_checkDistance, _yPos+_checkDistance, _zPos]; _suitableArea = _surfaceToCheck call fnc_isSoftSurface;};
		if (_suitableArea) then{_surfaceToCheck = surfaceTypeASL [_xPos+_checkDistance, _yPos+_checkDistance, _zPos]; _suitableArea = _surfaceToCheck call fnc_isSoftSurface;};
		// Checking sides of the garden plot
		if (_suitableArea) then{_surfaceToCheck = surfaceTypeASL [_xPos+_checkDistance, _yPos, _zPos]; _suitableArea = _surfaceToCheck call fnc_isSoftSurface;};
		if (_suitableArea) then{_surfaceToCheck = surfaceTypeASL [_xPos-_checkDistance, _yPos, _zPos]; _suitableArea = _surfaceToCheck call fnc_isSoftSurface;};
		if (_suitableArea) then{_surfaceToCheck = surfaceTypeASL [_xPos, _yPos+_checkDistance, _zPos]; _suitableArea = _surfaceToCheck call fnc_isSoftSurface;};
		if (_suitableArea) then{_surfaceToCheck = surfaceTypeASL [_xPos, _yPos-_checkDistance, _zPos]; _suitableArea = _surfaceToCheck call fnc_isSoftSurface;};
		
		if !(_suitableArea)
		exitWith{
			[_person, "This place is not suitable for a garden plot.", "colorImportant"] call fnc_playerMessage;
		};
		
		// Check if this place is collision free
		if (collisionBox [[_xPos, _yPos, _zPos ], [3.3,3.3,2] ,[vectorDir _person, RoadWayNormalAsl [_xPos, _yPos, _zPos]], players])
		exitWith{
			[_person, "There is not enough room for the garden plot.", "colorImportant"] call fnc_playerMessage;
		};
		if (collisionBox [[_xPos, _yPos, _zPos+15 ], [1,1,30] ,[vectorDir _person, [0,0,1]], players])
		exitWith{
			[_person, "I cannot make a garden plot here.", "colorImportant"] call fnc_playerMessage;
		};
		
		// Everything is checked, now start digging
		_person setVariable ["isUsingSomething", 1];
		_result = format["[1, %1, _this, ""%2""] call player_DigGardenPlot", [_xPos,_yPos,_zPos], _surface];
		
		_animation = "digHoe";
		if (_tool isKindOf "Tool_Shovel" or _tool isKindOf "Tool_FieldShovel") then {_animation = "digShovel";};
		if (typeOf _tool == "Tool_IceAxe") then {_animation = "PlayerCraft";};
		_person playAction [_animation, compile _result];
	};
	
	// Called when the action has ended
	case 1:
	{
		_pos = _this select 1;
		_user = _this select 2;
		_surface = _this select 3;
		_user setVariable ["isUsingSomething", 0];
		itemInHands _user setDamage (damage itemInHands _user + 0.05);
		
		_fertility = _surface call fnc_getSurfaceFertility;
		_tileObj = "GardenPlot" createVehicle _pos;
		_pos = [_pos select 0, _pos select 1, 0.01];
		_tileObj setPosATL _pos;
		_grassRemoval = "Tent_ClutterCutter" createVehicle _pos; // Removes the grass around the spot
		_tileObj setVariable ["baseFertility", _fertility];
		
		// Give player some worm
		_possiblyFoundWorm = [_user, 0.3] call fnc_giveWorms;
		if (isNull _possiblyFoundWorm) then {
			[_user, "I've prepared the garden plot.", "colorAction"] call fnc_playerMessage;
		} else {
			[_user, "I've prepared the garden plot and found a worm in the ground.", "colorAction"] call fnc_playerMessage;
		};
	};
}
