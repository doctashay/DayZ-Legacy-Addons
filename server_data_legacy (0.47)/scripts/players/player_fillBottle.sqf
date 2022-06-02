private["_sourceObject","_waterVessel","_person","_name","_playAnim","_animationLenght"];

//Define
//[this,_inHands,_owner,_name]
_sourceObject	= _this select 0;
_waterVessel	= _this select 1;
_person		= _this select 2;
//_name		= _this select 3;

if (damage _waterVessel >= 1) exitWith
{
	//feedback to player
	[_person,format["Can not fill ruined %1 with water",displayName _waterVessel],"colorAction"] call fnc_playerMessage;
};

//conduct action
_person say3D ["z_fillwater_0", 20];

// Default play animation for filling from pod
_playAnim		= "fillBottlePond";
_animationLenght	= 2;

// If source object is OBJECT
if ( typeName _sourceObject == "OBJECT" ) then
{
	// IBJECT is Well then play animation filling bottle from well
	if ( typeOf _sourceObject == "Land_pumpa" ) then
	{
		_playAnim		= "fillBottleWell";
		_animationLenght	= 4;
	}
};

_person playAction [_playAnim, {}];

//wait until animation finish
sleep _animationLenght;

//Update resources
_waterVessel setQuantity (maxQuantity _waterVessel);

//feedback to player
[_person,format["I have filled a %1 with water.",displayName _waterVessel],"colorAction"] call fnc_playerMessage;

