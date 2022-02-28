private["_item","_actionName","_itemDir","_config","_name","_sounds","_action","_trashItem","_sound","_soundConfig","_distance","_calories","_water","_trashPos","_trash","_person"];
//Define
//[this,_inHands,_owner,_name]
_sourceObject = _this select 0;
_waterVessel = 	_this select 1;
_person = 		_this select 2;
//_actionName = 	_this select 3;

//conduct action
_person say3D ["z_fillwater_0", 20];
_person playAction ["fillBottlePond",{}];

//wait until animation done
sleep 2;

//Update resources
_waterVessel setVariable ["quantity",maxQuantity _waterVessel];

//feedback to player
[_person,format["You have filled a %1 with water",displayName _waterVessel],"colorAction"] call fnc_playerMessage;

