_v = _this select 0;
_int = _this select 1;
_t = _this select 2;
_pos = getpos _v;


// Particle effects
_smoke = "#particlesource" createVehicleLocal _pos;
_smoke attachto [_v,[0,0,0],"destructionEffect1"];
_smoke setParticleParams [["\DZ\data\data\ParticleEffects\Universal\Universal_02", 8, 0, 40],
			"", "Billboard", 1, 7, [0, 0, 0], [0, 0, 0], 1, 1.275, 1, 0, [10,18,24],
			[[0.1,0.1,0.1,0.6],[0.1,0.1,0.1,0.35],[0.1,0.1,0.1,0.01]], [0.5], 0.1, 0.1, "", "", _v];
_smoke setParticleRandom [2, [2, 2, 2], [1.5, 1.5, 3.5], 0, 0, [0, 0, 0, 0], 0, 0];
_smoke setDropInterval 0.02;

_dirt = "#particlesource" createVehicleLocal _pos;
_dirt attachto [_v,[0,0,0],"destructionEffect1"];
_dirt setParticleParams [["\DZ\data\data\ParticleEffects\Universal\Universal",16,12,9,0], "", "Billboard", 1, 5, [0, 0, 0], [0, 0, 5], 0, 5, 1, 0, [7,12],
	  [[0.1,0.1,0.1,0.6],[0.1,0.1,0.1,0.35],[0.1,0.1,0.1,0.01]], [1000], 0, 0, "", "", _v,360];
_dirt setParticleRandom [0, [1, 1, 1], [1, 1, 2.5], 0, 0, [0, 0, 0, 0.5], 0, 0];
_dirt setDropInterval 0.05;

// ["JmenoModelu"],"NazevAnimace","TypAnimace",RychlostAnimace,DobaZivota,[Pozice],[SilaPohybu],Rotace,Hmotnost,Objem,Rubbing,[Velikost],[Barva],
// [FazeAnimace],PeriodaNahodnehoSmeru,IntensitaNahodnehoSmeru,"OnTimer","PredZnicenim","Objekt";

	//creating ground craters
if ((speed _v) > 15) then {	
	_i=0;
	while {((speed _v) > 60) && (_i < 30)} do
	{
		_pos=getpos _v;
		_xv=velocity _v select 0;
		_yv=velocity _v select 1;
		_dir = abs(_xv atan2 _yv);
		_speed = (speed _v);
		
		_Crater= "CraterLong" createvehiclelocal [_pos select 0, _pos select 1, 0];
		if ((random 1) > 0.5) then {
			_Crater setdir (_dir + 170 + (random 20))
		} else {
			_Crater setdir (_dir - 10 + (random 20))
		};
		_terH = getTerrainHeightASL [_pos select 0, _pos select 1];
		if (_terH > 0) then {
			_Crater setpos [_pos select 0, _pos select 1, -0.05];
		} else {
			_Crater setpos [_pos select 0, _pos select 1, (-0.05 + _terH)];
		};
		_speed = (speed _v);
		_velz=velocity _v select 2;

		if (_velz>1) then {_v setvelocity [_xv/1.3,_yv/1.3,0]}
		else {_v setvelocity [_xv/1.2,_yv/1.2,velocity _v select 2]};

		_tv=abs(_xv)+abs(_yv)+abs(_zv);
		if (_tv>2) then {_dr=1/_tv} else {_dr=1};
		_smoke setDropInterval _dr*1.5;
		_dirt setDropInterval _dr;

		sleep (0.25 - (_speed / 1000));
		_i = _i + 1;
	};
	
	while {(((speed _v) > 0.1) && ((speed _v) < 60)) && (_i < 60)} do
	{
		_pos=getpos _v;
		_xv=velocity _v select 0;
		_yv=velocity _v select 1;
		_dir = abs(_xv atan2 _yv);
		_speed = (speed _v);
		
		_Crater= "CraterLong_small" createvehiclelocal [_pos select 0, _pos select 1, 0];
		if ((random 1) > 0.5) then {
			_Crater setdir (_dir + 165 + (random 20))
		} else {
			_Crater setdir (_dir - 15 + (random 20))
		};
		_terH = getTerrainHeightASL [_pos select 0, _pos select 1];
		if (_terH > 0) then {
			_Crater setpos [_pos select 0, _pos select 1, -0.05];
		} else {
			_Crater setpos [_pos select 0, _pos select 1, (-0.05 + _terH)];
		};
		_speed = (speed _v);
		_velz=velocity _v select 2;

		if (_velz>1) then {_v setvelocity [_xv/1.3,_yv/1.3,0]}
		else {_v setvelocity [_xv/1.2,_yv/1.2,velocity _v select 2]};

		_tv=abs(_xv)+abs(_yv)+abs(_zv);
		if (_tv>2) then {_dr=1/_tv} else {_dr=1};
		_smoke setDropInterval _dr*1.5;
		_dirt setDropInterval _dr;

		sleep (0.25 - (_speed / 1000));
		_i = _i + 1;
	};
};

deleteVehicle _smoke;
deleteVehicle _dirt;

/*
_v setvelocity [0,0,-0.1];
if (local _v) then
{
	_v setVehicleInit format ["[this, %1, %2,false,true]spawn BIS_fnc_effectKilledBurn",_int, _t];
	processInitCommands; //ClearvehicleInit done at end of burn script
	[_v,_int,false] spawn BIS_fnc_effectKilledSecondaries;
};
sleep 0.5;
_v setvelocity [0,0,-0.01];
*/