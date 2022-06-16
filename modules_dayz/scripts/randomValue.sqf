private["_min","_max","_v"];
if (count _this == 0) exitWith {-1};
_min = (_this select 0);
_max = (_this select 1);
_v = round (_min + (random _max));
_v