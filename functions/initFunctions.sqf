scriptName "Functions\initFunctions.sqf";
/*
	File: init.sqf
	Author: Karel Moricky

	Description:
	Function library initialization.

	Parameter(s):
	_this select 0: 'Function manager' logic

	Returns:
	Nothing
*/

#define VERSION	3.0

call compile preprocessFileLineNumbers "\dz\modulesDayZ\init.sqf";

// //--- Check version, has to match config version
// if (getnumber (configfile >> "CfgFunctions" >> "version") != VERSION) exitwith {
// 	textlogformat [
// 		"Log: ERROR: Functions versions mismatch - config is %1, but script is %2",
// 		getnumber (configfile >> "CfgFunctions" >> "version"),
// 		VERSION
// 	];
// };

//--- Fake header
_fnc_scriptName = if (isnil "_fnc_scriptName") then {"Functions Init"} else {_fnc_scriptName};


/******************************************************************************************************
	DEFINE HEADERS

	Headers are pieces of code inserted on the beginning of every function code before compiling.
	Using 'BIS_fnc_functionsDebug', you can alter the headers to provide special debug output.

	Modes can be following:
	0: No Debug - header saves parent script name and current script name into variables
	1: Save script Map - header additionaly save an array of all parent scripts into variable
	2: Save and log script map - apart from saving into variable, script map is also logged through debugLog

	Some system function are using simplified header unaffected to current debug mode.
	These functions has headerType = 1; set in config.

******************************************************************************************************/

private ["_this","_headerNoDebug","_headerSaveScriptMap","_headerLogScriptMap","_headerSystem","_debug","_headerDefault","_fncCompile","_recompile"];

_headerNoDebug = "
	_fnc_scriptNameParentTemp = if !(isnil '_fnc_scriptName') then {_fnc_scriptName} else {'%1'};
	private ['_fnc_scriptNameParent'];
	_fnc_scriptNameParent = _fnc_scriptNameParentTemp;
	_fnc_scriptNameParentTemp = nil;

	private ['_fnc_scriptName'];
	_fnc_scriptName = '%1';
	scriptname _fnc_scriptName;
";
_headerSaveScriptMap = "
	_fnc_scriptMapTemp = if !(isnil '_fnc_scriptMap') then {_fnc_scriptMap} else {[]};
	private ['_fnc_scriptMap'];
	_fnc_scriptMap = _fnc_scriptMapTemp + [_fnc_scriptName];
	_fnc_scriptMapTemp = nil;
";
_headerLogScriptMap = "
	_this call {
		private '_fnc_scriptMapText';
		_fnc_scriptMapText = '';
		{
			_fnc_scriptMapText = _fnc_scriptMapText + ' >> ' + _x;
		} foreach _fnc_scriptMap;
		textlogformat ['%2',_fnc_scriptMapText,_this];
	};
";
_headerSystem = "
	private ['_fnc_scriptNameParent'];
	_fnc_scriptNameParent = if !(isnil '_fnc_scriptName') then {_fnc_scriptName} else {'%1'};
	scriptname '%1';
";
_headerNone = "";

//--- Compose headers based on current debug mode
_debug = uinamespace getvariable ["bis_fnc_initFunctions_debugMode",0];
_headerDefault = switch _debug do {

	//--- 0 - Debug mode off
	default {
		_headerNoDebug
	};

	//--- 1 - Save script map (order of executed functions) to '_fnc_scriptMap' variable
	case 1: {
		_headerNoDebug + _headerSaveScriptMap
	};

	//--- 2 - Save script map and log it
	case 2: {
		_headerNoDebug + _headerSaveScriptMap + _headerLogScriptMap
	};
};


///////////////////////////////////////////////////////////////////////////////////////////////////////
//--- Compile function
_fncCompile = {
	private ["_fncVar","_fncMeta","_fncPath","_fncHeader","_fncExt","_header","_debugMessage"];
	_fncVar = _this select 0;
	_fncMeta = _this select 1;
	_fncPath = _fncMeta select 0;
	_fncExt = _fncMeta select 1;
	_fncHeader = _fncMeta select 2;

	switch _fncExt do {

		//--- SQF
		case ".sqf": {
			_header = switch (_fncHeader) do {

				//--- No header (used in low-level functions, like 'fired' event handlers for every weapon)
				case -1: {
					_headerNone
				};

				//--- System functions' header (rewrite default header based on debug mode)
				case 1: {
					_headerSystem
				};


				//--- Full header
				default {
					_headerDefault
				}
			};
			_debugMessage = "Log: [Functions]%1 | %2";
			compile (
				format [_header,_fncVar,_debugMessage] + preprocessfilelinenumbers _fncPath
			);
		};

		//--- FSM
		case ".fsm": {
			compile format ["_this execfsm '%1';",_fncPath];
		};

		default {0}
	};
};


/******************************************************************************************************
	COMPILE ONE FUNCTION

	When input is string containing function name instead of number, only the function is recompiled.

	The script stops here, reads function's meta data and recompile the function
	based on its extension and header.

	Instead of creating missionNamespace shortcut, it saves the function directly. Use it only for debugging!

******************************************************************************************************/

//--- Compile only selected
if (isnil "_this") then {_this = [];};
if (typename _this != typename []) then {_this = [_this];};
_recompile = if (count _this > 0) then {_this select 0} else {0};

if (typename _recompile == typename "") exitwith {
	private ["_fnc","_fncMeta","_headerType","_var"];

	//--- Recompile specific function
	_fnc = uinamespace getvariable _recompile;
	if !(isnil "_fnc") then {
		_fncMeta = _recompile call (uinamespace getvariable "bis_fnc_functionMeta");
		_headerType = if (count _this > 1) then {_this select 1} else {0};
		_var = [_recompile,[_recompile,_fncMeta,_headerType] call _fncCompile];
		uinamespace setvariable _var;
		missionnamespace setvariable _var;
		if (isnil "_functions_listRecompile") then {
			textlogformat ["Log: [Functions]: %1 recompiled with meta %2",_recompile,_fncMeta];
		};
	} else {
		_fncError = uinamespace getvariable "bis_fnc_error";
		if !(isnil "_fncError") then {
			["%1 is not a function.",_recompile] call _fncError;
		} else {
			textlogformat ["Log: [Functions]: ERROR: %1 is not a function.",_recompile];
		};
	};
};


/******************************************************************************************************
	COMPILE EVERYTHING IN GIVEN NAMESPACE(S)

	Function codes are present only in uiNamespace. Mission variables contains only shortcuts to uiNamespace.
	To executed only required compilation section, input param can be one of following numbers:

	0 - Autodetect what compile type should be used
	1 - Forced recompile of all the things
	2 - Create only uiNamespace variables (used in UI)
	3 - Create only missionNamespace variables

******************************************************************************************************/

//--- Get existing lists (create new ones when they doesn't exist)
private ["_functions_list","_functions_listForced","_functions_listForcedStart","_functions_listRecompile","_file","_cfgSettings","_listConfigs","_recompileNames"];
_functions_list = uinamespace getvariable ["bis_functions_list",[]];
_functions_listForced = uinamespace getvariable ["bis_functions_listForced",[]];
_functions_listForcedStart = [];
_functions_listRecompile = uinamespace getvariable ["bis_functions_listRecompile",[]];

//--- When not forced, recompile only mission if uiNamespace functions exists
if (typename _recompile != typename 1) then {
	_recompile = if (count _functions_list > 0) then {3} else {0};
};

//--- When autodetect, recognize what recompile type is required
if (_recompile == 0 && !isnil {missionnamespace getvariable "bis_fnc_init"}) exitwith {};
if (_recompile == 0 && !isnil {uinamespace getvariable "bis_fnc_init"}) then {_recompile = 3;};


_file = gettext (configfile >> "cfgFunctions" >> "file");
_cfgSettings = [
	[	configfile,		_file,		1	],	//--- 0
	[	campaignconfigfile,	"functions",	0	],	//--- 1
	[	missionconfigfile,	"functions",	0	]	//--- 2
];
	
_listConfigs = switch _recompile do {
	case 0: {
		[0,1,2];
	};
	case 1: {
		_functions_list = [];
		uinamespace setvariable ["bis_functions_list",_functions_list];
		_functions_listForced = [];
		uinamespace setvariable ["bis_functions_listForced",_functions_listForced];
		_functions_listRecompile = [];
		uinamespace setvariable ["bis_functions_listRecompile",_functions_listRecompile];
		[0,1,2];
	};
	case 2: {
		[0];
	};
	case 3: {
		[1,2];
	};
};

/*
//--- Create functions logic (cannot be created when game is launching; server only)
if (isserver && isnil "bis_functions_mainscope" && !isnil {uinamespace getvariable "bis_fnc_init"} && worldname != "") then {
	private ["_grpLogic"];
	createcenter sidelogic;
	_grpLogic = creategroup sidelogic;
	bis_functions_mainscope = _grpLogic createunit ["Logic",[9,9,9],[],0,"none"];
	publicvariable "bis_functions_mainscope";
};
*/


/******************************************************************************************************
	SCAN CFGFUNCTIONS

	Go through CfgFunctions, scan categories and declare all functions.

	Following variables are stored:
	<tag>_fnc_<functionName> - actual code of the function
	<tag>_fnc_<functionName>_meta - additional meta data of this format
		[<path>,<extension>,<header>,<forced>,<recompile>,<category>]
		* path - path to actual file
		* extension - file extension, either ".sqf" or ".fsm"
		* header - header type. Usually 0, system functions are using 1 (see DEFINE HEADERS section)
		* forced - function is executed automatically upon mission start
		* recompile - function is recompiled upon mission start
		* category - function's category based on config structure

******************************************************************************************************/

for "_t" from 0 to (count _listConfigs - 1) do {
	private ["_cfg","_pathConfig","_pathFile","_pathAccess","_cfgFunctions"];
	_cfg = _cfgSettings select (_listConfigs select _t);
	_pathConfig = _cfg select 0;
	_pathFile = _cfg select 1;
	_pathAccess = _cfg select 2;

	_cfgFunctions = (_pathConfig >> "cfgfunctions");
	for "_c" from 0 to (count _cfgFunctions - 1) do {
		private ["_currentTag"];
		_currentTag = _cfgFunctions select _c;

		//--- Is Tag
		if (isclass _currentTag) then {

			//--- Check of all required patches are in CfgPatches
			private ["_requiredAddons","_requiredAddonsMet"];
			_requiredAddons = getarray (_currentTag >> "requiredAddons");
			_requiredAddonsMet = true;
			{
				_requiredAddonsMet = _requiredAddonsMet && isclass (configfile >> "CfgPatches" >> _x);
			} foreach _requiredAddons;

			if (_requiredAddonsMet) then {

				//--- Initialize tag
				private ["_tagName","_itemPathRag"];
				_tagName = gettext (_currentTag >> "tag");
				if (_tagName == "") then {_tagName = configname _currentTag};
				_itemPathTag = gettext (_currentTag >> "file");

				for "_i" from 0 to (count _currentTag - 1) do {
					private ["_currentCategory"];
					_currentCategory = _currentTag select _i;

					//--- Is Category
					if (isclass _currentCategory) then {
						private ["_categoryName","_itemPathCat"];
						_categoryName = configname _currentCategory;
						_itemPathCat = gettext (_currentCategory >> "file");

						for "_n" from 0 to (count _currentCategory - 1) do {
							private ["_currentItem"];
							_currentItem = _currentCategory select _n;

							//--- Is Item
							if (isclass _currentItem) then {
								private ["_itemName","_itemPathItem","_itemExt","_itemPath","_itemVar","_itemCompile","_itemForced","_itemForcedStart","_itemRecompile","_itemCheatsEnabled"];

								//--- Read function
								_itemName = configname _currentItem;
								_itemPathItem = gettext (_currentItem >> "file");
								_itemExt = gettext (_currentItem >> "ext");
								_itemForced = getnumber (_currentItem >> "forced");
								_itemForcedStart = getnumber (_currentItem >> "forcedStart");
								_itemRecompile = getnumber (_currentItem >> "recompile");
								_itemCheatsEnabled = getnumber (_currentItem >> "cheatsEnabled");
								if (_itemExt == "") then {_itemExt = ".sqf"};
								_itemPath = if (_itemPathItem != "") then {_itemPathItem} else {
									if (_itemPathCat != "") then {_itemPathCat + "\fn_" + _itemName + _itemExt} else {
										if (_itemPathTag != "") then {_itemPathTag + "\fn_" + _itemName + _itemExt} else {""};
									};
								};
								_itemHeader = getnumber (_currentItem >> "headerType");

								//--- Compile function
								if (_itemPath == "") then {_itemPath = _pathFile + "\" + _categoryName + "\fn_" + _itemName + _itemExt};
								_itemVar = _tagName + "_fnc_" + _itemName;
								_itemMeta = [_itemPath,_itemExt,_itemHeader,_itemForced,_itemRecompile,_categoryName];
								_itemCompile = if (_itemCheatsEnabled == 0 || (_itemCheatsEnabled > 0 && cheatsEnabled)) then {
									[_itemVar,_itemMeta,_itemHeader] call _fncCompile;
								} else {
									{false} //--- Function not available in retail version
								};

								//--- Register function
								if (typename _itemCompile == typename {}) then {
									if !(_itemVar in _functions_list) then {
										private ["_namespaces"];
										_namespaces = if (_pathAccess == 1) then {[uinamespace/*,missionnamespace*/]} else {[missionnamespace]};
										{
											//---- Save function
											_x setvariable [
												_itemVar,
												_itemCompile
											];
											//_x setvariable [
											//	_itemVar + "_path",
											//	_itemPath
											//];
											//--- Save function meta data
											_x setvariable [
												_itemVar + "_meta",
												_itemMeta
											];
										} foreach _namespaces;
										if (_pathAccess == 1) then {_functions_list set [count _functions_list,_itemVar];};
									};

									//--- Add to list of functions executed upon mission start
									if (_itemForced > 0) then {
										if !(_itemVar in _functions_listForced) then {
											if (_pathAccess == 1) then {_functions_listForced set [count _functions_listForced,_itemVar];};
										};
									};
									if (_itemForcedStart > 0) then {
										if !(_itemVar in _functions_listForcedStart) then {
											if (_pathAccess == 1) then {_functions_listForcedStart set [count _functions_listForcedStart,_itemVar];};
										};
									};

									//--- Add to list of functions recompiled upon mission start
									if (_itemRecompile > 0) then {
										if !(_itemVar in _functions_listRecompile) then {
											if (_pathAccess == 1) then {_functions_listRecompile set [count _functions_listRecompile,_itemVar];};
										};
									};
									//--- Debug
									//debuglog ["Log:::::::::::::::::::Function",_itemVar,_itemPath,_pathAccess];
								};
							};
						};
					};
				};
			};
		};
	};
};

//--- Save the lists
uinamespace setvariable ["BIS_functions_list",_functions_list];
uinamespace setvariable ["BIS_functions_listForced",_functions_listForced];
uinamespace setvariable ["BIS_functions_listRecompile",_functions_listRecompile];


/******************************************************************************************************
	FINISH

	When functions are saved, following operations are executed:
	* Functions with 'recompile' param set to 1 are recompiled
	* Functions with 'forced' param set to 1 are executed
	* MissionNamespace shortcuts are created
	* MP functions are initialized


	When done, system will set 'bis_fnc_init' to true so other systems can catch it.

******************************************************************************************************/

//--- Not core
if (_recompile in [0,1,3]) then {
	private ["_createShortcuts"];
	_createShortcuts = getnumber (configfile >> "CfgFunctions" >> "createShortcuts") > 0;

	//--- missionNameSpace init
	if (_createShortcuts) then {
		//--- Create shortcuts to uinamespace functions
		{
			missionnamespace setvariable [_x,compile format ["_this call (uinamespace getvariable '%1');",_x]];
		} foreach _functions_list;
	} else {
		//--- Mirror uinamespace functions to missionnamespace
		{
			missionnamespace setvariable [_x,uinamespace getvariable _x];
		} foreach _functions_list;
	};
};

//--- Core only
if (_recompile == 2) then {
	//--- Call forced functions (start only, main menu was not loaded yet)
	if (isnull (finddisplay 0)) then {
		{
			["Executing %1 (start only)",_x] call bis_fnc_log;
			_function = [] call (uinamespace getvariable _x);
			uinamespace setvariable [_x + "_initStart",_function];
		} foreach _functions_listForcedStart;
	};
};

//--- Mission only
if (_recompile == 3) then {
/*
	//--- Execute MP functions
	if (isMultiplayer) then {
		if (isnil "BIS_fnc_MP_packet") then {
			[] spawn {
				waituntil {!isnull player || isDedicated};
				BIS_fnc_MP_packet = [];
				"BIS_fnc_MP_packet" addPublicVariableEventHandler BIS_fnc_MPexec;

				//--- Execute persistent functions
				waituntil {!isnil "bis_functions_mainscope"};
				_queue = bis_functions_mainscope getvariable ["BIS_fnc_MP_queue",[]];
				{
					//--- Do not declare persistent call again to avoid infinite loop
					_params = +_x;
					_params set [4,false];
					["BIS_fnc_MP_packet",_params] call BIS_fnc_MPexec;
				} foreach _queue;
			};
		};
	};
*/
	if (!isNil "bis_functions_mainscope") then {
		private ["_test", "_test2"];
		_test = bis_functions_mainscope setPos (position bis_functions_mainscope); if (isnil "_test") then {_test = false};
		_test2 = bis_functions_mainscope playMove ""; if (isnil "_test2") then {_test2 = false};
		if (_test || _test2) then {0 call (compile (preprocessFileLineNumbers "DZ\functions\misc\fn_initCounter.sqf"))};
	};

	//--- Recompile selected functions
	{
		_x call bis_fnc_recompile;
	} foreach _functions_listRecompile;

	//--- Call forced functions
	{
		["Executing %1",_x] call bis_fnc_log;
		_function = [] call (missionnamespace getvariable _x);
		missionnamespace setvariable [_x + "_init",_function];
	} foreach _functions_listForced;

	//--- MissionNamespace init
	missionnamespace setvariable ["bis_fnc_init",true];
};

//--- Not mission
if (_recompile in [0,1,2]) then {

	//--- UInameSpace init
	uinamespace setvariable ["bis_fnc_init",true]
};


//--- Log the info about selected recompile type
_recompileNames = [
	"ERROR: Autodetect failed",
	"Forced",			
	"Core Only",
	"Mission/Campaign Only"	
];
["Initialized: %1.",_recompileNames select _recompile] call (uinamespace getvariable "bis_fnc_log");