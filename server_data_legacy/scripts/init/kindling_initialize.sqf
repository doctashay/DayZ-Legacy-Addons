private["_object"];
/*
	Run on initialization of a kindling

	Authors: Rocket, Peter Nespesny
*/
if (isServer) then
{
	_this spawn {
		_this synchronizeVariable ["fire",1,{_this call event_fnc_kindlingFire}];
	};
};
