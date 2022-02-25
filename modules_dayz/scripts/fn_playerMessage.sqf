private["_person","_client","_text","_textFormat"];
_person = _this select 0;
_text = _this select 1;
_textFormat = _this select 2;
_client = owner _person;

if (lifeState _person != "ALIVE") exitWith {};

if (isDedicated) then {
	_client statusChat [_text,_textFormat];
} else {
	statusChat [_text,_textFormat];
};