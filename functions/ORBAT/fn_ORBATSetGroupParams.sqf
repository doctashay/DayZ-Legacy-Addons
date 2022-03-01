/*
	Author: Karel Moricky

	Description:
	Override group params from CfgORBAT.

	Parameter(s):
		0: CONFIG - path to group in CfgORBAT. If only this parameter is passed, override for the group is removed.
		1: STRING - text
		2: STRING - texture
		3: NUMBER - textureSize
		4: NUMBER - insignia
		5: NUMBER - size
		6: ARRAY - color
		7: STRING - commander
		8: STRING - commanderRank
		9: STRING - description
		10: ARRAY - short name
		11: ARRAY - assets
		12: NUMBER = id

	Returns:
	BOOL
*/
private ["_group","_groupArray","_groupID","_types","_type","_value"];
_group = [_this,0,configfile,[configfile]] call bis_fnc_param;
_groupArray = [];
_groupArray resize 9;

_remove = if (typename _this == typename []) then {count _this <= 1} else {true};
if (_remove) then {
	//--- Remove param
	_groupID = BIS_fnc_ORBATsetGroupParams_groups find _group;
	if (_groupID >= 0) then {
		BIS_fnc_ORBATsetGroupParams_groups set [_groupID,-1];
		BIS_fnc_ORBATsetGroupParams_groups set [_groupID + 1,-1];
		BIS_fnc_ORBATsetGroupParams_groups = BIS_fnc_ORBATsetGroupParams_groups - [-1];
		true
	} else {
		false
	};
} else {
	//--- Set param
	_typesArray = [
		["",00], //--- ID
		[""], //--- Size
		[""], //--- Type
		[""], //--- Side
		[""], //--- Text
		[""], //--- TestShort
		[""], //--- Texture
		[00], //--- TextureSize
		[""], //--- insignia
		[[]], //--- Color
		[""], //--- Commander
		[""], //--- CommanderRank
		[""], //--- Description
		[[]] //--- Assets
	];


	for "_t" from 0 to (count _typesArray - 1) do {
		_types = _typesArray select _t;
		_value = [_this,_t + 1,objnull,_types + [objnull]] call bis_fnc_param;
		if ({typename _value == typename _x} count _types > 0) then {
			_groupArray set [_t,_value];
		};
	};

	if (isnil "BIS_fnc_ORBATsetGroupParams_groups") then {BIS_fnc_ORBATsetGroupParams_groups = [];};
	_groupID = BIS_fnc_ORBATsetGroupParams_groups find _group;
	if (_groupID < 0) then {_groupID = count BIS_fnc_ORBATsetGroupParams_groups};

	//--- Create a new entry
	BIS_fnc_ORBATsetGroupParams_groups set [_groupID,_group];
	BIS_fnc_ORBATsetGroupParams_groups set [_groupID + 1,_groupArray];
	true
};