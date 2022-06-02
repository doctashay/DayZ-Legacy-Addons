/*
	Description: Makes the player's character gut the dead body and gives him its organs.
*/

_user = _this select 0;
_tool = _this select 1;
_body = _user getVariable "skinnedBody";
_gainedMeat = []; //Items with various quantity
_gainedItems = [];//Items with various quality
_gainedStack = [];//Stack of items (ex.: feathers)

switch (true) do 
{

	// carp
	case (_body isKindOf "Food_Carp"):
	{
		_gainedFood =	[ ["Meat_CarpFillet",2], ["Food_SmallGuts",1]	];
	};

	// Mackerel
	case (_body isKindOf "Food_Mackerel"):
	{
		_gainedFood =	[ ["Meat_MackerelFillet",1], ["Food_SmallGuts",1]	];
	};

	// survivors
	case (_body isKindOf "SurvivorBase"):
	{
		_gainedFood =	[ ["Meat_HumanSteak",4] ];	
		_gainedItems =	[ ["",0]				];
		_gainedStack =	[ ["Consumable_Bones",5] ];
	};

	// cow and bull
	case (_body isKindOf "Animal_BosTaurusF" or _body isKindOf "Animal_BosTaurus" ):
	{
		_gainedFood =	[ ["Meat_CowSteak",5], 		["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltCow",1],["Food_Lard",1]					];
		_gainedStack =	[ ["Consumable_Bones",10] ];
	};

	// roe deer and roe deer femina
	case (_body isKindOf "Animal_CapreolusCapreolus" or _body isKindOf "Animal_CapreolusCapreolusF" ):
	{
		_gainedFood =	[ ["Meat_DeerSteak",4], ["Food_Guts",1]	];
		_gainedItems =	[ ["Food_Lard",0.8], ["Consumable_PeltDeer",1]				];	
		_gainedStack =	[ ["Consumable_Bones",7] ];	
	};

	// domestic goat
	case (_body isKindOf "Animal_CapraHircus" ):
	{
		_gainedFood =	[ ["Meat_GoatSteak",4], ["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltGoat",1],["Food_Lard",0.4]				];
		_gainedStack =	[ ["Consumable_Bones",4] ];
	};

	// wolf
	case (_body isKindOf "Animal_CanisLupus" ):
	{
		_gainedFood =	[ ["Meat_WolfSteak",4], ["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltWolf",1],["Food_Lard",0.4]				];
		_gainedStack =	[ ["Consumable_Bones",4] ];
	};

	// bear
	case (_body isKindOf "Animal_UrsusArctos" ):
	{
		_gainedFood =	[ ["Meat_BearSteak",8], ["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltBear",1],["Food_Lard",0.4]				];
		_gainedStack =	[ ["Consumable_Bones",7] ];
	};

	// mouflon
	case (_body isKindOf "Animal_OvisOrientalis" ):
	{
		_gainedFood =	[ ["Meat_MouflonSteak",4], ["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltMouflon",1],["Food_Lard",0.4]				];
		_gainedStack =	[ ["Consumable_Bones",4] ];
	};

	// male Red Deer
	case (_body isKindOf "Animal_CervusElaphus" or _body isKindOf "Animal_CervusElaphusF" ):
	{
		_gainedFood =	[ ["Meat_DeerSteak",4], ["Food_Guts",1]	];
		_gainedItems =	[ ["Food_Lard",0.8], ["Consumable_PeltDeer",1]				];	
		_gainedStack =	[ ["Consumable_Bones",7] ];		
	};

	// hen, chicken, cock
	case (_body isKindOf "Animal_GallusGallusDomesticusF" or _body isKindOf "Animal_GallusGallusDomesticus" ):
	{
		_gainedFood =	[ ["Meat_ChickenBreast",2], ["Food_SmallGuts",1] ];
		_gainedStack =	[ ["Consumable_Bones",2], ["Crafting_ChickenFeather",20] ];
	};

	// rabbit, hare
	case (_body isKindOf "Animal_LepusEuropaeus"):
	{
		_gainedFood =	[ ["Meat_RabbitLeg",2], ["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltRabbit",1]			];
		_gainedStack =	[ ["Consumable_Bones",2] ];
	};

	// domestic pig
	case (_body isKindOf "Animal_SusDomesticus"):
	{
		_gainedFood =	[ ["Meat_PigSteak",4], ["Food_Guts",1] ];
		_gainedItems =	[ ["Consumable_PeltPig",1],["Food_Lard",0.8]				];
		_gainedStack =	[ ["Consumable_Bones",4] ];
	};

	// wildboar
	case (_body isKindOf "Animal_SusScrofa"):
	{
		_gainedFood =	[ ["Meat_BoarSteak",4], ["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltWildboar",1],["Food_Lard",0.8]			];
		_gainedStack =	[ ["Consumable_Bones",5] ];
	};
	
	// Sheep
	case (_body isKindOf "Animal_OvisAriesF"  or _body isKindOf "Animal_OvisAries"):
	{
		_gainedFood =	[ ["Meat_SheepSteak",4], ["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltSheep",1],["Food_Lard",0.85]			];
		_gainedStack =	[ ["Consumable_Bones",5] ];
	};

	// Fox
	case (_body isKindOf "Animal_VulpesVulpes"):
	{
		_gainedFood =	[ ["Meat_FoxSteak",3], ["Food_Guts",1]	];
		_gainedItems =	[ ["Consumable_PeltFox",1],["Food_Lard",0.85]			];
		_gainedStack =	[ ["Consumable_Bones",5] ];
	};
};

if (count _gainedMeat == 0 && count _gainedItems == 0 && count _gainedStack == 0) then 
{
	[_user,"There is nothing useful to gut from this carcass.",""] call fnc_playerMessage;	
}else{
	_user setVariable ["skinnedBody", nil];
	
	// Adding meat and guts to the player's inventory
	if (count _gainedFood > 0) then {
		{
			_forEachEntry = _x;
			for [{_itemCount = 1},{_itemCount <= _forEachEntry select 1},{_itemCount = _itemCount + 1}] do {
				_item = [_forEachEntry select 0, _user] call player_addInventory;
				_item setQuantity ( 1 - (damage (_tool) * 0.5 + random 0.1));
			};
		} forEach _gainedFood;
	};
	
	// Adding pelts and other items to the player's inventory
	if (count _gainedItems > 0) then {
		{
			_forEachEntry = _x;
			_item = [_forEachEntry select 0, _user] call player_addInventory;
			_item setDamage ( (damage (_tool) * 0.5 + random 0.1));
			_item setQuantity (_forEachEntry select 1);
		} forEach _gainedItems;
	};
	
	// Adding stacks of various things to the player's inventory
	if (count _gainedStack > 0) then
	{
		{
			_forEachEntry = _x;
			_item = [_forEachEntry select 0, _user] call player_addInventory;
			_item setQuantity (_forEachEntry select 1);
		} forEach _gainedStack;
	};
	
	_tool setDamage (damage _tool)+0.02;
	deleteVehicle _body;
	_user setVariable ["skinnedBody", nil];
};
