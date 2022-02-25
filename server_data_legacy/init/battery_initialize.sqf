private["_battery","_val","_var"];
/*
	Init script that checks if power value loaded, if not loads a power value
*/
_battery = _this select 0;
_var = _this select 1;
_val = _battery getVariable [_var,-1];
if (_val < 0) then {
	_val = getNumber (configFile >> "CfgVehicles" >> typeOf _battery >> "Resources" >> _var);
	_battery setVariable [_var,_val];
};