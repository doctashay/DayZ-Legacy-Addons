_vehicle = _this select 0;
_vehiclePart = _this select 1;
_damage = _this select 2;

_vehicleType = typeOf _vehicle;
_theImpulse = [0, 10, 0];

//diag_log format [ "vehicle:%1, part:%2, dmg:%3, type:%4", _vehicle, _vehiclePart, _damage, _vehicleType];

_doImpulse =
{
	_item = _this select 0;
	_offset = _this select 1;
	_impulseOri = _this select 2;
	
	_ok = moveToMyWorldPos _item;
	_ori = getDir _vehicle;

	_offsetX = (_offset select 0) * 0.01;
	_offsetY = (_offset select 1) * 0.01;

	_posItemX = (getPosASL _item) select 0;
	_posItemY = (getPosASL _item) select 1;	
	
	_posItemX = _posItemX + (cos _ori * _offsetX) + (sin _ori * _offsetY);
	_posItemY = _posItemY + (cos _ori * _offsetY) + (sin _ori * _offsetX);
	_posItemZ = ( getPosASL _item select 2) + ((_offset select 2) *0.01);

	//diag_log format [ "x:%1, y:%2, z:%3", _posItemX, _posItemY, _posItemZ];

	_item setPosASL [_posItemX,_posItemY,_posItemZ];

	_ori = vectorDir _vehicle;

	_impulseX = (_theImpulse select 0) + ( (_ori select 0) * (_impulseOri select 0)) + ( (_ori select 0) * (_impulseOri select 2));
	_impulseY = (_theImpulse select 2) + ( (_ori select 1) * (_impulseOri select 2)) + ( (_ori select 1) * (_impulseOri select 0));
	_impulseZ = (_theImpulse select 1) + (_impulseOri select 1);
	
	//diag_log format [ "%4:: Impx:%1, Impy:%2, Impz:%3", _impulseX, _impulseY, _impulseZ, _vehiclePart];
	
	_item applyImpulse [_impulseX, _impulseZ, _impulseY];
};


if ( _vehiclePart == 'light_left') then
{
	_item = _vehicle itemInSlot 'LightBulb';
	if ( !(isNull _item) ) then
	{
		_item setDamage _damage;
	};
};

//---
if ( _vehiclePart == 'light_right' ) then
{
	_item = _vehicle itemInSlot 'LightBulb';
	if ( !(isNull _item) ) then
	{
		_item setDamage _damage;
	};
};

//---
if ( _vehiclePart == 'engine' ) then
{
	_item = _vehicle itemInSlot 'SparkPlug';
	if ( !(isNull _item) ) then
	{
		_item setDamage _damage;
	};
};

//---
if ( _vehiclePart == 'engine' ) then
{
	_item = _vehicle itemInSlot 'GlowPlug';
	if ( !(isNull _item) ) then
	{
		_item setDamage _damage;
	};
};

//---
if ( _vehiclePart == 'engine' ) then
{
	_item = _vehicle itemInSlot 'TruckRadiator';
	if ( !(isNull _item) ) then
	{
		_item setDamage _damage;
	};
};

//---
if ( _vehiclePart == 'engine' ) then
{
	_item = _vehicle itemInSlot 'CarRadiator';
	if ( !(isNull _item) ) then
	{
		_item setDamage _damage;
	};
};


//---
if ( _vehiclePart == 'battery' ) then
{
	_item = _vehicle itemInSlot 'TruckBattery';
	if ( !(isNull _item) ) then
	{
		_item setDamage _damage;
	};
};

//---
if ( _vehiclePart == 'battery' ) then
{
	_item = _vehicle itemInSlot 'CarBattery';
	if ( !(isNull _item) ) then
	{
		_item setDamage _damage;
	};
};

switch ( _vehicleType ) do
{
	//------------------------------------------------------------------------------
	case "OffroadHatchback" :
	{
		switch ( _vehiclePart ) do
		{
			case 'wheel_1_1_steering' :
			{
				_item = _vehicle itemInSlot 'NivaWheel_1_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_1_2_steering' :
			{
				_item = _vehicle itemInSlot 'NivaWheel_1_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_1_steering' :
			{
				_item = _vehicle itemInSlot 'NivaWheel_2_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_2_steering' :
			{
				_item = _vehicle itemInSlot 'NivaWheel_2_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			//---
			case 'doors_driver' :
			{
				_item = _vehicle itemInSlot 'NivaDriverDoors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[15,0,5],[-10,0,0]] call _doImpulse;
					};
				};
			};
			
			//---
			case 'doors_codriver' :
			{
				_item = _vehicle itemInSlot 'NivaCoDriverDoors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[-15,0,5],[10,0,0]] call _doImpulse;
					};
				};
			};

			//---
			case 'doors_hood' :
			{
				_item = _vehicle itemInSlot 'NivaHood';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[0,40,10],[0,0,20]] call _doImpulse;
					};
				};
			};

			//---
			case 'doors_trunk' :
			{
				_item = _vehicle itemInSlot 'NivaTrunk';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[0,-10,5],[0,-15,10]] call _doImpulse;
					};
				};
			};
		};
	};

	//------------------------------------------------------------------------------
	case "CivilianSedan" :
	{
		switch ( _vehiclePart ) do
		{
			case 'wheel_1_1_steering' :
			{
				_item = _vehicle itemInSlot 'CivSedanWheel_1_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_1_2_steering' :
			{
				_item = _vehicle itemInSlot 'CivSedanWheel_1_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_1_steering' :
			{
				_item = _vehicle itemInSlot 'CivSedanWheel_2_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_2_steering' :
			{
				_item = _vehicle itemInSlot 'CivSedanWheel_2_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'doors_driver' :
			{
				_item = _vehicle itemInSlot 'CivSedanDriverDoors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[15,0,5],[-10,0,0]] call _doImpulse;
					};
				};
			};

			//---
			case 'doors_codriver' :
			{
				_item = _vehicle itemInSlot 'CivSedanCoDriverDoors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[-15,0,5],[10,0,0]] call _doImpulse;
					};
				};
			};

			//---
			case 'doors_cargo1' :
			{
				_item = _vehicle itemInSlot 'CivSedanCargo1Doors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[15,0,5],[-10,0,0]] call _doImpulse;
					};
				};
			};

			//---
			case 'doors_cargo2' :
			{
				_item = _vehicle itemInSlot 'CivSedanCargo2Doors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[-15,0,5],[10,0,0]] call _doImpulse;
					};
				};
			};

			//---
			case 'doors_hood' :
			{
				_item = _vehicle itemInSlot 'CivSedanHood';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[0,40,10],[0,0,20]] call _doImpulse;
					};
				};
			};

			//---
			case 'doors_trunk' :
			{
				_item = _vehicle itemInSlot 'CivSedanTrunk';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[0,-40,10],[0,0,-20]] call _doImpulse;
					};
				};
			};
		};
	};

	//------------------------------------------------------------------------------
	case "TransitBus" :
	{
		//---
		switch ( _vehiclePart ) do
		{
			case 'wheel_1_1_steering' :
			{
				_item = _vehicle itemInSlot 'BusWheel_1_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_1_2_steering' :
			{
				_item = _vehicle itemInSlot 'BusWheel_1_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_1_steering' :
			{
				_item = _vehicle itemInSlot 'BusWheel_2_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_2_steering' :
			{
				_item = _vehicle itemInSlot 'BusWheel_2_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'doors_hood' :
			{
				_item = _vehicle itemInSlot 'BusHood';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[0,0,0],[0,-1,0]] call _doImpulse;
					};
				};
			};
		};
	};
	
	//------------------------------------------------------------------------------
	case "V3S_Chassis" :
	{
		switch ( _vehiclePart ) do
		{
			case 'wheel_1_1_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_1_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_1_2_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_1_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_1_3_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_1_3';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_1_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_2_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_2_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_2_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};
			case 'wheel_2_3_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_2_3';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};
			//---
			case 'doors_driver' :
			{
				_item = _vehicle itemInSlot 'V3SDriverDoors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[15,0,5],[-10,0,0]] call _doImpulse;
					};
				};
			};

			//---
			case 'doors_codriver' :
			{
				_item = _vehicle itemInSlot 'V3SCoDriverDoors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[-15,0,5],[10,0,0]] call _doImpulse;
					};
				};
			};
			
			//---
			case 'doors_hood' :
			{
				_item = _vehicle itemInSlot 'V3SHood';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if ( damage _item >= 1 ) then
					{
						[_item,[0,40,10],[0,0,20]] call _doImpulse;
					};
				};
			};
		};
	};

	//------------------------------------------------------------------------------
	case "V3S_Cargo" :
	{
		switch ( _vehiclePart ) do
		{
			case 'wheel_1_1_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_1_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_1_2_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_1_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_1_3_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_1_3';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_1_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_2_1';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};

			case 'wheel_2_2_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_2_2';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};
			case 'wheel_2_3_steering' :
			{
				_item = _vehicle itemInSlot 'V3SWheel_2_3';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
				};
			};
			//---
			case 'doors_driver' :
			{
				_item = _vehicle itemInSlot 'V3SDriverDoors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if (_vehicle getHitPointDamage 'HitDoorsDriver' >= 1 ) then
					{
						_ok = moveToMyWorldPos _item;
						_item applyImpulse _theImpulse;
					};
				};
			};

			//---
			case 'doors_codriver' :
			{
				_item = _vehicle itemInSlot 'V3SCoDriverDoors';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if (_vehicle getHitPointDamage 'HitDoorsCoDriver' >= 1 ) then
					{
						_ok = moveToMyWorldPos _item;
						_item applyImpulse _theImpulse;
					};
				};
			};
			
			//---
			case 'doors_hood' :
			{
				_item = _vehicle itemInSlot 'V3SHood';
				if ( !(isNull _item) ) then
				{
					_item setDamage _damage;
					if (_vehicle getHitPointDamage 'HitDoorsHood' >= 1 ) then
					{
						_ok = moveToMyWorldPos _item;
						_item applyImpulse _theBigImpulse;
					};
				};
			};
		};
	};
};

_damage