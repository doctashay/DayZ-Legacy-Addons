_v=_this select 0;
_int = (fuel _v)*(8+random 2);
_t=time;

//Remove weapons/ammo to prevent explosion. Script will create its own explosions (doesnt work?)
removeallweapons _v;

if (local _v) then {_expl="HelicopterExploSmall" createvehicle (getpos _v);};

clearVehicleInit _v;

[_v,_int,_t] spawn {
	_v = _this select 0;
	_int = _this select 1;
	_t = _this select 2;
	
	waitUntil {((getPos _v) select 2) < 2};
	_pos = getpos _v;
	
	if ((!surfaceiswater(_pos)) && (local _v)) then
	{	
		if ((speed _v) < 50) then {
			_velz=velocity _v select 2;
			if (_velz>1) then (_v setvelocity [velocity _v select 0,velocity _v select 1,0]);
			_pos = getPos _v;
			_expl="HelicopterExploBig" createvehicle [_pos select 0,_pos select 1,(_pos select 2) + 1];		//DD: ground explosion - should stay here
			sleep 0.05;
		};
		
		_v setVehicleInit format ["[this, %1, %2]spawn BIS_fnc_effectKilledAirDestructionStage2",_int, _t];
		processInitCommands; 	//ClearvehicleInit done at end of burn script
	}
};