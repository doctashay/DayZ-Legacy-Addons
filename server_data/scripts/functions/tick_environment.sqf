private["_agent","_pos","_isSea","_isWater","_bones","_delta","_anim","_bodyPosition","_isSwim","_playerWet","_isDrying"];
_agent = _this;
_pos = position _agent;
_isSea = surfaceIsWater _pos;
_isWater = surfaceType _pos == "FreshWater";
_bones = [];
_delta = 0;
_isWater = false;
_playerWet = _agent getVariable ["wet",0];
_gettingWet = _agent getVariable ["gettingWet",false];
_isDrying = !_gettingWet;
_agentSpeed = ([0,0,0] distance (velocity _agent)) min 6;
_airTemperature = 10; //airTemperature;
	
//SeaWater or Water
if (_isWater or _isSea) then
{
	_anim = animationState _agent;
	_bodyPosition = getText(configFile >> "CfgMovesMaleSdr2" >> "states" >> _anim >> "bodyPosition");
	_isSwim = _bodyPosition == "swim";
	_delta = 0.5 * DZ_TICK;	//increase in wetness
	_isDrying = false;
	
	//Is the deep or shallow?
	if (_isSwim) then
	{
		//deep
		if(!(captive _agent))then{
			[_agent,0] call player_drown;
		};
		_bones = [
			["Head",1],
			["Chest",1],
			["Back",1],
			["Pelvis",1],
			["LeftFoot",1]
		];
	}
	else
	{
		//shallow
		switch (_bodyPosition) do
		{
			case "prone":
			{
				// drowning
				[_agent,1] call player_drown;
				
				_bones = [
					["Head",0.7],
					["Chest",1],
					["Back",0.7],
					["Pelvis",1],					
					["LeftFoot",1]
				];
			};
			case "kneel":
			{
				if((captive _agent) && (_height < -1))then{[_agent,1] call player_drown;}else{[_agent,0] call player_drown;};
				_bones = [
					["Chest",0.2],
					["Back",0.05],
					["Pelvis",0.4],
					["LeftFoot",1]
				];
			};
			case "stand":
			{
				if((captive _agent) && (_height < -1.5))then{[_agent,1] call player_drown;}else{[_agent,0] call player_drown;};
				_bones = [
					["Pelvis",0.05],
					["LeftFoot",1]
				];
			};
		};
	};
}
else
{
	//drowning
	if(!(captive _agent))then{
		[_agent,0] call player_drown;
	};
	if (!_gettingWet) then
	{
		//probably drying
		_isDrying = true;
		//movement + wind + sunshine
		_delta = -1*(((1+(_agentSpeed/3)) + ((windSpeed min 2) max 1))/2000*((1+worldLightScale) min 2));
		_bones = [
			["Head",1],
			["Chest",0.6],
			["Back",0.7],
			["Pelvis",0.2],
			["LeftFoot",0.3]
		];
	}
	else
	{
		//getting rained on
		if((_agent itemInSlot "body") isKindOf "RaincoatBase" || (_agent itemInSlot "body") isKindOf "Gorka_up_Base" || (_agent itemInSlot "body") isKindOf "FirefighterJacketBase")then{
			_delta = -1*(((1+(_agentSpeed/3)) + ((windSpeed min 2) max 1))/2000*((1+worldLightScale) min 2));
		}else{
			_delta = rain * 0.1 * DZ_TICK;
		};
		
		_bones = [
			["Head",1],
			["Chest",1],
			["Back",0.7],
			["Pelvis",0.7],					
			["LeftFoot",0.7]
		];
	};
	
	//-------------------------
	if ( !(isNull (_agent itemInSlot "Feet")) ) then
	{
		_speed = speed _agent;
		if ( _speed > 0.5 ) then
		{
			_shoes = _agent itemInSlot "Feet";
			if ( damage _shoes < 1 ) then
			{
				_rough = getNumber (configFile >> "CfgSurfaces" >> surfaceType getPosASL _agent >> "rough");
				_hp = getNumber (configFile >> "CfgVehicles" >> typeOf _shoes >> "armor");
				if (_speed < 5) then
				{
					_rough = _rough * 0.25;
				};
				if (_speed >= 5 && _speed <= 10) then
				{
					_rough = _rough * 0.5;
				};
/*
				if (_speed > 10 && _speed <= 15) then
				{
					_rough = _rough * 1.3;
				};	
*/
				if (_speed > 15) then
				{
					_rough = _rough * 2;
				};

				_dmg = (1/_hp) * 0.01 * _rough;
				_shoes setDamage damage _shoes + _dmg;
			};
		};
	};
};
_heatpackon = 0;
_totalHeatIsolation = 0;
//check slots assigned to each bone
{
	
	_slots = getArray(configFile >> "cfgBody" >> (_x select 0) >> "inventorySlots");
	_scale = (_x select 1);
	_filledSlots = 0;
	{
		private["_item","_wetness","_slot"];
		//find out what is on the player
		_slot = _x;
		_item = _agent itemInSlot _x;
		call fnc_processItemWetness;

		//process items inside
		if(_item isKindOf 'ClothingBase')then{
			/*
				CALCULATE TEMPERATURE ISOLATION
			*/
			_totalHeatIsolation = _totalHeatIsolation + ((1-(damage _item)/2)*getNumber (configFile >> "cfgVehicles" >> typeOf _item >> "heatIsolation"));
			_waterproof = getNumber (configFile >> "cfgVehicles" >> typeOf _item >> "absorbency");
			_itemwet = _item getVariable ["wet",0];
			_inside = itemsInCargo _item;
			{
				_cargoitem = _x;
				if(_cargoitem isKindOf 'ClothingBase' and _waterproof > 0 and (_itemwet == 0 or !_isDrying))then{
					_cargowetness = _cargoitem getVariable ["wet",0];
					_cargoabsorbancy = getNumber(configFile >> "cfgVehicles" >> typeOf _cargoitem >> "absorbency");
					_cargowetness = ((_cargowetness + (_delta * _scale)) min _cargoabsorbancy) max 0;
					_cargoitem setVariable ["wet",_cargowetness];
				}else{
					//checking for active heatpacks
					if(!(_isWater) and ((damage _cargoitem) < 1))then{
						_temper = getTemperature _cargoitem;
						if(_temper > 0)then{
							if(_cargoitem isKindOf 'Tool_Heatpack')then{ 
								_cargoitem setDamage ((damage _cargoitem)+0.002);
								if(_temper < 0.01)then{_cargoitem setDamage 1;};
								_heatpackon = _heatpackon + (_temper/2);	
							}else{
								if(_temper-0.02 < 0)then{_cargoitem setTemperature 0;}else{_cargoitem setTemperature (_temper-0.02);};
								_heatpackon = _heatpackon + (_temper/4);
							};
						};
					};
				};
			} forEach _inside;
		};

	} forEach _slots;
} forEach _bones;

//Raining

//Process wetness of player
_agent setVariable ["wet",_playerWet];
_agent setVariable ["isdryingstate",_isDrying];

if (_playerWet > 0) then
{ 
	[0,_agent,"Wet"] call event_modifier;
};
/*

TEMPERATURE

*/
_playerTemperature = _agent getVariable ["bodytemperature",36.5];
_heatcomfort = 0;

//SETING BODY SHAKE when player is hypothermic
// _shake = 0;
// if(_playerTemperature < 35.5)then{_shake = ((35.5-_playerTemperature) min 1);};
// _agent SetBodyShaking _shake;
/*
[_agent,format['delta:%1 wet:%2',_delta,_playerWet],'colorImportant'] call fnc_playerMessage;
[_agent,format['windspeed:%1',windSpeed],'colorImportant'] call fnc_playerMessage;
[_agent,format['agentSpeed:%1',_agentSpeed],'colorImportant'] call fnc_playerMessage;
[_agent,format['worldLightScale:%1',worldLightScale],'colorImportant'] call fnc_playerMessage;
*/
//_heatcomfort = ((_totalHeatIsolation max 5.5)*1.25*((((_agentSpeed/2) max 1) min 3)-_playerWet)/2-(_playerTemperature-(_worldLightScale*15 -((windSpeed*3) min 6)-(getPosASL _agent select 2)/100))) min 100;	


_heatcomfort = (_heatpackon+(((_airTemperature+_totalHeatIsolation) max 7)*((((_agentSpeed/3.2) max 1) - _playerWet) max 0.1))- ( _playerTemperature + (((worldLightScale max 0) min 2)*10) - ((windSpeed*3) min 6) - ((getPosASL _agent select 2)/100) ) ) min 100;

//[_agent,format['totalHeatIsolation:%1 heatcomfort%2',_totalHeatIsolation,_heatcomfort],'colorImportant'] call fnc_playerMessage;
_agent setVariable ["heatcomfort",_heatcomfort];
