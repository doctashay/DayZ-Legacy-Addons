private["_agent","_maxDis","_dis","_val","_maxExp","_myExp"];
_agent = 	_this select 0;
_dis =		_this select 1;
_maxDis = 	_this select 2;
//diag_log ("VAL:  " + str(_this));
_val = 		(_maxDis - _dis) max 0;
_maxExp = 	((exp 2) * _maxDis);
_myExp = 	((exp 2) * (_val)) / _maxExp;
_myExp = _myExp * 0.7;
_myExp