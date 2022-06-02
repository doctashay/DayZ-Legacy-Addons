/*
	Color items placed in barrel
	Author: Jan Tomasik 

*/
private["_owner","_barrel","_cargo","_disinfectcount","_clothcount","_leather"];

	_barrel = _this select 0;
	_owner = _this select 1;
	_cargo = itemsInCargo _barrel;
	_disinfectcount = 0;
	_clothcount = 0;
	_leather = false;

	//fill database with color ratio
	{
		if(((_x isKindOf 'Medical_DisinfectantSpray') or (_x isKindOf 'Consumable_GardenLime')) and ((damage _x) < 1))then{_disinfectcount=_disinfectcount+((quantity _x)*10);};
		if((_x isKindOf 'ClothingBase') and ((damage _x) < 1))then{_clothcount = _clothcount+1;};
	} forEach _cargo;
	
	//simple material check
	if((_disinfectcount==0))exitWith{
		[_owner,'I need to add at least some disinfectant or lime.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	if(((quantity _barrel) < (_clothcount*2000)) or ((quantity _barrel) < 10000))exitWith{
		[_owner,'There is not enough water.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	if((_clothcount==0))exitWith{
		[_owner,'There is nothing to bleach.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	//wait certain amount of time till its ready
	sleep 60;
	/*_currentTime = time;   
	while {time < _currentTime+(_shirtcount*10)} do {  
		
	}; 
	*/
	_barrel setVariable['lidopen',true];
	{	
		if(_x isKindOf 'ClothingBase')then{
			if(_disinfectcount > 0)then{
				
				if(_x isKindOf 'Bag_LeatherSackBase')then		{_leather=true;_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo 'Bag_LeatherSackBase_Natural';_item setDamage _dmg;};
				if(_x isKindOf 'Vest_LeatherStorageBase')then	{_leather=true;_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo 'Vest_LeatherStorage_Natural';_item setDamage _dmg;};
				if(_x isKindOf 'Top_LeatherJacketBase')then		{_leather=true;_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo 'Top_LeatherJacket__Natural';_item setDamage _dmg;};
				if(_x isKindOf 'Pants_LeatherPantsBase')then	{_leather=true;_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo 'Pants_LeatherPants_Natural';_item setDamage _dmg;};
				if(_x isKindOf 'Shoes_LeatherMoccasinsBase')then{_leather=true;_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo 'Shoes_LeatherMoccasins_Natural';_item setDamage _dmg;};
				if(_x isKindOf 'Hat_LeatherBase')then			{_leather=true;_dmg = (damage _x);deleteVehicle _x;_item = _barrel createInCargo 'Hat_Leather_Natural';_item setDamage _dmg;};
				if(!_leather and ((_x isKindOf 'TShirtWhite') or (_x isKindOf 'Armband_White')))then{
					_x setObjectTexture[0,"#(argb,8,8,3)color(0.8,0.8,0.8,1.0,CO)"]; 
					_x setObjectTexture[1,"#(argb,8,8,3)color(0.8,0.8,0.8,1.0,CO)"]; 
					_x setObjectTexture[2,"#(argb,8,8,3)color(0.8,0.8,0.8,1.0,CO)"]; 
					_x setVariable["color","0.8,0.8,0.8"]; 
				};
				_leather=false;
				_disinfectcount=_disinfectcount-1;
				//i am really lazy here, but we probably erase it so its just temp
				{
					if((_x isKindOf 'Medical_DisinfectantSpray') or (_x isKindOf 'Consumable_GardenLime'))then{
						_x addQuantity -0.1;
						if((quantity _x) == 0)then{
							deleteVehicle _x;
						};
					};
				} forEach _cargo;
			};			
		};
	} forEach _cargo;
	_barrel setVariable['lidopen',false];
	_barrel setVariable ['busy',false];