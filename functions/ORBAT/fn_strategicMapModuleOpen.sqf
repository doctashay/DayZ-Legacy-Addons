private ["_logic","_units","_show"];

_logic = [_this,0,objnull,[objnull]] call bis_fnc_param;
_units = [_this,1,[player],[[]]] call bis_fnc_param;

if !(player in _units) exitwith {false};

_overcast = _logic getvariable ["Overcast",""];
_overcast = if (_overcast == "") then {overcast} else {_overcast call bis_fnc_parsenumber};

_isNight = _logic getvariable ["Daytime",""];
_isNight = if (_isNight == "") then {0} else {_isNight call bis_fnc_parsenumber};
_isNight = _isNight > 0;

_coreCount = 0;
_corePos = position _logic;
_markers = [];
_missions = [];
_ORBAT = [];
_images = [];
{
	if (typeof _x == "ModuleStrategicMapInit_F") then {
		_coreCount = _coreCount + 1;
		if (_coreCount == 1) then {
			//_corePos = position _x;
			_markers = _x getvariable ["Markers",""];
			_markers = call compile ("[" + _markers + "]");
			{
				switch (typeof _x) do {
					case "ModuleStrategicMapMission_F": {
						_pos = position _x;
						_code = _x getvariable ["Code",""];
						_title = _x getvariable ["Title",""];
						_description = _x getvariable ["Description",""];
						_player = _x getvariable ["Player",""];
						_image = _x getvariable ["Image",""];
						_size = _x getvariable ["Size","1"];
						_size = parsenumber _size;

						if (typename _code == typename "") then {_code = compile _code;};

						//--- Check for localization
						_title = _title call bis_fnc_localize;
						_description = _description call bis_fnc_localize;

						_missions set [
							count _missions,
							[_pos,_code,_title,_description,_player,_image,_size]
						];
					};
					case "ModuleStrategicMapORBAT_F": {
						_pos = position _x;
						_path = call compile (_x getvariable "Path");
						_parent = call compile (_x getvariable "Parent");
						_tags = _x getvariable ["Tags",""];
						_tiers = (call compile (_x getvariable "Tiers")) call bis_fnc_parsenumber;

						if (isnil "_path") then {_path = configfile;};
						if (isnil "_parent") then {_parent = configfile;};
						if (isnil "_tiers") then {_tiers = -1;};

						_path = [_path,0,configfile,[configfile]] call bis_fnc_paramIn;
						_parent = [_parent,0,configfile,[configfile]] call bis_fnc_paramIn;
						_tags = call compile ("[" + _tags + "]");

						_ORBAT set [
							count _ORBAT,
							[_pos,_path,_parent,_tags,_tiers]
						];
					};
					case "ModuleStrategicMapImage_F": {
						_pos = position _x;
						_dir = direction _x;

						_texture = _x getvariable ["Texture","#(argb,8,8,3)color(0,0,0,0)"];
						_color = call compile (_x getvariable "Color");
						_w = (_x getvariable ["Width","100"]) call bis_fnc_parsenumber;
						_h = (_x getvariable ["Height","100"]) call bis_fnc_parsenumber;
						_text = _x getvariable ["Text",""];
						_shadow = call compile (_x getvariable "Shadow");

						if (isnil "_color") then {_color = [1,1,1,1];};
						if (isnil "_shadow") then {_shadow = false;};

						_texture = [_texture,0,"#(argb,8,8,3)color(0,0,0,0)",[""]] call bis_fnc_paramIn;
						_color = [[_color],0,[0,0,0,0],[[]]] call bis_fnc_paramIn;
						_w = [_w,0,100,[0]] call bis_fnc_paramIn;
						_h = [_h,0,100,[0]] call bis_fnc_paramIn;
						_text = [_text,0,"",[""]] call bis_fnc_paramIn;
						_shadow = [_shadow,0,false,[false]] call bis_fnc_paramIn;
						_color = _color call bis_fnc_colorConfigToRGBA;

						_images set [
							count _images,
							[_texture,_color,_pos,_w,_h,_dir,_text,_shadow]
						];
					};
				};
			} foreach (_x call bis_fnc_moduleModules);
		};
	};
} foreach (_logic call bis_fnc_moduleModules);

if (_coreCount > 0) then {
	if (_coreCount > 1) then {["Multiple ""Strategic Map"" modules connected to ""Open Strategic Map"" module (%1), there should be only one."] call bis_fnc_error;};
	[
		nil,
		_corePos,
		_missions,
		_ORBAT,
		_markers,
		_images,
		_overcast,
		_isNight
	] spawn {
		cuttext ["","black out",0.5];
		sleep 0.6;
		_this call bis_fnc_strategicMapOpen;
	};
} else {
	["No ""Strategic Map"" module connected to ""Open Strategic Map"" module (%1).",_logic] call bis_fnc_error;
};

true