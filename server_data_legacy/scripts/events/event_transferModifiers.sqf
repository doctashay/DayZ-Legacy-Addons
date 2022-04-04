/*	
	This script transfers modifiers (aka disease) between objects and/or players.
	
	author: Peter Nespesny
*/
private["_target","_source","_method","_interactionWeight","_headWear","_handsWear","_obstructionHead","_handsWear","_obstruction"];
	    
//hint "Checking transfer";

_target = _this select 0;
_source = _this select 1;
_method = _this select 2;
_interactionWeight = _this select 3; // interaction weight value of given action for use in disease transfer formula

//hint str(_this);
//hint str(_interactionWeight);

/*
// Get items weared on player such as helmets, glasses, masks, gloves... etc
_headWear = _target itemInSlot "Headgear"; 
_glassWear = _target itemInSlot "Headgear";
_maskWear = _target itemInSlot "Mask";
_handsWear = _target itemInSlot "Handsgear";
// physical obstruction value of DRESSED items (like masks, gloves..) for use in disease transfer formula
_obstructionHead = getNumber (configFile >> "CfgVehicles" >> typeOf _headWear >> "DamageArmor" >> "biological");
_obstructionGlass = getNumber (configFile >> "CfgVehicles" >> typeOf _glassWear >> "DamageArmor" >> "biological");
_obstructionMask = getNumber (configFile >> "CfgVehicles" >> typeOf _maskWear >> "DamageArmor" >> "biological");
_obstructionHands = getNumber (configFile >> "CfgVehicles" >> typeOf _handsWear >> "DamageArmor" >> "biological");

_obstruction = _obstructionHead + _obstructionGlass + _obstructionMask + _obstructionHands;
//hint str(_obstruction);
_debugText11 = format ["DBG>> obstr total:%5 = head:%1 + glass:%2 + mask:%3 + hands:%4",_obstructionHead,_obstructionGlass,_obstructionMask,_obstructionHands,_obstruction];
statusChat [_debugText11,""];
*/

_obstruction = 0;

{
	private["_a","_b","_modifiers"];
	// Iterate through each combination of target and source
	_a = _x select 0;	// target
	_b = _x select 1;	// source	
	
	//diag_log format ["TRANSFER>> target: %1 source: %2",_a,_b];
	
	if (typeName _b == "OBJECT") then
	{
		_modifiers = _b getVariable ["modifiers",[]];
		
		//diag_log format ["TRANSFER>> source: %1 and its modifiers: %2",_b,_modifiers];
	}
	else
	{
		_modifiers = getArray (configFile >> "CfgVehicles" >> _b >> "diseases");
		
		//diag_log format ["TRANSFER>> source: %1 and its modifiers: %2",_b,_modifiers];
	};
	
	{
		private["_modifier","_config"];
		_modifier = _x;
		
		//diag_log format ["TRANSFER>> currently tested modifier: %1",_modifier];
		
		// Check if modifier have a transmission class (if it is a disease)
		_config = configFile >> "CfgModifiers" >> _modifier;
		
		if (isClass (_config >> "Transmission")) then
		{
			// This section will only run if the modifier has a transmission class!
			private["_transferability","_probability","_probabilityToNotTransfer","_randomNum"];
			
			// Don't check or add modifier if it's already in player's modifiers array
			_currentModifiers = _a getVariable "modifiers";
			_inModifiers = _modifier in _currentModifiers;

			if (_inModifiers) exitWith
			{
				//diag_log format ["TRANSFER>> Not going to add %1 as it's already in %2 modifiers",_modifier,_a];
			};
			
			// Continue as modifier isn't in player's modifier array			
			_transferability = getNumber (_config >> "Transmission" >> _method >> "transferability"); // Efficiency rate of penetrate receptive person AKA chance of spread

			// For each one (_x) run some kind of test to see if transfer	
			_probability = _interactionWeight - _obstruction + _transferability; // probability to transfer disease
			_probabilityToNotTransfer = 1 - _probability; // probability of not getting disease on player
			_randomNum = random 1;
			
			//diag_log format ["TRANSFER>> interact: %1 - obstruct: %2 + transfer: %3 = probab: %4",_interactionWeight,_obstruction,_transferability,_probability];
			//diag_log format ["TRANSFER>> random: %1 VS. probability not to transfer: %2",_randomNum,_probabilityToNotTransfer];

			// Insert variable for if transmit
			if (_randomNum >= _probabilityToNotTransfer) then
			{
				//diag_log format ["TRANSFER>> Transfer between source and target was successful",""];
				
				// Check if target is a player
				if (_a isKindOf "SurvivorBase") then
				{	
					// This section will only run if the target is a survivor class!
					private ["_invasivity","_toxicity","_survivorBlood","_survivorHealth","_survivorDiet","_survivorExposure","_immunityStrength","_allStages","_stagesCount","_stagesStep"];
					
					//diag_log format ["TRANSFER>> Transfering modifier to survivor",""];					
					
					_invasivity = getNumber (_config >> "Transmission" >> "invasivity");
					_toxicity = getNumber (_config >> "Transmission" >> "toxicity");
										
					_survivorDiet = _a getVariable "diet";
					_survivorBlood = _a getVariable "blood";	
					_survivorHealth = _a getVariable "health";				
					//_survivorExposure = _a getVariable "exposure";
										
					//diag_log format ["TRANSFER>> Diet = %1, Blood = %2, Health = %3)",_survivorDiet,_survivorBlood,_survivorHealth];
					
					_immunityStrength = (_survivorDiet + (_survivorBlood/5000) + (_survivorHealth/5000)) / 3;  // Draft of immunity strength formula
					//_immunityStrength = (_survivorDiet + (_survivorBlood/5000) + (_survivorHealth/5000) + _survivorExposure) / 4;
					
					//diag_log format ["TRANSFER>> Immunity strength = %1",_immunityStrength];					
					//diag_log format ["TRANSFER>> Impact on player = %1, (immunity strength = %2 / toxicity = %3)",_toxicity / _immunityStrength,_immunityStrength,_toxicity];
					
					// Put all available stages of modifier into the array
					_allStages = configFile >> "CfgModifiers" >> _modifier >> "Stages";
					_stagesCount = count _allStages;
					_stagesStep = 1 / _stagesCount;
					
					if (_invasivity >= _immunityStrength) then
					{
						private ["_impactOnPlayer"];

						statusChat ["DBG>> And he gets it in ... stage!!!",""];
						
						_impactOnPlayer =  _toxicity / _immunityStrength; // Higher the number is, the lighter impact disease have on player (lower number == heavier impact)
												
						//diag_log format ["TRANSFER>> Stages count = %1, stages step = %2",_stagesCount,_stagesStep];
						
						for "_i" from (_stagesCount - 1) to 1 step -1 do
						//for "_i" from 0 to (_stagesCount - 1) step 1 do
						{	
							//diag_log format ["TRANSFER>> Comparing impact with stage #%1: %2; Impact = %3 >= Stage cap = %4 <<<",_i,_allStages select _i,_impactOnPlayer,_stagesStep * _i];
							
							if (_impactOnPlayer >= (_stagesStep * _i)) exitWith
							{
								[2,_a,_x,_i] call event_modifier;
								//diag_log format ["TRANSFER>> Impact on player = %1, stage treshold = %2, modifier added in stage %3",_impactOnPlayer,(_stagesStep * _i),(_allStages select _i)];
							};
						};
						/*
						_stagesArray = [];
						
						for "_i" from 0 to ((count _allStages) - 1) do 
						{
							_stage = _allStages select _i;
							diag_log format [str(_stage),""];
							_stagesArrayLenght = count _stagesArray;
							if (_stagesArrayLenght == 0) then
							{
								_stagesArray set [0,_stage];
							}
							else
							{
								_stagesArray set [_stagesArrayLenght,_stage];
							};				
						};
						
						diag_log format [str(_stagesArray),""];
						diag_log format [str(count _stagesArray),""];
						*/						
					}
					else
					{	
						// Add immunity stage of the modifier
						//diag_log format["DBG>> adding modifier in immunity stage %1",(_allStages select 0)];
						//[2,_a,_x,0] call event_modifier;							
					};
				}
				else
				{
					// This section will only run if the target is NOT a survivor class!
					
					/*
					if (_a isKindOf "Medical_TetracyclineAntibiotics") exitWith
					{
						diag_log format ["TRANSFER>> Exit as it's tabs",""]; //hotfix
					};		
					*/
					
					// Check if disease can be transfered back from player to item (example Influenza can be, Brain disease cannot be transfered from player)
					_fromPlayer = getNumber (_config >> "Transmission" >> "Direct" >> "fromPlayer");
					
					if (_fromPlayer == 1) then
					{
						//diag_log format ["TRANSFER>> Transfering modifier to the item in carrier stage",""];
						[2,_a,_x,1] call event_modifier;					
					}
				};
			};
		}
		else
		{
			//diag_log format ["TRANSFER>> Not transferable modifier",""];
		};
		
	} forEach _modifiers;
	
} forEach [[_target,_source],[_source,_target]];	
