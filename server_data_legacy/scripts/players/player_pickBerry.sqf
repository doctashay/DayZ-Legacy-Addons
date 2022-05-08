private["_state","_poisonChance","_randnum","_result","_quant","_newItem"];
/*
	Function handling searching bushes for berries

	Author: Jan Tomasik
*/
_state = _this select 0;
switch _state do 
{
	case 0:
	{
		private["_person","_berry"];
		_person = _this select 1;
		_berry = _this select 2;
		_result = format["[1,_this,%1] call player_pickBerry",str(_berry)];			
		_person playAction ["PlayerCraft",compile _result];
	};
	case 1:
	{
		private["_person","_berry"];
		_person = _this select 1;
		_berry = _this select 2;
		_name =  getText(configFile >> "CfgVehicles" >> _berry >> "displayName");
		_quant =  getNumber(configFile >> "CfgVehicles" >> _berry >> "stackedMax");
		_randnum = round (random 7);
		if (_randnum==1) then {
			_newItem = [_berry,_person] call player_addInventory;
			if(_quant == 0)then{
				_newItem setQuantity 0;
			}else{
				_newItem setQuantity 1;
			};
			[_person,format["I have found something!",_name],""] call fnc_playerMessage;	
		} else {
			[_person,"I have not found a thing.",""] call fnc_playerMessage;	
		};
	};
}
