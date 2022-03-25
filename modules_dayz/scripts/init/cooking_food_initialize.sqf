private ["_state","_params","_item","_type"];

/*
	Manage fireplace states.
	
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_food = _this select 1;
_params = _this select 2;  //additional params

switch _state do
{	
	//init
	case 0:
	{
		if (isServer) then
		{
			//diag_log format["[Server] cooking_processFood ['%1'] - Event '%2' | Stage = %3", displayName _food, _params select 1, _params select 0]; 
			
			//set init stage
			_food_params_default = _params select 0; //default values
			[_food, _food_params_default] call fnc_changeFoodStage;
			
			//sync variables
			_this spawn 
			{
				//_this select 1) synchronizeVariable ["food_stage", 1, {_this call event_fnc_foodStage}]; //currently this event is not calling properly, therefore it is called manually
				(_this select 1) synchronizeVariable ["food_stage", 1];
				(_this select 1) synchronizeVariable ["quantity", 1];
				(_this select 1) synchronizeVariable ["temperature", 0.2];
			};
		};
		
		//update visual appearance on init (client only)
		_food call event_fnc_foodStage;
	};
	
	default {};
};
