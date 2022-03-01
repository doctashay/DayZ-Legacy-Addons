/*
This script creates a deployed snare trap on the ground and if there are no players near it, it has a chance to spawn a caught animal in it.
The success chance depends on the surface the trap was placed on.
*/
_user = _this select 0;
_trapItem = _this select 1;
_surfaceType = _this select 2;
_trapEnabled = false;
_damage = damage _trapItem;

_dist = 1;
_dir = direction _user;
_xPos = (getPos _user select 0) + (sin _dir * _dist);
_yPos = (getPos _user select 1) + (cos _dir * _dist);
_pos = [_xPos, _yPos]; //Position of the deployed snare trap on the ground

_wearOut = 0.35; //Added damage after each use
_minPlayerDistance = 100; //Minimal allowed distance to the closest player for the trap to work
_initialWaitTime = 120 + random 300; //After this time after deployment, the trap is activated
_updateinterval = 15; //How often is the trap updated after its activation. (in seconds)

_catchChance = 0;
switch(_surfaceType) do {// 0.0 - 1.0: odds of catching something on every usable surface
	case ("CRBoulders"	): {	_catchChance =	0.10 };
	case ("CRHlina"		): {	_catchChance =	0.15 };
	case ("CRForest1"	): {	_catchChance =	0.50 };
	case ("CRForest2"	): {	_catchChance =	0.50 };
	case ("CRGrass1"	): {	_catchChance =	0.35 };
	case ("CRGrass2"	): {	_catchChance =	0.35 };
	case ("CRGrit1"		): {	_catchChance =	0.10 };
	case ("cesta"		): {	_catchChance =	0.30 };
};
//hint format["_surfaceType = %1\n_catchChance = %2",_surfaceType,_catchChance]; //For debugging
_user playmove "amelpercmstpsraswnondnon_throwc"; //Throw item animation

sleep 1;

deleteVehicle _trapItem; //Remove the item from player's hands
_trapItem = objNull;
_trapObj = "snareTrapDeployed" createVehicle _pos; //re-create it on the ground as an object
_trapObj setpos _pos; //Set position precisely
_trapObj setDir getDir _user;
_trapObj setdamage _damage;//Item wear-out
_damage = _damage + _wearOut;
[_user,"I have deployed the snare trap.","colorStatusChannel"] call fnc_playerMessage;

sleep _initialWaitTime; //Wait some time to prevent player re-connect exploit.

_fncTrapUsed = 
{
	_obj = _this; //The trap
	deleteVehicle _obj;
	_objNew = "snareTrapUsed" createVehicle _pos;
	_objNew setdir random 360; //Rotate the trap so it looks like the animal struggled with it.
	_objNew setdamage _damage; //Also damage it a little
	_objNew;
};

while {(!_trapEnabled) and (!isNull _trapObj)} do 
{
	//Find closest player
	_distance = 9999999;
	{
		_distanceNew = _x distance _trapObj;
		if (  _distanceNew < _distance ) then
		{
			_distance = _distanceNew;
		};
	} forEach players;

	//Activate the trap if the closest player is far enough
	if ( _distance > _minPlayerDistance ) then
	{
		_trapEnabled = true;
	};
	//Activation: decide if successful or not
	if ( _catchChance > random 1 and _trapEnabled ) then
	{
		//SUCCESSFUL CATCH!
		_trapObj = _trapObj call _fncTrapUsed; //Respawn the trap
		_rabbit = createAgent ["RabbitV2", _pos, [], 0, "NONE"];
		_xPosBody = (getPos _trapObj select 0) + (sin (direction _trapObj +20) * 0.25);
		_yPosBody = (getPos _trapObj select 1) + (cos (direction _trapObj +20) * 0.25);
		_rabbit setpos [_xPosBody, _yPosBody, getPos _trapObj select 2];
		_rabbit setdir (direction _trapObj);
		_rabbit playMove "RabbitV2_DeathInSnare"; //Place the rabbit into the trap correctly
		sleep 1;
		_rabbit setDamage 1;
	}else{ if ( _trapEnabled ) then
		{
			//UNSUCCESSFUL CATCH!
			_trapObj call _fncTrapUsed;
		};
	};
	sleep _updateinterval;
};