private ["_u", "_sh","_i","_no","_int","_pos1","_li","_pos2","_devCoef","_devPos1","_devPos2","_pos"];
_u = _this select 0;
_sh = nearestobject [_u, _this select 4];
_pos1 = getPos _sh;

//Light
[_sh] spawn {
	_sh = _this select 0;
	_li = "#lightpoint" createVehicleLocal getpos _sh;
	_li setLightBrightness 0.8;
	_li setLightAmbient[0.8, 0.6, 0.6];
	_li setLightColor[0.8, 0.6, 0.6];
	_li setLightAttenuation [0,0,0,10];
	_li lightAttachObject [_sh, [0,0,0]];
	
	waitUntil {((getPos _sh) select 2) < 0.3};
	deleteVehicle _li;
};

//Smoke
[_sh, _pos1] spawn {
	_sh = _this select 0;
	_pos1 = _this select 1;
	_arg = 0.6;
	
	sleep 0.1;
	_pos2 = getPos _sh;
	_devPos1 = [((_pos2 select 0) - (_pos1 select 0)),((_pos2 select 1) - (_pos1 select 1)),((_pos2 select 2) - (_pos1 select 2))];
	_devCoef = 5.2/(_pos1 distance _pos2);					//distance from rocket coef
	_devPos2 = [(_devPos1 select 0) * _devCoef,(_devPos1 select 1) * _devCoef,(_devPos1 select 2) * _devCoef];
	_pos = [((_pos1 select 0)-((_devPos2 select 0)*_arg)),((_pos1 select 1)-((_devPos2 select 1)*_arg)),((_pos1 select 2)-((_devPos2 select 2)*_arg))];
	
	_i=1;
	_no=26+random 6;
	while {_i<_no} do {
		drop [["\DZ\data\data\ParticleEffects\Universal\Universal", 16, 7, 48],
		"", "Billboard", 1, 6+random 3,
		[(_pos select 0) + (-0.5 + random 1), (_pos select 1) + (-0.5 + random 1), (_pos select 2) + (-0.5 + random 1)],
		[(-4 * (_devPos2 select 0)) + (-3 + random 6),(-4 * (_devPos2 select 1)) + (-3 + random 6),-0.75 + random 1.5],
		6, 1.275, 1, 0.4, 
		[2.5,5+random 1.8],
		[[1,1,1,0],[1,1,1,0.35],[1,1,1,0.23],[1,1,1,0.16],[1,1,1,0.09], [1,1,1,0.02]],
		[2,0.7,0.5],0.1,0.1,"","",""];
		_i=_i+1;
	};
};

_i=1;
_no=12+random 2;
while {_i<_no}
do
	{
	drop [["\DZ\data\data\ParticleEffects\Universal\Universal", 16, 7, 48],
	"", "Billboard", 1, 4+random 2,
	[-0.5 + random 1, 2 + random 0.5, -0.5 + random 1],
	[-0.8+random 1.6,-0.8+random 1.6,-0.8+random 1.6],
	1, 1.275, 1, 0.4, 
	[2.5,5+random 1.8],
	[[1,1,1,0],[1,1,1,0.22],[1,1,1,0.15],[1,1,1,0.1],[1,1,1,0.06], [1,1,1,0.02]],
	[2,0.7,0.5],0.1,0.1,"","",_sh];
	_i=_i+1;
	};

//Dust
_null = [_u] execVM "\DZ\data\data\ParticleEffects\SCRIPTS\muzzle\cannondust.sqf";
// ["JmenoModelu"],"NazevAnimace","TypAnimace",RychlostAnimace,DobaZivota,[Pozice],[SilaPohybu],Rotace,Hmotnost,Objem,Rubbing,[Velikost],[Barva],
// [FazeAnimace],PeriodaNahodnehoSmeru,IntensitaNahodnehoSmeru,"OnTimer","PredZnicenim","Objekt";
