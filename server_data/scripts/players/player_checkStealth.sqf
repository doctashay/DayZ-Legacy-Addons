private["_agent","_surfaceType","_isInside","_vel","_speed","_pos","_scaleLight","_scaleSound","_visibility","_audibility","_anim","_skeleton","_animPose","_visiblePose","_audiblePose","_visibleTerrain","_visibleSpeed","_audibleSpeed","_audibleTerrain","_audial","_visual","_array"];
/*
	Run for each player during each tick, checks the players stealth levels for sight and sound
	and then returns an array of values, used for zombie detection. Use is made of global variables
	that provide scales for values according to environmental factors.
*/

_agent = 		_this select 0;
_surfaceType = 	_this select 1;
_isInside = 	_this select 2;
_vel = 		velocity (vehicle _agent);
_speed = 	(_vel distance [0,0,0]);
_pos = 		getPosATL _agent;

//Get global variables set under server tasks
_scaleLight = worldLightScale;
_scaleSound = worldSoundScale;

//Ensure zero or above
_visibility = 	100;
_audibility = 	50;
_scaleLight = 	_scaleLight max 0;

//Visibility
_anim = 	animationState _agent;
_skeleton = getText (configFile >> "CfgVehicles" >> typeOf _agent >> "moves");
_animPose = getText (configFile >> _skeleton >> "states" >> _anim >> "bodyPosition");
_visiblePose =
	switch (_animPose) do 
	{ 
		case "down": 	{0.05};
		case "prone": 	{0.05};
		case "kneel": 	{0.25}; 
		case "stand": 	{1.00}; 
		default 		{1.00};
	};
_audiblePose =
	switch (_animPose) do 
	{ 
		case "down": 	{0.05};	
		case "prone": 	{0.3}; 
		case "kneel": 	{0.8}; 
		case "stand": 	{1.0}; 
		default 		{1.0};
	};
_agent setVariable ["bodyPosition",_animPose];
_visibleTerrain = 	getNumber (configFile >> "CfgSurfaces" >> _surfaceType >> "visible" >> _animPose);
_visibleSpeed = 	_speed * (_visiblePose * 20);

//Audibility
_audibleSpeed = 	_speed * (_audiblePose * 10);
_audibleTerrain = getNumber (configFile >> "CfgSurfaces" >> _surfaceType >> "audibility");

//Work out result
_audial = 	round
	(
		(
			(_audibleSpeed * _audiblePose * _audibleTerrain)
		) * _scaleSound
	);
_visual = round
	(
		(
			(_visibility * _visiblePose * _visibleTerrain) + _visibleSpeed
		) * _scaleLight
	);
_array = [_audial,_visual];
_array