/*
	Author: Karel Moricky

	Description:
	Recompiles all functions
*/
private ["_functionsInit"];
_functionsInit = gettext (configfile >> "CfgFunctions" >> "init");
if (_functionsInit != "") then {
	if (cheatsEnabled) then {call compile "diag_mergeConfigFile ['o:\arma3\DZ\functions\config.cpp'];"};
	_this call compile preprocessfilelinenumbers _functionsInit;
	true
} else {
	"Functions Init not found!" call (uinamespace getvariable "bis_fnc_error");
	false
};