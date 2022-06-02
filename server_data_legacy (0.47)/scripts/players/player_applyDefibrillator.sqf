private["_item","_agent","_person","_battery","_agentBlood"];
/*
	Revive player with defibrillator, if he isn't in unconscious state then put him into it.
	
	Author: Peter Nespesny
*/
_agent = _this select 0;
_person = _this select 1;
_item = _person getVariable ["inUseItem",objNull];
_battery = _item itemInSlot "BatteryD";

_batteryPower = _battery getVariable ["power",0];

if (_batteryPower >= 20000) then 
{	
	_battery setVariable ["power",0];	
	_agent setVariable ['shock',5000];
		
	if (_agent getVariable["fibrillation",false]) then
	{
		_agent setVariable["fibrillation",false];
		[1,_agent,"HeartAttack"] call event_modifier;
	}
	else
	{
		_health = _agent getVariable["health",DZ_HEALTH];
		_rand = random 1;		
		if ((_health < (DZ_HEALTH * 0.3)) or (_rand < 0.3)) then
		{
			_agent setDamage 1;
		}
		else
		{
			_agent getVariable["fibrillation",true];
			[2,_agent,"HeartAttack",1] call event_modifier;
		};
	};
}
else
{
	[_owner,format["The battery doesn't have enough charge to exert a shock",""],"colorAction"] call fnc_playerMessage;	
};