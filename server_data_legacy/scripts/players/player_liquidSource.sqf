private["_item","_itemType","_actionName","_itemDir","_config","_name","_statusText","_sounds","_action","_trashItem","_sound","_soundConfig","_distance","_string","_trashPos","_trash","_person","_used","_use"];
/*
	Executed when a player selects the "use" action from the actions interaction menu
	
	TODO: Remove broadcasting of variables, only added as UI tooltips not generated on server yet.
*/
//Define
_source = _this select 0;
_bottle = _this select 1;
_person = _this select 2;
_sourceType = _this select 3;

_person setVariable ['isUsingSomething',1];

if ( typeName _source == "OBJECT" ) then
{
	_modifiers = _source getVariable ["modifiers",[]];
	_modifiersCnt = count _modifiers;
	_sickness = _source getVariable ["sickness",0];
	
	if ( damage _source >= 1 ) exitWith 
	{
		[_person,format["The source of %1 is completly damaged.", _sourceType],"colorAction"] call fnc_playerMessage;
		_person setVariable ['isUsingSomething',0];
	};
};



if ( !(isNull _bottle) && damage _bottle >= 1 ) exitWith
{
	[_person,format["I can not fill the %1 its completely damaged.", displayName _bottle],"colorAction"] call fnc_playerMessage;
	_person setVariable ['isUsingSomething',0];
};

/*
_qua = _source getVariable ["quantity",0];

if ( quantity _bottle != _qua) exitWith
{
	[_person,format["quantity: %1 - variable %2.", quantity _bottle, _qua],"colorAction"] call fnc_playerMessage;
};
*/

//zbyvajici podminka
//_inHands isKindOf 'BottleBase';

//Cholera, Influenza, Angina, Salmonellosis
_diseases = ["Cholera", "Salmonellosis"];

//------------
pumpAnimation =
{
	if ( _source animationPhase 'Arm' <= 0.1 ) then
	{
		_source animate ['Arm',1];
		//_source call effect_PumpWater_particle;
	};
	if ( _source animationPhase 'Arm' >= 0.9 ) then
	{
		_source animate ['Arm',0];
		//_source call effect_PumpWater_particle;
	};
};

//------------
processDisease = 
{

	//hint str _sickness;
	//hint str (_this select 0);
	//hint str (_this select 1);
	if ( _sickness == 0 ) then
	{
		_rand = random(1);
		
		if ( _rand > 1 ) then
		{
			_disease = _diseases select (floor random (count _diseases));
			[0,_source, _disease] call event_modifier;
			_source setVariable ["sickness", 1];
			
			if ( (_this select 1) == _bottle ) then
			{
				//hint format ["lahev-%1",_bottle];
				[0,_bottle, _disease] call event_modifier;
			};
			if ( (_this select 1) == _person ) then
			{
				[0,_person, _disease] call event_modifier;
			};
		}
		else
		{
			_source setVariable ["sickness", -1];
		};
	}
	else
	{
		_diseases = _modifiers;
		//hint format ["%1 ?? %2",(_this select 1),_bottle];
		
		if ( (_this select 1) == _bottle ) then
		{
			{
				[0,_bottle, _x] call event_modifier;
			} forEach _diseases;
		};
		if ( (_this select 1) == _person ) then
		{
			{
				[0,_person, _x] call event_modifier;
			} forEach _diseases;
		};
	};
};

//-----------------------------**************************************************------------------------------------------------------------------------

if ( !(isNull _bottle) && !(itemInHands _person isKindOf "BottleBase") ) exitWith
{
	[_person,format["%1 cannot be filled up.", displayName _bottle],"colorAction"] call fnc_playerMessage;
	_person setVariable ['isUsingSomething',0];
	_source call pumpAnimation;
};

if ( !(isNull _bottle) && quantity _bottle >= maxQuantity _bottle ) exitWith
{
	[_person,format["The %1 is already full.", displayName _bottle],"colorAction"] call fnc_playerMessage;
	_person setVariable ['isUsingSomething',0];
};

if ( !(isNull _bottle) && ( quantity _bottle > 0 && (quantity _bottle < (maxQuantity _bottle) && _bottle getVariable ["liquidType",""] != _sourceType ) ) ) exitWith
{
	[_person,format["There is already something in the %1.", displayName _bottle],"colorAction"] call fnc_playerMessage;
	_person setVariable ['isUsingSomething',0];
};

//-----------------------------**************************************************------------------------------------------------------------------------

switch _sourceType do
{
	case "water" :
	{
		if ( isNull _bottle ) then
		{
			//hint "Nic v ruce";
			if ( _sickness >= 0 ) then
			{
				[_source, _person] call processDisease;
			};
			
			if ( typeName _source == "OBJECT" ) then
			{
				_source call pumpAnimation;
				_person playAction ['drinkWell',{_this setVariable ['isUsingSomething',0];}];	
				[_person,"WellWater"] call player_fnc_processStomach;
				[_person,'I drink some water from the well','colorAction'] call fnc_playerMessage;
			}
			else
			{
				_person playAction ['drinkPond',{_this setVariable ['isUsingSomething',0];}];
				[_person,"RiverWater"] call player_fnc_processStomach;
				[_person,"I have drunk some water from the pond","colorAction"] call fnc_playerMessage;
			};
		}
		else
		{
			if ( _bottle isKindOf "BottleBase" ) then
			{
				//hint "Lahev v ruce";
				if ( _sickness >= 0 ) then
				{
					[_source, _bottle] call processDisease;		
				};
				
				if ( typeName _source == "OBJECT" ) then
				{
					_source call pumpAnimation;
				};
				
				_inHands setVariable ["liquidType", _sourceType];
				[_source,_inHands,_owner, _sourceType] spawn player_fillBottle;
			}
			else
			{
				//hint "V ruce neco uplne jineho";
				_source call pumpAnimation;	
			};
		};
	};

	case "gasoline" :
	{
		if ( _bottle isKindOf "BottleBase" ) then
		{
			//hint "Lahev v ruce";
			//_source call gasAnimation;
			_inHands setVariable ["liquidType", _sourceType];
			[_source,_inHands,_owner, _sourceType] spawn player_fillBottle;
		};
/*
		else
		{
			//hint "V ruce neco uplne jineho";
			if ( typeName _source == "OBJECT" ) then
			{
				_source call pumpAnimation;
			};
		};
*/
	};
	
	case "vodka" :
	{
		hint "vodka";
	
	};
	
	case "disinfectant" :
	{
		hint "disinfectant";
	
	};
};


