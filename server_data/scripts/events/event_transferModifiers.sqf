/*	
	This script transfers modifiers (aka disease) between objects and/or players.
	
	author: Peter Nespesny
*/
private["_target","_source","_method","_interactionWeight","_headWear","_handsWear","_obstructionHead","_handsWear","_obstruction"];

hint "DBG>> checking transfer";

_target = _this select 0;
_source = _this select 1;
_method = _this select 2;
_interactionWeight = _this select 3; 		// interaction weight value of given action for use in disease transfer formula

//hint str(_this);
//hint str(_interactionWeight);

_headWear = _person itemInSlot "Headgear"; // get item weared on player's head such as masks, glasses... etc
_handsWear = _person itemInSlot "Handsgear"; // get item weared on player's hands such as gloves... etc
_obstructionHead = getNumber (configFile >> "CfgVehicles" >> typeOf _headWear >> "DamageArmor" >> "biological"); // physical obstruction value of DRESSED item (like masks, gloves..) for use in disease transfer formula
_obstructionHands = getNumber (configFile >> "CfgVehicles" >> typeOf _handsWear >> "DamageArmor" >> "biological"); // physical obstruction value of DRESSED item (like masks, gloves..) for use in disease transfer formula

_obstruction = _obstructionHead + _obstructionHands;
//_obstruction = 0;

{
	private["_a","_b","_modifiers"];
	// iterate through each combination of target and source
	_a = _x select 0;	// target
	_b = _x select 1;	// source	
	
	_modifiers = _b getVariable ["modifiers",[]];
	{
		private["_modifier","_config"];
		_modifier = _x;
		
		// check if modifier have a transmission class (if it is a disease)
		_config = configFile >> "CfgModifiers" >> _modifier;
		if (isClass (_config >> "Transmission")) then
		{
			// this section will only run if the modifier has a transmission class!
			private["_transferability","_probability","_probabilityToNotTransfer","_randomNum"];
			
			_transferability = getNumber (_config >> "Transmission" >> _method >> "transferability"); // efficiency rate of penetrate receptive person AKA chance of spread

			// for each one (_x) run some kind of test to see if transfer	
			_probability = _interactionWeight - _obstruction + _transferability; // probability to transfer disease
			_probabilityToNotTransfer = 1 - _probability; 	// probability of not getting disease on player
			_randomNum = random 1;
			
			//_debugText1 = format ["DBG>> interact:%1 - obstruct:%2 + transfer:%3 = probab:%4",_interactionWeight,_obstruction,_transferability,_probability];
			//_debugText2 = format ["DBG>> random:%1 VS. probNotToTransf:%2",_randomNum,_probabilityToNotTransfer];
			//statusChat [_debugText1,""];
			//statusChat [_debugText2,""];

			// insert variable for if transmit
			if (_randomNum >= _probabilityToNotTransfer) then
			{
				//diag_log ["DBG>> Transfer between originator and receptive person was successful",""];
				
				// check if target is a player
				if (_a isKindOf "SurvivorBase") then
				{	
					// this section will only run if the target is a survivor class!
					private ["_invasivity","_toxicity","_survivorBlood","_survivorHealth","_survivorDiet","_survivorExposure","_immunityStrength","_allStages","_stagesCount","_stagesStep"];
					
					//diag_log ["DBG>> Transfering to survivor",""];				
					
					_invasivity = getNumber (_config >> "Transmission" >> "invasivity");
					_toxicity = getNumber (_config >> "Transmission" >> "toxicity"); 
					
					_survivorBlood = _person getVariable "blood";
					_survivorHealth = _person getVariable "health";
					_survivorDiet = _person getVariable "diet";
					
					_survivorExposure = _person getVariable "exposure";
										
					//_immunityStrength = (_survivorDiet + (_survivorBlood/5000) + (_survivorHealth/5000) + _survivorExposure) / 4; // draft of immunity strength formula
					_immunityStrength = (_survivorDiet + (_survivorBlood/5000) + (_survivorHealth/5000)) / 6;
					
					//diag_log [format ["DBG>> Impact on player = %1, immunity strength = %2 / invasivity = %3",_immunityStrength / _invasivity,_immunityStrength,_invasivity],""];
					
					// put all available stages of modifier into the array
					_allStages = configFile >> "CfgModifiers" >> _modifier >> "Stages";
					_stagesCount = count _allStages;
					_stagesStep = 1 / _stagesCount;
					
					if (_invasivity >= _immunityStrength) then
					{
						private ["_impactOnPlayer"];
						
						_impactOnPlayer = _immunityStrength / _toxicity; //higher the number is, the lighter impact disease have on player (lower number == heavier impact)
												
						//diag_log [format ["Stages count = %1, stages step = %2",_stagesCount,_stagesStep],""];
						
						for "_i" from (_stagesCount - 1) to 1 step -1 do
						{	
							//diag_log [format ["Comparing impact on player with stage %1",_i],""];
							if (_impactOnPlayer > (_stagesStep * _i)) exitWith
							{
								[2,_a,_x,_i] call event_modifier;
								//diag_log [format ["Impact on player = %1, stage treshold = %2, modifier added in stage %3",_impactOnPlayer,(_stagesStep * _i),(_allStages select _i)],""];
							};
						};
						/*
						_stagesArray = [];
						
						for "_i" from 0 to ((count _allStages) - 1) do 
						{
							_stage = _allStages select _i;
							diag_log [str(_stage),""];
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
						
						diag_log [str(_stagesArray),""];
						diag_log [str(count _stagesArray),""];
						*/						
					}
					else
					{	
						// add immunity stage of the modifier
						//diag_log [format["DBG>> adding modifier in immunity stage %1",(_allStages select 0)],""];
						//[2,_a,_x,0] call event_modifier;							
					};
				}
				else
				{
					// this section will only run if the target is NOT a survivor class!
					//diag_log ["DBG>> Transfering disease to the item in carrier stage",""];					
					[2,_a,_x,1] call event_modifier;
				};
			};
		};
	} forEach _modifiers;
} forEach [[_target,_source],[_source,_target]];	