::Mod_Sellswords.HooksMod.hook("scripts/items/weapons/greenskins/goblin_spiked_balls", function( q )
{
	q.onEquip = @( __original ) function()
	{
		__original();
		this.addSkill(this.new("scripts/skills/actives/bash_ranged"));
	}
});
