private["_person","_sender","_receiver","_max","_senderQty","_receiverQty","_exchanged","_config"];
/*
	Split loose items
	
	Author: Rocket
*/
_person = _owner;
_sender = _tool1;
_type = typeOf _sender;

_config = 	configFile >> "CfgVehicles" >> _type;
_name = 	getText (_config >> "displayName");
_senderQty = quantity _sender;

if (_senderQty < 2) exitWith
{	
	[_person,"Not enough to split into two groups",""] call fnc_playerMessage;
};

//check damage of combined piles and setDamage to the receiver
_condition = damage _sender;
_dirty = false;
if (_condition >= 0.5) then
{
	_dirty = true;
};

//process changes
_receiverQty = floor(_senderQty / 2);
_senderQty = _senderQty - _receiverQty;

//save results
_sender setQuantity _senderQty;

//new pile
_parent = itemParent _sender;
_pile = [_type,_parent,_person] call player_addInventory;
_pile setQuantity _receiverQty;
_pile setDamage (damage _sender);
if (_type == "Consumable_Rags") then
{
	if (_dirty) then
	{
		_pile setDamage _condition;
		//[0,_pile,'WoundInfection'] call event_modifier;
	};
};	
_dirty = false;

//send response
[_person,"craft_rounds"] call event_saySound;
[_person,format["I have split the %1",_name],"colorAction"] call fnc_playerMessage;