/*	
	This script transfers modifiers (aka disease) between objects and/or players.
	
	author: Peter Nespesny
*/
private["_target","_source","_method","_interactionWeight","_headWear","_obstructionHead","_obstruction"];

//hint "DBG>> checking transfer";

_target = _this select 0;
_source = _this select 1;
_method = _this select 2;
_interactionWeight = _this select 3; 		// interaction weight value of given action for use in disease transfer formula

//hint str(_this);
//hint str(_interactionWeight);

_headWear = _person itemInSlot "Headgear"; 			// get item weared on player's head such as masks, glasses... etc
//_handsWear = _person itemInSlot "Handsgear";		// get item weared on player's hands such as gloves... etc
_obstructionHead = getNumber (configFile >> "CfgVehicles" >> typeOf _headWear >> "DamageArmor" >> "biological");			// physical obstruction value of DRESSED item (like masks, gloves..) for use in disease transfer formula
_obstructionHands = 0; //getNumber (configFile >> "CfgVehicles" >> typeOf _handsWear >> "DamageArmor" >> "biological");	// physical obstruction value of DRESSED item (like masks, gloves..) for use in disease transfer formula
_obstruction = _obstructionHead + _obstructionHands;

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
			/*
				This section will only run if the modifier has a transmission class!
			*/					
			private["_transferability","_probability","_probabilityToNotTransfer","_randomNum"];
			_transferability = getNumber (_config >> "Transmission" >> _method >> "transferability"); //efficiency rate of penetrate receptive person AKA chance of spread

			// for each one (_x) run some kind of test to see if transfer	
			_probability = _interactionWeight - _obstruction + _transferability; 	//probability to transfer disease
			_probabilityToNotTransfer = 1 - _probability; 	//probability of not getting disease on player
			_randomNum = random 1;
			
			//_debugText1 = format ["DBG>> interact:%1 - obstruct:%2 + transfer:%3 = probab:%4",_interactionWeight,_obstruction,_transferability,_probability];
			//_debugText2 = format ["DBG>> random:%1 VS. probNotToTransf:%2",_randomNum,_probabilityToNotTransfer];
			//statusChat [_debugText1,""];
			//statusChat [_debugText2,""];

			// insert variable for if transmit
			if (_randomNum >= _probabilityToNotTransfer) then
			{
				statusChat ["DBG>> gonna transfer..",""];
				
				// check if target is a player
				if (_a isKindOf "SurvivorBase") then
				{	
					/*
						This section will only run if the target is a survivor class!
					*/	
					private ["_invasivity","_survivorBlood","_immunityStrength"];
					
					statusChat ["DBG>> ..to survivor!",""];				
					
					_invasivity = getNumber (_config >> "Transmission" >> "invasivity");
					//_toxicity = getNumber (_config >> "Transmission" >> "toxicity"); 	// we probably don't need the toxicity
					
					_survivorBlood = _person getVariable "blood";
					_survivorHealth = _person getVariable "health";
					_survivorExposure = _person getVariable "exposure";
					_survivorDiet = _person getVariable "diet";
										
					_immunityStrength = (_survivorDiet + (_survivorBlood/5000) + (_survivorHealth/5000) + _survivorExposure) / 4; // draft of immunity strength formula
					
					//statusChat [str(_immunityStrength),""]; // DEBUG
					
					////_medicalRecord = DOES HE HAD DISEASE IN PAST?; // probably use immune stage of modifier to assure he not gets it for a while...
					
					if (_invasivity >= _immunityStrength) then
					{
						private ["_impactOnPlayer"];

						statusChat ["DBG>> And he gets it in ... stage!!!",""];
						
						_impactOnPlayer = _immunityStrength / _invasivity; //higher the number is, the lighter impact disease have on player
						
						//statusChat [str(_impactOnPlayer),""]; // DEBUG
						
						switch true do
						{	
							/*
								This section will decide what is the impact of the disease on player
							*/
							case (_impactOnPlayer > 1):
							{
							};
							case (_impactOnPlayer >= 0.8):
							{
								//hint "DBG>> carrier impact";								
								[2,_a,_x,0] call event_modifier;
							};
							case (_impactOnPlayer >= 0.6):
							{
								//hint "DBG>> light impact";								
								[2,_a,_x,1] call event_modifier;
							};
							case (_impactOnPlayer >= 0.4):
							{
								//hint "DBG>> medium impact";								
								[2,_a,_x,2] call event_modifier;
							};
							case (_impactOnPlayer >= 0.2):
							{
								//hint "DBG>> hard impact";								
								[2,_a,_x,3] call event_modifier;
							};
							case (_impactOnPlayer > 0):
							{
								//hint "DBG>> deadly impact";								
								[2,_a,_x,4] call event_modifier;
							};
						};
						//hint "DBG>> immunity";
						//[0,_a,_x,10] call event_modifier;
					};
				}
				else
				{	
					/*
						This section will only run if the target is NOT a survivor class!
					*/	
					statusChat ["DBG>> ..to item",""];					
					[2,_a,_x,0] call event_modifier;
				};
			};
		};
	} forEach _modifiers;
} forEach [[_target,_source],[_source,_target]];	