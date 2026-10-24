-- Default rogue macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").ROGUE = {
    { name = "Sap", spells = { "Sap" }, body = [[
        #showtooltip
        /stopattack
        /use Sap
    ]] },
    { name = "Gouge", spells = { "Gouge" }, body = [[
        #showtooltip
        /stopattack
        /use Gouge
    ]] },
    { name = "Blind", spells = { "Blind" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Blind
    ]] },
    -- Off the mount and into Stealth; Pick Pocket (mouseover, else target) once you're in stealth.
    { name = "Stealth", spells = { "Stealth", "Pick Pocket" }, body = [[
        #showtooltip
        /dismount [mounted]
        /stopattack
        /use [stealth,@mouseover,harm,nodead] [stealth] Pick Pocket; !Stealth
    ]] },
    { name = "Vanish", spells = { "Vanish" }, body = [[
        #showtooltip
        /stopattack
        /use Vanish
    ]] },
    -- Lands where the mouse points.
    { name = "Distract", spells = { "Distract" }, body = [[
        #showtooltip
        /use [@cursor] Distract
    ]] },
}

ns.Exclude("ROGUE", {
    "Pick Lock",
    "Disarm Trap",
})
