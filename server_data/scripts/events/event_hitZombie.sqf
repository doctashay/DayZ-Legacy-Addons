_agent = _this select 0;
_selection = _this select 1;
_damage = _this select 2;
_source = _this select 3;
_bone = (((_this select 5) select 1) select 0);
if ( typeName _bone == "STRING" ) then
{
	switch (_bone) do
	{
		case "head": 
		{
			//diag_log format ["ZOMBIE: Headshot knockdown %1",_agent];
			_damage = _damage + random (_damage * 3);
			if (!isUnconscious _agent) then
			{
				_agent playAction ["knockDownBack",{_this setUnconscious false}];
				_agent setUnconscious true;
			};
		};
	};
};
if ((itemInHands _source) isKindOf "Chainsaw" )then{
	if ((isOn (itemInHands _source)))then{
		_damage = _damage + 1;
	}else{
		_damage = _damage + 0.35;
	};
};

if ((itemInHands _source) isKindOf "CattleProd")then{
	_battery = (itemInHands _source) itemInSlot "BatteryD"; 
	_batterypower = _battery getVariable ["power",0];
	if (_batterypower >= 5000)then{
		if (!isUnconscious _agent) then
			{
				_agent playAction ["knockDownBack",{_this setUnconscious false}];
				_agent setUnconscious true;
			};
		_batterypower=_batterypower-5000;
		_battery setVariable ["power",_batterypower];
		_damage = _damage + 0.5;
	};
};

if ((itemInHands _source) isKindOf "StunBaton")then{
	_battery = (itemInHands _source) itemInSlot "BatteryD"; 
	_batterypower = _battery getVariable ["power",0];
	if (_batterypower >= 2000)then{
		if (!isUnconscious _agent) then
			{
				_agent playAction ["knockDownBack",{_this setUnconscious false}];
				_agent setUnconscious true;
			};
		_batterypower=_batterypower-2000;
		_battery setVariable ["power",_batterypower];
		_damage = _damage + 0.5;
	};
};
//hint format["hit: %1\nDamage: %2\nBone: %3",_selection,(_damage),_bone];
_damage
