private ["_player","_state","_params"];

/*
	Manage fireplace actions.
	
	Usage:
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_player = _this select 1;
_params = _this select 2;

switch _state do
{	
	//craft fireplace
	case 0:
	{
		_tool1 = _params select 0; //fuel item
		_tool2 = _params select 1; //kindling item
		
		//create in inventory
		_fireplace = ["Fireplace", _player] call player_addInventory;
		
		//split and move stick, kindling into created fireplace (moveToInventory)
		//tool1
		_tool1_new = (typeOf _tool1) createVehicle  (getPosATL _tool1);
		_tool1_new setQuantity 1;
		[_tool1, -1] call fnc_addQuantity;  //remove quantity only if the new tool is created
		_fireplace movetoInventory _tool1_new;
		//tool2
		_tool2_new = (typeOf _tool2) createVehicle  (getPosATL _tool2);
		_tool2_new setQuantity 1;
		[_tool2, -1] call fnc_addQuantity; //remove quantity only if the new tool is created
		_fireplace movetoInventory _tool2_new;
		
		//player message
		[_player, format['I made fireplace.'],'colorAction'] call fnc_playerMessage;
	};
	
	//**********************************************
	// TODO - move conditions to ignite action
	//**********************************************
	//craft fireplace - start
	case 55:
	{
		private["_fireplace_kit","_fireplace_base","_fireplace_base_amount","_fireplace_kit_pos"];
		_fireplace_kit = _params select 0;
		_fireplace_init_fuel = _params select 1;
		_fireplace_kit_pos = position _fireplace_kit;
		
		//TODO
		_players = nearestObjects [_fireplace_kit, ["SurvivorBase"], 1.5];
		
		//test collision
		_fireplace_kit_pos_ASL = getPosASL _fireplace_kit;
		_fireplace_kit_pos = getPosATL _fireplace_kit;
		_xPos = _fireplace_kit_pos_ASL select 0;
		_yPos = _fireplace_kit_pos_ASL select 1;
		/*
		_bbox = (collisionBox [[_xPos, _yPos, (_fireplace_kit_pos_ASL select 2 ) + 1.4], [1,1,2.5] ,[[0,0,0], [0, 0, 0]], _player]);
		if ( _bbox ) exitWith
		{
			[_player,format['I cannot make the fireplace here.'],'colorAction'] call fnc_playerMessage;
		};
		*/
		_bbox = (collisionBox [[_xPos, _yPos, (_fireplace_kit_pos_ASL select 2 ) + 1.4], [1,1,2.5] ,[[0,0,0], [0, 0, 0]], _players]);
		if ( _bbox ) exitWith
		{
			{
				[_x, format['The fireplace cannot be placed here.'],'colorAction'] call fnc_playerMessage;
			} foreach _players;
		};
		
		//check slope
		_terrainNormal = RoadWayNormalAsl [_xPos, _yPos, (_fireplace_kit_pos_ASL select 2 ) + 1.4];
		_terrainSlope = atg(sqrt((_terrainNormal select 0)*(_terrainNormal select 0) + (_terrainNormal select 1)*(_terrainNormal select 1))/(_terrainNormal select 2) );
		/*
		if (_terrainSlope > 10) exitWith
		{
			[_player, "The terrain is too steep here.", "colorImportant"] call fnc_playerMessage;
		};
		*/
		if (_terrainSlope > 10) exitWith
		{
			{
				[_x, "The terrain is too steep here.", "colorImportant"] call fnc_playerMessage;
			} foreach _players;
		};
		
		//check if player stands in the water (thus he is trying to ignite fireplace in/under the water
		_sur = surfaceTypeASL [_xPos, _yPos, _fireplace_kit_pos_ASL select 2];
		/*
		if ( _sur == "FreshWater" || _sur == "sea") exitWith
		{
			[_player,format['I cannot make fireplace in the water.'],'colorAction'] call fnc_playerMessage;		
		};
		*/
		if ( _sur == "FreshWater" || _sur == "sea") exitWith
		{
			{
				[_x,format['The fireplace cannot be placed in the water.'],'colorAction'] call fnc_playerMessage;		
			} foreach _players;
		};
		
		//store parameters
		//_player setVariable ['play_action_params', [_fireplace_kit, _fireplace_init_fuel, _fireplace_kit_pos]];
		//play action
		//_player playAction ['PlayerCraft',{[6, _this, []] call fireplace_manageActions}];
		[6, _this, [_fireplace_kit, _fireplace_init_fuel, _fireplace_kit_pos]] call fireplace_manageActions;
	};
	
	//craft fireplace - end
	case 66:
	{
		private["_fireplace_kit","_fireplace_base","_fireplace_base_amount","_fireplace_kit_pos"];
		//_params = _player getVariable 'play_action_params';
		_params = _this select 2;
		_fireplace_kit = _params select 0;
		_fireplace_init_fuel = _params select 1;
		_fireplace_kit_pos = _params select 2;
		
		//delete  fireplace kit
		deleteVehicle _fireplace_kit;
		
		//spawn fireplace and set position to fireplace kit
		//_fireplace = createVehicle ["Fireplace", _fireplace_kit_pos, [], 0, "NONE"];
		_fireplace = "Fireplace" createVehicle _fireplace_kit_pos;
		
		//set initial fuel
		_fireplace setVariable ['fuel', _fireplace_init_fuel];
		
		//remove grass beneath the fireplace
		_grassRemoval = "Tent_ClutterCutter" createVehicle _fireplace_kit_pos; // Removes the grass around the spot
		
		//TODO
		_players = nearestObjects [_fireplace, ["SurvivorBase"], 1.5];
		//TODO
		/*
			[_player,format['I made a fireplace.'],'colorAction'] call fnc_playerMessage;
		*/
		{
			[_x, format['The fireplace was created.'],'colorAction'] call fnc_playerMessage;
		} forEach _players;
	};
	//**********************************************
	
	default {};
};
