//Define values
_catchChance = 50; //Chance of catching something
_trap = _this;
_trap setVariable ['internalenergy', 0.2]; //The first timer
_wearOut = 0.2; //Added damage after each use
_minPlayerDistance = 5; //Minimum distance from closest player for the trap to work
_trapEnabled = true;
_pos = getPos _trap;

//Find closest player
_distance = 9999999;
_closestPlayer = 
{
	_distanceNew = _x distance _trap;
	if (  _distanceNew < _distance ) then
	{
		_distance = _distanceNew;
	};
} forEach players;

//Check if the closest player is not too close
if ( _distance < _minPlayerDistance ) then
{
	_trap setVariable ['internalenergy', 0.2];
	_trapEnabled = false;
	_trap powerOn true;
}else{
	_trap setdamage (damage _trap + _wearOut);
};

//Decide whenever trap catches something or not
if ( _catchChance > random 100 and _trapEnabled ) then
{	
	_rabbit = createAgent ['RabbitV2', _pos, [], 0, 'NONE'];
	_rabbit setDamage 1;
	hint "The trap has caught something!";
}else
{
	if ( _trapEnabled ) then 
	{
		hint "The trap has failed!";
	};
};