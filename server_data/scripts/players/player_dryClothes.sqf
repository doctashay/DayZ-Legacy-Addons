call
{
	private["_player","_playAnim"];
	_player = _this;
	_playAnim = "PlayerBandage";
	
	_player playAction [_playAnim, {_this spawn fnc_dryClothes_doAction}];
};

fnc_dryClothes_doAction = 
{
	private["_player","_wetness"];
	_player = _this;
	_wetness = _player getVariable["wet", 0.0];
	
	_player setVariable["wet", _wetness - 0.2];  
	[_player, format["You've squezed some water out of your clothes."], "colorStatusChannel"] call fnc_playerMessage;
};
