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
_result = 	(quantity _this) >= (maxQuantity _this);
_result