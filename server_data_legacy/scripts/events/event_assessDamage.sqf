//if ((_this select 1)!="") exitWith {0};
private["_agent","_damage","_source","_bone","_base","_items","_slots"];
//111628
//select bone to damage
_agent = _this select 0;
_selection = _this select 1;
_damage = _this select 2;
_source = _this select 3;
_ammo = _this select 4;
_ammoConfig = configFile >> "cfgAmmo" >> _ammo;
_isMelee = _ammo isKindOf "MeleeDamage";
_isZombie = _source isKindOf "ZombieEngine";
_final = 0;

//WIP vehicle death handling
//_isVehicle = _source isKindOf "VehicleDamage"; 

//ignore very low damage
if (_damage < 0.1 and !_isMelee) exitWith {0};

if (_isZombie) then
{
	//_damage = _damage * 3;
	_diseaseChance = random 1;
	switch true do 
	{
		case (_diseaseChance < 0.01): {[0,_agent,"BrainFlu"] call event_modifier;};	//brain flu
		case (_diseaseChance < 0.2): {[0,_agent,"WoundInfection"] call event_modifier;};	//infection
	};
};
//else
//{
//	admin_log format ['Source is:: %1.',_source];
//};
//hint(str _damage);
_bone = (((_this select 5) select 1) select 0);

if (count (_this select 5) > 1) then
{
	_bone = (((_this select 5) select 1) select 0);
}
else
{
	//undefined, so fall damage
	//_bone = "Pelvis";
	_bone = "";
		
	//handle damage script is probably called for each hit selection separately, so if some actions should be done only once during hit we need if below
	if(_selection == "feet") then
	{
		_legdmg = _damage*0.7;
		_legactdmg = (_agent getHitPointDamage 'HitLegs');
		//if(_legactdmg < _legdmg)then{ //in case I dont want to cummulate damage in leg, but damage leg based on height of each fall independently
		_agent setHit ['legs',(_legactdmg+_legdmg)];
		
		//};
		
		//remove blood for falldamage
		if(_damage > 0.25) then
		{
			_admg = ((_agent getVariable ['blood',2500]) - _damage*1500);
			_agent setVariable ['blood',_admg];
		};
		//kill player instantly
		if(_damage > 1.4) then
		{
			_agent setDamage 1;
		};
		
		//damage gear
		_shoes = (_agent itemInSlot "Feet");
		_currfdmg = (damage _shoes) + _damage*0.9;
		_shoes setDamage _currfdmg;	
		
		_pants = (_agent itemInSlot "Legs");
		_currpdmg = (damage _pants) + _damage/2;
		_pants setDamage _currpdmg;	
		if(_currpdmg > 0.6) then
		{	//damage items in pants
			{
				_x setDamage ((damage _x) + _damage/2);
			} forEach itemsInCargo _pants;
		};
	};
};

_config = configFile >> "cfgBody" >> _bone;
_base = configName inheritsFrom _config;

//ensure correct parented bone
if (_base != "") then
{
	_bone = configName inheritsFrom _config;
};

if (_bone == "") exitWith {0};

if (!_isZombie) then
{
	_item = itemInHands _source;
	_v = damage _item;
	_apply = getNumber(configFile >> "cfgVehicles" >> typeOf _item >> "fragility");
	
	//change damage based on melee object damage
	if (_isMelee) then
	{		
		_damage = _damage * (1 - _v);	//TODO: Peter is going to write log scale :)
	};	
	
	//apply damage to item
	if (_apply > 0) then
	{
		_v = _v + (_apply * _damage);
		_item setDamage _v;
	};
};

//ensure correct damage is applied (for now)
_hitPoint = getText(configFile >> "cfgBody" >> _bone >> "hitPoint");

//process pp effect
if (isPlayer _agent) then
{
	effectDazed = true;
	(owner _agent) publicVariableClient "effectDazed";
};
//slot items
_items = [];
call damage_fnc_generateSlots;

/*
	Process Item Damage
*/
{
	private["_item","_itemConfig","_condition"];
	_item = _x;
	_itemConfig = configFile >> "cfgVehicles" >> typeOf _item >> "DamageArmor";
	_condition = 1 - (damage _item);	//current condition
	
	diag_log format["DAMAGING ITEM %1",typeOf _item];
	
	//Damage Item Itself
	_resolved = false;
	if (isClass _itemConfig) then
	{
		//Apply damage to an item that has armor
		_armor = getNumber(_itemConfig >> "ballistic") * _condition;	//get current damage state		
		if (_armor > 0) then
		{
			//Remove armor from object
			_armorResult = ((_armor - _damage) max 0) / _armor;
			_damage = (_damage - _armor) max 0;
			_item setDamage (1 - _armorResult);	//apply damage to armored item
			_resolved = true;
			diag_log format["DAMAGED ITEM %1 to %2",typeOf _item,_armorResult];
		}
	};
	if (!_resolved) then
	{
		//Apply damage to an item that has no armor
		_item setDamage ((damage _item) + _damage);
		diag_log format["DAMAGED ITEM %1 with %2 to %3",typeOf _item,_damage,((damage _item) + _damage)];
	};
	
	//Damage Interior Items
	if (_damage > 0.05) then 
	{
		{
			if ((damage _x) < 1) then
			{
				_condition = 1 - (damage _x);
				_x setDamage ((damage _x) + _damage);
				_damage = (_damage - (_condition / 4)) max 0;
			};
		} forEach itemsInCargo _item;
	};	
} forEach _items;

// don't do damage for dead bodies
if(!alive _agent) exitWith {0; ProfileStop "event_assessDamage.sqf";};



/*
APPLY BODY DAMAGE
*/
"shock" call damage_fnc_applyStateChange;
"blood" call damage_fnc_applyStateChange;
"health" call damage_fnc_applyStateChange;

if (isPlayer _agent) then
{
	switch (toLower _bone) do 
	{
		case "head":
		{
			_shock = _agent getVariable ["shock",0];
			_totalShock = (random (getNumber(_ammoConfig >> "hitShockHead")) + _shock);
			
			//deduct protective shock
			_headwear = _agent itemInSlot "headgear";
			_shockProtection = getNumber(configFile >> "cfgVehicles" >> typeOf _headwear >> "DamageArmor" >> "shock") * (1 - damage _headwear);
			_totalShock = (_totalShock - _shockProtection) max 0;
			
			_agent setVariable ["shock",_totalShock];
			if (_totalShock > (_agent getVariable["blood",0])) then
			{
				//will happen anyway but make it happen fast
				[0,_agent,"Unconscious"] call event_modifier;
			};
		};
		case "chest":
		{
		};
		default
		{
			_damage = _damage / 3;
		};
	};
};

//make bleeding occur
if (_damage <= 0) exitWith {0};

call damage_publishBleeding;
_damage
