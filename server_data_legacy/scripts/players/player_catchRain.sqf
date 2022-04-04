private ["_player","_state","_item"];

//input
_state = _this select 0;
_player = _this select 1;
_item = _this select 2;

switch _state do
{	
	//catch rain - START
	case 1:
	{
		private["_play_action_params"];
		
		_animation = 'ItemUseShort'; //default animation
		
		if ( _item isKindOf 'CookwareContainer' ) then 
		{ 
			_animation = 'PlayerCatchRain'; 
		}; 
		
		//set and store parameters
		_player setVariable ['play_action_params', [_item]];
		_player setVariable ['isUsingSomething', 1];
		
		//play animation
		_player playAction [_animation, {[11, _this, objNull] call player_catchRain;}];
	};

	//catch rain - END
	case 11:
	{
		private["_player","_play_action_params","_item"];
		_player = _this select 1;		
		_play_action_params = _player getVariable 'play_action_params';
		_item = _play_action_params select 0;

		//add liquid quantity
		_item addQuantity 50;
		
		//set and clear params
		_player setVariable ['play_action_params', []];
		_player setVariable ['isUsingSomething', 0];
		
		//message player
		[_player, format['I have caught some rain.'],'colorAction'] call fnc_playerMessage;
	};	
	
	default {};
};
