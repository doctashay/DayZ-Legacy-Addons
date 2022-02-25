private["_agent","_uid"];
_agent = _this select 0;
_killer = _this select 1;
_uid = getClientUID(owner _agent);
diag_log format["Player %1 was killed by %2",name _agent, name _killer];
if (DZ_MP_CONNECT) then
{
	_agent call dbSavePlayerPrep;
	dbServerSaveCharacter _agent;
	dbKillCharacter _uid;
};
_agent setVariable ["bleedingsources","[]"];