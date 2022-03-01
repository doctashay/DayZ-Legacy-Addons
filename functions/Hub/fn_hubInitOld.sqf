if (getnumber (campaignconfigfile >> "campaign" >> "enableHub") > 0) then {
	_missionMeta = [] call bis_fnc_hubmissionmeta;
	_hub = _missionMeta select 1;

	//--- Temp info
	if (_hub) then {
		hint parsetext format ["<t size='2'>%1</t><br />Use radio to proceed to a next mission.<br /><br />You will start the next mission with equipment you had when ending the hub.",missionname];
	} else {
		hint parsetext format ["<t size='2'>%1</t><br />Use radio to proceed to a next mission.",missionname];
	};

	//--- Skirmish init
	"INIT" spawn bis_fnc_hubSkirmish;

	//--- Declare variables with state of all missions
	if (isnil "bis_missions") then {
		bis_missions = [];
		_cfg = campaignconfigfile >> "campaign" >> "missions";
		for "_m" from 0 to (count _cfg - 1) do {
			_mission = _cfg select _m;
			if (isclass _mission) then {
				_missionName = configname _mission;
				bis_missions set [count bis_missions,_missionName];	
				missionnamespace setvariable [_missionName,false];
				savevar _missionName;
			};
		};
		savevar "bis_missions";

	};
	
	// Weapon Pool
	if (_hub) then {
		[] call BIS_fnc_hubWeaponPool;
	};


	//--- Temp mission end
	if (isnil "BIS_endTrigger") then {
		BIS_endTrigger = createtrigger ["emptydetector",position player];
		BIS_endTrigger settriggeractivation ["juliet","present",true];
		BIS_endTrigger settriggerstatements ["this","[] spawn BIS_end",""];
		BIS_endTrigger settriggertext "Next mission";
	};
	BIS_end = {
		_cfgCampaign = campaignconfigfile >> "campaign" >> "missions";
		_links = getarray (_cfgCampaign >> missionname >> "links");
		_links set [0,-1];
		_links = _links - [-1];
		_linkConditions = getarray (_cfgCampaign >> missionname >> "linkConditions");
		_linkConditions set [0,-1];
		_linkConditions = _linkConditions - [-1];
		{
			//--- Hide unavailable
			_condition = _linkConditions select _foreachindex;
			if (_condition != "") then {
				if !(call compile _condition) then {_links set [_foreachindex,-1]};
			};

			//--- Disable completed
			if (missionnamespace getvariable [_x,false]) then {
				if (getnumber (_cfgCampaign >> _x >> "repeat") == 0) then {
					_links set [_foreachindex,[_x + " (Finished)"]]
				};
			};
		} foreach _links;
		_links = _links - [-1];

		_next = [_links,missionname + ": Select next mission",[0.3,0.2,0.4,0.6]] call bis_fnc_guimessage;
		if (_next select 0) then {
			_end = _links select (_next select 1);
			missionnamespace setvariable [missionname,true];
			savevar missionname;
			[_end,nil,nil,nil,{[] call BIS_fnc_hubExit}] call bis_fnc_endmission;
		};
	};

};
true