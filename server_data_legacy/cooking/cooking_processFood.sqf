private ["_state","_food","_params","_config_name","_config_food"];

/*
	Food
	
	Usage:
	[_state, _food, _params] call cooking_processFood
	X = 0 -> transfer diseases
	X = 1 -> food - update progress (cooking)
	
	Author: Lubos Kovac
*/

_state = _this select 0;
_food = _this select 1;
_params = _this select 2;  //additional params

//debugLog
//[player, format["displayname food = %1", displayName _food], "colorStatusChannel"] call fnc_playerMessage;

//config
_config_name = "CfgVehicles";
_config_food = configFile >> _config_name >> typeOf _food;

//cooking params
_food_temperature_coef = 10;
_food_max_temperature_mp = 2;

//food params
_food_stage = _food getVariable ['food_stage', ['Raw',0]];
_food_stage_name = _food_stage select 0;
_food_stage_index = _food_stage select 1;
_food_stage_params = getArray (_config_food >> "Stages" >> _food_stage_name);

switch _state do
{	
	//debug
	//check food status
	case -22:
	{
		_player = _params select 0;
		
		[_player, format["_food = %1 | _food_stage_name = %2 | _food_stage_index = %3", displayName _food, _food_stage_name, _food_stage_index], "colorStatusChannel"] call fnc_playerMessage;
	};
	
	//TODO
	//set initial coooking stage (based on cooking equipment base ingredient)
	case -2:
	{
		private["_cooking_base","_cooking_stage"];
		_cooking_equipment = _params select 0;
		
		_cooking_base = (_cooking_equipment getVariable ["cooking_base", ["empty", 0]]) select 0;
		
		_last_cooking_base = _cooking_base;
		
		switch true do
		{
			case (_cooking_base == "water"):
			{
				_cooking_stage = 'Cooked';
			};
			
			case (_cooking_base == "fat"):
			{
				_cooking_stage = 'Fried';
			};
			
			default { _cooking_stage = 'Dried'; }; //no ingredient
		};
		
		//if previous stage was different -> reset stage index
		if (_last_cooking_base != _cooking_base) then
		{
			_food_stage_index = 0;
		};
		
		_food setVariable ['food_stage', [_cooking_stage,_food_stage_index]];
	};
	
	//update visual appearance
	case -1:
	{
		private["_food_textures","_food_materials","_food_appearance","_food_texture_index","_food_material_index"];
		_food_textures = getArray (_config_food >> "foodTextures");
		_food_materials = getArray (_config_food >> "foodMaterials");
		_food_appearance = (_food_stage_params select _food_stage_index) select 3;
		
		_food_texture_index = _food_appearance select 0;
		_food_material_index = _food_appearance select 1;
		_food setObjectTexture [0, _food_textures select _food_texture_index];
		_food setObjectMaterial [0, _food_materials select _food_material_index];
	};
	
	//transfer diseases
	case 0: 
	{
		private["_food_diseases","_player"];
		_player = _params select 0;
			
		_food_diseases = (_food_stage_params select _food_stage_index) select 2;
		
		//debugLog
		//[_player = _this select 0;, format["food type = %1, _food_stage_name = '%2', _food_stage_index = '%3'", typeOf _food, _food_stage_name, _food_stage_index], "colorStatusChannel"] call fnc_playerMessage;
		
		//debugLog
		//[_player = _this select 0;, format["_food_stage_params = %1", count _food_stage_params], "colorStatusChannel"] call fnc_playerMessage;
		
		{
			_poisonChance = random 1; 
			
			_propability = _x select 0;
			_disease = _x select 1;
			
			if (_poisonChance < _propability) then 
			{
				//debugLog
				//[_player, format["Disease transfered %1[with %2 chance].", _disease, _propability], "colorStatusChannel"] call fnc_playerMessage;
				
				[0, _player, _disease] call event_modifier;
			};

		} foreach _food_diseases;
		
		//debugLog
		//[_player, format["Disease transfer...Done! (max %1).", count _food_diseases], "colorStatusChannel"] call fnc_playerMessage;
	};
	
	//food - update progress (cooking)
	//[params = 0. fireplace temperature, ]
	case 1: 
	{
		_cooking_equipment_temp = _params select 0;
		_food_time_coef = _params select 1;
		
		_food_cooking_params = (_food_stage_params select _food_stage_index) select 1;
		_food_temperature = _food getVariable ['temperature',0];
		_food_cooking_time = _food getVariable ['cooking_time',0];
		_food_min_temperature = _food_cooking_params select 0;
		_food_min_time = _food_cooking_params select 1;
		_food_max_time = _food_cooking_params select 2;
		
		//cooking progress
		if (_cooking_equipment_temp > _food_min_temperature) then
		{
			//add temerature only
			_temp = _food_temperature + _food_temperature_coef;
			_food setVariable ['temperature', (_temp min (_food_min_temperature * _food_max_temperature_mp))]; //clamp temperature
			
			//debugLog
			//[player, format["Food %1 temperature %2.", displayName _food, _temp], "colorStatusChannel"] call fnc_playerMessage;
			
			if (_food_temperature > _food_min_temperature) then
			{
				//add time 
				_food_cooking_time = _food_cooking_time + _food_time_coef;
				_food setVariable ['cooking_time',_food_cooking_time];
				
				//progress to next stage
				if (_food_cooking_time > _food_max_time and 
					_food_stage_index < (count _food_stage_params)-1 ) then
				{
					_food_stage_index = _food_stage_index + 1;
					
					//set index
					_food setVariable ['food_stage',[_food_stage_name, _food_stage_index]];
					
					diag_log format["changing food texture on %1 to %2 [%3]", displayName _food, _food_stage_name, _food_stage_index];
					
					//[player, format["changing food texture on %1 to %2 [%3]", displayName _food, _food_stage_name, _food_stage_index], "colorStatusChannel"] call fnc_playerMessage;
					
					//reset cooking time
					_food setVariable ['cooking_time', 0];
				};
				
				//[_player, format["Food Update food = '%1', food temperature = '%2', food stage = '%3', food stage index = '%4'.", displayName _food, _food_temperature, _food_stage_name, _food_stage_index], "colorStatusChannel"] call fnc_playerMessage;
			};
		};
	};
	
	default {};
};