/*
This script creates a deployed bear trap on the ground and if there is any player,zombie,animal in nearby radius, it has a chance to be caught in it.
The success chance depends on the surface the trap was placed on, and damage of trap itself.
*/
_funcToCall = _this select 0;
_user = _this select 1;
_trapItem = _this select 2;
_damage = damage _trapItem;

_dist = 0;
_dir = direction _user;
_xPos = (getPosATL _user select 0) + (sin _dir * _dist);
_yPos = (getPosATL _user select 1) + (cos _dir * _dist);
_zPos = (getPosATL _user select 2) ;
_pos = [_xPos, _yPos, _zPos]; 		//Position of the deployed snare trap on the ground

_wearOut = 0.15; 			//Added damage after trap activation
_minDistance = 1.00;  		//Minimal allowed distance to the closest player for the trap to work
_initialWaitTime = 1.5; 	//After this time after deployment, the trap is activated
_updateinterval = 0.5; 		//How often is the trap updated after its activation. (in seconds)
//_damagePlayer = 0.25; 		//How much damage player gets when caught
_catchChance = 1.0;			//Chance for catch

_fnc_explode_fire = 
{
	 private["_item","_explosion_pos"];
	 
	 _item = _this;
	 _trapItem setVariable ["isEnabled",false];
	 
	 //get explosion position 
	 _explosion_pos = getPosATL _item;
	 //spawn explosion
	 _explosion = 'Land_A_FuelStation_Feed' createVehicle _explosion_pos;
	 _explosion setPosATL _explosion_pos;
	 _explosion setDamage 1;
	 
	 //delete both
	 deleteVehicle _explosion;
	 deleteVehicle _item;
};

_fncManipulateWithTrap = 
{
	//[_user,"_fncManipulateWithTrap","colorStatusChannel"] call fnc_playerMessage;
	if ( _damage > random 1 ) exitWith
	{
		_trapItem call _fnc_explode_fire;
		[_user, "You've been hurt by improper manipulation with land mine","colorStatusChannel"] call fnc_playerMessage;
		false
	};
	true
};

_fncDeactivateTrap = 
{
	//[_user,"_fncDeactivateTrap","colorStatusChannel"] call fnc_playerMessage;
	_obj = _this; //The trap
	_damage = _damage + _wearOut;
	_obj setdamage (_damage); //Also damage it a little
	_obj setVariable ["isEnabled",false];

	_user playAction ['PlayerCraft',{}];
	sleep 7;
	_trapManipulationResult = _trapItem call _fncManipulateWithTrap;
	if ( _trapManipulationResult ) then
	{
		[_user,"I have deactivated land mine.","colorStatusChannel"] call fnc_playerMessage;
	};
};


_fncPickupTrap = {
	_user = _this select 1;
	_trap = _this select 2;
	if (_trap getVariable ["isEnabled",false]) then
	{
		_trap call _fnc_explode_fire;
	};
	_item = ['Trap_LandMine', _user] call player_addInventory;  
	_item setdamage (damage _trap);
	
	deleteVehicle _trap;
};

_fncActivateTrap =
{
	_obj = _this; //The trap

	_trapManipulationResult = _trapItem call _fncManipulateWithTrap;
	if ( _trapManipulationResult ) then
	{
		_obj setVariable ["isEnabled",true];
		_obj setVariable ["isActivating",true];

		[_user,"Mine will be active in 3 seconds","colorStatusChannel"] call fnc_playerMessage;
		sleep 1;
		[_user,"Mine will be active in 2 seconds","colorStatusChannel"] call fnc_playerMessage;
		sleep 1;
		[_user,"Mine will be active in 1 second","colorStatusChannel"] call fnc_playerMessage;
		sleep 1;
		[_user,"Mine is active","colorStatusChannel"] call fnc_playerMessage;

		_obj setVariable ["isActivating",false];
		
		switch( surfaceTypeASL (getPosASL _user) ) do {// 0.0 - 1.0: odds of catching something on every usable surface
			case ("CRBoulders"	): {	_catchChance =	1.00 };
			case ("CRHlina"		): {	_catchChance =	1.00 };
			case ("CRForest1"	): {	_catchChance =	1.00 };
			case ("CRForest2"	): {	_catchChance =	1.00 };
			case ("CRGrass1"	): {	_catchChance =	1.00 };
			case ("CRGrass2"	): {	_catchChance =	1.00 };
			case ("CRGrit1"		): {	_catchChance =	1.00 };
			case ("cesta"		): {	_catchChance =	1.00 };
			case ("Freshwater"	): {	_catchChance =	1.00 };
		};
		
		while {(_obj getVariable ["isEnabled",false]) and (!isNull _obj)} do 
		{
			//[_user,format["_trapEnabled = %1",_trapEnabled],"colorStatusChannel"] call fnc_playerMessage;
			if ( (_catchChance * (1-_damage/2)) > random 1 ) then
			{
				//Find agents in distance
				//agents = nearestObjects [_obj, ["SurvivorBase","AnimalBase","ZombieBase"], _minDistance];
				agents = nearestObjects [_obj, ["SurvivorBase"], _minDistance];
				{
					_agent = _x;
					if (_agent isKindOf "SurvivorBase") then
					{
						 _obj call _fnc_explode_fire;
						[_agent, "You've been hurt by land mine","colorImportant"] call fnc_playerMessage;
					};
					if true exitWith{};
				} forEach agents;
			};
			sleep _updateinterval;
		};
	};
};

_fncSetUpLandMine =
{
	_user playAction ['PlayerCraft',{}];
	deleteVehicle _trapItem; 						//Remove the item from player's hands
	sleep 7;
	_trapItem = objNull;
	sleep _initialWaitTime; 						//Wait some time until trap is activated
	_trapItem = "Trap_LandMineGround" createVehicle _pos; 		//re-create it on the ground as an object
	_trapItem setdamage _damage; 					//transfer damage from former object
	_trapItem setDir getDir _user;
	_trapItem setPosATL _pos; 							//Set position precisely and align the object to slope
	[_user,"I have deployed the land mine.","colorStatusChannel"] call fnc_playerMessage;
	//_trapItem call _fncActivateTrap;	
};

//[_user,format["function to call = %1",_funcToCall],"colorStatusChannel"] call fnc_playerMessage;
switch(_funcToCall) do 
{
	case ("_fncSetUpLandMine"		): { _trapItem call _fncSetUpLandMine; };
	case ("_fncActivateTrap"	): { _trapItem call _fncActivateTrap; };
	case ("_fncDeactivateTrap"	): { _trapItem call _fncDeactivateTrap; };
	case ("_fncPickupTrap"		): { _this call _fncPickupTrap; };
};