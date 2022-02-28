private["_person","_item"];
/*
	Function to activate a player notification on success of crafting a simple item

	Author: Rocket
*/
_person = 	_this select 0;	
_item = 	_this select 1;
[_person,format['You have crafted %1',displayName _item],'colorAction'] call fnc_playerMessage;