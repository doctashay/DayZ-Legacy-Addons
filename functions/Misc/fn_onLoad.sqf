/*
	Author: Karel Moricky

	Description:
	Register code to be executed after mission load.

	Parameter(s):
	_this:
		CODE
		ARRAY - code with custom arguments in format [CODE,ARG1,ARG2,...]
		NUMBER - remove code of given index

	Returns:
	NUMBER - index of onLoad code
*/

private ["_input","_index"];

_input = _this;

//--- Executed first time
if (isnil "BIS_fnc_onLoad_listCodes") then {
	BIS_fnc_onLoad_listCodes = [];
	BIS_fnc_onLoad_monitor = _this spawn {
		//scriptName "Load Manager";
		private ["_load"];
		while {true} do {

			//--- Wait until load
			_load = [] spawn {
				//scriptName "Load Manager Serialization";
				disableserialization;
				waituntil {false};
			};
			waituntil {scriptdone _load};

			//--- Execute onLoad codes
			_listCodes = +BIS_fnc_onLoad_listCodes; //--- Make it local in case somebody updates the list during load
			{
				if (typename _x == typename []) then {
					(_x select 1) call (_x select 0)
				};
			} foreach _listCodes;
		};
	};
};

_index = switch (typename _input) do {
	case (typename []): {

		//--- Add code with arguments
		_code = [_input,0,{},[{}]] call bis_fnc_param;
		if (typename _code == typename {}) then {
			_index = count BIS_fnc_onLoad_listCodes;
			_args = [_input,1,_index] call bis_fnc_param;
			BIS_fnc_onLoad_listCodes set [_index,[_code,_args]];

			_index
		};
	};
	case (typename {}): {

		//--- Add code without arguments
		_index = count BIS_fnc_onLoad_listCodes;
		BIS_fnc_onLoad_listCodes set [_index,[_input,_index]];
		_index
	};
	case (typename 00): {

		//--- Remove
		if (_input >= 0) then {
			BIS_fnc_onLoad_listCodes set [_input,_input];
		};
		_input
	};
	default {-1}
};

_index