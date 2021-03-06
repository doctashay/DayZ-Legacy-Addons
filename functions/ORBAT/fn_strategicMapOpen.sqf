/*
	Author: Karel Moricky

	Description:
	Open strategic map.

	Parameter(s):
		0: DISPLAY - parent display. When empty, mission display is used.
		1: ARRAY - default view position in format [x,y,y] or [x,y]
		2: ARRAY - list of missions in format:
			0: ARRAY - mission position in format [x,y,y] or [x,y]
			1: CODE - expression executed when user clicks on mission icon
			2: STRING - mission name
			3: STRING - short description
			4: STRING - name of mission's player
			5: STRING - path to overview image
			6: NUMBER - size multiplier, 1 means default size
		3: ARRAY - list of ORBAT groups in format:
			0: ARRAY - group position in format [x,y,y] or [x,y]
			1: CONFIG - preview CfgORBAT group
			2: CONFIG - topmost displayed CfgORBAT group
			3: ARRAY - list of allowed tags
			4: NUMBER - maximum number of displayed tiers
		4: ARRAY - list of markers revealed in strategic map (will be hidden when map is closed)
		5: ARRAY - list of custom images in format:
			0: STRING - texture path
			1: ARRAY - color in format [R,G,B,A]
			2: ARRAY - image position
			3: NUMBER - image width (in metres)
			4: NUMBER - image height (in metres)
			5: NUMBER - image angle (in degrees)
			6: STRING - text displayed next to the image
			7: BOOL - true to display shadow
		6: NUMBER - value in range <0-1> defining weather on strategic map (i.e. density of clouds)
		7: BOOL - true for night version of strategic map (darker with blue tone)

	Returns:
	DISPLAY - RscDisplayStrategicMap
*/
private ["_parentDisplayDefault","_parentDisplay","_mapCenter","_missions","_ORBAT","_markers","_images","_overcast","_scale","_display","_playerIcon","_playerColor","_cloudTextures","_cloudsGrid","_cloudsMax","_cloudsSize","_map","_fade"];
disableserialization;

_parentDisplayDefault = switch false do {
	case isnull (finddisplay 37): {finddisplay 37}; //--- GetReady
	case isnull (finddisplay 52): {finddisplay 52}; //--- ServerGetReady
	case isnull (finddisplay 53): {finddisplay 53}; //--- ClientGetReady
	default {[] call bis_fnc_displayMission}; //--- Mission
};
_parentDisplay = [_this,0,_parentDisplayDefault,[displaynull]] call (uinamespace getvariable "bis_fnc_param");
_mapCenter = [_this,1,position player] call bis_fnc_param;
_mapCenter = _mapCenter call bis_fnc_position;
_missions = [_this,2,[],[[]]] call bis_fnc_param;
_ORBAT = [_this,3,[],[[]]] call bis_fnc_param;
_markers = [_this,4,[],[[]]] call bis_fnc_param;
_images = [_this,5,[],[[]]] call bis_fnc_param;
_overcast = ([_this,6,overcast,[0]] call bis_fnc_param) max 0 min 1;
_isNight = [_this,7,false,[false]] call bis_fnc_param;

//--- Calculate terrain size and outside color
_mapSize = [] call bis_fnc_mapSize;
BIS_fnc_strategicMapOpen_mapSize = _mapSize;
BIS_fnc_strategicMapOpen_isNight = _isNight;

_scale = 3500 / _mapSize / safezoneH;
_maxSatelliteAlpha = if (_isNight) then {0.75} else {1};

_colorOutside = configfile >> "CfgWorlds" >> worldname >> "OutsideTerrain" >> "colorOutside";
_colorOutside = if (isarray _colorOutside) then {
	_colorOutside call bis_fnc_colorCOnfigToRGBA;
} else {
	["colorOutside param is mission in ""CfgWorlds"" >> ""%1"" >> ""OutsideTerrain""",worldname] call bis_fnc_error;
	[0,0,0,1]
};

with uinamespace do {
	RscDisplayStrategicMap_scaleMin = _scale;
	RscDisplayStrategicMap_scaleMax = _scale;
	RscDisplayStrategicMap_scaleDefault = _scale;
	RscDisplayStrategicMap_maxSatelliteAlpha = _maxSatelliteAlpha;

	RscDisplayStrategicMap_colorOutside_R = _colorOutside select 0;
	RscDisplayStrategicMap_colorOutside_G = _colorOutside select 1;
	RscDisplayStrategicMap_colorOutside_B = _colorOutside select 2;
};

//--- Create the viewer
_parentDisplay createdisplay "RscDisplayStrategicMap";
_display = finddisplay 506;
if (isnull _display) exitwith {"Unable to create 'RscDisplayStrategicMap' display." call (uinamespace getvariable "bis_fnc_error"); displaynull};

//--- Life, calculations and everything
startloadingscreen ["","RscDisplayLoadingBlack"];

BIS_fnc_strategicMapOpen_player = player;
//selectnoplayer;

//--- Process ORBAT
BIS_fnc_strategicMapOpen_ORBAT = [];
_onClick = [];
{
	private ["_pos","_class","_parent","_tags","_tiers","_classParams","_text","_texture","_size","_color","_sizeLocal","_sizeParams","_sizeTexture"];
	_pos = [_x,0,player] call bis_fnc_paramIn;
	_pos = _pos call bis_fnc_position;

	_class = [_x,1,configfile >> "CfgORBAT",[configfile]] call bis_fnc_paramIn;
	_parent = [_x,2,_class,[configfile]] call bis_fnc_paramIn;
	_tags = [_x,3,[],[[]]] call bis_fnc_paramIn;
	_tiers = [_x,4,-1,[0]] call bis_fnc_paramIn;

	_classParams = _class call bis_fnc_ORBATGetGroupParams;
	_text = _classParams select ("text" call bis_fnc_ORBATGetGroupParams);
	_texture = _classParams select ("texture" call bis_fnc_ORBATGetGroupParams);
	_size = _classParams select ("size" call bis_fnc_ORBATGetGroupParams);
	_color = _classParams select ("color" call bis_fnc_ORBATGetGroupParams);

	_iconSize = sqrt (_size + 1) * 32;

	//--- Group size
	_sizeLocal = _size max 0 min (count (BIS_fnc_ORBATGetGroupParams_sizes) - 1);
	_sizeParams = BIS_fnc_ORBATGetGroupParams_sizes select _sizeLocal;
	_sizeTexture = _sizeParams select 0;

	BIS_fnc_strategicMapOpen_ORBAT set [
		count BIS_fnc_strategicMapOpen_ORBAT,
		[
			_class,
			[_parent,_tags,_tiers],
			[
				_texture,
				_color,
				_pos,
				_iconSize,
				_iconSize,
				0,
				"",
				false
			],
			_classParams
		]
	];

	//--- Create shortcut from ORBAT viewer
	_onClick set [count _onClick,_class];
	_onClick set [count _onClick,{[_this select 0,1] spawn bis_fnc_strategicMapAnimate; true}];
} foreach _ORBAT;
BIS_fnc_strategicMapOpen_ORBATonClick = _onClick;

//--- Process Missions
BIS_fnc_strategicMapOpen_missions = [];
_playerIcon = gettext (configfile >> "CfgInGameUI" >> "IslandMap" >> "iconPlayer");
_playerColor = (getarray (configfile >> "cfgingameui" >> "islandmap" >> "colorMe")) call BIS_fnc_colorRGBAtoHTML;
{
	private ["_pos","_code","_title","_description","_player","_picture","_iconSize","_infoText"];
	_pos = [_x,0,player] call bis_fnc_paramIn;
	_pos = _pos call bis_fnc_position;

	_code = [_x,1,{},[{}]] call bis_fnc_paramIn;
	_title = [_x,2,"ERROR: MISSING TITLE",[""]] call bis_fnc_paramIn;
	_description = [_x,3,"",[""]] call bis_fnc_paramIn;
	_player = [_x,4,"",[""]] call bis_fnc_paramIn;
	_picture = [_x,5,"",[""]] call bis_fnc_paramIn;
	_iconSize = [_x,6,1,[1]] call bis_fnc_paramIn;

	_infoText = _title;
	if (_player != "") then {_infoText = _infoText + format ["<br /><t size='0.2' color='#00000000'>-<br /></t><img size='1' image='%2' color='%3'/><t size='0.8'> %1</t>",_player,_playerIcon,_playerColor];};
	if (_description != "") then {_infoText = _infoText + format ["<br /><t size='0.5' color='#00000000'>-<br /></t><t size='0.8'>%1</t>",_description];};
	//if (_picture != "") then {_infoText = _infoText + format ["<br /><img size='5.55' image='%1' />",_picture];};

	BIS_fnc_strategicMapOpen_missions set [
		count BIS_fnc_strategicMapOpen_missions,
		[
			_pos,
			_code,
			_title,
			_iconSize,
			_picture,
			0,
			0,
			0,
			_infoText
		]
	];

} foreach _missions;

//--- Process Images
BIS_fnc_strategicMapOpen_images = [];
{
	private ["_texture","_color","_pos","_w","_h","_dir","_text","_shadow"];
	_texture = [_x,0,"#(argb,8,8,3)color(0,0,0,0)",[""]] call bis_fnc_paramIn;
	_color = [_x,1,[1,1,1,1],[[]]] call bis_fnc_paramIn;
	_pos = [_x,2,position player] call bis_fnc_paramIn;
	_w = [_x,3,0,[0]] call bis_fnc_paramIn;
	_h = [_x,4,0,[0]] call bis_fnc_paramIn;
	_dir = [_x,5,0,[0]] call bis_fnc_paramIn;
	_text = [_x,6,"",[""]] call bis_fnc_paramIn;
	_shadow = [_x,7,false,[false]] call bis_fnc_paramIn;

	_pos = _pos call bis_fnc_position;
	_color = _color call bis_fnc_colorConfigToRGBA;
	_coef = (0.182 * safezoneH); //--- Magic constant to make kilometer a kilometer
	_w = _w * _coef;
	_h = _h * _coef;

	BIS_fnc_strategicMapOpen_images set [
		count BIS_fnc_strategicMapOpen_images,
		[_texture,_color,_pos,_w,_h,_dir,_text,_shadow]
	];
} foreach _images;

//--- Random clouds
_cloudTextures = [
	"\DZ\data\data\mrak_01_ca.paa",
	"\DZ\data\data\mrak_02_ca.paa",
	"\DZ\data\data\mrak_03_ca.paa",
	"\DZ\data\data\mrak_04_ca.paa"
];
_cloudsGrid = 500;
_cloudsMax = (_mapSize / _cloudsGrid) * _overcast;
_cloudsSize = (_cloudsGrid / 2) + (_cloudsGrid * _overcast);
BIS_fnc_strategicMapOpen_overcast = _overcast;
BIS_fnc_strategicMapOpen_clouds = [];

for "_i" from 1 to (_cloudsMax) do {
	BIS_fnc_strategicMapOpen_clouds set [
		count BIS_fnc_strategicMapOpen_clouds,
		[
			_cloudTextures call bis_fnc_selectrandom,
			(random _mapSize),
			((_mapSize / _cloudsMax) * _i),
			random 360,
			_cloudsSize + (_cloudsSize * _overcast),
			[1,1,1,0.25]
		]
	];
};


BIS_fnc_strategicMapOpen_indexSizeTexture =	("sizeTexture" call bis_fnc_ORBATGetGroupParams);
BIS_fnc_strategicMapOpen_indexTextureSize =	("textureSize" call bis_fnc_ORBATGetGroupParams);

BIS_fnc_strategicMapOpen_draw = {
	scriptname "bis_fnc_strategicMapOpen - Draw";
	_map = _this select 0;
	_mapSize = BIS_fnc_strategicMapOpen_mapSize / 2;
	_display = ctrlparent _map;
	_time = diag_ticktime;

	_tooltip = (ctrlparent _map) displayctrl 2350;
	_tooltip ctrlsetfade 1;
	_tooltip ctrlcommit 0;

	_mousePos = _map ctrlmapscreentoworld BIS_fnc_strategicMapOpen_mousePos;
	_mouseLimit = BIS_fnc_strategicMapOpen_mapSize / 3400;
	_selected = [];

	//--- Cross grid
	_map drawRectangle [
		[_mapSize,_mapSize,0],
		_mapSize,
		_mapSize,
		0,
		[1,1,1,0.42],
		"\DZ\ui\data\GUI\Rsc\RscDisplayStrategicMap\cross_ca.paa"
	];

	//--- Images
	{
		_map drawicon _x;
	} foreach BIS_fnc_strategicMapOpen_images;

	//--- ORBAT groups
	{
		_class = _x select 0;
		_iconParams = +(_x select 2);
		_classParams = +(_x select 3);

		_pos = _iconParams select 2;
		_iconSize = _iconParams select 3;

		if (((_iconParams select 2) distance _mousePos) < (_mouseLimit * _iconSize)) then {
			_iconParams set [3,(_iconParams select 3) * 1.2];
			_iconParams set [4,(_iconParams select 4) * 1.2];
			_selected = _x;
		};

		_textureSize = _classParams select BIS_fnc_strategicMapOpen_indexTextureSize;
		_iconSizeParams = +_iconParams;
		_iconParams set [3,(_iconParams select 3) * _textureSize];
		_iconParams set [4,(_iconParams select 4) * _textureSize];

		_map drawIcon _iconParams;

		//--- Draw size texture
		_size = _classParams select 5;
		if (_size >= 0) then {
			_sizeTexture = _classParams select BIS_fnc_strategicMapOpen_indexSizeTexture;
			_iconSizeParams set [0,_sizeTexture];
			_map drawIcon _iconSizeParams;
		};

	} foreach BIS_fnc_strategicMapOpen_ORBAT;

	//--- Clouds
	_cloudSpeed = sin _time * (1138 + 2000 * BIS_fnc_strategicMapOpen_overcast);
	{
		_texture = _x select 0;
		_posX = _x select 1;
		_posY = _x select 2;
		_dir = _x select 3;
		_size = _x select 4;
		_color = _x select 5;

		_map drawIcon [
			_texture,
			_color,
			[
				_posX + _cloudSpeed,
				_posY
			],
			_size,
			_size,
			_dir + (_time * _foreachindex) / (count BIS_fnc_strategicMapOpen_clouds * 3),
			"",
			false
		];
	} foreach BIS_fnc_strategicMapOpen_clouds;

	//--- Missions
	_textureAnimPhase = abs(6 - floor (_time * 16) % 12);
	{
		_pos = _x select 0;
		_title = _x select 2;
		_size = (_x select 3) * 32;
		_alpha = 0.75;
		if ((_pos distance _mousePos) < (_mouseLimit * _size)) then {
			_size = _size * 1.2;
			_alpha = 1;
			_selected = _x;
		};

		_map drawIcon [
			format ["\DZ\ui\data\Map\GroupIcons\badge_rotate_%1_gs.paa",_textureAnimPhase],
			[1,1,1,_alpha],
			_pos,
			_size,
			_size,
			0,
			" " + _title,
			2,
			0.08,
			"PuristaBold"
		];
	} foreach BIS_fnc_strategicMapOpen_missions;

	//--- Night
	if (BIS_fnc_strategicMapOpen_isNight) then {
		_map drawRectangle [
			[_mapSize,_mapSize,0],
			99999,
			99999,
			0,
			[0,0.05,0.2,0.42],
			"#(argb,8,8,3)color(1,1,1,1)"
		];
	};

	//--- Tooltip
	if (count _selected > 0 && !BIS_fnc_strategicMapOpen_mouseClickDisable) then {
		switch (count _selected) do {

			//--- ORBAT
			case 4: {
				_class = _selected select 0;
				_classParams = _selected select 3;

				[_classParams,_display,BIS_fnc_strategicMapOpen_mousePos] call bis_fnc_ORBATTooltip;
			};

			//--- Mission
			case 9: {
				[_selected,_display,BIS_fnc_strategicMapOpen_mousePos] call bis_fnc_ORBATTooltip;
			};
		};
	};
	_info ctrlcommit 0;
	BIS_fnc_strategicMapOpen_selected = _selected;
};

//--- Mouse click on icon
BIS_fnc_strategicMapOpen_selected = [];
BIS_fnc_strategicMapOpen_mousePos = [0,0];
BIS_fnc_strategicMapOpen_mouse = {
	BIS_fnc_strategicMapOpen_mousePos = [_this select 1,_this select 2];
};
BIS_fnc_strategicMapOpen_mouseClickDisable = false;
BIS_fnc_strategicMapOpen_mouseClick = {
	if !(BIS_fnc_strategicMapOpen_mouseClickDisable) then {
		disableserialization;
		_display = ctrlparent (_this select 0);
		_selected = BIS_fnc_strategicMapOpen_selected;
		switch (count _selected) do {

			//--- ORBAT
			case 4: {
				BIS_fnc_strategicMapOpen_mouseClickDisable = true;
				_class = _selected select 0;
				_input = _selected select 1;
				_parent = _input select 0;
				_tags = _input select 1;
				_tiers = _input select 2;

				_fade = _display displayctrl 1099;
				_fade ctrlsetfade 0;
				_fade ctrlcommit 0.3;
				uisleep 0.3;
				if (isnull _display) exitwith {};

				//--- Show and animate ORBAT
				_displayORBAT = [_parent,_display,_tags,_tiers,BIS_fnc_strategicMapOpen_ORBATonClick] call bis_fnc_ORBATOpen;
				if (_class != _parent) then {
					[_class,0,1] call bis_fnc_ORBATanimate;
				};

				//--- Fade back
				waituntil {isnull _displayORBAT};
				_fade ctrlsetfade 1;
				_fade ctrlcommit 0.3;
				uisleep 0.1; //--- Delay to prevent double-clicking
				BIS_fnc_strategicMapOpen_mouseClickDisable = false;
			};

			//--- Mission
			case 9: {
				BIS_fnc_strategicMapOpen_mouseClickDisable = true;
				_code = _selected select 1;
				_title = _selected select 2;
				_start = [
					format ["Do you want to start mission ""%1""?",_title],
					"Mission",
					true,
					true,
					_display,
					true
				] call bis_fnc_guimessage;
				if (_start) then {
					BIS_fnc_strategicMapOpen_mouseClickDisable = true;
					_fade = _display displayctrl 1099;
					_fade ctrlsetfade 0;
					_fade ctrlcommit 2;
					uisleep 2;
					_display closedisplay 2;
					_selected call _code;
				} else {
					BIS_fnc_strategicMapOpen_mouseClickDisable = false;
				};
			};
		};
	};
};

BIS_fnc_strategicMapOpen_keyDown = {
	_display = _this select 0;
	_key = _this select 1;

	//--- H
	switch _key do {
		case 35: {
			_fade = ceil ctrlfade (_display displayctrl 2);
			_fade = (_fade + 1) % 2;
			{
				(_display displayctrl _x) ctrlsetfade _fade;
				(_display displayctrl _x) ctrlcommit 0.3;
			} foreach [2,1000,2350,2301];
		};
	};
	false
};


_map = _display displayctrl 51;
_map ctrlmapanimadd [0,_scale,_mapCenter];
ctrlmapanimcommit _map;

_map ctrladdeventhandler ["draw","_this call BIS_fnc_strategicMapOpen_draw;"];
_map ctrladdeventhandler ["mousemoving","_this call BIS_fnc_strategicMapOpen_mouse;"];
_map ctrladdeventhandler ["mouseholding","_this call BIS_fnc_strategicMapOpen_mouse;"];
_map ctrladdeventhandler ["mousebuttonclick","_this spawn BIS_fnc_strategicMapOpen_mouseClick;"];
_display displayaddeventhandler ["keydown","_this call BIS_fnc_strategicMapOpen_keyDown"];

if (_isNight) then {
	_map ctrlsetbackgroundcolor [0,0,0,1];
	_map ctrlcommit 0;
};

//--- Measure
[_display] spawn {
	disableserialization;
	_display = _this select 0;
	_showMiles = false;
	
	_map = _display displayctrl 51;
	waituntil {ctrlmapanimdone _map};

	_xStart = (_map ctrlmapworldtoscreen [0,0,0]) select 0;
	_xEnd = (_map ctrlmapworldtoscreen [1000,0,0]) select 0;
	_w1km = abs (_xstart - _xEnd);
	_w1m = _w1km * 1.60934;
	if !(_showMiles) then {_w1m = 0.01};
	_h = 0.01;

	_measure = _display displayctrl 2301;
	_measure ctrlsetposition [
		safezoneX + 0.02125,
		safezoneY + safezoneH - 3.5 * 0.04,
		1,
		_h * 5
	];
	//_measure ctrlsetfade 0.25;
	_measure ctrlcommit 0;
	_measure ctrlenable false;
	
	_colors = ["#(argb,8,8,3)color(0,0,0,1)","\DZ\ui\data\GUI\Rsc\RscDisplayStrategicMap\measure_ca.paa"];
	_kmSegment = _w1km / 5;
	for "_i" from 0 to 4 do {
		_km = _display displayctrl (1200 + _i);
		_km ctrlsettext (_colors select (_i % 2));
		_km ctrlsetposition [
			_w1m + _kmSegment * _i,
			_h,
			_kmSegment,
			_h
		];
		_km ctrlcommit 0;
	};

	_text_0 = _display displayctrl 1002;
	_text_0 ctrlsetposition [
		_w1m - _w1km,
		_h * 3,
		2 * _w1km,
		_h * 2
	];
	_text_0 ctrlcommit 0;
	_text_km = _display displayctrl 1004;
	_text_km ctrlsetposition [
		_w1m - _w1km + (safezoneH / 30),
		_h * 3,
		2 * _w1km,
		_h * 2
	];
	_text_km ctrlcommit 0;

	if (_showMiles) then {
		_m0 = _display displayctrl 1205;
		_m0 ctrlsettext "#(argb,8,8,3)color(1,1,1,1)";
		_m0 ctrlsetposition [
			0,
			_h,
			_w1m,
			_h
		];
		_m0 ctrlcommit 0;
		_text_m = _display displayctrl 1003;
		_text_m ctrlsetposition [
			0,
			_h * 3,
			2 * _w1m,
			_h * 2
		];
		_text_m ctrlcommit 0;
	};
};


//--- Show markers
{
	_x setmarkeralpha 1;
} foreach _markers;
BIS_fnc_strategicMapOpen_markers = _markers;

//--- Fade in
_fade = _display displayctrl 1099;
_fade ctrlsetfade 1;
_fade ctrlcommit 2;

//--- Create upward looking camera (increases FPS, as no scene is drawn)
BIS_fnc_strategicMapOpen_camera = if (count allmissionobjects "Camera" == 0) then {
	_camera = "camera" camcreate position player;
	_camera cameraeffect ["internal","back"];
	_camera campreparepos [position player select 0,position player select 1,(position player select 2) + 10];
	_camera campreparetarget [position player select 0,(position player select 1) + 1,(position player select 2) + 1000];
	_camera campreparefov 0.1;
	_camera camcommitprepared 0;
	_camera
} else {
	objnull
};

//--- Garbage collector
_display displayaddeventhandler [
	"unload",
	"
		{
			_x setmarkeralpha 0;
		} foreach BIS_fnc_strategicMapOpen_markers;

		BIS_fnc_strategicMapOpen_camera cameraeffect ['terminate','back'];
		camdestroy BIS_fnc_strategicMapOpen_camera;

		BIS_fnc_strategicMapOpen_camera = nil;
		BIS_fnc_strategicMapOpen_player = nil;
		BIS_fnc_strategicMapOpen_mapSize = nil;
		BIS_fnc_strategicMapOpen_isNight = nil;
		BIS_fnc_strategicMapOpen_ORBAT = nil;
		BIS_fnc_strategicMapOpen_ORBATOverlay = nil;
		BIS_fnc_strategicMapOpen_missions = nil;
		BIS_fnc_strategicMapOpen_markers = nil;
		BIS_fnc_strategicMapOpen_images = nil;
		BIS_fnc_strategicMapOpen_draw = nil;
		BIS_fnc_strategicMapOpen_clouds = nil;
		BIS_fnc_strategicMapOpen_mousePos = nil;
		BIS_fnc_strategicMapOpen_mouseClickDisable = nil;
		BIS_fnc_strategicMapOpen_selected = nil;
		BIS_fnc_strategicMapOpen_indexSizeTexture = nil;
		BIS_fnc_strategicMapOpen_indexTextureSize = nil;
		with uinamespace do {
			RscDisplayStrategicMap_scaleMin = nil;
			RscDisplayStrategicMap_scaleMax = nil;
			RscDisplayStrategicMap_scaleDefault = nil;

			RscDisplayStrategicMap_colorOutside_R = nil;
			RscDisplayStrategicMap_colorOutside_G = nil;
			RscDisplayStrategicMap_colorOutside_B = nil;
		};
	"
];

cuttext ["","black in"];
endloadingscreen;

_display