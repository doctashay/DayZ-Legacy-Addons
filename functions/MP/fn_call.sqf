private ["_params","_code"];
_params = [_this,0,[]] call bis_fnc_param;
_code = [_this,1,{},[{}]] call bis_fnc_param;

_params call _code