::ModRangedCombatRework.HooksMod.hook("scripts/skills/perks/perk_legend_muscularity", function ( q )
{
	function onUpdate( _properties )
	{
		local actor = this.getContainer().getActor();
		local item = actor.getMainhandItem();
		if (item.isItemType(this.Const.Items.ItemType.RangedWeapon) && item.isWeaponType(this.Const.Items.WeaponType.Bow))
		{
			local fatigue = actor.getFatigue();
			_properties.DamageRegularMin += this.Math.min(50, this.Math.floor(fatigue * 0.1));
			_properties.DamageRegularMax += this.Math.min(50, this.Math.floor(fatigue * 0.1));
			return;
		}
		else if (!_skill.isRanged() || (item != null && item.isItemType(this.Const.Items.ItemType.Weapon) && item.isWeaponType(this.Const.Items.WeaponType.Throwing)))
		{
			local bodyHealth = this.getContainer().getActor().getHitpoints();
			_properties.DamageRegularMin += this.Math.min(50, this.Math.floor(bodyHealth * 0.1));
			_properties.DamageRegularMax += this.Math.min(50, this.Math.floor(bodyHealth * 0.1));
		}
		
	}
});