//Assess Terrain
private["_unit","_pos","_type","_typeA","_array","_isInside"];
_unit = 	_this;
_pos = 		getPosATL _unit;
_type = 	surfaceType _pos;

_footDamage = 	getNumber (configFile >> "CfgSurfaces" >> _type >> "footDamage");
_isInside = 	getNumber (configFile >> "CfgSurfaces" >> _type >> "interior");

_array = [_type,_footDamage,_isInside];
_array