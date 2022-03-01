/* DayZ Legacy 0.44 */
/* dayz_bulletHit.sqf - Handles camera shake to simulate character pain when hit with a bullet */

private["_commit"];
_commit = 2;
//if (!r_player_unconscious) then {
	"colorCorrections" ppEffectEnable true;"colorCorrections" ppEffectAdjust [1, 1, 0, [1, 1, 1, 0.0], [1, 1, 1, 0.1],  [1, 1, 1, 0.0]];"colorCorrections" ppEffectCommit 0;
	"dynamicBlur" ppEffectEnable true;"dynamicBlur" ppEffectAdjust [2]; "dynamicBlur" ppEffectCommit 0;
	addCamShake [7, 1, 50];
	"colorCorrections" ppEffectAdjust [1, 1, 0, [1, 1, 1, 0.0], [1, 1, 1, 1],  [1, 1, 1, 0.0]];"colorCorrections" ppEffectCommit _commit;
	"dynamicBlur" ppEffectAdjust [0]; "dynamicBlur" ppEffectCommit _commit;
//};