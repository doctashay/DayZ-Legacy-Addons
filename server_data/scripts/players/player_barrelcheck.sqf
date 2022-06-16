/*
	Check whether basic ingredients are in barrel
	Author: Jan Tomasik 

*/
	_check = _this select 0;
	_barrel = _this select 1;
	_cargo = itemsInCargo _barrel;
	_guts=false;
	_plant=false;
	_disin=false;
	_cloth=false;
	_color=false;
	_pelt=false;
	_lime=false;
	_barkbeige=false;
	_barkbrown=false;
	_lime=false;
	_nails=false;
	_leather=false;
	_result=false;
	//calculate amout of materials
	{
		if((damage _x) < 1)then{
			if(_x isKindOf 'Food_SmallGuts' and !_guts)then										{_guts=true;};
			if((_x isKindOf 'Consumable_PlantMaterial') and (quantity _x > 0) and !_plant)then	{_plant=true;};
			if((_x isKindOf 'Medical_DisinfectantSpray') and (quantity _x > 0) and !_disin)then	{_disin=true;};
			if(((_x isKindOf 'Armband_White') or (_x isKindOf 'TShirtWhite')) and !_cloth)then	{_cloth=true;};
			if(((_x isKindOf 'Fruit_CaninaBerry') or (_x isKindOf 'Fruit_SambucusBerry')) and !_color)then{_color=true;};
			if(_x isKindOf 'Consumable_PeltBase' and !_pelt)then								{_pelt=true;};
			if((_x isKindOf 'Consumable_Bark_Birch') and (quantity _x > 0) and !_barkbeige)then	{_barkbeige=true;};
			if((_x isKindOf 'Consumable_Bark_Oak') and (quantity _x > 0) and !_barkbrown)then	{_barkbrown=true;};
			if((_x isKindOf 'Consumable_GardenLime') and (quantity _x > 0) and !_lime)then		{_lime=true;};
			if((_x isKindOf 'Consumable_Nails') and (quantity _x > 0) and !_nails)then			{_nails=true;};
			if(((_x isKindOf 'Bag_LeatherSack_Natural') or 
				(_x isKindOf 'Vest_LeatherStorage_Natural') or 
				(_x isKindOf 'Top_LeatherJacket_Natural') or 
				(_x isKindOf 'Pants_LeatherPants_Natural') or 
				(_x isKindOf 'Shoes_LeatherMoccasins_Natural') or 
				(_x isKindOf 'Hat_Leather_Natural')) and !_leather)then							{_leather=true;};
		};
	} forEach _cargo;
	
	switch _check do{
		case 0: {if(_guts and _plant)then{_result=true;};};				  //fertilizer
		case 1: {if(_cloth and (_plant or _color))then{_result=true;};}; //coloring
		case 2: {if(_pelt and _lime)then{_result=true;};};			    //tanning
		case 3: {if(_disin and (_cloth or _leather))then{_result=true;};}; 		   //desinfect
		case 4: {if(_barkbeige and _leather)then{_result=true;};}; 		   //color leather
		case 5: {if(_barkbrown and _leather)then{_result=true;};}; 		   //color leather
		case 6: {if(_nails and _leather)then{_result=true;};}; 		   //color leather
	};
	
	_result;