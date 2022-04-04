/*
	Color items placed in barrel
	Author: Jan Tomasik 

*/
private["_owner","_rgbAr","_barrel","_cargo","_colorcount","_shirtcount","_r","_g","_b","_color"];

	_barrel = _this select 0;
	_owner = _this select 1;
	_cargo = itemsInCargo _barrel;
	_colorcount= 0;
	_shirtcount = 0;
	_rgbAr = [0.8,0.8,0.8,0];

	//fill database with color ratio
	{
		if(((_x isKindOf 'TShirtWhite') or (_x isKindOf 'Armband_White')) and ((damage _x) < 1))then{_shirtcount=_shirtcount+1;};
		if(((_x isKindOf 'FruitBase') or (_x isKindOf 'Consumable_PlantMaterial')) and ((damage _x) < 1))then{
			if(_x isKindOf 'Fruit_CaninaBerry')then				{_rgbAr set [1,((_rgbAr select 1)-0.1)];_rgbAr set [2,((_rgbAr select 2)-0.1)];_colorcount=_colorcount+1;deleteVehicle _x;};
			if(_x isKindOf 'Consumable_PlantMaterial')then	{_rgbAr set [0,((_rgbAr select 0)-0.1)];_rgbAr set [2,((_rgbAr select 2)-(quantity _x))];_colorcount=_colorcount+(quantity _x);deleteVehicle _x;};
			if(_x isKindOf 'Fruit_SambucusBerry')then			{_rgbAr set [0,((_rgbAr select 0)-0.1)];_rgbAr set [1,((_rgbAr select 1)-0.1)];_colorcount=_colorcount+1;deleteVehicle _x;};
		};
	} forEach _cargo;
	
	//simple material check
	if((_colorcount==0))exitWith{
		[_owner,'I need to add at least one color.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	if(((quantity _barrel) < (_shirtcount*2000)) or ((quantity _barrel) < 10000))exitWith{
		[_owner,'There is not enough water.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	if((_shirtcount==0))exitWith{
		[_owner,'There is nothing to color in it.',""] call fnc_playerMessage;
		_barrel setVariable ['busy',false];
	};
	
	//wait certain amount of time till its ready
	sleep 60;
	/*_currentTime = time;   
	while {time < _currentTime+(_shirtcount*10)} do {  
		
	}; 
	*/
	
	//color items
	_r = (((_rgbAr select 0) max 0));
	_g = (((_rgbAr select 1) max 0));
	_b = (((_rgbAr select 2) max 0));
	_color = format["#(argb,8,8,3)color(%1,%2,%3,1.0,CO)",_r,_g,_b];
	_savecolor = format["%1,%2,%3",_r,_g,_b];
	{	
		if((_x isKindOf 'TShirtWhite') or (_x isKindOf 'Armband_White'))then{
			_x setObjectTexture[0,_color]; 
			_x setObjectTexture[1,_color]; 
			_x setObjectTexture[2,_color]; 
			_x setVariable["color",_savecolor]; 
		};
	} forEach _cargo;

	_barrel setVariable ['busy',false];