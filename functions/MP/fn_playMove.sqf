private ["_person","_move"];
_person = [_this,0,objnull,[objnull]] call bis_fnc_param;
_move = [_this,1,"",[""]] call bis_fnc_param;

_person playmove _move