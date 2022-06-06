private["_object"];
/*
	Run on initialization of a wreck

	Authors: Rocket, Peter Nespesny
*/

if ( isServer ) then
{
	//_this setVariable ["fuel",0];
	_this spawn
	{
		_this synchronizeVariable ["fire",1,{_this call event_fnc_wreckSmoke}];	
		
		//_this synchronizeVariable ["fire",1];
		//_this call event_fnc_wreckSmoke;		
		
	};	
};
/*
if (isServer) then
{
	_this call effect_createWreckSmoke;
};
*/