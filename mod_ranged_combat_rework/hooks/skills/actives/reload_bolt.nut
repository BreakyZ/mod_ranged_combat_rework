::ModRangedCombatRework.HooksMod.hook("scripts/skills/actives/reload_bolt", function( q )
{
	q.onAfterUpdate = @(__original) function( _properties )
	{
		__original();
		this.m.FatigueCostMult = this.m.FatigueCostMult * (1.0 - (this.getContainer().getActor().getFatigue() * 0.001));
	}
});