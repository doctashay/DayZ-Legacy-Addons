private ["_state","_player","_params"];

/*
	Manage cooking actions.
	
	Usage:
	[_state, _player, _fireplace] call cooking_manageActions
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_player = _this select 1;
_params = _this select 2;

_water_min_volume = 500; //ml

switch _state do
{	
	//fill cooking pot with bottle (water/oil/fat)
	case 1: 
	{
		private["_source","_base_name","_base_volume","_cooking_equipment"];
		_cooking_equipment = _params select 0;
		_source = _params select 1;
		_cooking_base = _cooking_equipment getVariable ['cooking_base', ['empty',0]];
		_base_name = _cooking_base select 0;
		_base_volume = _cooking_base select 1;
		
		//condition for _base_volume
		if (_base_name == "empty") then  //empty
		{	
			//set base name and volume 
			switch true do
			{
				case (_source isKindOf "BottleBase"): 
				{ 
					_base_name = "water"; 
					_base_volume = _water_min_volume; 
				};
				
				default {}; //is empty
			};
			
			if (_base_volume <= quantity _source) then
			{
				//set cooking base for cooking equipment
				_cooking_equipment setVariable ['cooking_base', [_base_name, _base_volume]];
				
				//remove water from the source
				[_source, -_base_volume] call fnc_addQuantity;
				
				//player message
				[_player, format["%1 was filled with %2 (%3 ml).", displayName _cooking_equipment, _base_name, _base_volume], "colorStatusChannel"] call fnc_playerMessage;			
			}
			else
			{
				//player message
				[_player, format["There is not enough %1 in %2.", _base_name, displayName _source], "colorStatusChannel"] call fnc_playerMessage;	
			};
		}
		else //already filled
		{
			//player message
			[_player, format["%1 is already filled with %2 (%3 ml).", displayName _cooking_equipment, _base_name, _base_volume], "colorStatusChannel"] call fnc_playerMessage;
		};
	};
	
	//empty cooking equipment
	case 33:
	{
		private["_cooking_equipment"];
		_cooking_equipment = _params select 0;
		
		//set cooking base for cooking equipment
		_cooking_equipment setVariable ['cooking_base', ["empty", 0]];
		
		//player message
		[_player, format["%1 has been emptied.", displayName _cooking_equipment], "colorStatusChannel"] call fnc_playerMessage;	
	};	
	
	//(DEBUG) check contents
	case -1: 
	{
		private["_source","_base_name","_base_volume","_cooking_equipment"];
		_cooking_equipment = _params select 0;
		_cooking_base = _cooking_equipment getVariable ['cooking_base', ['empty',0]];
		_base_name = _cooking_base select 0;
		_base_volume = _cooking_base select 1;
		
		//player message
		[_player, format["[Debug] Equipment = %1, Base_name = %2, Base_volume %3 ml.", displayName _cooking_equipment, _base_name, _base_volume], "colorStatusChannel"] call fnc_playerMessage;
	};
	
	default {};
};
