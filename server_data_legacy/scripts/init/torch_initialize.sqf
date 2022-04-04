private["_object"];
/*
	Run on initialization of a torch

	Authors: Rocket, Peter Nespesny
*/
if (isServer) then
{	
	//hint "init torch";
	_this setVariable ["fire",0];
	_this spawn {
		_this synchronizeVariable ["fire",1,{_this call event_fnc_torchFire}];
	};
};