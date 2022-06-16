_user = _this select 0;
_tool = _this select 1;
_body = _this select 2;
_name = _this select 3;

_user setVariable ["isUsingSomething",1];
[0,_tool,_user,_name] call player_actionOnTarget;

//[_user,"I have started gutting the dead body.",""] call fnc_playerMessage;
//_user setVariable ["inUseItem",_tool]; //Is this needed?
_body setVariable ["isBeingSkinned", true];
_user setVariable ["skinnedBody",_body];