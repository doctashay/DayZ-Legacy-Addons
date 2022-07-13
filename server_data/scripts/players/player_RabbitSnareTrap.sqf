Hint "Creating trap...";

player playAction "Surrender";
sleep 3;

_pauseDistance = 10;
_timer = round( 5 + random (5) );
_failChance = 50;
_x = getpos player select 0;
_y = getpos player select 1;
_dir = getdir player;
_thing = createVehicle 
	[
		"Land_Campfire", 
		[_x + (4*sin(_dir)), _y + (4*cos(_dir)), 0], 
		[], 
		0, 
		"NONE"
	];

while {_timer > 0} do
{	
	if ( player distance _thing > _pauseDistance ) then 
	{
		_timer = _timer - 1;
		hintSilent format ["Remaining time: %1", _timer];
		
		if (_timer <= 0) then 
		{
			if ( random 100 > _failChance ) then
			{
				_thing inflame true;
				hint "Trap successfull!";
			}else
			{
				hint "Trap failed!";
				deletevehicle _thing;
			};
		}
	}
	else
	{
	hintSilent "You are too close!";
	};
	
	sleep 1;
};