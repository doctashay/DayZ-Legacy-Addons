private["_target","_agent","_cantSee"];
_target = _this select 0;
_agent = _this select 1;
_cantSee = true;
if ((!isNull _target) and (!isNull _agent)) then {
	_tPos = eyePos _target;	//(getPosASL _target);
	_zPos = eyePos _agent;	//(getPosASL _agent);
	if ((count _tPos > 0) and (count _zPos > 0)) then {
		_cantSee = terrainIntersectASL [(eyePos _target), (eyePos _agent)];
		//diag_log ("terrainIntersectASL: " + str(_cantSee));
		if (!_cantSee) then {
			_cantSee = lineIntersects [(eyePos _target), (eyePos _agent)];
			//diag_log ("lineIntersects: " + str(_cantSee));
		};
	};
};
_cantSee