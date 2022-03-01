/*
	Author: Thomas Ryan
	
	Description:
	Set-up the hub weapon pool.
	
	Parameters:
	None.
	
	Returns:
	Bool.
*/

// If a saved weapon pool exists
if (!(isNil "BIS_pool")) then {
	// Determine pool contents
	_mags = [BIS_pool,0,[],[[]]] call BIS_fnc_param;
	_weaps = [BIS_pool,1,[],[[]]] call BIS_fnc_param;
	
	_magClasses = [_mags,0,[],[[]]] call BIS_fnc_paramIn;
	_magCounts = [_mags,1,[],[[]]] call BIS_fnc_paramIn;
	
	{
		// Determine the number of magazines
		_magCount = _magCounts select (_magClasses find _x);
		
		// Add magazines to the weapon pool
		BIS_poolHolder addMagazineCargo [_x,_magCount];
	} forEach _magClasses;
	
	_weapClasses = [_weaps,0,[],[[]]] call BIS_fnc_paramIn;
	_weapCounts = [_weaps,1,[],[[]]] call BIS_fnc_paramIn;
	
	{
		// Determine the number of weapons
		_weapCount = _weapCounts select (_weapClasses find _x);
		
		// Add weapons to the weapon pool
		BIS_poolHolder addWeaponCargo [_x,_weapCount];
	} forEach _weapClasses;
};

true