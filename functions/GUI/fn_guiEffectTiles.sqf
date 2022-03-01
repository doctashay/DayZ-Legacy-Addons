/*
	Author: Karel Moricky

	Description:
	Animates UAV tiles behind menu displays

	Parameter(s):
	_this select 0: DISPLAY

	Returns:
	BOOL
*/
with uinamespace do {
	_display = [_this,0,displaynull,[displaynull]] call bis_fnc_param;
	_classname = [_this,1,"",[""]] call bis_fnc_param;

	if !(isnull (_display displayctrl 115000)) then {

		//--- Set animation coeficient (creates sliding animation when opening/closing a display)
		BIS_fnc_guiEffectTiles_coef = if (isnull player) then {1} else {0};

		//--- Create PP effect
		BIS_fnc_guiEffectTiles_ppChromAberration = ppeffectcreate ["chromAberration",212];

		//--- Define function executon upon mouseHolding and mouseMoving (e.g. always)
		if (isnil "BIS_fnc_guiEffectTiles_animate" || cheatsEnabled) then {

			//--- Load alpha value from display config
			BIS_fnc_guiEffectTiles_alpha = getnumber (configfile >> _classname >> "effectTilesAlpha");
			if (BIS_fnc_guiEffectTiles_alpha <= 0) then {BIS_fnc_guiEffectTiles_alpha = 0.05};

			BIS_fnc_guiEffectTiles_animate = {
				disableserialization;
				_display = _this select 0;

				//--- More visible tiles in death screen
				_alpha = if (_display == finddisplay 58) then {0.15} else {0.05};

				//--- Stronger chromatic aberation in pause menu
				_ppStrengthBase = 0;
				if ("RscDisplayInterrupt" in (uinamespace getvariable ['GUI_classes',[]])) then {
					_ppStrengthBase = 0.024 + 0.01 * (sin (diag_ticktime * 100));

					//--- Random defects in pause menu main screen (would be distracting in submenus)
					if (_display == finddisplay 49) then {
						if (random 1 > (1 - 0.24 / diag_fps)) then {_ppStrengthBase = _ppStrengthBase * (5 + random 5)};
					};
				};

				//--- Animate tiles
				for "_ix" from 0 to 5 do {
					_animation = 1 + 0.8 * round (1 - abs sin ((BIS_fnc_guiEffectTiles_coef -8/12 + _ix/12) * 180));
					for "_iy" from 0 to 5 do {
						_coef = abs sin ((diag_ticktime + (_ix + _iy)^2 + (_ix - _iy)^2) * 24);
						_control = _display displayctrl (115000 + (10 * _ix) + _iy);
						_control ctrlsetbackgroundcolor [
							_coef,
							_coef,
							_coef,
							BIS_fnc_guiEffectTiles_alpha * _animation
						];
						_control ctrlcommit 0;
					};
				};

				//--- Transition animation
				BIS_fnc_guiEffectTiles_coef = if (BIS_fnc_guiEffectTiles_coef > 0) then {
					(BIS_fnc_guiEffectTiles_coef - ((1 / diag_fps) * 3)) max 0;
				} else {
					(BIS_fnc_guiEffectTiles_coef + ((1 / diag_fps) * 3)) min 0;
				};
				_ppStrength = _ppStrengthBase + 0.02 * sin (BIS_fnc_guiEffectTiles_coef * 180);
				BIS_fnc_guiEffectTiles_ppChromAberration ppEffectEnable true;
				BIS_fnc_guiEffectTiles_ppChromAberration ppEffectAdjust [_ppStrength,0,true];
				BIS_fnc_guiEffectTiles_ppChromAberration ppEffectCommit 0;
			};
		};

		[_display] call BIS_fnc_guiEffectTiles_animate;
		_display displayaddeventhandler ["unload","with uinamespace do {BIS_fnc_guiEffectTiles_coef = -1; BIS_fnc_guiEffectTiles_ppChromAberration ppEffectEnable false;};"];
		_display displayaddeventhandler ["mousemoving","with uinamespace do {_this call BIS_fnc_guiEffectTiles_animate;};"];
		_display displayaddeventhandler ["mouseholding","with uinamespace do {_this call BIS_fnc_guiEffectTiles_animate;};"];

		//--- PP effects
		BIS_fnc_guiEffectTiles_ppChromAberration ppEffectEnable true;
		BIS_fnc_guiEffectTiles_ppChromAberration ppEffectCommit 0;
	};
};
true