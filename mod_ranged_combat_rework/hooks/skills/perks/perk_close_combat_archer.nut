::ModRangedCombatRework.HooksMod.hook("scripts/skills/perks/perk_close_combat_archer", function ( q )
{
	q.create = @(__original) function()
	{
		__original();
		this.m.Type = this.Const.SkillType.Perk | this.Const.SkillType.StatusEffect;
	}

	q.onGetHitFactors = @(__original) function ( _skill, _targetTile, _tooltip )
	{
		local bonus = getBonus() / 100;
		local actor = this.getContainer().getActor();
		local item = actor.getMainhandItem();
		if (_skill.isRanged())
		{
			local actor = this.getContainer().getActor();
			if (_skill.isRanged())
			{
				switch (true)
				{
					case _skill.getID() == "actives.shoot_bolt":
					case _skill.getID() == "actives.shoot_stake":
					case _skill.getID() == "actives.quick_shot":
					case _skill.getID() == "actives.sling_stone":
					case _skill.getID() == "actives.legend_shoot_stone":
					{
						if (actor.getTile().getDistanceTo(_targetEntity.getTile()) <= 4)
							return;
						{
							_tooltip.push({
								id = 1,
								type = "text",
								icon = "ui/tooltips/positive.png",
								text = this.getBonus() + "% more damage \n" + " " + this.getName()
							});
						}
						return;
					}
					case !item.isItemType(this.Const.Items.ItemType.RangedWeapon):
					case !item.isWeaponType(this.Const.Items.WeaponType.Throwing) && !item.isWeaponType(this.Const.Items.WeaponType.Firearm):
						return;
				}
				_tooltip.push({
					id = 1,
					type = "text",
					icon = "ui/tooltips/positive.png",
					text = this.getBonus() + "% more damage \n" + "  " +  this.getName()
				});
			}
		}
	}

	q.onAnySkillUsed = @( __original ) function( _skill, _targetEntity, _properties )
	{
		if (_targetEntity == null)
			return;

		local bonus = getBonus() / 100;
		local actor = this.getContainer().getActor();
		local item = actor.getMainhandItem();

		if (_skill.isRanged())
		{
			switch (true)
			{
				case _skill.getID() == "actives.shoot_bolt":
				case _skill.getID() == "actives.shoot_stake":
				case _skill.getID() == "actives.quick_shot":
				case _skill.getID() == "actives.sling_stone":
				case _skill.getID() == "actives.legend_shoot_stone":
				case actor.getTile().getDistanceTo(_targetEntity.getTile()) <= 4
				{
					_properties.DamageRegularMult *= 1.0 + bonus;
					_properties.DamageArmorMult *= 1.0 + bonus;
					if (actor.getSkills().hasSkill("perk.legend_heightened_reflexes"))
						this.m.ActionPointCost -= 1;
					return;
				}
				case !item.isItemType(this.Const.Items.ItemType.RangedWeapon):
				case !item.isWeaponType(this.Const.Items.WeaponType.Throwing) && item.isWeaponType(this.Const.Items.WeaponType.Firearm):
					return;
			}
			_properties.DamageRegularMult *= 1 + bonus;
			_properties.DamageArmorMult *= 1 + bonus;
		}
	}

	q.getBonus <- function()
	{
		local actor = this.getContainer().getActor()
		local actorProperties = actor.getCurrentProperties();
		local mskillBonus = 0;
		local rdefBonus = 0;

		if (actor.getMainhandItem().isWeaponType(this.Const.Items.WeaponType.Throwing))
		{
			mskillBonus = this.Math.floor(0.3 * actorProperties.getMeleeSkill());
			rdefBonus = this.Math.floor(0.5 * actorProperties.getRangedDefense());
		}
		else
		{
			mskillBonus = 0;
			rdefBonus = this.Math.floor(0.1 * actorProperties.getRangedDefense());
		}

		return this.Math.max(mskillBonus, rdefBonus);
	}

	q.getTooltip = @( __original ) function ()
	{
		local tooltip = this.skill.getTooltip();
		local actor = this.getContainer().getActor();
		local bonus = getBonus();

		if (actor.getMainhandItem().isWeaponType(this.Const.Items.WeaponType.Firearm && actor.getMainhandItem().isItemType(this.Const.Items.ItemType.RangedWeapon)))
		{
			tooltip.push({
				id = 6,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Increases your damage done by [color=" + this.Const.UI.Color.PositiveValue + "]" + bonus + "%[/color]."
			});
		}

		if (actor.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
		{
			if (actor.getMainhandItem().isWeaponType(this.Const.Items.WeaponType.Throwing))
			{
				tooltip.extend([
				{
					id = 6,
					type = "text",
					icon = "ui/tooltips/warning.png",
					text = "Reduces your maximum range to [color=" + this.Const.UI.Color.NegativeValue + "]3[/color]."
				},
				{
					id = 6,
					type = "text",
					icon = "ui/icons/damage_dealt.png",
					text = "Allows you to use throwing weapons in melee."
				},
				{
					id = 6,
					type = "text",
					icon = "ui/icons/damage_dealt.png",
					text = "Increases your damage done by [color=" + this.Const.UI.Color.PositiveValue + "]" + bonus + "%[/color]."
				}]);
			}
			else
			{
				tooltip.push({
					id = 6,
					type = "text",
					icon = "ui/icons/damage_dealt.png",
					text = "Increases your damage done by [color=" + this.Const.UI.Color.PositiveValue + "]" + bonus + "%[/color] when using [color=#000ec1]Quick Shot[/color], [color=#000ec1]Shoot Bolt[/color], [color=#000ec1]Shoot Stake[/color], [color=#000ec1]Loose Stone[/color] and [color=#000ec1]Sling Stone[/color] at targets at range of 4 or less."
				});
				if (actor.getSkills().hasSkill("perk.legend_heightened_reflexes"))
				{
					tooltip.push({
						id = 6,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Decreases Action Point cost by [color=" + this.Const.UI.Color.NegativeValue + "]1[/color] when using [color=#000ec1]Quick Shot[/color], [color=#000ec1]Shoot Bolt[/color], [color=#000ec1]Shoot Stake[/color], [color=#000ec1]Loose Stone[/color] and [color=#000ec1]Sling Stone[/color] at targets at range of 4 or less."
					});
				}
			}
		}

		return tooltip;
	}

	q.onAdded <- function ()
	{
		local addPerk = function ( _perk, _row = 0 )
		{
			local actor = this.getContainer().getActor();

			if (typeof actor == "instance")
				actor = actor.get();

			if (!this.isKindOf(actor, "player"))
				return;

			local bg = actor.getBackground();

			if (bg == null)
				return;

			bg.addPerk(_perk, _row);
		}

		if (!this.getContainer().hasSkill("perk.legend_heightened_reflexes"))
			addPerk(this.Const.Perks.PerkDefs.LegendHeightenedReflexes, 5);
	}
});
