/*
	Author: Karel Moricky

	Description:
	Return config path to given entry.

	Parameter(s):
		0: CONFIG
		1 (Optional): ARRAY or STRING - type of returned value (default: ARRAY)

	Returns:
		ARRAY - list of classes (e.g. ["configfile","CfgVehicles"])
		STRING - composed path (e.g. "configfile >> 'CfgVehicles'")
*/

private ["_config","_slash","_fnc_addWord","_configArray","_word","_words","_wordsString","_class"];
_config = [_this,0,configfile,[configfile]] call bis_fnc_param;
_returnMode = [_this,1,[],[[],""]] call bis_fnc_param;
_slash = toarray "/" select 0;

//--- Function to add a word to array
_fnc_addWord = {
	_wordString = tostring _word;
	if (_wordstring == str configfile) then {_wordString = "configfile"};
	if (_wordstring == str campaignconfigfile) then {_wordString = "campaignconfigfile"};
	if (_wordstring == str missionconfigfile) then {_wordString = "missionconfigfile"};
	_words set [count _words,_wordString];
	_word = [];
};

//--- Scan config path
_configArray = toarray str _config;
_word = [];
_words = [];
{
	if (_x == _slash) then {
		call _fnc_addWord;
	} else {
		_word set [count _word,_x];
	};
} foreach _configArray;
call _fnc_addWord;

if (typename _returnMode == typename "") then {
	_wordsString = "";
	{
		_class = _x;
		if ({_class == _x} count ["configfile","campaignconfigfile","missionconfigfile"] == 0) then {_class = str _class;};

		if (_foreachindex > 0) then {_wordsString = _wordsString + " >> ";};
		_wordsString = _wordsString + _class;
	} foreach _words;
	_wordsString
} else {
	_words
};