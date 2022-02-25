private["_state","_poisonChance","_randnum","_result","_tempit"];
/*
	Function handling searching bushes for berries

	Author: Jan Tomasik
*/
_state = _this select 0;
switch _state do 
{
	case 0:
	{
		private["_person","_poisonous"];
		_person = _this select 1;
		_poisonous = _this select 2;
		_result = format["[1,_this,%1] call player_pickBerry",str(_poisonous)];	
		_person playAction ["PlayerCraft",compile _result];
	};
	case 1:
	{
		private["_person","_poisonous"];
		_person = _this select 1;
		_poisonous = _this select 2;
		_randnum = round (random 10);
		if (_randnum==1) then {
			[_person,"Berries"] call player_fnc_processStomach;
			[_person,"You have found and ate some berries.",""] call fnc_playerMessage;
			if (_poisonous) then {
				_poisonChance = random 1; 
				switch true do {
					case (_poisonChance < 0.05): 
					{
						[0,_person,"FoodPoisoning_HeavyImpact"] call event_modifier;
					}; 
					case (_poisonChance < 0.85): 
					{
						[0,_person,"FoodPoisoning_MediumImpact"] call event_modifier;
					};
				};
			};
		} else {
			//_tempit = _person createInInventory "Berries"; //we might spawn berries in players inventory but this way we wont have any control over amount of them in world so i commented it out
			//_tempit setVariable ["quantity",1];
			[_person,"You haven't found a single berry.",""] call fnc_playerMessage;
		};
	};
}

