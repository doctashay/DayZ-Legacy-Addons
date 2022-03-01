/*
	Author: Karel Moricky

	Description:
	Load newsfeed

	Parameter(s):
	_this select 0: DISPLAY - display where newsfeed with idc 1101 is

	Returns:
	BOOL - true when online
*/
private ["_display","_newsOnline","_newsOffline","_ctrlHTML","_htmlLoaded"];
_display = [_this,0,finddisplay 0,[displaynull]] call bis_fnc_param;

//_newsOnline = format ["http://takeonthegame.com/newsfeed/news.php?language=%1&version=%2",language,productVersion select 2];
_newsOnline = "http://www.arma3.com/newsfeed/a3_countdown.php";
_newsOffline = "";
if (getnumber (configfile >> "demo") > 0) then {
	_newsOnline = "";
	_newsOffline = "";
};

_ctrlHTML = _display displayctrl 1101;
_ctrlHTML htmlLoad _newsOnline;

_htmlLoaded = ctrlHTMLLoaded _ctrlHTML; 
//if (!_htmlLoaded) then {_ctrlHTML htmlLoad _newsOffline;};

_htmlLoaded