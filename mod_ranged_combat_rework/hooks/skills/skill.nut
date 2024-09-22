::ModRangedCombatRework.HooksMod.hook("scripts/skills/skill", function(q) {
	q.attackEntity = @(__original) function( _user, _targetEntity, _allowDiversion = true )
	{
		if (isRanged() && !::Tactical.TurnSequenceBar.isActiveEntity(_user))
			_allowDiversion = false; // no astray shot bullshit, too many problems and no way to fix that

		return __original(_user, _targetEntity, _allowDiversion);
	}
});