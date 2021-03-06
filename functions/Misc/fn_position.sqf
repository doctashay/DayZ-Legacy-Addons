/*
	Author: Karel Moricky

	Description:
	Return position

	Parameter(s):
	_this:
		ARRAY - position in format [x,y] or [x,y,z]
		OBJECT - object
		LOCATION - location
		STRING - marker
		CODE - result of code

	Returns:
	ARRAY - position in format [x,y] or [x,y,z]
*/

private ["_pos"];
_pos = [[_this],0,[0,0,0],[[],objnull,locationnull,"",{}],[2,3]] call bis_fnc_param;

if (typename _this == typename []) then {
	if (count _this in [2,3]) then {_pos = _this};
};

switch (typename _pos) do {

	case (typename []): {
		_pos
	};

	case (typename ""): {
		markerpos _pos
	};

	case (typename {}): {
		call _pos
	};

	case (typename objnull): {
		position _pos
	};

	case (typename locationnull): {
		locationposition _pos
	};
};