-- Default priest macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").PRIEST = {
    { name = "Shackle Undead", spells = { "Shackle Undead" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Shackle Undead
    ]] },
    { name = "Mind Soothe", spells = { "Mind Soothe" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Mind Soothe
    ]] },
    -- Dead friend under the mouse, else your dead target.
    { name = "Resurrection", spells = { "Resurrection" }, body = [[
        #showtooltip
        /use [@mouseover,help,dead] [] Resurrection
    ]] },
}

ns.Exclude("PRIEST", {
    "Mind Vision",
    "Levitate",
})
