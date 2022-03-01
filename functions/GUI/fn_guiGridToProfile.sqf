_forced = [_this,0,false,[false]] call (uinamespace getvariable "bis_fnc_param");

_cfgUIDefault = configfile >> "cfgUIDefault";
_vars = ["X","Y","W","H"];

for "_t" from 0 to (count _cfgUIDefault - 1) do {
	_tag = _cfgUIDefault select _t;
	if (isclass _tag) then {
		_cfgGrids = _tag >> "Grids";
		for "_g" from 0 to (count _cfgGrids - 1) do {
			_grid = _cfgGrids select _g;
			if (isclass _grid) then {
				_saveToProfile = getarray (_grid >> "saveToProfile");
				_position = getarray (_grid >> "position");
				_areaBase = _position select 0;
				_varBase = /*"grid_" + */configname _tag + "_" + configname _grid + "_";
				{
					_index = [[_x],0,-1,[0]] call (uinamespace getvariable "bis_fnc_paramIn");
					if (_index >= 0 && _index < 4) then {
						_var = _varBase + (_vars select _index);
						_area = _areaBase select _index;
						_profile = profilenamespace getvariable _var;

						if (isnil "_profile" || _forced) then {
							if (typename _area != typename "") then {_area = str _area;};
							profilenamespace setvariable [_var,_area];
						};
					};
				} foreach _saveToProfile;
			};
		};
	};
};