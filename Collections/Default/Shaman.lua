-- Default shaman macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").SHAMAN = {
    -- Dead friend under the mouse, else your dead target.
    { name = "Res", spells = { "Ancestral Spirit" }, body = [[
        #showtooltip
        /use [@mouseover,help,dead] [] Ancestral Spirit
    ]] },
}

ns.Exclude("SHAMAN", {
    "Far Sight",
    "Water Walking",
    "Astral Recall",
})
