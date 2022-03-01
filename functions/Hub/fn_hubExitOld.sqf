/*
	Author: Thomas Ryan
	
	Description:
	Execute code defined as BIS_fnc_endMission_code when Hub missions end.
	
	Parameters:
	None.
	
	Returns:
	Nothing.
*/

// If end code exists
if (!(isNil "BIS_fnc_endMission_code")) then {
	// Execute the defined end code
	[] call BIS_fnc_endMission_code;
};