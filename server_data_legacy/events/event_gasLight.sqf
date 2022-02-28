_lamp = _this select 1;
_state = _this select 0;

statusChat [str(_this),""];
_position = getPosATL _lamp;

switch (_state) do
{
	case 0: 
	{
		_config = configFile >> "cfgVehicles" >> typeOf _lamp >> "flame";
		_sfx = objNull;
		
		if (isClass _config) then {
			//stop sound
			_sfx = _lamp getVariable ["soundSource",objNull];
			if (!isNull _sfx) then
			{
				deleteVehicle _sfx;
			};
			
			//set flame
			_lamp setObjectMaterial [0,"dz\gear\cooking\data\gaslight.rvmat"];
			_lamp setVariable ["light",false];
		};
	};
	case 1:
	{
		//flame
		_config = configFile >> "cfgVehicles" >> typeOf _lamp >> "flame";
		_sfx = objNull;
		
		if (isClass _config) then {
			//create sound
			//commented out because cant keep sound with player!!!
			//_sfx = createSoundSource [getText(_config >> "sound"),_position,[],0];
			//_lamp setVariable ["soundSource",_sfx];

			//set flame
			_lamp setObjectMaterial [0,getText(_config >> "material")];
		};
		_lamp setVariable ["light",true];
	};
};