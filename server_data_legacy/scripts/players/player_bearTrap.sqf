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
_damagePlayer = 0.25; 		//How much damage player gets when caught
_catchChance = 0.7;			//Chance for catch
_wrongManipulation = 0.05;	//Chance for damage when manipulating (activate/deactivate) with trap

_fncManipulateWithTrap = 
{
	//[_user,"_fncManipulateWithTrap","colorStatusChannel"] call fnc_playerMessage;
	if ( _wrongManipulation > random 1 ) exitWith
	{
		//_user setDamage( (damage _user)+_damagePlayer);  //set damage to victim
		_user setHitPointDamage ["hitHands", 1];
		[_user, "You've been hurt by improper manipulation with trap","colorStatusChannel"] call fnc_playerMessage;
		false
	};
	true
};

_fncDeactivateTrap = 
{
	//[_user,"_fncDeactivateTrap","colorStatusChannel"] call fnc_playerMessage;
	_obj = _this; //The trap
	_obj setdamage (_damage); //Also damage it a little
	_obj animate["BearTrap_Set", 1]; // 0 means SHOW this selection!
	_obj animate["BearTrap_Triggered", 0]; // 1 means HIDE this selection!
	_obj setVariable ["isEnabled",false];
	_trapManipulationResult = _trapItem call _fncManipulateWithTrap;
};

_fncPickupTrap = {
	_user = _this select 1;
	_trap = _this select 2;
	_item = ['Trap_Bear', _user] call player_addInventory;  
	_item setdamage (damage _trap);
	_trap call _fncDeactivateTrap;
	deleteVehicle _trap;
};


_fncActivateTrap =
{
	//[_user,"_fncActivateTrap","colorStatusChannel"] call fnc_playerMessage;
	_trapManipulationResult = _trapItem call _fncManipulateWithTrap;
	if ( _trapManipulationResult ) then
	{
		_obj = _this; //The trap
		_damage = _damage + _wearOut;
		_obj animate["BearTrap_Set", 0]; // 0 means SHOW this selection!
		_obj animate["BearTrap_Triggered", 1]; // 1 means HIDE this selection!
		_obj setVariable ["isEnabled",true];
		
		switch( surfaceTypeASL (getPosASL _user) ) do {// 0.0 - 1.0: odds of catching something on every usable surface
			case ("CRBoulders"	): {	_catchChance =	0.70 };
			case ("CRHlina"		): {	_catchChance =	0.70 };
			case ("CRForest1"	): {	_catchChance =	0.95 };
			case ("CRForest2"	): {	_catchChance =	0.95 };
			case ("CRGrass1"	): {	_catchChance =	0.95 };
			case ("CRGrass2"	): {	_catchChance =	0.95 };
			case ("CRGrit1"		): {	_catchChance =	0.70 };
			case ("cesta"		): {	_catchChance =	0.50 };
			case ("Freshwater"	): {	_catchChance =	0.95 };
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
						//_agent setDamage( (damage _agent) + (_damagePlayer * (1-_damage)));  //set damage to victim.
						_damage = damage _agent;
						_damageHands = _agent getHitPointDamage "hitHands";
						_damageBody = _agent getHitPointDamage "hitBody";
						_damageHead = _agent getHitPointDamage "hitHead";
						_damageFeet = _agent getHitPointDamage "hitFeet";
						
						_agent setVelocity [0,0,-8];
						
						sleep 0.5;
						
						if (alive _agent) then {
							_agent setDamage _damage;
							_agent setHitPointDamage ["hitHands", _damageHands];
							_agent setHitPointDamage ["hitBody", _damageBody];
							_agent setHitPointDamage ["hitHead", _damageHead];
							_agent setHitPointDamage ["hitFeet", _damageFeet];
							_agent setHitPointDamage ["hitLegs", 1];
						};
						
						[_agent, "You've been hurt by bear trap","colorImportant"] call fnc_playerMessage;
					}else
					{ 
						_agent setDamage(1);  //set damage to victim
					};
					_obj call _fncDeactivateTrap;
					if true exitWith{};
				} forEach agents;
			};
			sleep _updateinterval;
		};
	};
};

_fncSetUpTrap =
{
	//[_user,"_fncDeployTrap","colorStatusChannel"] call fnc_playerMessage;
	//_user playmoveNow "amelpercmstpsraswnondnon_throwc"; //Throw item animation
	_user playAction ['startFire',{}];

	deleteVehicle _trapItem; 						//Remove the item from player's hands
	sleep 6;
	_trapItem = objNull;
	sleep _initialWaitTime; 						//Wait some time until trap is activated
	_trapItem = "Trap_BearGround" createVehicle _pos; 		//re-create it on the ground as an object
	_trapItem setdamage _damage; 					//transfer damage from former object
	_trapItem setDir getDir _user;
	_trapItem setPosATL _pos; 							//Set position precisely and align the object to slope
	[_user,"I have deployed the bear trap.","colorStatusChannel"] call fnc_playerMessage;
	//_trapItem call _fncActivateTrap;	
};

//[_user,format["function to call = %1",_funcToCall],"colorStatusChannel"] call fnc_playerMessage;
switch(_funcToCall) do 
{
	case ("_fncSetUpTrap"		): { _trapItem call _fncSetUpTrap; };
	case ("_fncActivateTrap"	): { _trapItem call _fncActivateTrap; };
	case ("_fncDeactivateTrap"	): { _trapItem call _fncDeactivateTrap; };
	case ("_fncPickupTrap"		): { _this call _fncPickupTrap; };
};