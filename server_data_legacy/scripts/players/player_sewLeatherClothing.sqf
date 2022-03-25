private["_person","_sender","_receiver","_max","_senderQty","_receiverQty","_exchanged","_config_kit", "_config_result","_tannedCount"];

_needQuantity		= _this select 0;
_result_class_name	= _this select 1;

_config_kit		= configFile >> "CfgVehicles" >> typeOf _tool1;
_sewingkit_name	= getText (_config_kit >> "displayName");

_config_result	= configFile >> "CfgVehicles" >> _result_class_name;
_result_name	= getText (_config_result >> "displayName");

if ( quantity _tool2 >= _needQuantity ) then
{
	_tool_new_damage = (damage _tool1 + (0.05*_needQuantity));
	
	if ( _tool_new_damage <= 1 ) then
	{
		// Decrese quantity of Tanned Leathers
		[_tool2, -_needQuantity] call fnc_addQuantity;
		
		// Add damage to Sewing Kit
		_tool1 setDamage ((damage _tool1 + (0.05*_needQuantity)) min 1);
		
		_item = [_result_class_name, _owner] call player_addInventory;
		
		[_owner,format["You have sewed %1.", _result_name],""] call fnc_playerMessage;
	}
	else
	{		
		[_owner,format["%1 is too damaged for sew %2.", _sewingkit_name, _result_name],""] call fnc_playerMessage;
	}
};