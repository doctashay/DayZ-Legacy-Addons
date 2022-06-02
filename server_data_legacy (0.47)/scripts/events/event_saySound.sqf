private["_unit","_type","_chance","_rnd","_sound","_local","_dis"];
_unit = _this select 0;
_type = _this select 1;

_doSound = true;
if (count _this > 2) then
{
	_rnd = (0 min (_this select 2)) max 1;
	//random check
	if ((random 1) < _rnd) then {}
	else
	{
		_type == ""
	};
};

//[_person,"craft_rounds"] call event_saySound;
if (_type == "") exitWith {};

_config = 	configFile >> "CfgActionSounds" >> _type;
_sounds = 	getArray (_config >> "sounds");
_distance = getNumber (_config >> "distance");

if (count _sounds > 0) then
{
	_sound = _sounds select (floor random (count _sounds));
	_unit say3D _sound;
};