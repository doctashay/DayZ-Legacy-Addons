_agent = _this select 0;
_selection = _this select 1;
_damage = _this select 2;
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
//hint format["hit: %1\nDamage: %2\nBone: %3",_selection,(_damage),_bone];
_damage