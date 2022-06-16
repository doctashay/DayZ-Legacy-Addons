private["_cooker","_mode","_position","_person"];
_cooker = _this select 0;
_mode = _this select 1;
_person = _this select 2;
_position = getPosATL _cooker;

//check disease
if (count _this == 3) then
{
	[_person,_cooker,"Direct"] call event_transferModifiers;
};

switch (_mode) do
{
	case 0: //SETUP COOKER
	{
		private["_canister","_bb","_y"];
		
	};
	case 1: //UNSET COOKER
	{
		private["_canister","_bb","_x"];
		
	};
	case 2:	//TURN COOKER ON
	{
	};
	case 3:	//TURN COOKER OFF
	{
		private["_sfx"];
	};
};