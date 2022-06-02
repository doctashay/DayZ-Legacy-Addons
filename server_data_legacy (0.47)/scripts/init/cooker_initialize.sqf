private["_object"];
/*
	Run on initialization of a cooker

	Author: Rocket
*/
if (isServer) then
{
	_this spawn {
		_this synchronizeVariable ["steam",1,{_this call event_fnc_cookerSteam}];
	};
};
