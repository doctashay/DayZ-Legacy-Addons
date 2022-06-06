/*
Description: Makes the player's character gut the dead body and gives him its organs.
Example:
	//Check if we can gut the given dead body
	if ( [_player, _deadBody, _toolForSkinning] call player_gutDeadBodyCheck ) then {
		//Now we can safely gut the dead body
		[_player, _deadBody, _toolForSkinning] spawn player_gutDeadBody; 
	};
*/

_user = _this select 0;
_tool = _this select 1;
_body = _user getVariable "skinnedBody";
_gainedMeat = []; //Items with various quantity
_gainedItems = [];//Items with various quality
_gainedStack = [];//Stack of items (ex.: feathers)

switch (true) do 
{	//Gained organs from each animal - 				  [itemType, count]
case (_body isKindOf "redDeer"):{									_gainedMeat = ["Meat_DeerSteak_Raw",4];		_gainedItems = ["Consumable_PeltDeer",1]; 	_gainedStack =["Food_Guts",1];};
case (_body isKindOf "Animal_CervusElaphus"):{						_gainedMeat = ["Meat_DeerSteak_Raw",4];		_gainedItems = ["Consumable_PeltDeer",1];	_gainedStack =["Food_Guts",1];};
case (_body isKindOf "wildBoarNew"):{								_gainedMeat = ["Meat_BoarSteak_Raw",6];		_gainedItems = ["Consumable_PeltWildboar",1];	_gainedStack =["Food_Guts",1];};
case (_body isKindOf "Animal_SusScrofa"):{							_gainedMeat = ["Meat_BoarSteak_Raw",6];		_gainedItems = ["Consumable_PeltWildboar",1];	_gainedStack =["Food_Guts",1];};
case (_body isKindOf "pig"):{										_gainedMeat = ["Meat_BoarSteak_Raw",8];		_gainedItems = ["Consumable_PeltPig",1];	_gainedStack =["Food_Guts",1];}; //Placeholder meat!
case (_body isKindOf "cowV2"):{										_gainedMeat = ["Meat_CowSteak_Raw",8];		_gainedItems = ["Consumable_PeltCow",1];	_gainedStack =["Food_Guts",1];};
case (_body isKindOf "Animal_GallusGallusDomesticusFeminam"):{		_gainedMeat = ["Meat_ChickenBreast_Raw",2];	_gainedStack = ["Crafting_ChickenFeather",20];	_gainedItems =["Food_SmallGuts",1];};
case (_body isKindOf "HenV2"):{										_gainedMeat = ["Meat_ChickenBreast_Raw",2];	_gainedStack = ["Crafting_ChickenFeather",20];	_gainedItems =["Food_SmallGuts",1];};
case (_body isKindOf "Hen"):{										_gainedMeat = ["Meat_ChickenBreast_Raw",2];	_gainedStack = ["Crafting_ChickenFeather",20];	_gainedItems =["Food_SmallGuts",1];};
case (_body isKindOf "Animal_CapraHircus"):{						_gainedMeat = ["Meat_GoatSteak_Raw",4];		_gainedItems = ["Consumable_PeltGoat",1];	_gainedStack =["Food_Guts",1];};
case (_body isKindOf "GoatV2"):{									_gainedMeat = ["Meat_GoatSteak_Raw",4];		_gainedItems = ["Consumable_PeltGoat",1];	_gainedStack =["Food_Guts",1];};
case (_body isKindOf "Bear"):{										_gainedMeat = ["Meat_DeerSteak_Raw",10];	_gainedItems = ["Consumable_PeltBear",1];	_gainedStack =["Food_SmallGuts",1];}; //Placeholder meat!
case (_body isKindOf "RabbitV2"):{									_gainedMeat = ["Meat_RabbitLeg_Raw",2];		_gainedItems = ["Consumable_PeltRabbit",1];	_gainedStack =["Food_SmallGuts",1];};
case (_body isKindOf "Animal_LepusEuropaeus"):{						_gainedMeat = ["Meat_RabbitLeg_Raw",2];		_gainedItems = ["Consumable_PeltRabbit",1];	_gainedStack =["Food_Guts",1];};
case (_body isKindOf "Food_Carp"):{									_gainedMeat = ["Meat_Fillet_Raw",2];		_gainedItems =["Food_SmallGuts",1];};
case (_body isKindOf "Food_Sardines"):{								_gainedMeat = ["Meat_Fillet_Raw",1];		_gainedItems =["Food_SmallGuts",1];};
case (_body isKindOf "Food_Tuna"):{									_gainedMeat = ["Meat_Fillet_Raw",2];		_gainedItems =["Food_SmallGuts",1];};
case (_body isKindOf "SurvivorBase"):{								_gainedMeat = ["Meat_HumanSteak_Raw",4];	_gainedItems = ["",0]};
};

if (count _gainedMeat == 0 && count _gainedItems == 0 && count _gainedStack == 0) then 
{
	[_user,"There is nothing useful to gut from this carcass.",""] call fnc_playerMessage;	
}else{
	if (count _gainedMeat > 0) then {
		for [{_x= 1},{_x <= _gainedMeat select 1},{_x = _x + 1}] do {
			_item = [_gainedMeat select 0, _user] call player_addInventory;
			_item setQuantity ( 1 - (damage (_tool) * 0.5 + random 0.1));
		};
	};
	
	// Adding pelts and other items to the player's inventory
	if (count _gainedItems > 0) then {
		for [{_x= 1},{_x <= _gainedItems select 1},{_x = _x + 1}] do {
			_item = [_gainedItems select 0, _user] call player_addInventory;
			_item setDamage ( (damage (_tool) * 0.5 + random 0.1));
			_item setQuantity 1;
		};
	};
	
	// Adding stacks of various things to the player's inventory
	if (count _gainedStack > 0) then
	{
		_item = [_gainedStack select 0, _user] call player_addInventory;
		_item setQuantity (_gainedStack select 1);
	};
	
	_tool setDamage (damage _tool)+0.02;
	deleteVehicle _body;
	_user setVariable ["skinnedBody", nil];
};
