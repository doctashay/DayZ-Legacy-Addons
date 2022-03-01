//scriptName "Functions\misc\fn_help.sqf";
/*
	File: help.sqf
	Author: Karel Moricky

	Description:
	Displays list of all available functions
*/

if !(isnull (findDisplay 2929)) exitwith {};
_this spawn {
	disableserialization;
	if (count _this > 0 ||true) then {
		_displayMission = [] call (uinamespace getvariable "bis_fnc_displayMission");
		_parent = if (isnull _displayMission) then {
			_displays = uinamespace getvariable ["GUI_displays",[]];
			_classes = uinamespace getvariable ["GUI_classes",[]];

			{
				if (isnull _x) then {
					_classes set [_foreachindex,-1];
				};
			} foreach _displays;
			_displays = _displays - [displaynull];
			_classes = _classes - [-1];

			if (count _displays > 0 && count _displays == count _classes) then {
				if ((_classes select (count _classes - 1)) == "RscDisplayDebug") then {
					//--- Debug console is open - use the display below it (otherwise you couldn't access the console while in the viewer)
					_displays select (count _displays - 2)
				} else {
					//--- Open the viewer from the last open display
					_displays select (count _displays - 1)
				};
			} else {

				//--- No displays are tracked - cannot open
				displaynull
			};
		} else {

			//--- Mission display is present - use it as parent
			_displayMission
		};
		_parent createdisplay "RscFunctionsViewer";
	} else {
		createDialog  "RscFunctionsViewer";
	};

	_display = findDisplay 2929;
	_listFunctions = _display displayCtrl 292901;
	_listSources = _display displayCtrl 292902;
	_listTags = _display displayCtrl 292903;
	_listCats = _display displayCtrl 292904;

	_listSources lbAdd "configFile";
	_listSources lbAdd "missionConfigFile";
	_listSources lbAdd "campaignConfigFile";
	uinamespace setvariable ["help_listSources",[configfile,missionconfigfile,campaignconfigfile]];
	uinamespace setvariable ["help_id",0];
	uinamespace setvariable ["help_fnc",-1];
	uinamespace setvariable ["help_refresh",false];
	uinamespace setvariable ["help_display",_display];

	_curSel = uinamespace getvariable "help_codeSources_curSel";
	if (isnil {_curSel}) then {uinamespace setvariable ["help_codeSources_curSel",0]};
	_curSel = uinamespace getvariable "help_codeTags_curSel";
	if (isnil {_curSel}) then {uinamespace setvariable ["help_codeTags_curSel",0]};
	_curSel = uinamespace getvariable "help_codeCats_curSel";
	if (isnil {_curSel}) then {uinamespace setvariable ["help_codeCats_curSel",0]};
	_curSel = uinamespace getvariable "help_codeFunction_curSel";
	if (isnil {_curSel}) then {uinamespace setvariable ["help_codeFunction_curSel",0]};

	uinamespace setvariable ["help_codeSources",{
			disableserialization;
			_id = _this select 1;
			if (_id < 0) exitwith {};
			_source = ((uinamespace getvariable "help_listSources") select _id) >> "cfgFunctions";
			_listTags = (findDisplay 2929) displayctrl 292903;
			lbclear _listTags;

			//--- All
			_lbTag = _listTags lbadd "<All>";
			_listTags lbsetdata [_lbTag,""];

			for "_s" from 0 to (count _source - 1) do {
				_currentTag = _source select _s;
				if (isclass _currentTag) then {
					_currentTagName = configname _currentTag;
					_lbTag = _listTags lbadd _currentTagName;
					_listTags lbsetdata [_lbTag,gettext (_currentTag >> "tag")];
					_listTags lbsetvalue [_lbTag,_s];
				};
			};
			lbsort _listTags;

			//--- Get value order after alphabetical sorting
			_values = [-1];
			for "_s" from 1 to (lbsize _listTags - 1) do {
				_values set [count _values,_listTags lbvalue _s];
			};
			uinamespace setvariable ["help_codeSources_values",_values];

			if (count _source == 0) then {[-1,-1] spawn (uinamespace getvariable 'help_codeTags')};

			if (_id != (uinamespace getvariable "help_codeSources_curSel")) then {
				uinamespace setvariable ["help_codeSources_curSel",_id];
				uinamespace setvariable ["help_codeTags_curSel",0];
				uinamespace setvariable ["help_codeCats_curSel",0];
				uinamespace setvariable ["help_codeFunction_curSel",0];
			};

			_listTags lbsetcursel (uinamespace getvariable "help_codeTags_curSel");
		}
	];
	uinamespace setvariable ["help_codeTags",{
			disableserialization;
			_id = _this select 1;
			_listSources = (findDisplay 2929) displayCtrl 292902;
			_listTags = (findDisplay 2929) displayctrl 292903;
			_listCats = (findDisplay 2929) displayctrl 292904;

			if (_id < 0) exitwith {
				lbclear _listCats;
				[-1,-1] spawn (uinamespace getvariable 'help_codeCats');
			};
			_tag = (uinamespace getvariable "help_listSources") select (lbcursel _listSources) >> "cfgFunctions" >> (_listTags lbtext (lbcursel _listTags));
			lbclear _listCats;

			if (isclass _tag) then {
				for "_t" from 0 to (count _tag - 1) do {
					_currentCat = _tag select _t;
					if (isclass _currentCat) then {
						_currentCatName = configname _currentCat;
						_lbCat = _listCats lbadd _currentCatName;
						_listCats lbsetdata [_lbCat,configname _tag];
					};
				};
			} else {
				_cats = [];
				_source = ((uinamespace getvariable "help_listSources") select (lbcursel _listSources)) >> "cfgFunctions";
				for "_s" from 0 to (count _source - 1) do {
					_tag = _source select _s;
					if (isclass _tag) then {
						for "_t" from 0 to (count _tag - 1) do {
							_currentCat = _tag select _t;
							_currentCatName = configname _currentCat;
							if (isclass _currentCat && !(_currentCatName in _cats)) then {
								_lbCat = _listCats lbadd _currentCatName;
								_listCats lbsetdata [_lbCat,configname _tag];
								_cats set [count _cats,_currentCatName];
							};
						};
					};
				};
			};
			lbsort _listCats;

			if (_id != (uinamespace getvariable "help_codeTags_curSel")) then {
				uinamespace setvariable ["help_codeTags_curSel",_id];
				uinamespace setvariable ["help_codeCats_curSel",0];
				uinamespace setvariable ["help_codeFunction_curSel",0];
			};

			_listCats lbsetcursel (uinamespace getvariable "help_codeCats_curSel")
		}
	];
	uinamespace setvariable ["help_codeCats",{
			disableserialization;
			_id = _this select 1;
			_listSources = (findDisplay 2929) displayCtrl 292902;
			_listTags = (findDisplay 2929) displayctrl 292903;
			_listCats = (findDisplay 2929) displayctrl 292904;
			_listFncs = (findDisplay 2929) displayctrl 292901;

			if (_id < 0) exitwith {lbclear _listFncs;};
			_cat = (uinamespace getvariable "help_listSources") select (lbcursel _listSources) >> "cfgFunctions" >> (_listCats lbdata (lbcursel _listCats)) >> (_listCats lbtext (lbcursel _listCats));
			lbclear _listFncs;
			_cursel = lbcursel _listTags;
			_tag = (uinamespace getvariable "help_listSources") select (lbcursel _listSources) >> "cfgFunctions" >> (_listTags lbtext (lbcursel _listTags));
			_tagName = gettext _tag;
			if (_tagName == "") then {_tagName = _listTags lbdata _cursel};
			if (_tagName == "") then {_tagName = _listTags lbtext _cursel};
			if (_tagName == "<All>") then {_tagName = "BIS"};
			if (isclass _tag) then {
				for "_t" from 0 to (count _Cat - 1) do {
					_currentFnc = _Cat select _t;
					if (isclass _currentFnc) then {
						_currentFncName = configname _currentFnc;
						_lbFnc = _listFncs lbadd (_tagName + "_fnc_" + _currentFncName);
						_listFncs lbsetdata [_lbFnc,_currentFncName];
						_listFncs lbsetvalue [_lbFnc,_cursel];
					};
				};
			} else {
				_source = ((uinamespace getvariable "help_listSources") select (lbcursel _listSources)) >> "cfgFunctions";
				_n = 1;
				for "_s" from 0 to (count _source - 1) do {
					_tag = _source select _s;
					if (isclass _tag) then {
						for "_c" from 0 to (count _tag - 1) do {
							_currentCat = _tag select _c;
							if (isclass _cat && configname _currentCat == configname _cat) then {
								for "_f" from 0 to (count _currentCat - 1) do {
									_currentFnc = _currentCat select _f;
									if (isclass _currentFnc) then {
										_currentFncName = configname _currentFnc;
										_lbFnc = _listFncs lbadd (_tagName + "_fnc_" + _currentFncName);
										_category = (uinamespace getvariable "help_codeSources_values") find (_n-1);
										_listFncs lbsetdata [_lbFnc,_currentFncName];
										_listFncs lbsetvalue [_lbFnc,_category];
									};
								};
							};
						};
						_n = _n + 1;
					};
				};



			};
			lbsort _listFncs;

			if (_id != (uinamespace getvariable "help_codeCats_curSel")) then {
				uinamespace setvariable ["help_codeCats_curSel",_id];
				uinamespace setvariable ["help_codeFunction_curSel",0];
			};

			_listFncs lbsetcursel (uinamespace getvariable "help_codeFunction_curSel");
		}
	];
	uinamespace setvariable ["help_codeFunction",{
			disableserialization;
			_display = findDisplay 2929;
			_listFunctions = _display displayCtrl 292901;
			_listSources = _display displayCtrl 292902;
			_listTags = _display displayCtrl 292903;
			_listCats = _display displayCtrl 292904;
			_textTitle = _display displayctrl 292905;
			_textPath = _display displayctrl 292906;
			_textDesc = _display displayctrl 292907;
			_textCode = _display displayctrl 292908;
			_btnCopy = _display displayctrl 292909;
			_btnCompile = _display displayctrl 292911;

			_id = _this select 1;
			_title = _listFunctions lbtext _id;
			_color = _listFunctions lbcolor _id;
			_source = (uinamespace getvariable "help_listSources") select (lbcursel _listSources);
			_itemMeta = _title call (uinamespace getvariable "bis_fnc_functionMeta");
			_itemConfig = _source >> "cfgFunctions" >> (_listTags lbtext (_listFunctions lbvalue _id)) >> (_listCats lbtext (lbcursel _listCats)) >> (_listFunctions lbdata _id);
			//[_itemConfig,_source ,  "cfgFunctions" ,  (_listTags lbtext (_listFunctions lbvalue _id)),(_listFunctions lbvalue _id),   (_listCats lbtext (lbcursel _listCats)) ,  (_listFunctions lbdata _id)] call bis_fnc_log;
			_desc = gettext (_itemConfig >> "description");
			_descColor = [1,1,1,1];
			if (_desc == "") then {_desc = "MISSING DESCRIPTION!"; _descColor = [1,0.3,0,1]};

			//_codePath = uinamespace getvariable format ["%1_path",_title];
			_codePath = _itemMeta select 0;
			if (isnil "_codePath") then {_codePath = missionnamespace getvariable format ["%1_path",_title];};
			_code = loadfile _codepath;
			uinamespace setvariable ["help_code",_code];

			if (format ["%1",_code] == "") then {
				_textCode ctrlshow false;
				_btnCopy ctrlshow false;
			} else {
				_textCode ctrlshow true;
				_btnCopy ctrlshow true;
			};

			_textDesc ctrlsettextcolor _descColor;

			_textTitle ctrlsettext _title;
			_textPath ctrlsettext ("  " + _codePath);
			_textDesc ctrlsettext _desc;
			_textCode ctrlsettext _code;

			_headerType = getnumber (_itemConfig >> "headerType");
			_btnCompileAction = format [
				"_list = (findDisplay 2929) displayctrl 292901; _fncName = _list lbtext (lbcursel _list); _fncName call bis_fnc_recompile;",
				_headerType
			];
			_btnCompile buttonsetaction _btnCompileAction;
			//_btnCompile ctrlsettext format ["Recompile %1",_title];

			uinamespace setvariable ["help_codeFunction_curSel",_id];
		}
	];

	_textCode = _display displayctrl 292908;
	_textCode ctrlshow false;
	_btnCopy = _display displayctrl 292909;
	_btnCopy ctrlshow false;
	_btnErrors = _display displayctrl 1704;
	_btnErrors ctrlseteventhandler [
		"buttonclick",
		"
			_currentMode = profilenamespace getvariable ['BIS_fnc_init_displayErrors',false];
			profilenamespace setvariable [
				'BIS_fnc_init_displayErrors',
				!_currentMode
			];
			saveprofilenamespace;

			(_this select 0) ctrlsettext format ['Show Errors: %1',!_currentMode];
		"
	];
	_btnErrors ctrlsettext format ['Show Errors: %1',profilenamespace getvariable ['BIS_fnc_init_displayErrors',false]];

	_listSources ctrlseteventhandler ["LBSelChanged","_this call (uinamespace getvariable 'help_codeSources')"];
	_listTags ctrlseteventhandler ["LBSelChanged","_this call (uinamespace getvariable 'help_codeTags')"];
	_listCats ctrlseteventhandler ["LBSelChanged","_this call (uinamespace getvariable 'help_codeCats')"];
	_listFunctions ctrlseteventhandler ["LBSelChanged","_this call (uinamespace getvariable 'help_codeFunction')"];

	_curSel = uinamespace getvariable "help_codeSources_curSel";
	if (!isnil {_curSel}) then {_listSources lbsetcursel _curSel} else {_listSources lbsetcursel 0;};

	_display displayaddeventhandler ["unload","
		uinamespace setvariable ['help',nil];
		uinamespace setvariable ['help_fnc',nil];
		uinamespace setvariable ['help_code',nil];
		uinamespace setvariable ['help_listSources',nil];
		uinamespace setvariable ['help_codeSources',nil];
		uinamespace setvariable ['help_codeSources_values',nil];
		uinamespace setvariable ['help_codeTags',nil];
		uinamespace setvariable ['help_codeCats',nil];
		uinamespace setvariable ['help_codeFncs',nil];
		uinamespace setvariable ['help_display',nil];
	"];
};