private ["_player","_state","_fireplace"];

/*
	Manage fireplace actions.
	
	Author: Lubos Kovac
*/

//input
_state = _this select 0;
_player = _this select 1;
_params = _this select 2;

//conditions
_max_wet_level_to_ignite = 0.2;
_min_temp_to_reignite = 200;

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

switch _state do
{	
	//can be ignited by match
	case 1:
	{
		_fireplace = _params select 0;
		
		if ( !(_fireplace getVariable ['fire', false]) and 
			 (itemInHands _player) isKindOf 'Consumable_Matchbox' and
			_fireplace animationPhase 'LidOn' == 1) then
		{
			true
		};
	};

	//can be ignited by flare
	case 11:
	{
		_fireplace = _params select 0;
		
		if ( !(_fireplace getVariable ['fire', false]) and 
			 (itemInHands _player) isKindOf 'Consumable_Roadflare' and
			 _fireplace animationPhase 'LidOn' == 1) then
		{
			true
		};
	};
	
	//can be extinguished
	case 3: 
	{ 
		_fireplace = _params select 0;
		
		if (
			((itemInHands _player) isKindOf 'Drink_WaterBottle' or 
			 (itemInHands _player) isKindOf 'Drink_Canteen' or 
			 (itemInHands _player) isKindOf 'Tool_FireExtinguisher') and
			_fireplace getVariable ['fire', false] and
			_fireplace animationPhase 'LidOn' == 1) then
		{
			true
		};
	};
	
	//TODO
	//inventory condition
	case 4: 
	{ 
		_fireplace = _params select 0;
		
		/*
		if (!(_fireplace getVariable ['is_fireplace', false]) and
			!(_fireplace getVariable ['fire', false])) then
		{
			true
		};
		*/
		if (count (itemsInInventory _fireplace) == 0) then
		{
			true
		}
		else
		{
			false
		};
	};	
	
	//can pose wooden stick towards fire
	case 5: 
	{ 
		_fireplace = _params select 0;
		
		if (
			(_player getVariable ['isUsingSomething',0] == 0) and 
			((itemInHands _player) isKindOf 'Crafting_LongWoodenStick') and
			[_player, _fireplace] call _is_facing_towards_fireplace and
			_fireplace animationPhase 'LidOn' == 1) then
		{
			true
		};
	};
			
	//is facing fireplace
	case 6:
	{
		_fireplace = _params select 0;
		[_player, _fireplace] call _is_facing_towards_fireplace;
	};
	
	//is posing stick towards fireplace
	case 7:
	{
		[_player] call _is_posing_stick;
	};
	
	//can open lid
	case 8:
	{
		_fireplace = _params select 0;
		_cooking_equipment = _fireplace getVariable ['cooking_equipment', objNull];
		
		if (_fireplace animationPhase 'LidOn' == 0 and 
			isNull _cooking_equipment) then
		{
			true
		};
	};
	
	//can close lid
	case 9:
	{
		_fireplace = _params select 0;
		
		if (_fireplace animationPhase 'LidOff' == 0) then
		{
			true
		};		
	};
	
	default {};
};
