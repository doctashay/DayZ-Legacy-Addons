private ["_state","_fireplace","_player","_params","_fuel"];

/*
	Manage fireplace.
	
	Usage:
	[X, fireplacem, player] call fireplace_manageFire
	X = 0 -> heating on
	X = 1 -> cooling off
	X = 2 -> turn fireplace on
	X = 3 -> turn fireplace off
	X = 4 -> re-ignite fire
	X = 5 -> burning process
	
	Author: Lubos Kovac, Peter Nespesny
*/

_state = _this select 0;
_fireplace = _this select 1;
_player = _this select 2;
_params = _this select 3;

_update_interval = 2;
_fuel_burn_rate = 1; //units per _update_interval
_temperature_inc_rate = 20; //units per _update_interval
_temperature_dec_rate = 10; //units per _update_interval

_min_fireplace_temp = 40;
_max_fireplace_temp = 1000;
_min_temp_to_reignite = 200;
_max_temp_after_extinguish = 80;
_max_wet_level_to_ignite = 0.2;
_min_fuel_to_ignite = 10; //excluding attached fuel items

//heat transfer
_fireplace_heat_radius = 2.5;
_fireplace_burn_radius = 0.5;
_fireplace_heat_wet_coef = 0.05; //speed coef which removes wetness
_fireplace_heat_dam_coef = 0.05; //speed coef which adds damage to item over time
_fireplace_heat_temp_coef = 0.5; //speed coef which builds up temperature

//cooking
_cooking_equipment_temp_inc_rate = 15; //units per _update_interval
_cooking_temperature_threshold = 100; //degree Celsius
_cooking_equipment_max_temp = 250; //degree Celsius

//extinguish
_extinguish_wet_coef = 0.5;
_min_water_to_extinguish = 500; //ml

//burning items
_item_temperature_coef = 10; //add value per update for temperature addition
_cooking_max_temp_other = 200; //max temperature for other (non-ingredient) items in the cooking equipment


switch _state do
{	
	//ignite by match
	case -1:
	{
		//discard one match
		(itemInHands _player) addQuantity -1;

		//PREREQUISITIES	
		//check match quantity
		if ((itemInHands _player) isKindOf 'Consumable_Matchbox' and 
			 quantity (itemInHands _player) < 1) exitWith 
		{
			[_player,format['There are no matches left.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check fuel 
		_kinidling_items_count = [4, _fireplace, objNull, ['kindling_items']] call fireplace_manageFuel;
		
		if (_kinidling_items_count == 0) exitWith 
		{
			[_player,format['There needs to be some kindling to start a fire.'],'colorAction'] call fnc_playerMessage;
		};
				
		//check rain
		if (_player getVariable ['gettingWet',false]) exitWith 
		{
			[_player,format['Match went out because of the rain.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check wetness
		if (_fireplace getVariable ['wet',0] >= _max_wet_level_to_ignite) exitWith
		{
			[_player,format['The fireplace is too wet to be ignited by match.'],'colorAction'] call fnc_playerMessage;
		};

		//test collision
		_pos = getPosASL _fireplace;
		_xPos = _pos select 0;
		_yPos = _pos select 1;
		_bbox = (collisionBox [[_xPos, _yPos, (_pos select 2 ) + 1.4], [0.3,0.3,2.5] ,[[0,0,0], [0, 0, 1]], _player]);
		if ( _bbox ) exitWith
		{
			[_player,format['I cannot ignite the fireplace, its not safe.'],'colorAction'] call fnc_playerMessage;
		};

		//check if player stands in the water (thus he is trying to ignite fireplace in/under the water
		_sur = surfaceTypeASL [_xPos, _yPos, _pos select 2];
		if ( _sur == "FreshWater" || _sur == "sea") exitWith
		{
			[_player,format['I cannot ignite fireplace in the water.'],'colorAction'] call fnc_playerMessage;		
		};
		
		//check wind
		_windStrength = (wind select 0) + (wind select 1) + (wind select 2);
		_probability = 0;

		//set probability to ignite against wind
		switch true do 
		{
			case (_windStrength > 13.9): //[_owner,format['Feels like a strong wind'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.6;
			};
			case (_windStrength > 10.8): //[_owner,format['Feels like a moderate wind'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.7;
			};
			case (_windStrength > 5.4): //[_owner,format['Feels like a heavy breeze'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.8;
			};
			case (_windStrength > 1.5): //[_owner,format['Feels like a moderate breeze'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.9;
			};
			case (_windStrength >= 0): //[_owner,format['Feels like only a light breeze'],'colorAction'] call fnc_playerMessage;
			{		
				_probability = 1;
			};
			default
			{
				_probability = 1;
			};
		};

		_probabilityToNotIgnite = 1 - _probability;
		_randomNum = random 1;
		
		
		//Try to start a fire
		if (_randomNum > _probabilityToNotIgnite) then
		{
			//store parameters
			_player setVariable ['play_action_params', [_fireplace]];
			_player playAction ['startFire',{[2, objNull, objNull, [_this]] call fireplace_manageFire;}];			
		}
		else
		{
			_player playAction ['startFire', {[_this, format['Match went out because of the wind'],'colorAction'] call fnc_playerMessage;}];
		};
	};
	
	//ignite by flare
	case -11:
	{
		//check flare state
		if !(isOn (itemInHands _player)) exitWith
		{
			[_player,format['The flare must be lit first.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check fuel 
		_kinidling_items_count = [4, _fireplace, objNull, ['kindling_items']] call fireplace_manageFuel;
		
		if (_kinidling_items_count == 0) exitWith 
		{
			[_player,format['There needs to be some kindling to start a fire.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check wetness
		if (_fireplace getVariable ['wet',0] >= _max_wet_level_to_ignite) exitWith
		{
			[_player,format['The fireplace is too wet to be ignited by flare.'],'colorAction'] call fnc_playerMessage;
		};
		
		//test collision
		_pos = getPosASL _fireplace;
		_xPos = _pos select 0;
		_yPos = _pos select 1;
		_bbox = (collisionBox [[_xPos, _yPos, (_pos select 2 ) + 1.4], [0.3,0.3,2.5] ,[[0,0,0], [0, 0, 1]], _player]);
		if ( _bbox ) exitWith
		{
			[_player,format['I cannot ignite the fireplace, its not safe.'],'colorAction'] call fnc_playerMessage;
		};

		//check if player stands in the water (thus he is trying to ignite fireplace in/under the water
		_sur = surfaceTypeASL [_xPos, _yPos, _pos select 2];
		if ( _sur == "FreshWater" || _sur == "sea") exitWith
		{
			[_player,format['I cannot ignite fireplace in the water.'],'colorAction'] call fnc_playerMessage;		
		};
		
		//Start a fire
		//store parameters
		_player setVariable ['play_action_params', [_fireplace]];
		_player playAction ['ItemUseShort',{[2, objNull, objNull, [_this]] call fireplace_manageFire;}];			
	};
	
	//**********************************************
	//reignite fire - start
	//blow air into the fire
	case -2:
	{
		_current_temp = _fireplace getVariable ['temperature',20];
		_wet_level = _fireplace getVariable ['wet', 0];
		
		//check wet level
		if (_wet_level > _max_wet_level_to_ignite) exitWith
		{
			[_player,format['Fireplace is too wet to be reignited.'],'colorAction'] call fnc_playerMessage;
		};
		
		//check temperature
		if (_current_temp < _min_temp_to_reignite) exitWith 
		{
			//player message
			[_player,format['The temperature is too low.'],'colorAction'] call fnc_playerMessage;		
		};
		
		//check fuel items
		_fuel_items_count = [4, _fireplace, objNull, ['fuel_items']] call fireplace_manageFuel;
		
		if (_fuel_items_count == 0) then
		{
			//player message
			[_player,format['There is nothing left to burn.'],'colorAction'] call fnc_playerMessage;		
		}
		else
		{
			//start action
			_player setVariable ['play_action_params', [_fireplace]];
			_player playAction ['DrinkPond', {[-22, objNull, _this, []] call fireplace_manageFire}];		
		};
	};
	
	//reignite fire - end
	case -22:
	{
		_params = _player getVariable 'play_action_params';
		_fireplace = _params select 0;
		
		//turn fire on and start heating on
		[2, _fireplace, _player, []] call fireplace_manageFire;
		
		//player message
		[_player,format['Blowing air into the fireplace caused fire to burn.'],'colorAction'] call fnc_playerMessage;
	};
	//**********************************************
	
	//**********************************************
	//extinguish - start
	case -3:
	{
		_water_source = itemInHands _player;
		
		if ((quantity _water_source) < _min_water_to_extinguish) exitWith 
		{
			[_player,format['There is not enough water in the %1 to extinguish the water.', displayname _water_source],'colorAction'] call fnc_playerMessage;
		};
		
		_player setVariable ['play_action_params', [_fireplace, _water_source]];
		
		//_player playAction ['extinguishFire', {[-4, objNull, _this, []] call fireplace_manageFire}]; 
		_player playAction ['ItemUseShort', {[-33, objNull, _this, []] call fireplace_manageFire}]; 
	};
	
	//extinguish - end
	case -33:
	{
		_params = _player getVariable 'play_action_params';
		_fireplace = _params select 0;
		_water_source = _params select 1;
		_fireplace setVariable ['fire',false]; 
		
		//set temperature
		_temperature = _fireplace getVariable ['temperature', 20]; 
		_fireplace setVariable ['temperature', (_temperature min _max_temp_after_extinguish)];
		
		//remove water from the source
		[_water_source, -_min_water_to_extinguish] call fnc_addQuantity;
		
		//stop cooking
		_cooking_equipment = _fireplace getVariable ['cooking_equipment', objNull];
		if !(isNull _cooking_equipment) then
		{
			_cooking_equipment setVariable ['is_cooking', false];
		};
		
		//spend actual fuel item
		[5, _fireplace, objNull, []] call fireplace_manageFuel;
		
		//add wetness to fireplace
		_wet_level = _fireplace getVariable ['wet', 0];
		_fireplace setVariable ['wet', _wet_level + _extinguish_wet_coef];
		
		[_player,format['I have extinguished the fire.'],'colorAction'] call fnc_playerMessage;
	};
	//**********************************************
	
	//heating on
	case 0: 
	{
		//add first fuel by spending available fuel/kindling item
		_spending_fuel = _fireplace getVariable ['spending_fuel', [objNull, 0]];
		_spending_fuel_amount = _spending_fuel select 1;
		
		//visual
		_fireplace setObjectMaterial [0,'dz\gear\cooking\data\stoneground.rvmat'];
		
		//burn
		while {_spending_fuel_amount >= _fuel_burn_rate and
			   _fireplace getVariable ['fire',false]
			  } do
		{
			sleep _update_interval; 
			
			//spent fuel 
			_temp_burn_rate = _fireplace getVariable ['fuel_burn_rate_mp', 1];
			_spending_fuel_amount = _spending_fuel_amount - (_temp_burn_rate * _fuel_burn_rate);
			
			if (_spending_fuel_amount < _fuel_burn_rate) then
			{
				//spend actual fuel item
				[5, _fireplace, objNull, []] call fireplace_manageFuel;
				//set next fuel item
				[3, _fireplace, objNull, []] call fireplace_manageFuel;
				
				//set new fuel amount
				_spending_fuel = _fireplace getVariable ['spending_fuel', [objNull, 0]];
				_spending_fuel_amount = _spending_fuel select 1;
			};
			
			_temperature = _fireplace getVariable 'temperature';
			//temperature increase
			if (_temperature <= _max_fireplace_temp - _temperature_inc_rate ) then
			{
				_temperature = _temperature + _temperature_inc_rate;
				_fireplace setVariable ['temperature', _temperature];
			};
			
			//burn items
			[5, _fireplace, _player, []] call fireplace_manageFire; //burn items in fireplace
			
			//heat nearest agents
			[6, _fireplace, _player, []] call fireplace_manageFire; //heat nearest agents
			
			//transfer heat to cooking equipment
			_cooking_equipment = _fireplace getVariable ['cooking_equipment', objNull];
			
			if !(isNull _cooking_equipment) then
			{
				_cooking_equipment_temp = _cooking_equipment getVariable ['temperature', _min_fireplace_temp];
				
				if (_cooking_equipment_temp >= _cooking_temperature_threshold and
					!(_cooking_equipment getVariable ["is_cooking", false]) ) then
				{
					//start cooking
					[ 1, _cooking_equipment, []] spawn cooking_cookingProcess;
				};
				
				_cooking_equipment setVariable ["temperature", ((_cooking_equipment_temp + _cooking_equipment_temp_inc_rate) min _cooking_equipment_max_temp)];
			};
		};
		
		//turn off fire
		[3, _fireplace, _player, []] call fireplace_manageFire; //turn off bonfire
	};
	
	 //colling off
	case 1:
	{
		private["_temperature","_temp_glow_on"];
		_temperature = _fireplace getVariable 'temperature';
		_check_glow = true; 
		_check_cooking = true;
		
		while {_temperature >= _min_fireplace_temp && !(_fireplace getVariable ['fire',false])} do
		{
			sleep _update_interval; 
			
			_temp_heat_loss_coef = _fireplace getVariable ['temperature_loss_mp', 1];
			_temperature = _temperature - (_temp_heat_loss_coef * _temperature_dec_rate);
			_fireplace setVariable ['temperature', _temperature];
			
			//DebugLog
			//hint format["Cooling off\n temperature = %1\n heat loss coef = %2",_temperature, _temp_heat_loss_coef];
			
			//stop cooking when temperature is below minimum
			if (_temperature < _cooking_temperature_threshold and _check_cooking) then
			{
				_cooking_equipment = _fireplace getVariable ['cooking_equipment', objNull];
				
				if !(isNull _cooking_equipment) then
				{
					_cooking_equipment setVariable ['is_cooking', false];
				};
				
				_check_cooking = false; //check only once
			};
			
			//turn off glow effect
			if (_temperature <= _min_temp_to_reignite and _check_glow) then
			{
				//visual
				_fireplace setObjectMaterial [0,'dz\gear\cooking\data\stonegroundnoemit.rvmat'];
				_check_glow = false;
							
				//turn light off
				_fireplace switchLight 'OFF';
			};
		};
		
		//DebugLog
		//hint format["Cooled off\n temperature = %1",_temperature];
	};
	
	//turn fire on
	case 2:
	{
		//if playAction
		if ((count _params) > 0) then 
		{
			_player = _params select 0;		
			_fireplace = (_player getVariable 'play_action_params') select 0;
			
			//remove grass beneath the fireplace
			_grassRemoval = "Tent_ClutterCutter" createVehicle (getPosATL _fireplace); // Removes the grass around the spot
		};
		
		//DebugLog
		//[_player, format["Starting fire... plr = %1, fp = %2", _player, _fireplace], "colorStatusChannel"] call fnc_playerMessage;
		
		//turn fire on
		if !(_fireplace getVariable ['fire',false]) then 
		{
			//set spending fuel on fire start
			[3, _fireplace, objNull, []] call fireplace_manageFuel; //set spending fuel
			
			//turn fire state on
			_fireplace setVariable ['fire', true];
			_fireplace setVariable ['is_fireplace', true];
			
			//turn light on
			_fireplace switchLight 'ON';
			
			//if playAction
			if ((count _params) > 0) then 
			{
				//message
				[_player,format["I have started the fire."],'colorAction'] call fnc_playerMessage;
			};
			
			//turn heating on
			[0, _fireplace, _player, []] spawn fireplace_manageFire;
		};
	};
	
	//turn fire off
	case 3:
	{
		//DebugLog
		//[_player, format["Stopping fire..."], "colorStatusChannel"] call fnc_playerMessage;
		
		//turn fire off
		_fireplace setVariable ['fire', false];
		
		//start cooling
		[1, _fireplace, _player, []] spawn fireplace_manageFire; //start cooling off
	};
	
	//burning (damage) process
	case 5:
	{
		{
			private["_item","_name","_damage"];
			_item = _x;
			_name = displayName _item;
			
			_damage = damage _item;
			_temperature = _item getVariable ['temperature', 20];
			
			if (_damage < 1) then
			{
				//set damage
				_item setDamage (_damage + _fireplace_heat_dam_coef);
				
				//add temerature
				_temp = _temperature + _item_temperature_coef;
				_item setVariable ['temperature', (_temp min _cooking_max_temp_other)]; //clamp temperature				
				
				//DEBUG
				//[_player, format["Fire damaged item %1.[temperatire = %2]", _name, (_temp min _cooking_max_temp_other)], "colorStatusChannel"] call fnc_playerMessage;
			};
		} foreach itemsInCargo _fireplace;
	};
	
	//warm up nearest agents
	//normal body temperature - 36.5
	//overheating body temperature - 38
	case 6:
	{
		private["_agents","_agent","_wet_level","_temp_level","_agent_distance","_temp_add"];
		_agents = nearestObjects [_fireplace, ["SurvivorBase"], _fireplace_heat_radius];
		
		{
			_agent = _x;
			_wet_level = _agent getVariable["wet", 0]; //TODO add agents clothes to heat transfer
			_temp_level = _agent getVariable["bodytemperature", 36.5];
			
			//heat comfort
			_agent_distance = (getPosASL _agent) distance (getPosASL _fireplace);
			
			//>38 warm, >200 burning
			_temp_add = 0;
			if(_agent_distance < _fireplace_burn_radius) then
			{
				_agent setVariable ["heatcomfort", 201]; //burn 
				
				//temperature level
				if(_temp_level < 38) then
				{
					_temp_add = _fireplace_heat_temp_coef * (_fireplace_heat_radius - _agent_distance);
				};
			}
			else
			{
				_agent setVariable ["heatcomfort", 30]; //warm
				
				//temperature level
				if(_temp_level < 36.5) then
				{
					_temp_add = _fireplace_heat_temp_coef * (_fireplace_heat_radius - _agent_distance);
				};
			};
			_agent setVariable["bodytemperature", _temp_level + _temp_add];
			
			//wet level
			if(_wet_level > 0.1) then
			{
				private["_heat"];
				_heat = _fireplace_heat_wet_coef * (_fireplace_heat_radius - _agent_distance);
				_agent setVariable["wet", _wet_level - _heat];
			};
			

		} forEach _agents;
	};
	
	default {};
};




