//DayZ Legacy 0.44
//player_queued.sqf - Handles spawn and inventory creation for the player
//This script has been redirected from dz\server_data\ to provide better ability to add or extend functionality.

diag_log "Started player queue script override";

_id = _this select 0;
_alive = _this select 1;

0 fadeSound 0;
0 fadeSpeech 0;
0 fadeMusic 0;

// _wait = _this select 3;

// if (_wait < 0) then
// {
// 	while {_wait < 0} do
// 	{
// 		titleText [format["Spawning in %1 seconds... Please wait...",-_wait],"BLACK FADED",10e10];
// 		_wait = _wait + 1;
// 		sleep 1;
// 	};
// };

titleText ["Welcome to DayZ Legacy. Please wait a moment...","BLACK FADED",10e10];
/*
myCamera = "camera" camCreate _position;
myCamera cameraEffect ["internal","back"];
myCamera camPrepareDir 120;
myCamera camPreparePos _position;
myCamera camCommitPrepared 0;
*/
//waitUntil {preloadCamera _position};

if (!_alive) then
{	
	//load data
	_top = getArray(configFile >> "cfgCharacterCreation" >> "top");
	_bottom = getArray(configFile >> "cfgCharacterCreation" >> "bottom");
	_shoe = getArray(configFile >> "cfgCharacterCreation" >> "shoe");
	_format = getText(configFile >> "cfgCharacterCreation" >> "format");

	//find selected skin
	_charType = profileNamespace getVariable ["defaultCharacter",""];
	_charTypeN = DZ_SkinsArray find _charType;
	if (_charTypeN < 0) then {_charTypeN = floor random (count DZ_SkinsArray)};

	//generate inventory array
	_topN = floor random (count _top);
	_bottomN = floor random (count _bottom);
	_shoeN = floor random (count _shoe);
	_array = profileNamespace getVariable ["defaultInventory",[]];
	{
		switch true do
		{
			case (_x isKindOf "TopwearBase"): {
				_topN = (_top find _x);
			};
			case (_x isKindOf "BottomwearBase"): {
				_bottomN = (_bottom find _x);
			};
			case (_x isKindOf "FootwearBase"): {
				_shoeN = (_shoe find _x);
			};
		};
	} forEach _array;
	clientNew = [_charTypeN,[_topN,_bottomN,_shoeN],_id];
	publicVariableServer "clientNew";	
	statusChat ['DayZ Legacy: Creating default scene.',''];
	waitUntil {isSceneReady};
	statusChat ['DayZ Legacy: Default scene created.',''];
	_id spawnForClient {execVM 'debugFunctions.sqf'}; //this causes recompilation every time you respawn
	//execVM "debugFunctions.sqf";
}
else
{
	clientReady = _id;
	publicVariableServer "clientReady";		
	statusChat ['DayZ Legacy: Scene created.',''];
	_id spawnForClient {execVM 'debugFunctions.sqf'};
	//execVM "debugFunctions.sqf";
};
5 fadeSound 0;
5 fadeSpeech 0;
5 fadeMusic 0;