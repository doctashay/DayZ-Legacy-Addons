private["_person","_sender","_receiver","_max","_senderQty","_receiverQty","_exchanged","_config"];
/*
	Combine loose (rounds) money
	
	Author: Rocket
*/
if(!isServer) exitWith {};

_person = _this select 0;
_sender = _this select 1;
_receiver = _this select 2;
_config = configFile >> "CfgVehicles" >> typeOf _receiver;
_name = 	getText (_config >> "displayName");
_max = getNumber (_config >> "stackedMax");
_senderQty =  quantity _sender;
_receiverQty = quantity _receiver;

//process changes
_exchanged = ((_receiverQty + _senderQty) min _max) - _receiverQty;
_receiverQty = _receiverQty + _exchanged;
_senderQty = _senderQty - _exchanged;

//check disease
[_receiver,_sender,"Direct",1] call event_transferModifiers;
[_person,_receiver,"Direct",1] call event_transferModifiers;

//save results
if (_senderQty > 0) then
{
	_sender setQuantity _senderQty;
}
else
{
	deleteVehicle _sender;
};
_receiver setQuantity _receiverQty;

//send response
[_person,"craft_rounds"] call event_saySound;
[_person,format["I have combined the %1",_name],"colorAction"] call fnc_playerMessage;