//Create static camera.
/*private ["_camera"];
_camera = "camera" camCreate [(position player select 0), (position player select 1) + 1, 1.5];
_camera camSetTarget [(position player select 0), (position player select 1) + 200, 1.5];
_camera camSetFov 0.7;
_camera cameraEffect ["INTERNAL", "Back"];
_camera camCommit 0;
*/
disableSerialization;

//Dialog on which to display the animated letters. Defines 60 controls as a pool to use.
private ["_delay", "_dlg", "_line"/*, "_display"*/];
if ((count _this) > 0) then 
{
	_delay = _this select 0;
} 
else 
{
	_delay = 0;
};

_dlg = createDialog "RscAnimatedLetters";
setMousePosition [-1, -1]; //Hide the cursor, a bit.

BIS_Credits_Counter = 0;
BIS_Credits_Done = false;

_line = 0;
/*_display = findDisplay 998877;

_ctrlBohemia = _display displayCtrl 900;
_ctrlBohemia ctrlSetFade 1;
_ctrlBohemia ctrlCommit 0;

_ctrlCopyrightBoh = _display displayCtrl 901;
_ctrlCopyrightBoh ctrlSetFade 1;
_ctrlCopyrightBoh ctrlCommit 0;

_ctrlCopyrightVorb = _display displayCtrl 902;
_ctrlCopyrightAL = _display displayCtrl 903;
_ctrlCopyrightAL ctrlSetFade 1;
_ctrlCopyrightAL ctrlCommit 0;

_ctrlCopyrightSpeex = _display displayCtrl 904;
_ctrlCopyrightSpeex ctrlSetFade 1;
_ctrlCopyrightSpeex ctrlCommit 0;

_ctrlCopyrightSpy = _display displayCtrl 905;
_ctrlCopyrightSpy ctrlSetFade 1;
_ctrlCopyrightSpy ctrlCommit 0;


_ctrlCopyrightVorb ctrlSetFade 1;
_ctrlCopyrightVorb ctrlCommit 0;
_ctrlTeam = _display displayCtrl 666;
_ctrlTeam ctrlSetFade 1;
_ctrlTeam ctrlCommit 0;

_ctrlBohemia ctrlSetFade 0;
_ctrlBohemia ctrlCommit 1;
sleep 2;
_ctrlBohemia ctrlSetFade 1;
_ctrlBohemia ctrlCommit 1;
sleep 2;

_ctrlTeam = _display displayCtrl 666;
//_ctrlTeam ctrlSetText "Team";

_ctrlTeam ctrlSetFade 1;
_ctrlTeam ctrlCommit 0;
sleep 1;

_ctrlTeam ctrlSetFade 0;
_ctrlTeam ctrlCommit 1;
sleep 1;

_ctrlTeam ctrlSetFade 1;
_ctrlTeam ctrlCommit 5;*/

sleep _delay;

//Credits director, controls the flow of what is shown.
//Pass: array of strings with single characters, animation mode.
private ["_stdPath"];
_stdPath = "dz\data\data\scripts\credits\";
//"

private ["_names"];
_names = 
[
	"Jan Absolin",
	"Mark Allen",
	"Přemysl Aubrecht",
	"Lukáš Bábíček",
	"Radek Barr",
	"Vilém Beneš",
	"František Bidlo",
	"Amarjit Bilkhu",
	"Georg Bleiss",
	"Martin Boček",
	"Andrej Boleslavský",
	"Alan Boyle",
	"Ivan Buchta",
	"Tomáš Bujňák",
	"Alan Bunker",
	"James Carey",
	"Aleš Cemper",
	"Miloslav Cinko",
	"Adam Cirok",
	"Steve Clark",
	"Mark Clemens",
	"Dan Cooke",
	"Carsten Cordes",
	"David Cupan",
	"Lukáš Čanda",
	"Filip Čort",
	//"Filip Čort",
	"Milan Dědic",
	"Mamadou Diavando",
	"Martin Dlask",
	"Viktor Dobiáš",
	"Gunther Doe",
	"Filip Doksanský",
	"Tomáš Dostál",
	"Pavel Drozhzhin",
	"Štefan Ďurmek",
	"Daniel Dvořák",
	"Ján Dušek",
	"Mark Dzulko",
	"Quirin Eberle",
	"Vojtěch Efler",
	"Michael Emmerich",
	"Libor Faltýnek",
	"Peter Fehér",
	"Daniela Feltová",
	"David Foltýn",
	"Lukas Fuhrer",
	"Yuriy Garazha",
	"Roman Gašperík",
	"Mark Gill",
	"Andrew Gluck",
	"Magdaléna Gracerová – Chrzová",
	"Silvana Greenfield",
	"Lukáš Gregor",
	"Pavel Guglava",
	"Morten Gundersen",
	"Lukáš Haládik",
	"Radim Halíř",
	"Charlotte Hall",
	"Evan Hanau",
	"Michal Harangozó",
	"Matthew Hardwick",
	"Alexander Harlander",
	"Jan Hauer",
	"Tomáš Havlík",
	"Morris Hebecker",
	"James High",
	"Marvin Hill",
	"Vojtěch Hladík",
	"Jan Hlavatý",
	"Martin Hofmann",
	"Tomáš Holčák",
	"Martin Horák",
	"Miroslav Horváth",
	"Jakub Horyna",
	"Pavel Houska",
	"Jan Hovora",
	"Ian Howe",
	"Martin Hruška",
	"Petr Chalupský",
	"Sharad Chaturvedi",
	"Diop Cherif",
	"Magdaléna B. Ištoková",
	"Jiří Jakubec",
	"Ryan James",
	"Anna Kadlecová",
	"Zbyšek Kalina",
	"Evgeny Karpenko",
	"Jaroslav Kašný",
	//"Jaroslav Kašný",
	"Kevin Killoran",
	"Štěpán Kment",
	"Štěpán Končelík",
	"Kamil Kopecký",
	"Hana Kotrčová",
	"Todd Kramer",
	"Petr Krejčík",
	"Silvia Krejzková",
	"Juraj Krnáč",
	"Jan Kroneisel",
	"Oldřich Kříž",
	"Martin Křížek",
	"Jan Kunt",
	"Zdeněk Kupka",
	"Mário Kurty",
	"Karel Kverka",
	"Earl Laamanen",
	"Joris-Jan van 't Land",
	"Jan Látal",
	"Ivana Lecká",
	"Ján Lenárd",
	"Jan Libich",
	"Denis Lyons",
	"Marián Maár",
	"Alex Mage",
	"Jan Mareček",
	//"Jan Mareček",
	"Jiří Martínek",
	"Todd Massie",
	"Mirek Mašate",
	"Karel Matějka",
	"Ondřej Matějka",
	"Václav Mazaný",
	"Mike Melvin",
	"Rebecca Meyer",
	"Ondřej Miller",
	"Alison Mitchell",
	"Peter Morrison",
	"Karel Mořický",
	"Vlastimil Müller",
	"Sebastian Müller",
	"Dan Musil",
	"Vladimír Nejedlý",
	"Otakar Nieder",
	"Ondřej Novák",
	"František Novák",
	"Tomáš Novák",
	"David Novotný",
	"Pavel Očovaj",
	"Kendrick Ong",
	"Zdeněk Opletal",
	"Bart van Paassen",
	"Slavomír Pavlíček",
	"Miluše Pavlíčková",
	"Zdeněk Pavlík",
	"Tomáš Pavlis",
	"Chiara Pasquini",
	"Radim Pech",
	"Tomáš Pecha",
	"Petr Pechar",
	"Michal Pekárek",
	"Ralph Pitt-Stanley",
	"Ondřej Plechata",
	"Martin Polák",
	"Tomáš Pondělík",
	"Jiří Pospíšil",
	"Franck Poulain",
	"Jan Pražák",
	"Alex Price",
	"Bronislav Prosecký",
	"Jörg Puls",
	"Jaromír Punčochář",
	"Sasha Pushanka",
	"Andrea Quinteri",
	"Martin Rác",
	"Josef Rác",
	"Petr Rak",
	"Jana Raudenská",
	"Václav Rolník",
	"Patrick Roza",
	"Monika Růžičková",
	"Michal Říha",
	"Petr Sedláček",
	"Bohumil Semerák",
	"Leoš Sikora",
	"Eduardo Simioni",
	"Kateřina Skalická",
	"Jan Sluka",
	"Lukáš Soukenka",
	"Vladimír Soukup",
	"Lara Spinazzola",
	"Eike Stamm",
	"Paul R. Statham",
	"Andreas Steinhorst",
	"Mark Stevens",
	"Nicole Straten",
	"Martin Sulák",
	"Hynek Svatoš",
	"Marek Svitek",
	"Jakub Šimek",
	"Marek Španěl",
	"Ondřej Španěl",
	"Stefano Stalla",
	"Pavel Tomeš",
	"Andrej Török",
	"Alexey Trushin",
	"Christopher Tucker",
	"Enrico Turri",
	"Marek Uhlíř",
	"Martin Valášek",
	"Ondřej Valášek",
	"Nadja Van Rooyen",
	"Martin Vaňo",
	"Andrey Varlamov",
	"Michal Varnuška",
	"Lukáš Veselý",
	"Zdeněk Vespalec",
	"Petr Víšek",
	"Radim Vítek",
	"Josef Vlach",
	"Johannes Wagner",
	"David Wágner",
	"David Walker",
	"Edmund Watts",
	"Andrew Wensley",
	"Jan Weyrostek",
	"Gail Whitmore",
	"Scott Williams",
	"Tim Woodley",
	"Miloš Zajíc",
	"David Zapletal",
	"Mariusz A. Zelmanski",
	"Josef Zemánek",
	"3D Brigade",
	"Eastern Eggs",
	"EC-Interactive",
	"Fanatic Games",
	"Game Armada",
	"Kentaur Club",
	"Přerov AFB",
	"Shack Tactical"
];

_names = _names + ["", "", "", "", "", "", ""]; //Needed to make the last page fade out.

private ["_timeNow"];
_timeNow = time;
for "_i" from 0 to ((count _names) - 1) do 
{
	if (_line == 7) then 
	{
		waitUntil {(time - _timeNow) >= 16};
		
		_line = 0;
		BIS_Credits_Counter = 0;
		_timeNow = time;
	};
	
	[_names select _i, _line] execVM (_stdPath + "animateLetters.sqf");
	sleep ((30 * 0.06) + 0.5);
	
	_line = _line + 1;
};

//sleep 16;

/*_ctrlCopyrightBoh ctrlSetFade 0;
_ctrlCopyrightBoh ctrlCommit 1;
sleep 2;

_ctrlCopyrightBoh ctrlSetFade 1;
_ctrlCopyrightBoh ctrlCommit 1;
sleep 2;

_ctrlCopyrightVorb ctrlSetFade 0;
_ctrlCopyrightVorb ctrlCommit 1;
sleep 2;

_ctrlCopyrightVorb ctrlSetFade 1;
_ctrlCopyrightVorb ctrlCommit 1;
sleep 2;

_ctrlCopyrightAL ctrlSetFade 0;
_ctrlCopyrightAL ctrlCommit 1;
sleep 2;

_ctrlCopyrightAL ctrlSetFade 1;
_ctrlCopyrightAL ctrlCommit 1;
sleep 2;

_ctrlCopyrightSpeex ctrlSetFade 0;
_ctrlCopyrightSpeex ctrlCommit 1;
sleep 2;

_ctrlCopyrightSpeex ctrlSetFade 1;
_ctrlCopyrightSpeex ctrlCommit 1;
sleep 2;

_ctrlCopyrightSpy ctrlSetFade 0;
_ctrlCopyrightSpy ctrlCommit 1;
sleep 2;
_ctrlCopyrightSpy ctrlSetFade 1;
_ctrlCopyrightSpy ctrlCommit 1;
sleep 2;*/

BIS_Credits_Done = true;

truetrue