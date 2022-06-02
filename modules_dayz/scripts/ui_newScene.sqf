_doSmooth = _this select 0;
_serial = _this select 1;

if (_doSmooth) then 
{
	titleText ["Loading scene...","BLACK",1];
};
if (count _this == 1) then
{
	_settings = count (configFile >> "cfgCharacterScenes" >> worldName);
	_serial = (floor random _settings);
}
else
{
	_serial = _this select 1;
};

//get variables
_setting = (configFile >> "cfgCharacterScenes" >> worldName) select _serial;
_target = getArray (_setting >> "target");
_position = getArray (_setting >> "position");
_fov = getNumber (_setting >> "fov");
sceneDate = getArray (_setting >> "date");
_aperture = getNumber (_setting >> "aperture");
_humidity = getNumber (_setting >> "humidity");
_overcast = getNumber (_setting >> "overcast");
if (_humidity == 0) then {_humidity = 0.2};
if (_overcast == 0) then {_overcast = 0.2};

//setup camera
if (isNull myCamera) then {
	myCamera = "camera" camCreate _position;
};
myCamera cameraEffect ["internal","back"];
myCamera camPrepareTarget _target;
myCamera camPreparePos _position;
myCamera camPrepareFOV _fov;
myCamera camPrepareFocus [5,1];
if (_doSmooth) then 
{
	sleep 1;
};
myCamera camCommitPrepared 0;
myCamera camPreload 1;

setDate sceneDate;
0 setOvercast _overcast;
simulSetHumidity _humidity;
setAperture _aperture;

sleep 0.1;
showCinemaBorder true;
demoPos = myCamera modelToWorld [0.685547,3.68823,-0.988281];
demoPos set [2,0];
_body = profileNamespace getVariable ["lastCharacter",""];
waitUntil {1 preloadObject _body};

if (isNull demoUnit) then
{
	demoUnit = _body createVehicleLocal demoPos;
};
demoDir = (direction myCamera - demoDefDir);
demoUnit setPosATL demoPos;
demoUnit setDir demoDir;
createDir = demoDir;

waitUntil {isSceneReady};

if (_doSmooth) then 
{
	titleText ["","BLACK IN",1];
};