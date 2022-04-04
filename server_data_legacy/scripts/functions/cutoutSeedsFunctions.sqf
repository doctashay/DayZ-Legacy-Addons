// Used in 'crafting' of seeds out of fruit + knife.
// Dried fruit gives different amount of seeds than any other state of food.
// Seed type and quantity is defined in config of each fruit.
// The _tool parameter is optional (can be objNull).
fnc_cutOutSeeds = 
{
	_user = _this select 0;
	_fruit = _this select 1;
	_tool = _this select 2; // Can be objNull
	_anyState_seedsQuantityCoef = _this select 3;
	_dried_seedsQuantityCoef = _this select 4;
	_seedsQuantityCoef = 0;
	
	// Damage check
	if (damage _fruit >= 1) exitWith {
		[_user, format["%1 is ruined.", displayName _fruit], "colorImportant"] call fnc_playerMessage;
	};
	
	// Tool is optional so player can use empty hands when the fruit is dry
	if !(isNull _tool) then {
		_tool setDamage damage _tool + 0.001;
	};
	
	// Calculate seeds quantity while taking fruit state into account
	_fruit_stage = _fruit getVariable ["food_stage",["Raw",0,0,0]];
	_fruitIsDry = ((_fruit_stage select 0) == "Dried");
	_fruitQuantity = quantity _fruit;
	_fruitName = toLower displayName _fruit;
	_fruitType = typeOf _fruit;
	deleteVehicle _fruit;
	
	if (_fruitIsDry) then 
	{
		_seedsQuantityCoef = _dried_seedsQuantityCoef; // Dried fruit should give more seeds
	}else{
		_seedsQuantityCoef = _anyState_seedsQuantityCoef;
	};
	
	// Hack for fruits which have quantity of 0 (like tomato, pepper...)
	if (_fruitQuantity == 0) then
	{
		_fruitQuantity = 1;
	};
	
	// Apply fruit quantity
	_config = configfile >> "CfgVehicles" >> _fruitType;
	_seedsQuantity = getNumber (_config >> "containsSeedsQuantity");
	_seedsQuantity = round (_seedsQuantity * _seedsQuantityCoef * _fruitQuantity);
	_message = format["I've cut out some seeds from the %1", _fruitName];
	
	// Set minimal seeds quantity to 1
	if (_seedsQuantity <= 1) then
	{
		_seedsQuantity = 1;
		_message = format["I've cut out a seed from the %1", _fruitName]; // Remove plural sense from the sentence
	};
	
	_config = configfile >> "CfgVehicles" >> _fruitType;
	_seedsType = getText (_config >> "containsSeedsType");
	
	_seeds = [_seedsType, _user] call player_addInventory;
	_seeds setQuantity _seedsQuantity;
	[_user, _message, "colorAction"] call fnc_playerMessage;
};

// Used in 'crafting' of seeds out of fruit + knife.
// Seed type and quantity is defined in config of pumpkin.
// The _tool parameter is REQUIRED here.
fnc_slicePumpkin = {
	_user = _this select 0;
	_pumpkin = _this select 1;
	_tool = _this select 2;
	_seedsQuantityCoef = _this select 3;
	_slicesCount = _this select 4;
	_fruitQuantity = quantity _pumpkin;
	
	// Check pumpkin's damage
	if (damage _pumpkin >= 1) exitWith {
		[_user, format["%1 is ruined.", displayName _pumpkin], "colorImportant"] call fnc_playerMessage;
	};
	
	// Apply pumpkin quantity
	_config = configfile >> "CfgVehicles" >> typeOf _pumpkin;
	_seedsQuantity = getNumber (_config >> "containsSeedsQuantity");
	_seedsQuantity = round (_seedsQuantity * _seedsQuantityCoef * _fruitQuantity);
	_foodName = toLower displayName _pumpkin;
	_message = format["I've cut out some seeds from the %1", _foodName];
	deleteVehicle _pumpkin; // Delete pumpkin before creating seeds and slices.
	
	// Set minimal seeds quantity to 1
	if (_seedsQuantity <= 1) then
	{
		_seedsQuantity = 1;
		_message = format["I've cut out a seed from the %1", _foodName]; // Remove plural sense from the sentence
	};
	
	// Create pumpkin slices
	_pumpkin_stage = _pumpkin getVariable ["food_stage",["Raw",0,0,0]];
	_pumpkinIsRotten = ((_pumpkin_stage select 0) == "Rotten");
	if (_pumpkinIsRotten) then
	{
		for [{_i=0},{_i<_slicesCount},{_i=_i+1}] do
		{
			_item = ["Fruit_PumpkinSliced", _user] call player_addInventory;
			[_item, "Rotten"] call fnc_changeFoodStage; // TO DO, Known issue: For some reason this cycle is executed only once, unless this line is commented out.
		};
	}
	else
	{
		for [{_i=0},{_i<_slicesCount},{_i=_i+1}] do
		{
			_item = ["Fruit_PumpkinSliced", _user] call player_addInventory;
		};
	};
	
	// Create seeds from config
	_config = configfile >> "CfgVehicles" >> typeOf _pumpkin;
	_seedsType = getText (_config >> "containsSeedsType");
	_seeds = [_seedsType, _user] call player_addInventory;
	_seeds setQuantity _seedsQuantity;
	_tool setDamage damage _tool + 0.001;
	[_user, _message, "colorAction"] call fnc_playerMessage;
}