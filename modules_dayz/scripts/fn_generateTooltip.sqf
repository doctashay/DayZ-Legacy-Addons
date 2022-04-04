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
_pwetness = player getVariable ["wet",0];
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

_bagwet = 1;
if(!isNull (itemParent _item) && (itemParent _item) isKindOf "ClothingBase")then{
	_bagwet = getNumber(configFile >> "cfgVehicles" >> typeOf (itemParent _item) >> "absorbency");
};

//wetness setting
if(!isNull (itemParent _item) && _bagwet > 0 && _pwetness > 0)then{
	_wetness=getNumber(_config >> "absorbency") min _pwetness;
};

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


//display precize weight
/*
_confweight=getNumber(_config >> "weight");
_weight=0;
if(_quantity > 0)then{
	_weight=round ((_wetness+1)*_confweight*_quantity);
}else{
	_weight=round ((_wetness+1)*_confweight);
};

if(_weight >= 1000)then{
	_text = format["%1 kg",(_weight/1000)];
}else{
	_text = format["%1 g",_weight];
};
_attributes = ["color","#A4A4A4","size", "1.15"];
call fnc_addTooltipText;
*/

_stackedUnit = getText(_config >> "stackedUnit");

//display weight
if(!(_stackedUnit == "ml"))then{
	_confweight=getNumber(_config >> "weight");
	_weight=0;
	
	if(_quantity > 0)then{
		_weight=round ((_wetness+1)*_confweight*_quantity);
		_magy = getNumber (_config >> "count");
		if(_magy > 0)then{
			_weight = _confweight;
		};
	}else{	
		_weight=round ((_wetness+1)*_confweight);
	};
	switch true do {
		case (_weight>=1000) : {_text=format["around %1 kg",(round (_weight/1000))];};
		case (_weight<=250)  : {_text="under 0.25 kg";};
		case (_weight<=500)  : {_text="under 0.5 kg";};
		case (_weight<1000)  : {_text="under 1 kg";};	
	};
	_attributes = ["color","#A4A4A4","size", "1.15"];
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
			switch (_stackedUnit == "ml") do {
				case (_quantity < 250) :	{_text = "under 0.25 l";};
				case (_quantity < 500) :	{_text = "under 0.5 l";};
				case (_quantity < 1000) :	{_text = "under 1 l";};
				case (_quantity >= 1000) :	{_quantity = round (_quantity * 0.001);_text = format["around %1 l",_quantity];};
			};			
			if(!(_stackedUnit == "ml"))then{
				_text = format["%1%2 remaining",_quantity,_stackedUnit];
			};
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
if (_descShortNum != 0) then
{
	_formatdesc = format [str _desc,_descShortNum];
	_desc = text _formatdesc;
};
_textArray set [count _textArray,lineBreak];
_textArray set [count _textArray,lineBreak];
_textArray set [count _textArray,_desc];

//output result
_text = 	composeText _textArray;
_text
