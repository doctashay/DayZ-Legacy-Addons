private ["_person","_sound"];
_person = [_this,0,objnull,[objnull]] call bis_fnc_param;
_sound = [_this,1,"",["",[]]] call bis_fnc_param;

_person say _sound