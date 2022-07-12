private["_action","_person","_modifier","_value","_cfgModifier","_modifiers","_modstates","_inArray","_doSave","_cleanup","_i","_array","_remaining","_reminder","_condition","_runEvent"];
/*
	Run whenever a brain thinks a modifier needs to be applied. In many case this
	will already have been applied, so closes gracefully. Multiple actions exist
	that allow the script to either add, cancel, or change the stage, of a modifier

	Author: Rocket
*/
_action = _this select 0;
_person = _this select 1;
_modifier = _this select 2;
_value = _this select 3;
_i = 0;

//[0,player,"Unconscious"] call event_modifier;
//[1,player,"Hunger"] call event_modifier;	//removes modifier
//[2,player,"CommonCold",1] call event_modifier; //add modifier directly in selected stage (index 1 in this case)
//[3,player,"CommonCold",0.5] call event_modifier;	//Halves the duration of the modifier

_cfgModifier = 	configFile >> "cfgModifiers" >> _modifier;

if (!isClass _cfgModifier) exitWith
{
	diag_log format["ERROR: %1 not found in CfgModifiers",_modifier];
};

_modifiers = _person getVariable ["modifiers",[]];
_modstates = _person getVariable["modstates",[]];
_doSave = false;
_cleanup = false;

_inArray = _modifier in _modifiers;

if (_inArray) then
{
	_i = _modifiers find _modifier;
}
else
{
	_i = count _modifiers;
};

switch _action do
{
	case 0:
	{
		private["_stage"];
		//add modifier
		if (!_inArray) then
		{
			_stage = 0;
			if (count _this > 3) then
			{
				_stage = _value;
			};
			
			//check condition
			call event_fnc_addModifier;
		};
	};
	case 1: 
	{
		private["_stage"];
		//remove modifier
		if (_inArray) then
		{
			_modifiers set [_i,0];
			if (count _modstates > 0) then	{_modstates set [_i,0]};
			_cleanup = true;
			_doSave = true;
		};
	};
	case 2:
	{
		private["_stage"];
		//change stage
		if (_inArray) then
		{
			private["_cStage"];
			_i = _modifiers find _modifier;				
			if (!isNil "_value") then
			{
				_cStage = (_modstates select _i) select 0;
				if (str(_cStage) != str(_value)) then	//this checks to see if its already changed
				{
					_stage = _value;
					_stages = _cfgModifier >> "Stages";
					_oldStage = _stage;
					if (typeName _cStage == "ARRAY") then
					{
						_oldStage = _stages select (_cStage select 0);
					}
					else
					{
						_oldStage = _stages select _cStage;
					};
					_oldNotifier = getArray (_oldStage >> "notifier");					
					
					//run ending statement
					_statement = getText (_oldStage >> "statementExit");	//_person
					call compile _statement;
					
					_cfgStage = _stages select _stage;
					
					if (isClass _cfgStage) then
					{
						//load new stage
						_remaining = getArray (_cfgStage >> "duration") call randomValue;
						_reminder = getArray (_cfgStage >> "cooldown") call randomValue;
						_stageArray = [_stage];
						_modstates set [_i,[_stageArray,_remaining,_reminder]];
						
						//diag_log str(_modstates);
						
						//send an activation message
						call event_fnc_sendActvMessage;
						_doSave = true;
					}
					else
					{
						diag_log format["ERROR: CfgModifiers >> %1 >> %2 stage does not exist",_modifier,_value];
					};
				};
			}
			else
			{
				diag_log format["ERROR: Bad data in _value passed to event_modifier",_modifier,_value];
			};
		}
		else
		{
			diag_log format["WARNING: CfgModifiers >> %1 stage change requested, but not active. Creating and carrying on.",[0,_person,_modifier]];
			[0,_person,_modifier,_value] call event_modifier;
		};
	};
	case 3:
	{
		//change modifer duration
		if (_inArray) then
		{
			private["_cState","_cDuration"];
			_i = _modifiers find _modifier;				
			if (!isNil "_value") then
			{
				_cState = (_modstates select _i);
				_cDuration = (_cState select 1) * _value;
				_cState set [1,_cDuration];
				_modstates set [_i,_cState];
				_doSave = true;
			}
			else
			{
				diag_log format["ERROR: Bad data in _value passed to event_modifier",_modifier,_value];
			};
		}
		else
		{
			diag_log format["WARNING: CfgModifiers >> %1 state change requested, but not active. Doing nothing.",[0,_person,_modifier]];
		};
	};
};

//check to see if need to save
call event_fnc_saveModifiers;