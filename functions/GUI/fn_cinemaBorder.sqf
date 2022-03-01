/*
	Author: Karel Moricky, modified by Thomas Ryan

	Description:
	Moves camera borders.

	Parameter(s):
		_this select 0: NUMBER - Mode (0 - in, 1 - out)
		_this select 1: NUMBER - Duration in seconds (default - 1.5)
		_this select 2: BOOL - Play sound (default - true)

	Returns:
	Nothing
*/

disableSerialization;

_mode = [_this,0,0,[0]] call BIS_fnc_param;
_duration = [_this,1,1.5,[0]] call BIS_fnc_param;
_sound = [_this,2,true,[true]] call BIS_fnc_param;

10 cutRsc ["RscCinemaBorder", "PLAIN"];

_borderDialog = uiNamespace getVariable "RscCinemaBorder";
_borderTop = _borderDialog displayCtrl 100001;
_borderBottom = _borderDialog displayCtrl 100002;
_height = 0.125 * safeZoneH;

switch (_mode) do {
	// In
	case 0: {
		if (_sound) then {playSound "border_in"};
		
		_borderTop ctrlSetPosition [safeZoneX, safeZoneY - _height, safeZoneW, _height];
		_borderTop ctrlCommit 0;
		_borderTop ctrlSetPosition [safeZoneX, safeZoneY,safeZoneW, _height];
		_borderTop ctrlCommit _duration;
		
		_borderBottom ctrlSetPosition [safeZoneX, safeZoneY + safeZoneH, safeZoneW, _height];
		_borderBottom ctrlCommit 0;
		_borderBottom ctrlSetPosition [safeZoneX, safeZoneY + safeZoneH - _height, safeZoneW, _height];
		_borderBottom ctrlCommit _duration;
		
		sleep _duration;
		
		showCinemaBorder true;
	};
	
	// Out
	case 1: {
		if (_sound) then {playSound "border_out"};
		
		showCinemaBorder false;
		
		_borderTop ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, _height];
		_borderTop ctrlCommit 0;
		_borderTop ctrlSetPosition [safeZoneX, safeZoneY - _height, safeZoneW, _height];
		_borderTop ctrlCommit _duration;
		
		_borderBottom ctrlSetPosition [safeZoneX, safeZoneY + safeZoneH - _height, safeZoneW, _height];
		_borderBottom ctrlCommit 0;
		_borderBottom ctrlSetPosition [safeZoneX, safeZoneY + safeZoneH, safeZoneW, _height];
		_borderBottom ctrlCommit _duration;
		
		sleep _duration;
		
		10 cutText ["", "PLAIN"];
	};
};