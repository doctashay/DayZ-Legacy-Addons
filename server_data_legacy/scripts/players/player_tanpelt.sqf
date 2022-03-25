/*
	Converts pelts into tanned pieces
	Author: Jan Tomasik 

*/
private["_owner","_limeperpelt","_barrel","_cargo","_peltcount","_limecount","_counter","_totalnewpeltcount","_tancAr","_peltAr","_minimumlime","_currentTime ","_maxpelts","_usedcount","_newpeltcount","_pilescount","_pilelime","_item","_rest","_restlime"];

	_limeperpelt = 0.5; //how many lime is consumed for generating one taned piece of pelt (1=10%)
	
	_barrel = _this select 0;
	_owner = _this select 1;
	_cargo = itemsInCargo _barrel;
	_peltcount = 0;
	_limecount = 0;
	_counter = 0;
	_totalnewpeltcount = 0;
	// if you gonna add new skin amount make sure that it will be ordered properly (from highest to lowest)
	_tancAr = [8,6,4,2]; //table of taned pieces animal pelt gives. it would be better to have it stored in pelt config itself, but guys did not do that that way so I continued in same way
	_peltAr = [0,0,0,0];
	_minimumlime = 10;
	
	//fill database with amount of pelts
	{
		if((_x isKindOf 'Consumable_GardenLime') and ((damage _x) < 1))then{
			_limecount = _limecount+round((quantity _x)*10);
		}else{
						
			//wasnt able to use switch case properly ask programmers whats the deal
			if((_x isKindOf 'Consumable_PeltBase') and ((damage _x) < 1))then{
				if(_x isKindOf 'Consumable_PeltBear')then		{if((_tancAr select 0) < _minimumlime)then{_minimumlime = (_tancAr select 0);};_peltAr set [0,((_peltAr select 0)+1)];_peltcount = (_peltcount+(_tancAr select 0));};
				if(_x isKindOf 'Consumable_PeltDeer')then		{if((_tancAr select 1) < _minimumlime)then{_minimumlime = (_tancAr select 1);};_peltAr set [1,((_peltAr select 1)+1)];_peltcount = (_peltcount+(_tancAr select 1));};
				if(_x isKindOf 'Consumable_PeltCow')then 		{if((_tancAr select 1) < _minimumlime)then{_minimumlime = (_tancAr select 1);};_peltAr set [1,((_peltAr select 1)+1)];_peltcount = (_peltcount+(_tancAr select 1));};
				if(_x isKindOf 'Consumable_PeltSheep')then		{if((_tancAr select 2) < _minimumlime)then{_minimumlime = (_tancAr select 2);};_peltAr set [2,((_peltAr select 2)+1)];_peltcount = (_peltcount+(_tancAr select 2));};
				if(_x isKindOf 'Consumable_PeltWildboar')then	{if((_tancAr select 2) < _minimumlime)then{_minimumlime = (_tancAr select 2);};_peltAr set [2,((_peltAr select 2)+1)];_peltcount = (_peltcount+(_tancAr select 2));};
				if(_x isKindOf 'Consumable_PeltPig')then		{if((_tancAr select 2) < _minimumlime)then{_minimumlime = (_tancAr select 2);};_peltAr set [2,((_peltAr select 2)+1)];_peltcount = (_peltcount+(_tancAr select 2));};
				if(_x isKindOf 'Consumable_PeltGoat')then 		{if((_tancAr select 2) < _minimumlime)then{_minimumlime = (_tancAr select 2);};_peltAr set [2,((_peltAr select 2)+1)];_peltcount = (_peltcount+(_tancAr select 2));};
				if(_x isKindOf 'Consumable_PeltRabbit')then		{if((_tancAr select 3) < _minimumlime)then{_minimumlime = (_tancAr select 3);};_peltAr set [3,((_peltAr select 3)+1)];_peltcount = (_peltcount+(_tancAr select 3));};				
			};
		};
	} forEach _cargo;
	
	//simple material check
	if((_peltcount==0))exitWith{
		[_owner,'I need to add pelts to tan.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	if((_limecount<_minimumlime*_limeperpelt))exitWith{
		[_owner,'Not enough lime for even one pelt.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	if(((quantity _barrel) < (_peltcount*1000)) or ((quantity _barrel) < 10000))exitWith{
		[_owner,'There is not enough water.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	//wait certain amount of time till its ready
	sleep 180;
	/*_currentTime = time;   
	while {time < _currentTime+10000} do {  
		
	}; 
	*/
	
	//calculate amount of pelts that could be taned
	{
		if(_x > 0)then{
			_maxpelts = floor (_limecount / ((_tancAr select _counter)*_limeperpelt));
			_usedcount = _maxpelts min (_peltAr select _counter);
			_newpeltcount = _usedcount * (_tancAr select _counter);
			_peltAr set [_counter,_usedcount];
			_limecount = _limecount - _newpeltcount*_limeperpelt;
			_totalnewpeltcount = _totalnewpeltcount + _newpeltcount;
		};
		_counter = _counter + 1;
	}forEach _peltAr;
	
	//delete used pelts
	{
		if(_x isKindOf 'Consumable_GardenLime')then{
			deleteVehicle _x;
		}else{
			if(_x isKindOf 'Consumable_PeltBase')then{
				if((_x isKindOf 'Consumable_PeltBear') and ((_peltAr select 0) > 0))then		{_peltAr set [0,((_peltAr select 0)-1)];deleteVehicle _x;};
				if((_x isKindOf 'Consumable_PeltDeer') and ((_peltAr select 1) > 0))then		{_peltAr set [1,((_peltAr select 1)-1)];deleteVehicle _x;};
				if((_x isKindOf 'Consumable_PeltCow') and ((_peltAr select 1) > 0))then 		{_peltAr set [1,((_peltAr select 1)-1)];deleteVehicle _x;};
				if((_x isKindOf 'Consumable_PeltSheep') and ((_peltAr select 2) > 0))then		{_peltAr set [2,((_peltAr select 2)-1)];deleteVehicle _x;};
				if((_x isKindOf 'Consumable_PeltWildboar') and ((_peltAr select 2) > 0))then	{_peltAr set [2,((_peltAr select 2)-1)];deleteVehicle _x;};
				if((_x isKindOf 'Consumable_PeltPig') and ((_peltAr select 2) > 0))then			{_peltAr set [2,((_peltAr select 2)-1)];deleteVehicle _x;};
				if((_x isKindOf 'Consumable_PeltGoat') and ((_peltAr select 2) > 0))then 		{_peltAr set [2,((_peltAr select 2)-1)];deleteVehicle _x;};
				if((_x isKindOf 'Consumable_PeltRabbit') and ((_peltAr select 3) > 0))then		{_peltAr set [3,((_peltAr select 3)-1)];deleteVehicle _x;};				
			};
		};
	} forEach _cargo;
	
	_barrel setVariable['lidopen',true];
	//generate taned skins in proper piles
	_pilescount = floor(_totalnewpeltcount/7);	
	for [{_i=0},{_i<_pilescount},{_i=_i+1}] do
	{	
		_item = _barrel createInCargo 'Consumable_TannedLeather';
		_item setQuantity 7;
	};
	_rest = (_totalnewpeltcount-(_pilescount*7));
	if(_rest > 0)then{
		_item = _barrel createInCargo 'Consumable_TannedLeather';
		_item setQuantity _rest;
	};
	//generate rest of lime in proper piles
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