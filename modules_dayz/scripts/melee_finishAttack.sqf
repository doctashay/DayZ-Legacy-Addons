/*
author: Rocket

Run at the end of a melee attack to conduct attack actions
*/
private["_agent","_range","_ammo","_array"];
//hint str(_this);
_agent = _this select 0;
_range = _this select 1;
_ammo = _this select 2;
_delay = _this select 3;
_unarmed = _this select 4;

_processHit = true;

if (_unarmed) then
{
	sleep 0.2;
	while {meleeAttack and _processHit} do
	{	
		[eyePos player,eyepos player #+ cursorDirection #* _range] call melee_fnc_checkHitLocal;
		//sleep 0.01;
	};	
}
else
{
	_lastStart = ATLToASL (_agent modelToWorld (_agent selectionPosition "MeleeBatStart"));
	_lastEnd = ATLToASL (_agent modelToWorld (_agent selectionPosition "MeleeBatEnd"));

	while {meleeAttack and _processHit} do
	{
		_start = ATLToASL (_agent modelToWorld (_agent selectionPosition "MeleeBatStart"));
		_end = ATLToASL (_agent modelToWorld (_agent selectionPosition "MeleeBatEnd"));		
		_dist = (_lastEnd distance _end);
		
		if (_dist > 0) then {
			[_lastEnd,_end] call melee_fnc_checkHitLocal;
			[_lastStart,_end] call melee_fnc_checkHitLocal;
			[_lastEnd,_lastStart] call melee_fnc_checkHitLocal;
		};
		
		_lastStart = _start;
		_lastEnd = _end;
		//sleep 0.01;
	};
};