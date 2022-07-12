_mode = _this select 0;
_param = _this select 1;

_display = findDisplay 167;

/*
"colorCorrections" ppEffectEnable true; "filmGrain" ppEffectEnable true; 
"filmGrain" ppEffectAdjust [0.02, 1, 1, 0.1, 1, false];
"colorCorrections" ppEffectAdjust [1, 0.8, -0.001, [0.0, 0.0, 0.0, 0.0], [0.8*2, 0.5*2, 0.0, 0.7], [0.9, 0.9, 0.9, 0.0]];   
"colorCorrections" ppEffectCommit 3;
*/

//functions

switch _mode do {
	case "onUnload":
	{
		call ui_fnc_createDefaultChar;
		demoUnit setPos demoPos;
		demoUnit setDir demoDir;
	};
	case "onLoad":
	{
		_defChar = profileNamespace getVariable ["defaultCharacter",""];
		if (_defChar == "") then 
		{
			null = [] spawn {(findDisplay 167) createDisplay "RscDisplayDefaultCharacter"};
		}
		else
		{
			ctrlShow [8013,false];
			call ui_fnc_createDefaultChar;
		};
	};
	case "bnBack":
	{
		(_display displayCtrl 8013) ctrlShow true;	//later character
		(_display displayCtrl 8003) ctrlShow false;	//default character
		(_display displayCtrl 8014) ctrlEnable false;	//earlier character
	};
	case "bnForward":
	{
		(_display displayCtrl 8013) ctrlShow false;	//later character
		(_display displayCtrl 8003) ctrlShow true;	//default character
		(_display displayCtrl 8014) ctrlEnable true;	//earlier character
	};
};