private["_item","_agent","_person","_battery"];

_agent = _this;

_item = _person getVariable ["inUseItem",objNull];
_battery = _item itemInSlot "BatteryD";
_batteryPower = _battery getVariable ["power",0];

if (_batteryPower >= 20000) then
{
	_battery setVariable ["power",0];

	if ((lifeState _agent) == "UNCONSCIOUS") then
	{
		_agent setVariable ['shock',0];
	}
	else
	{
		_agent setVariable ['shock',5000];
	};
}
else
{
	[_owner,format["The battery doesn't have enough charge to exert a shock",""],"colorAction"] call fnc_playerMessage;	
};