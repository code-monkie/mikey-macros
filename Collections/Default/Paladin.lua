-- Default paladin macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").PALADIN = {
    { name = "Turn Undead", spells = { "Turn Undead" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Turn Undead
    ]] },
    -- Dead friend under the mouse, else your dead target, else the targeting hand. 0.2.27: @target named, so
    -- the friendly NPC you face (Forever's soft target) is skipped.
    { name = "Res", spells = { "Redemption" }, body = [[
        #showtooltip
        /use [@mouseover,help,dead] [@target,help,dead] [] Redemption
    ]] },
}

ns.Exclude("PALADIN", {
    "Sense Undead",
    "Summon Warhorse",
    "Summon Charger",
})
