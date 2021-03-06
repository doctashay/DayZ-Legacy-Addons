//scriptName "fn_dbClassId.sqf";
/*
	Author: Karel Moricky

	Description:
	Converts string to class definition.

	Parameter(s):
	_this: STRING (converts to)
	or
	_this select 0: STRING (converts from)

	Returns:
	STRING
*/

private ["_text","_textArray","_dbSymbol"];
_text = _this;
_dbSymbol = toarray (call BIS_fnc_dbSymbolClass) select 0;
if (typename _text == typename []) then {

	//--- From
	_text = _text select 0;
	_textArray = toarray _text;
	if ((_textArray select 0) == _dbSymbol) then {_textArray set [0,-1]};
	_textArray = _textArray - [-1];
} else {

	//--- To
	_textArray = toarray _text;
	if ((_textArray select 0) != _dbSymbol) then {_textArray = [_dbSymbol] + _textArray};
};
if (isnil "_fnc_dbValueId_noUpper") then {toupper tostring _textArray} else {tostring _textArray};