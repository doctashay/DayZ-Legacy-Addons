//Returns true or false depending on player's circumstances upon which he is able to gut a given dead body.
_user = _this select 0;
_body = _this select 1;
_tool = _this select 2;
_isBodyFree = false;
_isCurrentToolUsable = false;

if (_tool isKindOf "KnifeBase" or _tool isKindOf "BayonetBase") then
{_isCurrentToolUsable = true} else {_isCurrentToolUsable = false};

_isBodyBeingUsed = _body getVariable "isBeingSkinned";
if (isNil "_isBodyBeingUsed") then {_isBodyFree = true} else {_isBodyFree = false};

if (!isNil "_body") then {
	if ( 
		(((_body isKindOf "DZ_AnimalBase" or _body isKindOf "SurvivorBase") && !alive _body) or _body isKindOf "FishCorpseBase") &&			
		_isCurrentToolUsable			&&
		damage _tool < 1 				&&
		_body distance _user < 1.75		&&
		_isBodyFree						&&
		_user getVariable ['isUsingSomething',0] == 0
		)then
	{
		true //Player can gut this animal
	}else{
		false //Player CANNOT gut this animal
	};
}else{
	false; //Player CANNOT gut undefined object
}
