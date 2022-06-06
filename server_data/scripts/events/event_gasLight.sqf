_lamp = _this select 1;
_state = _this select 0;

statusChat [str(_this),""];
_position = getPosATL _lamp;

_mconfig = configFile >> "cfgVehicles" >> typeOf _lamp;
_config = _mconfig >> "flame";
_texture = getText(_config >> "texture");
_material = getText(_config >> "material");

switch (_state) do
{
	case 0: 
	{
		_sfx = objNull;
		
		//turn lamp off			
		_lamp switchLight 'OFF';
		
		if (isClass _config) then {
			//stop sound
			_sfx = _lamp getVariable ["soundSource",objNull];
			if (!isNull _sfx) then
			{
				deleteVehicle _sfx;
			};
			
			//set flame
			if (_texture != "") then
			{
				hint "clear";
				_lamp setObjectTexture [0,"#(rgb,8,8,3)color(1,0,0,0)"];
			};
			if (_material != "") then
			{
				_matOld = getArray(_mconfig >> "hiddenSelectionsMaterials");
				if (count _matOld > 0) then
				{
					_lamp setObjectMaterial [0,_matOld select 0];
				}
				else
				{
					_lamp setObjectMaterial [0,"dz\data\data\default.rvmat"];
				};
			};
			_lamp setVariable ["light",false];
		};
	};
	case 1:
	{
		_sfx = objNull;
		
		if (hasPower _lamp) then
		{
			//turn lamp on			
			_lamp switchLight 'ON';
			
			if (isClass _config) then {
				//create sound
				//commented out because cant keep sound with player!!!
				//_sfx = createSoundSource [getText(_config >> "sound"),_position,[],0];
				//_lamp setVariable ["soundSource",_sfx];

				//set flame
				if (_texture != "") then
				{
					_lamp setObjectTexture [0,_texture];
				};
				if (_material != "") then
				{
					_lamp setObjectMaterial [0,_material];
				};
			};
			_lamp setVariable ["light",true];
		};
	};
};