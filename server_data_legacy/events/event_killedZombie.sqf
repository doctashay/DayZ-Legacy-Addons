private["_agent","_uid"];
_agent = _this select 0;
_killer = _this select 1;
//respawn new
diag_log format ["ZOMBIE DIED: %1 spawned",_zombie];

//cleanup
sleep 5;
deleteVehicle _agent;
/*
_originalPos = getPosATL _agent;
_testPos = _originalPos findEmptyPosition [200, 400];
if (count _testPos > 0) then
{
	_zombie = _testPos call fnc_spawnZombie;
	
	diag_log format ["NEW ZOMBIE: %1 spawned at %2",typeOf _zombie,_originalPos];

	if ((itemInHands _killer) isKindOf "DefaultWeapon") then
	{
		_zombie reveal [_killer, 4];
	};
};
*/
_rnd = floor(random(count DZ_ZombieTypes));
_zombie = createAgent [(DZ_ZombieTypes select _rnd),_this,[],500,"NONE"];
_zombie addeventhandler ["HandleDamage",{_this call event_hitZombie} ];
_zombie addeventhandler ["killed",{null = _this spawn event_killedZombie} ];
_zombie setDir floor(random 360);
if ((itemInHands _killer) isKindOf "DefaultWeapon") then
{
	_zombie reveal [_killer, 4];
};