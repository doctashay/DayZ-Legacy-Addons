/*
author: Rocket

This script is activated when the player presses the left mouse button. The
script checks if the player has a weapon and/or can conduct a melee attack
and then executes it.
*/
private["_button","_handled","_action","_range","_delay","_ammo","_item","_config"];
_button = _this select 1; 
_ctrl = _this select 5;
_handled = false;

if (dialog) exitWith {false};	//close if dialog open (e.g. gear menu)
if (meleeAttack or (captive player) or (lifeState player == "UNCONSCIOUS")) exitWith {};


_action = "";
_range = 1;
_delay = 0.3;
_ammo = "MeleeDamage";
_item = itemInHands player;
_straightShot = false;

_allowMelee = getNumber(configFile >> "CfgMovesMaleSdr2" >> "states" >> animationState player >> "allowMelee") == 1;

if (!_allowMelee) exitWith {};

meleeAttempt = true;

//melee item?
if (!isNull _item) then
{
	_config = configFile >> "cfgVehicles" >> typeOf _item;
	if (!isClass (_config >> "melee")) exitWith {};	
	if (_button != 0) exitWith {};
	
	_range = getNumber(_config >> "melee" >> "range");
	_delay = getNumber(_config >> "melee" >> "swingTime");
	_action = getText(_config >> "melee" >> "action");
	_ammo = getText(_config >> "melee" >> "ammo");
	_handled = true;
	_straightShot = getNumber(_config >> "melee" >> "useCursor") == 1;
}
else
{
	if (_button != 0) exitWith {};
	_handled = true;
	
	_ammo = "MeleeFist";
	_delay = 0.5;
	_straightShot = true;
};

if (_handled) then
{
	//play melee action
	[_action,[player,_range,_ammo,_delay,_straightShot]] spawn 
	{
		_action = (_this select 0);
		while {meleeAttempt} do 
		{
			//Make sound effect of punching 
			meleeAttack = true;
			_array = (_this select 1);
			_ammo = _array select 2;
			if (_ammo == "MeleeFist") then
			{
				meleeAttackType = if (meleeAttackType == 1) then {2} else {1};
				_action = format["MeleeAttack%1",meleeAttackType];
			};
			[player,"action_punch"] call event_saySound;
			
			_array spawn melee_finishAttack;
			playerAction [_action,{meleeAttack = false}];
			waitUntil {!meleeAttack};
			sleep 0.05;
		};
	};
	
}; 
//end code 
_handled 