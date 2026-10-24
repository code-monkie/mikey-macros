-- Default druid macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").DRUID = {
    { name = "Hibernate", spells = { "Hibernate" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Hibernate
    ]] },
    { name = "Soothe Animal", spells = { "Soothe Animal" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Soothe Animal
    ]] },
    { name = "Prowl", spells = { "Prowl" }, body = [[
        #showtooltip
        /stopattack
        /use !Prowl
    ]] },
    -- Out of combat Revive (where the game has it), in combat Rebirth; mouseover first.
    { name = "Rebirth", spells = { "Rebirth", "Revive" }, body = [[
        #showtooltip
        /use [nocombat,@mouseover,help,dead] [nocombat] Revive; [@mouseover,help,dead] [] Rebirth
    ]] },
}

ns.Exclude("DRUID", {
    "Teleport: Moonglade",
    "Track Humanoids",
})
