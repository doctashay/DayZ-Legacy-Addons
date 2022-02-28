/*
	File: inString.sqf
	Author: Rocket Himself
	
	Description:
	max ammo for an object
	
	Parameter(s):
	_this:	object
	
	Returns:
	Boolean (true if object is at max ammo count).
*/

private ["_itemType","_max","_qty","_result"];
_result = 	(_this getVariable["quantity",0]) >= getNumber(configFile >> "CfgVehicles" >> typeOf _this >> "stackedMax");
_result