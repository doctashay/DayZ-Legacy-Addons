private[];

_bag = _this select 0;
_target = _this select 1;

_bagBloodType = _bag getVariable "filledWith";
_targetBloodType = _target getVariable "bloodtype";
_targetCompatibleBloodTypes = getArray (configFile >> 'cfgSolutions' >> (_target getVariable 'bloodtype') >> 'compatible');

_matched = false;

//statusChat str(_bagBloodType);
//statusChat str(_targetBloodType);
//statusChat str(_targetCompatibleBloodTypes);

if (_bagBloodType == _targetBloodType) then
{
	//hint "same type";
	_target setVariable ['blood',((_target getVariable 'blood') + 1000) min 5000];
}
else
{
	{		
		if (_x == _bagBloodType) exitWith
		{	
			//hint "compatible type";
			_target setVariable ['blood',((_target getVariable 'blood') + 1000) min 5000];
			_matched = true;
		};	
	} foreach _targetCompatibleBloodTypes;
	
	if (not _matched) then
	{
		//hint "types doesn't match";
		[0,_target,"HemolyticReactionHeavyImpact"] call event_modifier;
	};
};