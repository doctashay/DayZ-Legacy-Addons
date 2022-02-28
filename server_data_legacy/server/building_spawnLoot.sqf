private["_serial","_positions","_lootGroup","_iArray","_iItem","_iClass","_iPos","_item","_mags","_qty","_max","_tQty","_canType","_obj","_type","_nearBy","_allItems","_items","_itemType","_itemChance","_lootChance","_weights","_index"];
_building = _this;

_type = 	typeOf _building;
_cfgSpawns = configFile >> "CfgVehicles" >> _type >> "Spawns";

//diag_log format["Starting loot spawn... %1",_type];
_thisbuilding = 0;
for "_i" from 0 to ((count _cfgSpawns) - 1) do 
{
	//Get the array of spawn containers
	_array = 	getArray (_cfgSpawns select _i >> "locations");
	_avail = 	getArray (_cfgSpawns select _i >> "items");
	_prob = 	getNumber (_cfgSpawns select _i >> "probability");
	
	//diag_log format["List: type: %3 = locations: %1 avail: %2: %4",_array,_avail,_type,_cfgSpawns select _i];
	
	{
		//if (_prob > (random 1)) then {
			_configArray = _x;
			_proxy = 	_building selectionProxy (_configArray select 0);
			_qty = _configArray select 1;
			_list = [];
			
			//Process maximum quantity number
			for "_p" from 1 to _qty do {
			
				//select random spawn from container
				_numCont = count _proxy;
				
				if (_numCont > 0) then {
					private["_x"];
					_proxyNum = (floor (random _numCont));
					_proxySel = _proxy select _proxyNum;
				
					//Process a spawn container
					_type =		(_proxySel select 0) call building_getProxyName;
					_position = (_proxySel select 2);
					_vDir = 	(_proxySel select 3);
					_vUp = 		(_proxySel select 4);
					
					//Select item type
					_allow = 	getArray (configFile >> "cfgSpawnContainers" >> _type >> "objects");
					_val = 0;
					
					{
						private["_spawnArray"];
						diag_log format["PRE ERROR: %1",_x];
						if (typeName _x == "ARRAY") then
						{
							_name = 	_x select 0;
							_chance = 	_x select 1;
							_doAdd = false;
							if (_name in _allow) then {_doAdd = true}
							else {
								{
									if(_name isKindOf _x) then {_doAdd = true};
								} forEach _allow;
							};
							if (_doAdd) then {
								_num = _chance * 10;
								_num = 1 max _num;
								for "_i" from 1 to _num do {
									_list set [count _list,_name];
								};
							};
							_val = _val + 1;
						}
						else
						{
							diag_log format["ERROR: %2 Spawn is %1 not ARRAY with %3 (subclass: %4)",typeName _x,typeOf _building,_x,configName(_cfgSpawns select _i)];
						};
					} forEach _avail;
					
					//diag_log format["List: type: %3 = allow: %1 avail: %2",_allow,_avail,_type];
					
					_rnd = 		floor(random count _list);
					if (count _list > 0) then {
						//add some random chance to exit
						if (random 1 < 0.333) exitWith {};
						
						_class = 	_list select _rnd;
						_offset = 0;	
						
						if((_vUp select 2) < 0.95) then {
							//Add proxy offset for items spawning on side
							_offset = 	getNumber (configFile >> "CfgVehicles" >> _class >> "spawnOffset");
							_z = _position select 2;
							_position set [2,(_z + _offset)];
						};					
						//diag_log format["List: class: %3, offset: %2",_array,_offset,_class];
					
						//Create item
						totalItems = totalItems + 1;
						_thisbuilding = _thisbuilding + 1;
						_item = 	createVehicle [_class, _position, [], 0, "CAN_COLLIDE"];
						_item setposASL _position;
						_item setVectorDirAndUp [_vDir,_vUp];
						_item setTargetCategory "loot";
						
						if(isClass(configFile >> "CfgVehicles" >> _class)) then {
							_attachments = getArray (configFile >> "CfgVehicles" >> _class >> "cargo");
							if(count _attachments > 0) then {
								{
									_attachment = _item createInCargo _x;
									_item setTargetCategory "loot";
								} forEach _attachments;
							};
						};
						
						if(isClass(configFile >> "CfgWeapons" >> _class)) then {
							_attachments = getArray (configFile >> "CfgWeapons" >> _class >> "baseAttachments");
							if(count _attachments > 0) then {
								{
									_attachment = _item createInInventory _x;
									_attachment enableSimulation false;
								} forEach _attachments;
							};
						};
					};
					
					_proxy set [_proxyNum,"DEL"];
					_proxy = _proxy - ["DEL"];
				};
			};
		//};
	} forEach _array;
};
diag_log format["INFO: %1 spawns %2 proxies %3",typeOf _building,_thisbuilding,_qty];