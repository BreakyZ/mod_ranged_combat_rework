::ModRangedCombatRework <- {
	ID = "mod_ranged_combat_rework",
	Name = "Mod Ranged Combat Rework",
	Version = "1.0.0"
};

::ModRangedCombatRework.HooksMod <- ::Hooks.register(::ModRangedCombatRework.ID, ::ModRangedCombatRework.Version, ::ModRangedCombatRework.Name);


// add which mods are needed to run this mod
::ModRangedCombatRework.HooksMod.require("mod_msu >= 1.2.6", "mod_modern_hooks");

// like above you can add as many parameters to determine the queue order of the mod before adding the parameter to run the callback function. 
::ModRangedCombatRework.HooksMod.queue(">mod_msu", ">mod_legends", ">mod_sellswords", function()
{
	// define mod class of this mod
	::ModRangedCombatRework.Mod <- ::MSU.Class.Mod(::ModRangedCombatRework.ID, ::ModRangedCombatRework.Version, ::ModRangedCombatRework.Name);
	if (!("Is_SSU_Exist" in this.getroottable())) ::Is_SSU_Exist <- ::mods_getRegisteredMod("mod_sellswords") != null;

	// load hook files
	::include("mod_ranged_combat_rework/load.nut");
}, ::Hooks.QueueBucket.Normal);