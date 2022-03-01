/*
	Author: Karel Moricky

	Description:
	Returns all subclasses within given class
	
	Parameter(s):
		0: CONFIG - class which is searched
	
	Returns:
	ARRAY of CONFIGs
*/

private ["_class","_result","_subclass"];
_class = [_this,0,configfile >> "",[configfile]] call bis_fnc_param;
_result = [];

for "_c" from 0 to (count _class - 1) do {
	_subclass = _class select _c;
	if (isclass _subclass) then {
		_result set [count _result,_subClass];
	};
};

_result