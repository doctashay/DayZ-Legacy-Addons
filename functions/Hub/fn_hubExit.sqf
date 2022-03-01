/*
	Author: Thomas Ryan
	
	Description:
	Hub systems exit
	
	Parameters:
		_this select 0 (Optional): BOOL - Save date (default: true)
		_this select 1 (Optional): BOOL - Save position (default: true)
		_this select 2 (Optional): BOOL - Save direction (default: true)
	
	Returns:
	True if it exists successfully, false if not
*/

private [
	"_saveDate",
	"_savePos",
	"_saveDir"
];

_saveDate = [_this, 0, true, [true]] call BIS_fnc_param;
_savePos = [_this, 1, true, [true]] call BIS_fnc_param;
_saveDir = [_this, 2, true, [true]] call BIS_fnc_param;

if (isMultiplayer) exitWith {"Hub systems are not multiplayer compatible" call BIS_fnc_error; false};
if (isNil "BIS_player") exitWith {"BIS_player does not exist" call BIS_fnc_error; false};

// Date
BIS_PER_date = if (_saveDate) then {date} else {nil};
saveVar "BIS_PER_date";

// Position
BIS_PER_position = if (_savePos) then {getPosATL vehicle BIS_player} else {nil};
saveVar "BIS_PER_position";

// Direction
BIS_PER_direction = if (_saveDir) then {direction vehicle BIS_player} else {nil};
saveVar "BIS_PER_direction";

true