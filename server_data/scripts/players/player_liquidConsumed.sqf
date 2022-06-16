//Define
_person = _this select 0;
_used = _this select 1;
_bottle = itemInHands _person;

_sickness = _bottle getVariable ["sickness",0];
_modifiers = _bottle getVariable ["modifiers",[]];
_modifiersCnt = count _modifiers;

_sourceType = _bottle getVariable ["liquidType",""];

//hint format ["lahev:%1,Clovek:%2", _used, _person];


switch _sourceType do
{
	case "water" :
	{
		//hint "water";
	};

	case "gasoline" :
	{
		//hint "gasoline";
		if ( _used <= 100 ) then
		{
			[0,_person,'FoodPoisoning_MediumImpact'] call event_modifier;
			//[0,_person,'FoodPoisoning_LightImpact'] call event_modifier;
		}
		else
		{
			[0,_person,'FoodPoisoning_MediumImpact'] call event_modifier;
		};
	};
	
	case "vodka" :
	{
		//hint "vodka";
	
	};
	
	case "disinfectant" :
	{
		//hint "disinfectant";
		if ( _used <= 100 ) then
		{
			[0,_person,'FoodPoisoning_LightImpact'] call event_modifier;
		}
		else
		{
			[0,_person,'FoodPoisoning_MediumImpact'] call event_modifier;
		};
	};
};

