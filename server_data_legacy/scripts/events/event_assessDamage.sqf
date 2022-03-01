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
//hint(str _damage);
_bone = (((_this select 5) select 1) select 0);

if (count (_this select 5) > 1) then
{
	_bone = (((_this select 5) select 1) select 0);
}
else
{
	//undefined, so fall damage
	_bone = "Pelvis";
	_selection = "legs";
	(_agent itemInSlot "Feet") setDamage 1;
	_final = _damage;
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
	{
		_x setDamage ((damage _x) + _damage);
	} forEach itemsInCargo _item;		
} forEach _items;

//statusChat [format["Hit: %1; Selection: %2; Damage: %3; Slots: %4; Items: %5",_bone,_selection,_damage,_slots,_items],""];

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