/*
	'Convert plant remains and guts into fertilizer
	Author: Jan Tomasik 

*/
private["_owner","_barrel","_cargo","_ferticount","_limecount","_plantcount","_item","_pileslime","_rest"];

	_barrel = _this select 0;
	_owner = _this select 1;
	_cargo = itemsInCargo _barrel;
	_limecount = 0;
	_ferticount = 0;
	_plantcount = 0;
	//calculate amout of materials
	{
		if((_x isKindOf 'Food_SmallGuts') and ((damage _x) < 1))then{_ferticount=_ferticount+((quantity _x)*10);};
		if((_x isKindOf 'Consumable_PlantMaterial') and ((damage _x) < 1))then{_plantcount = _plantcount+((quantity _x)*10);};
	} forEach _cargo;
	
	//simple material check
	if((_ferticount==0))exitWith{
		[_owner,'I need to add at least some lime.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	if(((quantity _barrel) < (_plantcount*1000)) or ((quantity _barrel) < 10000))exitWith{
		[_owner,'There is not enough water.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	if((_plantcount==0))exitWith{
		[_owner,'I need to add at least some plant remains.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	//wait certain amount of time till its ready
	sleep 60;
	/*_currentTime = time;   
	while {time < _currentTime+(_shirtcount*10)} do {  
		
	}; 
	*/
	{	
		if(_x isKindOf 'Consumable_PlantMaterial')then{
			if(_ferticount > 0)then{
				_limecount = _limecount+(quantity _x);
				_ferticount = _ferticount-1;
				_x addQuantity -0.1;
				if((quantity _x) == 0)then{
					deleteVehicle _x;
				};
				//i am really lazy here, but we might scratch it all so its just temp
				{
					if(_x isKindOf 'Food_SmallGuts')then{
						_x addQuantity -0.1;
						if((quantity _x) == 0)then{
							deleteVehicle _x;
						};
					};
				} forEach _cargo;
			};			
		};
	} forEach _cargo;
	hint str _limecount;
	//generate rest of lime in proper piles
	_barrel setVariable['lidopen',true];
	if(_limecount>0)then{
		_pileslime = floor(_limecount/10);	
		for [{_i=0},{_i<_pileslime},{_i=_i+1}] do
		{	
			_item = _barrel createInCargo 'Consumable_GardenLime';
			_item setQuantity 1;
			_item setDamage 0.85;
		};
		_rest = (_limecount-(_pileslime*10));
		if(_rest > 0)then{
			_item = _barrel createInCargo 'Consumable_GardenLime';
			_item setQuantity (_rest/10);
			_item setDamage 0.85;
		};
	};
	_barrel setVariable['lidopen',false];
	_barrel setVariable ['busy',false];