/*
	Color pelts using bark
	Author: Jan Tomasik 

*/
private["_owner","_limeperpelt","_barrel","_cargo","_peltcount","_limecount","_counter","_totalnewpeltcount","_tancAr","_peltAr","_minimumlime","_currentTime ","_maxpelts","_usedcount","_newpeltcount","_pilescount","_pilelime","_item","_rest","_restlime","_restitem"];

	_limeperpelt = 1; //how many lime is consumed for generating one taned piece of pelt (1=10%)
	
	_barrel = _this select 0;
	_owner = _this select 1;
	_color = _this select 2;
	_cargo = itemsInCargo _barrel;
	_peltcount = 0;
	_limecount = 0;
	_counter = 0;
	_totalnewpeltcount = 0;
	_maxquant = 0;
	// if you gonna add new skin amount make sure that it will be ordered properly (from highest to lowest)
	_tancAr = [25,6,4,2,1]; //table of taned pieces animal pelt gives. it would be better to have it stored in pelt config itself, but guys did not do that that way so I continued in same way
	_peltAr = [ 0,0,0,0,0];
	_minimumlime = 10;
	
		
	//transfer int to string
	switch _color do {
		case 0: {_color = 'Beige';_restitem = 'Consumable_Bark_Birch';};
		case 1: {_color = 'Brown';_restitem = 'Consumable_Bark_Oak';};
		case 2: {_color = 'Black';_restitem = 'Consumable_Nails';};
	};
	
	
	//fill database with amount of clothes
	{
		
		if((_x isKindOf _restitem) and ((damage _x) < 1))then{
			_limecount = _limecount+(quantity _x);
		}else{
						
			//wasnt able to use switch case properly ask programmers whats the deal
			if((_x isKindOf 'ClothingBase') and ((damage _x) < 1))then{
				if(_x isKindOf 'Bag_LeatherSack_Natural')then		{if((_tancAr select 0) < _minimumlime)	then{_minimumlime = (_tancAr select 0);};_peltAr set [0,((_peltAr select 0)+1)];_peltcount = (_peltcount+(_tancAr select 0));};
				if(_x isKindOf 'Vest_LeatherStorage_Natural')then	{if((_tancAr select 1) < _minimumlime)	then{_minimumlime = (_tancAr select 1);};_peltAr set [1,((_peltAr select 1)+1)];_peltcount = (_peltcount+(_tancAr select 1));};
				if(_x isKindOf 'Top_LeatherJacket_Natural')then		{if((_tancAr select 2) < _minimumlime)	then{_minimumlime = (_tancAr select 2);};_peltAr set [2,((_peltAr select 2)+1)];_peltcount = (_peltcount+(_tancAr select 2));};
				if(_x isKindOf 'Pants_LeatherPants_Natural')then 	{if((_tancAr select 3) < _minimumlime)	then{_minimumlime = (_tancAr select 3);};_peltAr set [3,((_peltAr select 3)+1)];_peltcount = (_peltcount+(_tancAr select 3));};
				if(_x isKindOf 'Shoes_LeatherMoccasins_Natural')then{if((_tancAr select 3) < _minimumlime)	then{_minimumlime = (_tancAr select 3);};_peltAr set [3,((_peltAr select 3)+1)];_peltcount = (_peltcount+(_tancAr select 3));};
				if(_x isKindOf 'Hat_Leather_Natural')then			{if((_tancAr select 4) < _minimumlime)	then{_minimumlime = (_tancAr select 4);};_peltAr set [4,((_peltAr select 4)+1)];_peltcount = (_peltcount+(_tancAr select 4));};
			};
		};
	} forEach _cargo;
	
	//simple material check
	if((_peltcount==0))exitWith{
		[_owner,'I need to add leather clothes to color.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	if((_limecount<_minimumlime*_limeperpelt))exitWith{
		[_owner,'Not enough bark for even one leather clothing.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	if(((quantity _barrel) < (_peltcount*1000)) or ((quantity _barrel) < 10000))exitWith{
		[_owner,'There is not enough water.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};


	//calculate amount of clothes that could be colored
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
	

	_barrel setVariable['lidopen',true];
	//generate rest of bark in proper piles
	if(_limecount>0)then{
		_pileslime = floor(_limecount/8);
		for [{_i=0},{_i<_pileslime},{_i=_i+1}] do
		{	
			_item = _barrel createInCargo _restitem;
			_item addQuantity 8;
			_item setDamage 0.85;
		};
		
		_rest = (_limecount-(_pileslime));
		if(_rest > 0)then{
			_item = _barrel createInCargo _restitem;
			_item addQuantity (_rest);
			_item setDamage 0.85;
		};
	};

	{
		if(_x isKindOf _restitem)then{
			deleteVehicle _x;
		}else{
			if(_x isKindOf 'ClothingBase')then{
				if((_x isKindOf 'Bag_LeatherSack_Natural') and ((_peltAr select 0) > 0))then		{_peltAr set [0,((_peltAr select 0)-1)];_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo format['Bag_LeatherSack_%1',_color];_item setDamage _dmg;};
				if((_x isKindOf 'Vest_LeatherStorage_Natural') and ((_peltAr select 1) > 0))then	{_peltAr set [1,((_peltAr select 1)-1)];_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo format['Vest_LeatherStorage_%1',_color];_item setDamage _dmg;};
				if((_x isKindOf 'Top_LeatherJacket_Natural') and ((_peltAr select 2) > 0))then		{_peltAr set [2,((_peltAr select 2)-1)];_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo format['Top_LeatherJacket_%1',_color];_item setDamage _dmg;};
				if((_x isKindOf 'Pants_LeatherPants_Natural') and ((_peltAr select 3) > 0))then		{_peltAr set [3,((_peltAr select 3)-1)];_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo format['Pants_LeatherPants_%1',_color];_item setDamage _dmg;};
				if((_x isKindOf 'Shoes_LeatherMoccasins_Natural') and ((_peltAr select 3) > 0))then	{_peltAr set [3,((_peltAr select 3)-1)];_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo format['Shoes_LeatherMoccasins_%1',_color];_item setDamage _dmg;};
				if((_x isKindOf 'Hat_Leather_Natural') and ((_peltAr select 4) > 0))then			{_peltAr set [4,((_peltAr select 4)-1)];_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo format['Hat_Leather_%1',_color];_item setDamage _dmg;};
			};
		};
	} forEach _cargo;
	

	_barrel setVariable['lidopen',false];
	_barrel setVariable ['busy',false];