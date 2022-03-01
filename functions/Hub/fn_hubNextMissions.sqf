/*
	Author: Karel Moricky, adapted by Thomas Ryan
	
	Description:
	Determine the missions the player can select at the hub.
	
	Parameters:
	None.
	
	Returns:
	List of the next missions in an array.
*/

// Determine the missions linked to the current one
_links = getArray (campaignConfigFile >> "Campaign" >> "Missions" >> missionName >> "links");
_links set [0,-1];
_links = _links - [-1];

// Determine the conditions of the links
_linkConditions = getArray (campaignConfigFile >> "Campaign" >> "Missions" >> missionName >> "linkConditions");
_linkConditions set [0,-1];
_linkConditions = _linkConditions - [-1];

{
	// Determine the mission's condition
	_condition = _linkConditions select _forEachIndex;
	
	// If it isn't an immediately accessible mission
	if (_condition != "") then {
		// If the condition does not return true
		if (!(call compile _condition)) then {
			// Remove the mission
			_links set [_forEachIndex,-1];
		};
	};
	
	// If the mission cannot be repeated
	if (missionNamespace getVariable [_x, false]) then {
		if (getNumber (campaignConfigFile >> "Campaign" >> "Missions" >> _x >> "repeat") == 0) then {
			// Remove the mission
			_links set [_forEachIndex,-1];
		};
	};
} forEach _links;

_links = _links - [-1];

// Return available missions
_links