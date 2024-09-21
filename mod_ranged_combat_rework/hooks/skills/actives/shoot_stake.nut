::ModRangedCombatRework.HooksMod.hook("scripts/skills/actives/shoot_stake", function( q )
{
	q.create = @(__original) function()
	{
		__original();
		this.m.MaxRange = 5;
	}

	q.getTooltip = @(__original) function()
	{
		tooltip = __original();

		if (this.getContainer().hasSkill("perk.ballistics"))
		{
			tooltip.push({
				id = 6,
				type = "text",
				icon = "ui/icons/direct_damage.png",
				text = "Up to [color=" + this.Const.UI.Color.PositiveValue + "]+20%[/color] of any damage ignores armor depending on the distance to the target, with the highest bonus in melee and lowest at maximum range"
			});
		}
	}

	q.onAfterUpdate = @(__original) function( _properties )
	{
		__original(_properties);
		this.m.DirectDamageMult = _properties.IsSpecializedInCrossbows ? 0.6 : 0.5;
	}

	q.onAnySkillUsed <- function( _skill, _targetEntity, _properties )
	{
		if (_targetEntity == null)
			return;

		if (_skill == this && this.getContainer().hasSkill("perk.ballistics"))
		{
			local distance = this.getContainer().getActor().getTile().getDistanceTo(_targetEntity.getTile());
			_properties.DamageDirectAdd += 0.25 - (distance * 0.05)
		}
	}
});