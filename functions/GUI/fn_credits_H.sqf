disableSerialization;
private ["_display","_displayMain"];
_displayMain = [_this,0,finddisplay 46,[displaynull]] call bis_fnc_param;
_mode = [_this,1,1,[0]] call bis_fnc_param;

if (_mode > 0) then {

	//--- Show display
	102 cuttext ["","black in",10e10];
	([] call bis_fnc_rscLayer) cutrsc ["RscCredits","plain"];
	waituntil {!isnil {uinamespace getvariable "Hsim_RscCredits"}};

	//See more complete and localized version below (make changes as you wish)
	_names = [
		[["Joris-Jan van 't Land"],[localize "STR_HSIM_CREDITS_ROLE1"]],
		[["Karel Mořický"],[localize "STR_HSIM_CREDITS_ROLE4"],["DZ\ui\data\GUI\Rsc\RscDisplayArcadeMap\stormy_ca.paa",[0.8,0.9,1]]],
		[["Jay Crowe"],[localize "STR_HSIM_CREDITS_ROLE3"],["DZ\ui\data\GUI\Rsc\RscDisplayArcadeMap\rainy_ca.paa",[0.6,0.6,0.6]]],
		[["Jan Kyncl"],[localize "STR_HSIM_CREDITS_ROLE12"]],
		[["Jiří Wainar"],[localize "STR_HSIM_CREDITS_ROLE28"]],
		[["František Novák"],[localize "STR_HSIM_CREDITS_ROLE29"]],
		[["Vojtěch Hladík"],[localize "STR_HSIM_CREDITS_ROLE29"]],
		[["Jakub Šimek"],[localize "STR_HSIM_CREDITS_ROLE29"]],
		[["Jan 'Řrřola' Kadlec"],[localize "STR_HSIM_CREDITS_ROLE29"]],
		[["Ondřej Španěl"],[localize "STR_HSIM_CREDITS_ROLE29"]],
		[["Jiří Martínek"],[localize "STR_HSIM_CREDITS_ROLE29"]],
		[["Lukáš Miláček"],[localize "STR_HSIM_CREDITS_ROLE27"]],
		[["Lukáš Haládik"],[localize "STR_HSIM_CREDITS_ROLE13", localize "STR_HSIM_CREDITS_ROLE41"]],
		[["Miroslav Horváth"],[localize "STR_HSIM_CREDITS_ROLE7"]],
		[["Thomas Ryan"],[localize "STR_HSIM_CREDITS_ROLE28"]],
		[["Marek Španěl"],[localize "STR_HSIM_CREDITS_ROLE27"]],
		[["Mário Kurty"],[localize "STR_HSIM_CREDITS_ROLE9"]], 
		[["Leoš Sikora"],[localize "STR_HSIM_CREDITS_ROLE31"]],
		[["Adam Franců"],[localize "STR_HSIM_CREDITS_ROLE31"]],
		[["Peter Nespešný"],[localize "STR_HSIM_CREDITS_ROLE31"]],
		[["Jan Pražák"],[localize "STR_HSIM_CREDITS_ROLE30"]],
		[["Jan Hovora"],[localize "STR_HSIM_CREDITS_ROLE30"]],
		[["Tomáš Pavlis"],[localize "STR_HSIM_CREDITS_ROLE30"]],
		[["Jan Šarbort"],[localize "STR_HSIM_CREDITS_ROLE30"]],
		[["Miroslav Jersenský"],[localize "STR_HSIM_CREDITS_ROLE30"]],
		[["Miroslav Tkadlec"],[localize "STR_HSIM_CREDITS_ROLE30"]],
		[["Lubor Černý"],[localize "STR_HSIM_CREDITS_ROLE30"]],
		[["Roman 'Gašpo' Gašperík"],[localize "STR_HSIM_CREDITS_ROLE30"]],
		[["Štěpán Kment"],[localize "STR_HSIM_CREDITS_ROLE32"]],
		[["Karel Taufman"],[localize "STR_HSIM_CREDITS_ROLE32"]],
		[["Paweł Smolewski"],[localize "STR_HSIM_CREDITS_ROLE32"]],
		[["Jakub Horyna"],[localize "STR_HSIM_CREDITS_ROLE12"]],
		[["Ondřej Matějka"],[localize "STR_HSIM_CREDITS_ROLE14", localize "STR_HSIM_CREDITS_ROLE41"]],
		[["Dan Brown"],[localize "STR_HSIM_CREDITS_ROLE15", "Stranger"]],
		[["Jan Hlavatý"],[localize "STR_HSIM_CREDITS_ROLE16"]],

		//--- Facilities management
		[
			[
				"Daniela Feltová",
				"Karel Kverka"
			],
			[localize "STR_HSIM_CREDITS_ROLE17"]
		],

		//--- Bohemia Interactive Brno
		[
			[
				"Lukáš Bábíček",
				"Ivan Buchta",
				"Pavel Guglava",
				"Lukáš Gregor"
			],
			["Bohemia Interactive Brno"]
		],

		[
			[
				"Jan Mareček",
				"Daniel Musil",
				"Zdeněk Pavlík"
			],
			["Bohemia Interactive Brno"]
		],

		//--- Bohemia Interactive Simulations
		[
			[
				"Adam Boyes",
				"Jakub Červený",
				"Mark Dzulko",
				"Radim Halíř"
			],
			["Bohemia Interactive Simulations"]
		],
		[
			[
				"Tomáš Kuklík",
				"Markus Kurzawa",
				"Earl Laamanen"
			],
			["Bohemia Interactive Simulations"]
		],
		[
			[
				"Mark Lacey",
				"Chad Lion",
				"Vladimír Nejedlý"
			],
			["Bohemia Interactive Simulations"]
		],

		[
			[
				"Eamonn Richardt",
				"Keijo 'Kegetys' Ruotsalainen",
				"Enrico Turri",
				"Tomáš Velebný"
			],
			["Bohemia Interactive Simulations"]
		],

		//--- Bohemia Interactive Praha
		[
			[
				"Michal Harangozó",
				"Barbora Havlíčková",
				"Jiří Jakubec",
				"Jan Kunt"
			],
			["Bohemia Interactive Praha"]
		],
		[
			[
				"Jan Libich",
				"Jervant Malakjan",
				"Pavel Medek",
				"Markéta Novotná"
			],
			["Bohemia Interactive Praha"]
		],
		[
			[
				"Slavomír Pavlíček",
				"Miluše Pavlíčková",
				"Monika Růžičková"
			],
			["Bohemia Interactive Praha"]
		],

		[
			[
				"Gabriela Šeršeňová",
				"Paul R. Statham",
				"Ota Vrťátko"
			],
			["Bohemia Interactive Praha"]
		],

		//--- Testers
		[
			[
				"Lukáš Čanda",
				"Filip Čort",
				"Šárka Hatašová",
				"Jan Hauer"
			],
			[localize "STR_HSIM_CREDITS_ROLE39"]
		],
		[
			[
				"Richard Kinter",
				"Matej Klapáč",
				"David Komínek",
				"Michal Král"
			],
			[localize "STR_HSIM_CREDITS_ROLE39"]
		],
		[
			[
				"Jiří Kunt",
				"Nikolas Rašín",
				"Michal Šodek",
				"Ondřej Škaroupka"
			],
			[localize "STR_HSIM_CREDITS_ROLE39"]
		],

		//--- Voice actors
		[["Guy Roberts"],[localize "STR_HSIM_CREDITS_ROLE33", "Tom Larkin"]],
		[["Jeff Smith"],[localize "STR_HSIM_CREDITS_ROLE33", "Joseph Larkin", localize "STR_HSIM_CREDITS_ROLE19"]],
		[["Lucy Fillery"],[localize "STR_HSIM_CREDITS_ROLE33", "Michelle Carmichael", localize "STR_HSIM_CREDITS_ROLE19"]],
		[["Brian Caspe"],[localize "STR_HSIM_CREDITS_ROLE33", "Andrew Craymer", "Sam Nichols", localize "STR_HSIM_CREDITS_ROLE19"]],
		[["Domingos Correia"],[localize "STR_HSIM_CREDITS_ROLE33", "Paul Kelly", "Garry Pierce", localize "STR_HSIM_CREDITS_ROLE19"]],
		[["Jim High"],[localize "STR_HSIM_CREDITS_ROLE33", "William R.J. Haydon", "Brian Frost", localize "STR_HSIM_CREDITS_ROLE19"]],
		[["Robert Polo"],[localize "STR_HSIM_CREDITS_ROLE33", "Howard Maddox", "Don Kinsley", localize "STR_HSIM_CREDITS_ROLE19"]],
		[["Jessica Boone"],[localize "STR_HSIM_CREDITS_ROLE33", "Maggie Townsend", localize "STR_HSIM_CREDITS_ROLE19"]],

		//--- External world design
		[
			[
				"Lukas Fuhrer",
				"Michael Emmerich"
			],
			[localize "STR_HSIM_CREDITS_ROLE34"]
		],

		//--- Consultants
		[["Petr 'Čerčil' Černý"],[localize "STR_HSIM_CREDITS_ROLE35"]],
		[["Michael Miller"],[localize "STR_HSIM_CREDITS_ROLE35"]],
		[["Adam Moore"],[localize "STR_HSIM_CREDITS_ROLE35"]],
		[["Tristan Heath"],[localize "STR_HSIM_CREDITS_ROLE35"]], 
		[[localize "STR_HSIM_CREDITS_ROLE26"],[localize "STR_HSIM_CREDITS_ROLE37", "http://www.mdvrt.cz/"]], 
		[["Daniel Tuček"],["DSA a.s.", "http://www.dsa.cz/"]], 
		[["Petr Tuček"],["AVIATIK s.r.o.", "http://www.aviatik.cz/"]], 
		[["Miroslav Rohel"],["F-Air s.r.o."]], 
		[["Jiří Proučil"],[localize "STR_HSIM_CREDITS_ROLE38", "http://www.hyperstavebniny.cz/"]], 

		//--- Focus Testers
		[
			[
				"Michal Fousek",
				"Gabriel Haládik",
				"Vladislav Jančík",
				"Martin Jaroš"
			],
			[localize "STR_HSIM_CREDITS_ROLE23"]
		],
		[
			[
				"Michal Kloda",
				"Karel Kříž",
				"Eva Mořická",
				"Petr Poselt"
			],
			[localize "STR_HSIM_CREDITS_ROLE23"]
		],

		[
			[
				"Michal Smrž",
				"Matouš Soukenka",
				"Dagmar Vomlelová",
				"Martin Zábranský"
			],
			[localize "STR_HSIM_CREDITS_ROLE23"]
		],

		//--- Community Management
		[["David Foltyn"],[localize "STR_HSIM_CREDITS_ROLE42"]], 

		//--- Special Thanks
		[["RTDynamics"],[localize "STR_HSIM_CREDITS_ROLE22"]], 
		[["Marcel Kica"],[localize "STR_HSIM_CREDITS_ROLE22"]], 
		[["Jiří Kašný"],[localize "STR_HSIM_CREDITS_ROLE22"]], 
		[["David Novotný"],[localize "STR_HSIM_CREDITS_ROLE22"]], 
		[[localize "STR_HSIM_CREDITS_ROLE25"],[localize "STR_HSIM_CREDITS_ROLE22"]]
	];

	with uinamespace do {
		disableSerialization;
		_display = uinamespace getvariable "Hsim_RscCredits";
		BIS_fnc_credits_H_display = _display;

		BIS_fnc_credits_H_music = [] spawn {
			0 fademusic 0.5;
			playmusic "Electronic_Track04_H";
			_duration = getnumber (configfile >> "cfgmusic" >> "Electronic_Track04_H" >> "duration");
			sleep (_duration - 5);
			5 fademusic 0;		
			sleep 5;
			playmusic ["Electronic_Track02_H",281-68];
			5 fademusic 0.5;
		};

		//--- Background
		_ctrlSky = _display displayctrl 1000;
		_ctrlSky ctrlsetbackgroundcolor [0.3,0.5,0.8,1];
		_ctrlSky ctrlsetposition [safezoneXAbs,safezoneY,safezoneWAbs,safezoneH];
		_ctrlSky ctrlcommit 0;

		_ctrlBlackLeft = _display displayctrl 9098;
		_ctrlBlackLeft ctrlsetbackgroundcolor [0,0,0,1];
		_ctrlBlackLeft ctrlsetposition [safezoneX - 10,safezoneY,10,safezoneH];
		_ctrlBlackLeft ctrlcommit 0;

		_ctrlBlackRight = _display displayctrl 9099;
		_ctrlBlackRight ctrlsetbackgroundcolor [0,0,0,1];
		_ctrlBlackRight ctrlsetposition [safezoneX + safezoneW,safezoneY,10,safezoneH];
		_ctrlBlackRight ctrlcommit 0;

		//--- Order
		_ctrlOrder = _display displayctrl 1199;
		_ctrlOrder ctrlsetstructuredtext parsetext ("<t align='center'>" + "(" + localize "str_hsim_bis_fnc_credits_h_order" + ")" + "</t>");
		_ctrlOrder ctrlsetposition [safezoneX,safezoneY + safezoneH - 0.05,safezoneW,0.05];
		_ctrlOrder ctrlcommit 0;
		[_ctrlOrder] spawn {disableSerialization; sleep 10; (_this select 0) ctrlsetfade 1; (_this select 0) ctrlcommit 1};

		//--- Sun
		_ctrlSun = _display displayctrl 1300;
		_ctrlSun ctrlsettext "DZ\ui\data\GUI\Rsc\RscDisplayArcadeMap\clear_ca.paa";
		_ctrlSun ctrlsettextcolor [1,1,0,1];
		_ctrlSun ctrlsetposition [safezoneX,safezoneY,safezoneW * 0.15,safezoneH * 0.15];
		_ctrlSun ctrlcommit 0;

		//--- Arise!
		_ctrlROFL_Y = 0.4 * safezoneH + safezoneY;
		_ctrlROFL ctrlsetposition [_ctrlROFL_X,_ctrlROFL_Y,_ctrlROFL_W,_ctrlROFL_H];
		_ctrlROFL ctrlcommit 3;

		//--- EH - keydown
		BIS_fnc_credits_H_keydown = {
			_key = _this select 1;
			_display = BIS_fnc_credits_H_display;

			//--- Escape
			if (_key == 1) exitwith {

			};

			_ctrlROFL = _display displayctrl 1301;
			_ctrlROFLPos = ctrlposition _ctrlROFL;

			//--- Left
			_keysLeft = actionKeys "HeliCyclicLeft";
			if (_key in _keysLeft) then {
				_ctrlROFLPos set [0,((_ctrlROFLPos select 0) - 0.01 * safezoneW) max (safezoneX)];
			};

			//--- Right
			_keysRight = actionKeys "HeliCyclicRight";
			if (_key in _keysRight) then {
				_ctrlROFLPos set [0,((_ctrlROFLPos select 0) + 0.01 * safezoneW) min (safezoneX + safezoneW - (_ctrlROFLPos select 2))];
			};

			//--- Up
			_keysUp = actionKeys "HeliCyclicForward";
			if (_key in _keysUp) then {
				_ctrlROFLPos set [1,((_ctrlROFLPos select 1) - 0.01 * safezoneH) max (safezoneY)];
			};

			//--- Down
			_keysDown = actionKeys "HeliCyclicBack";
			if (_key in _keysDown) then {
				_ctrlROFLPos set [1,((_ctrlROFLPos select 1) + 0.01 * safezoneH) min (safezoneY + safezoneH - (_ctrlROFLPos select 3))];

			};

			if (ctrlcommitted _ctrlROFL) then {
				_ctrlROFL ctrlsetposition _ctrlROFLPos;
				_ctrlROFL ctrlcommit 0;
			};
		};
		uinamespace setvariable ["BIS_fnc_credits_H_keydown",BIS_fnc_credits_H_keydown];
		_displayMain displayaddeventhandler ["keydown","with uinamespace do {_this call BIS_fnc_credits_H_keydown;};"];

		//--- Names
		104 cuttext ["","black in",1];
		_c = 0;
		_cMod = 10;
		_delay = 18+2; //--- Travel time from left to right
		_ctrlText = controlnull;
		for "_n" from 0 to (count _names - 1) do {
			_random = floor random (count _names);
			_nameArray = _names select _random;
			_names set [_random,-1];
			_names = _names - [-1];

			_name = _nameArray select 0;
			_functions = _nameArray select 1;

			_cloudParams = [_nameArray,2,[]] call bis_fnc_paramIn;
			_cloudText = [_cloudParams,0,"DZ\ui\data\GUI\Rsc\RscDisplayArcadeMap\overcast_ca.paa"] call bis_fnc_paramIn;
			_cloudColor = [_cloudParams,1,[1,1,1]] call bis_fnc_paramIn;

			_text = "";
			{
				_text = _text + "<t size='2'>" + _x + "</t><br />";
			} foreach _name;
			_text = _text + "<t color='#aaccff'>";
			{
				_text = _text + _x + "<br />";
			} foreach _functions;
			_text = "<t align='center'>" + _text + "</t></t>";
			_textLines = 2 + count _functions;

			//--- Name
			_ctrlText = _display displayctrl (/*1100*/9000 + (_c % _cMod));
			_ctrlText ctrlsetstructuredtext parsetext _text;
			_ctrlText_W = 0.3 * safezoneW;
			_ctrlText_H = 1;//(((1 / 1.2 * (safezoneW / safezoneH)) / 20) * 0.7) * _textLines;
			_ctrlText_X = (1) * safezoneW + safezoneX;
			_ctrlText_Y = (random safezoneH min ((safezoneH / 2) + safezoneY));
			_ctrlText ctrlsetposition [_ctrlText_X,_ctrlText_Y,_ctrlText_W,_ctrlText_H];
			_ctrlText ctrlcommit 0;

			//--- Cloud
			_ctrlCloud = _display displayctrl (1302 + (_c % _cMod));
			_ctrlCloud ctrlsettext _cloudText;
			_ctrlCloud ctrlsettextcolor (_cloudColor + [1]);
			_ctrlCloud_W = _ctrlText_W;
			_ctrlCloud_H = _ctrlText_W / 3 * (1 + random 1);//_ctrlText_H * 4;
			_ctrlCloud_X = _ctrlText_X;
			_ctrlCloud_Y = _ctrlText_Y - _ctrlCloud_H * 0.8;
			_ctrlCloud ctrlsetposition [_ctrlCloud_X,_ctrlCloud_Y,_ctrlCloud_W,_ctrlCloud_H];
			_ctrlCloud ctrlcommit 0;

			//------------------------------------------------------------------------------
			//--- Move left
			_ctrlText_X = safezoneX - _ctrlText_W;
			_ctrlText ctrlsetposition [_ctrlText_X,_ctrlText_Y,_ctrlText_W,_ctrlText_H];
			_ctrlText ctrlcommit _delay;

			_ctrlCloud_X = _ctrlText_X;
			_ctrlCloud ctrlsetposition [_ctrlCloud_X,_ctrlCloud_Y,_ctrlCloud_W,_ctrlCloud_H];
			_ctrlCloud ctrlcommit _delay;

			_time = time;
			waituntil {
				sleep 0.1;
				_ctrlSun ctrlsettextcolor [1,1,0,0.7 + random 0.3];
				(time - _time) > (_delay / 5)
			};
			_c = _c + 1;

		};
		//waituntil {ctrlcommitted _ctrlText};
		sleep (_delay / 2);

		//--- Final logo
		_ctrlLogo = _display displayctrl (1302 + (_c % _cMod));
		_ctrlLogo ctrlsettext "DZ\ui\data\Logos\bi_ca.paa";
		_ctrlLogo ctrlsettextcolor [1,1,1,1];
		_ctrlLogo_W = 0.5 * safezoneW;
		_ctrlLogo_H = 0.5 * safezoneH;
		_ctrlLogo_X = safezoneW + safezoneX;
		_ctrlLogo_Y = 0.5 - _ctrlLogo_H / 2;
		_ctrlLogo ctrlsetposition [_ctrlLogo_X,_ctrlLogo_Y,_ctrlLogo_W,_ctrlLogo_H];
		_ctrlLogo ctrlcommit 0;

		_ctrlLogo_X = _ctrlText_X;
		_ctrlLogo ctrlsetposition [0.5 - (_ctrlLogo_W / 2),_ctrlLogo_Y,_ctrlLogo_W,_ctrlLogo_H];
		_ctrlLogo ctrlcommit (_delay / 2);

		for "_i" from 0 to 10 do {
			sleep 0.1;
			_ctrlROFL ctrlsetfade 0;
			_ctrlROFL ctrlcommit 0;
			sleep 0.1;
			_ctrlROFL ctrlsetfade 1;
			_ctrlROFL ctrlcommit 0;
		};

		waituntil {ctrlcommitted _ctrlLogo};
		sleep 3;

		[_displayMain,0] call bis_fnc_credits_H;
	};

} else {
	//--- End
	104 cuttext ["","black out",3];
	sleep 3;
	102 cuttext ["","plain"];
	103 cuttext ["","plain"];
	104 cuttext ["","plain"];

	terminate BIS_fnc_credits_H_music;

	BIS_fnc_credits_H_display = nil;
	BIS_fnc_credits_H_keydown = nil;
	BIS_fnc_credits_H_music = nil;
};
