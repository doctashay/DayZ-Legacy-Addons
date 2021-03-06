/*
	This script clears modifiers (aka disease) from objects and players.
	Also it can shorten or prolonging duration of disease modifier on players. 
	
	[_itemType,_person] call event_clearModifiers;
	
	author: Peter Nespesny
*/
private["_target","_source","_method","_modifiers"];

//hint "DBG>> checking cleansing";

_source = _this select 0; //tool1 is used on another item
_target = _this select 1; //tool2 or player
//_method = _this select 2;

//diag_log format ["CLEAR>> checking clearing of target: %2 modifiers with source: %1",_source,_target];

_modifiers = _target getVariable ["modifiers",[]];

switch true do
{
	case (_target isKindOf "inventoryBase"):
	//case (_target isKindOf "inventoryItemBase"): //due to that old deprecated misc items!
	{
		{
			private["_modifier","_config","_disinfectionEfficiency"];
			_modifier = _x;
			
			//statusChat [str(_source),[]];
			
			_disinfectionEfficiency = getNumber (configFile >> "CfgVehicles" >> typeOf _source >> "disinfectionEfficiency");
			
			// check if modifier have a transmission class (if it is a disease)
			_config = configFile >> "CfgModifiers" >> _modifier;
			if (isClass (_config >> "Transmission")) then
			{
				//	This section will only run if the modifier has a transmission class!
									
				private["_physicalResistance"];
				_physicalResistance = getNumber (_config >> "Transmission" >> "physicalResistance");

				// insert variable for if disease is cleared
				if (_disinfectionEfficiency >= _physicalResistance) then
				{
					//diag_log format ["CLEAR>> Target's modifier %1 is cleared",_modifier];					
					[1,_target,_x] call event_modifier; //remove modifier completely
				};	
			};		
		} forEach _modifiers;
	};
	case (_target isKindOf "survivorBase"):
	{
		{
			private["_modifier","_config"];
			_modifier = _x;
			
			//diag_log format ["CLEAR>> Target's currently checked modifier: %1",_modifier];
			
			// check if modifier have a transmission class (if it is a disease)
			_config = configFile >> "CfgModifiers" >> _modifier;
			if (isClass (_config >> "Transmission")) then
			{
				//	This section will only run if the modifier has a transmission class!							
				private["_chemicalResistance","_treatmentAcceleration","_treatment","_diseaseExit"];
			
				_treatment = getNumber (configFile >> "CfgVehicles" >> _source >> "Medicine" >> "treatment"); // 0.9 for tetracycline
				_diseaseExit = getNumber (configFile >> "CfgVehicles" >> _source >> "Medicine" >> "diseaseExit") == 1;			
				_chemicalResistance = getNumber (_config >> "Transmission" >> "chemicalResistance"); // 0.6 for cholera
				
				//diag_log format ["CLEAR>> Treatment of source: %1 and Chemical Resistance of modifier: %2",_treatment,_chemicalResistance];
				
				// insert variable for if disease is cured/speeded
				if (_treatment >= _chemicalResistance) then
				{
					_treatmentAcceleration = _chemicalResistance / _treatment;
					//diag_log format ["CLEAR>> Modifier duration is multiplied by %1",_treatmentAcceleration];						
					[3,_target,_modifier,_treatmentAcceleration] call event_modifier;	// changes the duration of the modifier (duration * treatmentAcceleration)
				};
				/*
				if (_diseaseExit) then
				{
					if (_treatment >= _chemicalResistance) then
					{
						//diag_log format ["CLEAR>> gonna completely cure..",""];
						[1,_target,_x] call event_modifier; //remove modifier completely
					};
				}
				else
				{
					if (_treatmentAcceleration > _chemicalResistance) then
					{
						//diag_log format ["CLEAR>> gonna speeded up..",""];						
						[3,_target,_x,_treatmentAcceleration] call event_modifier;	// changes the duration of the modifier (duration * treatmentAcceleration)
					}
				};
				*/
			};		
		} forEach _modifiers;
	};
};
