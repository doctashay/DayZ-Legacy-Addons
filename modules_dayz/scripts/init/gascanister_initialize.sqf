private ["_state","_params"];

/*
	Manage gascanister init.
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_params = _this select 1;

switch _state do
{	
	//init
	case 0: 
	{
		_canister = _params select 0;
		_var = _params select 1;
		
		_value = _canister getVariable [_var, -1];
		
		//if not set, set init values from config
		if (_value < 0) then
		{
			_value = getNumber (configFile >> "CfgVehicles" >> typeOf _canister >> "Resources" >> _var);
			_canister setVariable [_var, _value];
		};
	};
	
	default {};
};
