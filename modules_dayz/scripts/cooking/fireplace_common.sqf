/*
	Fireplace common functions.
	
	Author: Lubos Kovac
*/

//get kindling count
_get_fuel_count = 
{
	private["_fireplace","_items","_items_count"];
	_fireplace = _this select 0;
	_items = _fireplace call fnc_getAttachments;
	
	_items_count = 0;
	{
		_item_obj = _x;
		
		if ( !(isNull _item_obj) and 
			_item_obj isKindOf "Consumable_Firewood" or 
			_item_obj isKindOf "Crafting_WoodenStick" or
			_item_obj isKindOf "ItemBook") then
		{
			_items_count = _items_count + 1;
		};
	} foreach _items;		
		
	_items_count
};

//get kindling count
_get_kindling_count = 
{
	private["_fireplace","_items","_items_count"];
	_fireplace = _this select 0;
	_items = _fireplace call fnc_getAttachments;
	
	_items_count = 0;
	{
		_item_obj = _x;
		
		if ( !(isNull _item_obj) and 
			_item_obj isKindOf "Consumable_Rags" or 
			_item_obj isKindOf "Medical_BandageDressing" or 
			_item_obj isKindOf "Medical_Bandage" or 
			_item_obj isKindOf "Consumable_Bark_Oak" or 
			_item_obj isKindOf "Consumable_Bark_Birch" or 
			_item_obj isKindOf "Consumable_Paper" ) then
		{
			_items_count = _items_count + 1;
		};
	} foreach _items;		
		
	_items_count
};

//player is facing towards fireplace
_is_facing_towards_fireplace  = 
{
	private["_player","_fireplace","_is_facing"];
	_player = _this select 0;
	_fireplace = _this select 1;
	_is_facing = false;

	//calculate direction vector
	_playerPos = getPosASL _player;
	_fireplacePos = getPosASL _fireplace;
	_vectorPF = [(_fireplacePos select 0)-(_playerPos select 0), (_fireplacePos select 1)-(_playerPos select 1), (_fireplacePos select 2)-(_playerPos select 2)];
	_x = _vectorPF select 0;
	_y = _vectorPF select 1;
	_z = _vectorPF select 2;
	
	//check vector magnitude (sqrt)
	_magnitude = sqrt (_x ^ 2 + _y ^ 2 + _z ^ 2);
	if (sqrt (_x ^ 2 + _y ^ 2 + _z ^ 2) == 0) exitWith
	{
		_is_facing
	};
	
	_vectorNormalized = [_x/_magnitude, _y/_magnitude, _z/_magnitude];
	
	//calculate dot product of  fireplace-player-direction vector and player-direction vector
	_playerDir = vectorDir _player;
	_dotProduct = ((_playerDir select 0) * (_vectorNormalized select 0)) + ((_playerDir select 1) * (_vectorNormalized select 1));
	
	//arcos of dot product -> direction angle
	//condition angle -> 25 degree
	if ( acos _dotProduct < 25 ) then 
	{
		_is_facing = true;
	};
	
	_is_facing
};

//player is posing stick
_is_posing_stick  = 
{
	private["_player","_state","_fireplace","_is_posing"];
	_player = _this select 0;
	_is_posing = false;
	_state = animationState _player;
	
	if (_state == "CdzpAmovPknlMstpSnonWnonDnon_fishingIdle" or 
		_state == "CdzpAidlPercMstpSrasWnonDnon_breath" ) then
	{
		_is_posing = true;
	};
	
	_is_posing
};

//no player hands
//no conatainer (bag, clothes)
_is_in_safe_position = 
{
	private["_item"];
	_item = _this;
	
	if ( !((itemParent _item) isKindOf "SurvivorBase") and
		 !((itemParent _item) isKindOf "ClothingBase") 
		) then
	{
		true
	}
	else
	{
		false
	};
};

