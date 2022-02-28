/* DayZ Legacy 0.44 */
/* fn_generateTooltip.sqf - Creates a tooltip with item information such as name, quality, and a picture */

private["_item","_title","_config","_desc","_text","_damage","_damageText","_subHeading","_used","_usedText","_type","_descShortNum"];
_item = 	_this;
_type = "cfgVehicles";
_config = 	configFile >> _type >> typeOf _item;
_textArray = [];

_damage = 	damage _item;
_used = 	_item getVariable ["used",-1];
_quantity = quantity _item;
_wetness = 	_item getVariable ["wet",0];
_descShortNum = 0;

if(!isClass _config) then {
	_type = "CfgMagazines";
	_config = configFile >> _type >> typeOf _item;	
	if(!isClass _config) then {
		_type = "CfgWeapons";
		_config = configFile >> _type >> typeOf _item;
	} else {
		_quantity = MagazineAmmo _item;
		_stackedUnit = " rounds";
	};
};

//Set the title
_text = displayName _item;
_attributes = ["size", "1.5"];
call fnc_addTooltipText;

//Damage
_text = "Pristine";
_color = "#40FF00";
switch true do {
	case (_damage == 1)  : {
		_text = "Ruined";
		_color = "#FF0000";
	};
	case (_damage >= 0.7)  : {
		_text = "Badly Damaged";
		_color = "#FFBF00";
	};
	case (_damage >= 0.5)  : {
		_text = "Damaged";
		_color = "#FFFF00";
	};
	case (_damage > 0.3)  : {
		_text = "Worn";
		_color = "#BFFF00";
	};
};
_attributes = ["color",_color,"size", "1.15"];
call fnc_addTooltipText;

//wetness setting
if (_wetness > 0) then {
	switch true do {
		case (_wetness >= 0.9)  : {
			_text = "Soaking Wet";
			_color = "#0051FF";
		};
		case (_wetness >= 0.5)  : {
			_text = "Wet";
			_color = "#009DFF";
		};
		case (_wetness > 0)  : {
			_text = "Damp";
			_color = "#00EEFF";
		};
	};
	_attributes = ["color",_color,"size", "1.15"];
	call fnc_addTooltipText;
};

//magazine ammunition quantity
_max = maxQuantity _item;
if (_max > 0) then
{
	if (_max == 1) then
	{
		//display magazine data
		_text = format["%1%% remaining",round((_quantity / _max) * 100)];
		_attributes = ["color","#A4A4A4"];
		call fnc_addTooltipText;
	}
	else
	{
		_stackedUnit = getText(_config >> "stackedUnit");
		if (_quantity >= 0) then {
			//display magazine data
			_text = format["%1%2 remaining",_quantity,_stackedUnit];
			_attributes = ["color","#A4A4A4"];
			call fnc_addTooltipText;
		};
	};
};

/*
DEBUG ONLY
*/

//set debug text (Only in SP!)
if (isServer) then //DZ_DEBUG
{
	_modifiers = _item getVariable ["modifiers",[]];
	{
		_text = format["DEBUG: %1",_x];
		_attributes =  ["color","#FF0000"];
		call fnc_addTooltipText;
	} forEach _modifiers;
	
	_resources = getArray (_config >> "tooltipResources");
	{
		_val = _item getVariable [_x,0];
		_text = format["DEBUG: %1: %2",_x,_val];
		_attributes =  ["color","#FF0000"];
		call fnc_addTooltipText;
	} forEach _resources;
	
	if (_wetness > 0) then 
	{
		_text = format["DEBUG: Wetness: %1",_wetness];
		_attributes = ["color","#FF0000"];
		call fnc_addTooltipText;
	};
};

/*
FINALIZE
*/

//set the description
_desc = text getText (_config >> "descriptionShort");
_descShortNum = getNumber (_config >> "descriptionShortNum");
if (_descShortNum != 0) then {
	_formatdesc = format [str _desc,_descShortNum];
	_desc = text _formatdesc;
};
_textArray set [count _textArray,lineBreak];
_textArray set [count _textArray,lineBreak];
_textArray set [count _textArray,_desc];

//output result
_text = 	composeText _textArray;
_text