_user = _this select 0;
_plant = _this select 1;
_fruit = "";
_fruitCount = 0;
_fruitDisplayname = "";
_objSoil = _plant getVariable "soil"; 
_plantSlot = _plant getVariable "plantSlot"; 

switch (typeOf _plant) do
{
	case ("TomatoPlant4"):{ //Fresh fruit
		_fruit = "fruit_TomatoFresh";
		_fruitCount = 13;
		_fruitDisplayname = "tomatoes";
	};
	case ("TomatoPlantRotten"):{ //Rotten fruit
		_fruit = "fruit_TomatoRotten";
		_fruitCount = 13;
		_fruitDisplayname = "rotten tomatoes";
	};
};

if (_fruit == "" || _fruitCount == 0 || _fruitDisplayname == "")exitWith{[_objSoil, _plantSlot] call fnc_resetState;};
deleteVehicle _plant;
[_user, format["You've harvested %1 %2.", _fruitCount, _fruitDisplayname],"colorStatusChannel"] call fnc_playerMessage;

while {_fruitCount > 0} do
{
	_fruitCount = _fruitCount - 1;
	//_item = _user createInInventory _fruit;
	_item = [_fruit,_user] call player_addInventory;
};
[_objSoil, _plantSlot] call fnc_resetState;