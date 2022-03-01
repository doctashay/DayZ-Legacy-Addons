scriptName "fn_flies.sqf";
/*
	Author: Karel Moricky & Tomas Pavlis

	Description:
	Spawns flies around position.

	Parameter(s):
	_this select 0: ARRAY - Position of flies
	_this select 1 (Optional): NUMBER - area size
	_this select 2 (Optional): NUMBER - number of crows

	Returns:
	ARRAY - list of all spawned crows
*/

_pos = _this select 0;
_interval = if (count _this > 1) then {_this select 1} else {-1};
_size = if (count _this > 2) then {_this select 2} else {-1};

if (_interval <= 0) then {_interval = 0.1;};
if (_size <= 0) then {_size = 1;};

// FIXED PARAMS
_source = "#particlesource" createVehicleLocal _pos;
_source setParticleParams 
/*Sprite*/		[["\DZ\misc3\DeadBodies\fly.p3d", 1, 0, 1, 0], "", // File, Ntieth, Index, Count, Loop(Bool)
/*Type*/ 			"spaceObject",
/*TimmerPer*/ 		1,
/*Lifetime*/ 		4,
/*Position*/		[0, 0, 0],
/*MoveVelocity*/	[0, 0, 0.5],
/*Simulation*/		1, 1.30, 1, 0, //rotationVel, weight, volume, rubbing
/*Scale*/		[0.03, 0.03, 0.03, 0],
/*Color*/		[[1, 1, 1, 1],[1, 1, 1, 1]],
/*AnimSpeed*/		[1.5,0.5],
/*randDirPeriod*/	0.01,
/*randDirIntesity*/	0.08,
/*onTimerScript*/ 	"",
/*DestroyScript*/ 	"",
/*Follow*/ 		_this];

// RANDOM / TOLERANCE PARAMS
_source setParticleRandom
/*LifeTime*/ 		[2,
/*Position*/		[_size, _size, 0.25], 
/*MoveVelocity*/	[0, 0, 0],
/*rotationVel*/ 	1, 
/*Scale*/		0.02, 
/*Color*/		[0, 0, 0, 0.1],
/*randDirPeriod*/	0.01,
/*randDirIntesity*/	0.03,
/*Angle*/ 		10];

_source setDropInterval _interval;
_sound = createSoundSource["Sound_Flies",_pos,[],0];

[_source,_sound]