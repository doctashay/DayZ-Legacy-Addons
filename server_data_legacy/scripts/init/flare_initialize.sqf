private["_object"];
/*
	Run on initialization of a flare

	Authors: Rocket, Peter Nespesny
*/
if (isServer) then
{	
	//hint "init flare";
	_this setVariable ["fire",0];
	_this spawn {
		_this synchronizeVariable ["fire",1,{_this call event_fnc_flareFire}];
	};
};
