_mode = _this select 0;
_param = _this select 1;

_zeroPos = [0,0,0];
_characterPos = getPosATL demoUnit;
_characterDir = getDir demoUnit;

//load data
_gender = getArray(configFile >> "cfgCharacterCreation" >> "gender");
_race = getArray(configFile >> "cfgCharacterCreation" >> "race");
_skin = getArray(configFile >> "cfgCharacterCreation" >> "skin");
_top = getArray(configFile >> "cfgCharacterCreation" >> "top");
_bottom = getArray(configFile >> "cfgCharacterCreation" >> "bottom");
_shoe = getArray(configFile >> "cfgCharacterCreation" >> "shoe");
_format = getText(configFile >> "cfgCharacterCreation" >> "format");

//build visual arrays
_topT = [];
{
	_topT set [count _topT,getText(configFile >> "cfgVehicles" >> _x >> "displayName")];
} forEach getArray(configFile >> "cfgCharacterCreation" >> "top");
_bottomT = [];
{
	_bottomT set [count _bottomT,getText(configFile >> "cfgVehicles" >> _x >> "displayName")];
} forEach getArray(configFile >> "cfgCharacterCreation" >> "bottom");
_format = getText(configFile >> "cfgCharacterCreation" >> "format");
_shoeT = [];
{
	_shoeT set [count _shoeT,getText(configFile >> "cfgVehicles" >> _x >> "displayName")];
} forEach getArray(configFile >> "cfgCharacterCreation" >> "shoe");
_format = getText(configFile >> "cfgCharacterCreation" >> "format");

//functions
_prepareCtrl = {
	private["_idc","_array","_ctrl","_serial"];
	_idc = _this select 0;
	_array = _this select 1;
	_serial = _this select 2;
	_ctrl = _display displayCtrl _idc;
	{_ctrl lbAdd _x} forEach _array;
	_ctrl lbSetCurSel _serial;
	_ctrl ctrlCommit 0;
};
_regenerateChar = {
	deleteVehicle demoUnit;
	_class = format[_format,(_gender select DZ_selectedSex),(_race select DZ_selectedSkin)];
	demoUnit = 	_class createVehicleLocal demoPos;
	demoTop = 	demoUnit createInInventory (_top select DZ_selectedTop);
	demoBottom = demoUnit createInInventory (_bottom select DZ_selectedBottom);
	demoShoe = 	demoUnit createInInventory (_shoe select DZ_selectedShoe);
	demoUnit setPos demoPos;
	demoUnit setDir createDir;
	demoUnit call ui_fnc_animateCharacter;
};

_createDefaultChar = {
	demoUnit = _this createVehicleLocal demoPos;
	demoUnit setPos demoPos;
	demoUnit setDir createDir;
	demoUnit call ui_fnc_animateCharacter;
};

_preloadItem = {
	startLoadingScreen ["Preloading..."];
	waitUntil{1 preloadObject _this};
	endLoadingScreen;
};

switch _mode do {
	case "onUnload":
	{
		demoUnit setDir demoDir;
		{
			deleteVehicle _x;
		} forEach preloaded;
		call ui_fnc_createDefaultChar;
		if (typeName rotateObject == "SCRIPT") then {call ui_fnc_mouseDragCancel};
		_lastCharacter = profileNamespace getVariable ["lastCharacter",""];
		if (_lastCharacter == "") then 
		{
			(findDisplay 167) closeDisplay 1;
		};
	};
	case "onLoad":
	{
		startLoadingScreen ["Loading Character Creation...."];
		_display = _param select 0;
		_s = 0;
		_c = 0;
		mousePressed = false;
		createDir = demoDir;
		
		_defInv = profileNamespace getVariable ["defaultInventory",[(_top select 0),(_bottom select 0),(_shoe select 0)]];
		_defChar = profileNamespace getVariable ["defaultCharacter",format[_format,(_gender select 0),(_race select 0)]];
		
		{deleteVehicle _x} forEach itemsInInventory demoUnit;
		deleteVehicle demoUnit;
		waitUntil {1 preloadObject _defChar};
		_defChar call _createDefaultChar;
		waitUntil {1 preloadObject _defChar};
		
		preloaded = [];
		_prepos = myCamera modelToWorld [0,-2,0];
		//preload characters
		{
			private["_race_x"];
			_race_x = _x;		
			{
				private["_gender_x","_type"];
				_gender_x = _x;
				_type = format[_format,_gender_x,_race_x];
				_obj = format[_format,_gender_x,_race_x] createVehicleLocal _prepos;
				_obj setPos _prepos;
				_obj disableAI "move";
				_obj disableAI "anim";
				_obj enableSimulation false;
				preloaded set [count preloaded,_obj];
				waitUntil {1 preloadObject _type};
			} forEach _gender;
		} forEach _race;		
		
		DZ_selectedSex = 0;
		if (demoUnit isKindOf "SurvivorMale") then {DZ_selectedSex = 1};
		_array = [];
		{
			_array set [count _array,format[_format,(_gender select DZ_selectedSex),_x]];		
		} forEach _race;
		
		DZ_selectedTop = 0;
		DZ_selectedBottom = 0;
		DZ_selectedShoe = 0;
		DZ_selectedSkin = 0;
		if (!isNull demoUnit) then
		{
			DZ_selectedSkin = _array find (typeOf demoUnit);	
			{
				switch true do
				{
					case (_x isKindOf "TopwearBase"): {
						DZ_selectedTop = (_top find _x);
					};
					case (_x isKindOf "BottomwearBase"): {
						DZ_selectedBottom = (_bottom find _x);
					};
					case (_x isKindOf "FootwearBase"): {
						DZ_selectedShoe = (_shoe find _x);
					};
				};
			} forEach _defInv;
		};
		
		[1410,_gender,DZ_selectedSex] call _prepareCtrl;
		[1420,_skin,DZ_selectedSkin] call _prepareCtrl;
		[1430,_topT,DZ_selectedTop] call _prepareCtrl;
		[1440,_bottomT,DZ_selectedBottom] call _prepareCtrl;
		[1450,_shoeT,DZ_selectedShoe] call _prepareCtrl;		
		
		//add base items
		//demoTop = demoUnit createInInventory (_top select DZ_selectedTop);
		//demoBottom = demoUnit createInInventory (_bottom select DZ_selectedBottom);
		//demoShoe = demoUnit createInInventory (_shoe select DZ_selectedShoe);
		
		waitUntil {isSceneReady};
		endLoadingScreen;
	};
	case "sexLBchanged": {
		DZ_selectedSex = (_this select 1) select 1;
		call _regenerateChar;
	};
	case "skinLBchanged": {
		DZ_selectedSkin = (_this select 1) select 1;
		call _regenerateChar;
	};
	case "topLBchanged": {
		DZ_selectedTop = (_this select 1) select 1;
		_item = (_top select DZ_selectedTop);
		deleteVehicle (demoUnit itemInSlot "body");
		demoTop = demoUnit createInInventory _item;
		null = _item spawn _preloadItem;
	};
	case "pantsLBchanged": {
		DZ_selectedBottom = (_this select 1) select 1;
		_item = (_bottom select DZ_selectedBottom);
		deleteVehicle (demoUnit itemInSlot "legs");
		demoBottom = demoUnit createInInventory _item;
		null = _item spawn _preloadItem;
	};
	case "shoeLBchanged": {
		DZ_selectedShoe = (_this select 1) select 1;
		_item = (_shoe select DZ_selectedShoe);
		deleteVehicle (demoUnit itemInSlot "feet");
		demoShoe = demoUnit createInInventory _item;
		null = _item spawn _preloadItem;
	};
};