class CfgPatches
{
	class DZ_ModuleZ
	{
		units[]={};
		weapons[]={};
		requiredVersion=0.1;
		requiredAddons[]={};
	};
};
class cfgBody
{
	class Head
	{
		hitPoint="HitHead";
		inventorySlots[]=
		{
			"headgear",
			"eyewear",
			"mask"
		};
	};
	class Neck: Head
	{
	};
	class Neck1: Head
	{
	};
	class Chest
	{
		hitPoint="HitBody";
		inventorySlots[]=
		{
			"vest",
			"body",
			"back",
			"gloves"
		};
	};
	class Spine: Chest
	{
		hitPoint="HitSpine";
	};
	class Spine1: Chest
	{
	};
	class Spine2: Chest
	{
	};
	class Spine3: Chest
	{
	};
	class LeftArm
	{
		hitPoint="HitHands";
		inventorySlots[]=
		{
			"body"
		};
	};
	class LeftShoulder: LeftArm
	{
		hitPoint="HitShoulder";
	};
	class LeftArmRoll: LeftArm
	{
	};
	class LeftForeArm: LeftArm
	{
	};
	class LeftForeArmRoll: LeftArm
	{
	};
	class LeftHand: LeftArm
	{
	};
	class RightArm
	{
		hitPoint="HitHands";
		inventorySlots[]=
		{
			"body"
		};
	};
	class RightShoulder: RightArm
	{
		hitPoint="HitShoulder";
	};
	class RightArmRoll: RightArm
	{
	};
	class RightForeArm: RightArm
	{
	};
	class RightForeArmRoll: RightArm
	{
	};
	class RightHand: RightArm
	{
	};
	class Pelvis
	{
		hitPoint="HitLegs";
		inventorySlots[]=
		{
			"legs"
		};
	};
	class LeftLeg
	{
		hitPoint="HitLegs";
		inventorySlots[]=
		{
			"legs"
		};
	};
	class LeftUpLeg: LeftLeg
	{
	};
	class LeftUpLegRoll: LeftLeg
	{
	};
	class LeftLegRoll: LeftLeg
	{
	};
	class RightLeg
	{
		hitPoint="HitLegs";
		inventorySlots[]=
		{
			"legs"
		};
	};
	class RightUpLeg: RightLeg
	{
	};
	class RightUpLegRoll: RightLeg
	{
	};
	class RightLegRoll: RightLeg
	{
	};
	class LeftFoot
	{
		hitPoint="HitFeet";
		inventorySlots[]=
		{
			"feet"
		};
	};
	class LeftToeBase: LeftFoot
	{
	};
	class RightFoot
	{
		hitPoint="HitFeet";
		inventorySlots[]=
		{
			"feet"
		};
	};
	class RightToeBase: RightFoot
	{
	};
};
class cfgNotifications
{
	class Sickness
	{
	};
	class Bleeding
	{
	};
	class Hunger
	{
	};
	class Thirst
	{
	};
};
class cfgCharacterCreation
{
	format="SurvivorParts%1%2";
	gender[]=
	{
		"Female",
		"Male"
	};
	race[]=
	{
		"African",
		"Latino",
		"Asian",
		"White"
	};
	skin[]=
	{
		"Very Dark",
		"Dark",
		"Medium",
		"Light"
	};
	top[]=
	{
		"TShirtBeige",
		"TShirtBlack",
		"TShirtBlue",
		"TShirtGreen",
		"TShirtRed",
		"TShirtWhite",
		"TShirtGrey"
	};
	bottom[]=
	{
		"Jeans_Black",
		"Jeans_BlueDark",
		"Jeans_Blue",
		"Jeans_Brown",
		"Jeans_Green",
		"Jeans_Grey"
	};
	shoe[]=
	{
		"AthleticShoes_Black",
		"AthleticShoes_Blue",
		"AthleticShoes_Brown",
		"AthleticShoes_Green",
		"AthleticShoes_Grey"
	};
};
class PreloadVehicles
{
	class SurvivorPartsMaleWhite
	{
		loadStyle=1;
	};
	class SurvivorPartsMaleAsian
	{
		loadStyle=1;
	};
	class SurvivorPartsMaleLatino
	{
		loadStyle=1;
	};
	class SurvivorPartsMaleAfrican
	{
		loadStyle=1;
	};
	class SurvivorPartsFemaleWhite
	{
		loadStyle=1;
	};
	class SurvivorPartsFemaleAsian
	{
		loadStyle=1;
	};
	class SurvivorPartsFemaleLatino
	{
		loadStyle=1;
	};
	class SurvivorPartsFemaleAfrican
	{
		loadStyle=1;
	};
};

class CfgSounds
{
    class introSong
    {
    name="introSong";
    sound[]={"dz\modulesDayz\introSong.ogg",0.5,1};
    titles[] = {};
    };
};

class cfgCharacterScenes
{
	class ChernarusPlus
	{
		class duskcastle1
		{
			target[]={-55262.371,86687.633,-11729.3};
			position[]={10255.49,12048.26,0.85000002};
			fov=0.51099998;
			date[]={3000,6,1,19,11};
			aperture=16;
		};
		class forest1
		{
			target[]={47732.75,94293.633,7079.5698};
			position[]={4929.4102,4186.3901,1.36};
			fov=0.47099999;
			date[]={1998,12,9,9,0};
			aperture=-1;
		};
		class urban1
		{
			target[]={-39951.559,91529.508,2169.1599};
			position[]={5536.4302,2507.53,0.75999999};
			fov=0.47999999;
			date[]={1998,10,1,10,0};
			aperture=48;
		};
		class bridge1
		{
			target[]={-98080.07,-9722.9902,4387.23};
			position[]={1092.16,2282.79,0.64999998};
			fov=0.465;
			date[]={3000,12,1,12,0};
			aperture=-1;
		};
		class swamp1
		{
			target[]={253.13,102111.66,-5170.21};
			position[]={3937.1399,2293.03,0.94999999};
			fov=0.465;
			date[]={3000,12,1,12,0};
			aperture=-1;
		};
		class dawnforest1
		{
			target[]={67424.844,-77935.281,-4371.46};
			position[]={13138.34,5925.6299,1.4299999};
			fov=0.43200001;
			date[]={1998,12,9,7,33};
			aperture=8;
		};
		class duskwoods1
		{
			target[]={-86017.703,-24673.73,3691.6399};
			position[]={9043.75,6172.7202,0.85000002};
			fov=0.47999999;
			date[]={3000,12,1,16,4};
			aperture=12;
		};
		class duskforest1
		{
			target[]={-87264.344,-39427.199,-949.60999};
			position[]={2601.03,4421,0.81};
			fov=0.461;
			date[]={3000,12,2,15,54};
			aperture=18;
		};
		class bridgeday1
		{
			target[]={37100.301,-90998.609,2357.26};
			position[]={1094.1,2264.52,0.82999998};
			fov=0.47799999;
			date[]={3000,12,1,9,20};
			aperture=40;
		};
		class gasstop1
		{
			target[]={18893.23,100359.63,8800.1201};
			position[]={1124.42,2364.9199,0.56999999};
			fov=0.46200001;
			date[]={2013,6,25,19,0};
			aperture=20;
			overcast=0.40000001;
			humidity=0.5;
		};
	};
	class sampleMap
	{
		class default
		{
			target[]={60497.789,-79032.57,-39.779999};
			position[]={2887.0801,2704.8201,1.23};
			fov=0.491;
			date[]={3000,12,1,7,27};
			aperture=18;
		};
	};
	class Namalsk
	{
		class default
		{
			target[]={60497.789,-79032.57,-39.779999};
			position[]={2887.0801,2704.8201,1.23};
			fov=0.491;
			date[]={3000,12,1,7,27};
			aperture=18;
		};
	};
};
