private["_state"];
/*
	Ignite fireplace with matches function, takes rain and strength of the wind into account.
	[0,this,_person] call player_igniteFireplace
	
	Author: Peter Nespesny
*/
_state = _this select 0;

switch _state do 
{
	case 0:
	{
		//pull data from passed parameters
		_fireplace = _this select 1;
		_person = _this select 2;
		_itemType = typeOf _fireplace;
		
		//check if there is at least one match left in the matchbox
		if (quantity (itemInHands _person) < 1) exitWith
		{
			[_person,format['I ran out of matches'],'colorAction'] call fnc_playerMessage;
		};
		
		//discard one match
		(itemInHands _person) addQuantity -1;

		//check rain
		if (_person getVariable ['gettingWet',false]) exitWith 
		{
			[_person,format['Match went out because of the rain'],'colorAction'] call fnc_playerMessage;
		};

		 //test collision
		 _pos = getPosASL _fireplace;
		 _xPos = _pos select 0;
		 _yPos = _pos select 1;
		 _bbox = (collisionBox [[_xPos, _yPos, (_pos select 2 ) + 1.4], [1,1,2.5] ,[[1,0,0], [0, 0, 1]], _person]);
		if ( _bbox ) exitWith
		{
			[_person,format['I cannot ignite the fireplace, its not safe'],'colorAction'] call fnc_playerMessage;
		};

		//check if player stands in the water (thus he is trying to ignite fireplace in/under the water
		_sur = surfaceTypeASL [_xPos, _yPos, _pos select 2];
		if ( _sur == "FreshWater" || _sur == "sea") exitWith
		{
			[_person,format['I cannot ignite fireplace in the water'],'colorAction'] call fnc_playerMessage;		
		};

/*		
		//check if player stands in the water (thus he is trying to ignite fireplace in/under the water
		if (surfaceIsWater (position _person)) exitWith
		{
			[_person,format['I cannot ignite fireplace in the water'],'colorAction'] call fnc_playerMessage;
		};
*/
		
		//check wind
		_windStrength = (wind select 0) + (wind select 1) + (wind select 2);
		_probability = 0;

		//set probability to ignite against wind
		switch true do 
		{
			case (_windStrength > 13.9): //[_owner,format['Feels like a strong wind'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.6;
			};
			case (_windStrength > 10.8): //[_owner,format['Feels like a moderate wind'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.7;
			};
			case (_windStrength > 5.4): //[_owner,format['Feels like a heavy breeze'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.8;
			};
			case (_windStrength > 1.5): //[_owner,format['Feels like a moderate breeze'],'colorAction'] call fnc_playerMessage;
			{
				_probability = 0.9;
			};
			case (_windStrength >= 0): //[_owner,format['Feels like only a light breeze'],'colorAction'] call fnc_playerMessage;
			{		
				_probability = 1;
			};
			default
			{
				_probability = 1;
			};
		};

		_probabilityToNotIgnite = 1 - _probability;
		_randomNum = random 1;

		if (_randomNum > _probabilityToNotIgnite) then
		{
			//conduct action
			//_string = format["[1,%1] call player_igniteFireplace",_fireplace]; //str(_fireplace)
			//diag_log _string;
			//_person playAction ['ItemUseShort',compile _string]; 	
					
			_person playAction ['startFire',{}];			
			this setVariable ['fire',true];
			this powerOn true;
			this animate['BurntWood',0];
			this animate['Wood',1];

			[_person,format["I've started the fire"],'colorAction'] call fnc_playerMessage;
		}
		else
		{
			[_person,format['Match went out because of the wind'],'colorAction'] call fnc_playerMessage;
		};		
	};
	//TO DO: ignite fireplace (start particles, turn light on.. etc.) after action is played
	case 1:
	{
			//_fireplace = _this select 1;
			//_person = _this select 2;
			/*
			diag_log _this;			
			_passedArray = _this select 1;
			_fireplace = _this select 1;
			diag_log _fireplace;
			*/
			/*
			this setVariable ['fire',true];
			this powerOn true;
			this animate['BurntWood',0];
			this animate['Wood',1];
			_position = getPosATL this;
			_sfx = createSoundSource [getText(configFile >> 'cfgVehicles' >> typeOf this >> 'flame' >> 'sound'),_position,[],0];
			this setVariable ['soundSource',_sfx];
			*/
			/*
			this setVariable ['fire',true];
			this powerOn true;
			this animate['BurntWood',0];
			this animate['Wood',1];
			*/			
			/*
			_fireplace setVariable ["fire",true]; 
			_fireplace powerOn true;
			_fireplace animate["BurntWood",0];
			_fireplace animate["Wood",1];
			diag_log "doh";
			*/
			//create fireplace sound source
			/*
			_position = getPosATL _fireplace;
			_sfx = createSoundSource [getText(configFile >> 'cfgVehicles' >> typeOf _fireplace >> 'flame' >> 'sound'),_position,[],0];
			_fireplace setVariable ['soundSource',_sfx];
			*/
	};
};

//////////////////////////////////////////////////////
/*
if (!(_person getVariable ['gettingWet',false])) then 
{
	this setVariable ['fire',true]; this powerOn true;this animate['BurntWood',0];this animate['Wood',1]; _position = getPosATL this; _sfx = createSoundSource [getText(configFile >> 'cfgVehicles' >> typeOf this >> 'flame' >> 'sound'),_position,[],0]; this setVariable ['soundSource',_sfx];
}
else
{
	[_owner,format['Match went out because of the rain'],'colorAction'] call fnc_playerMessage;
};
*/