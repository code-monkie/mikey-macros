-- Rogue macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.

local _, ns = ...

ns.classes.ROGUE = {
    { name = "Stealth", spells = { "Stealth", "Pick Pocket" }, body = [[
        #showtooltip
        /dismount [mounted]
        /stopattack
        /use [nostealth] !Stealth; [@mouseover,harm,nodead] [harm,nodead] Pick Pocket
    ]] },

    -- Ambush from stealth; otherwise Backstab, falling through to Sinister
    -- Strike when Backstab can't be used (no main-hand dagger, or not behind).
    { name = "Builder", spells = { "Sinister Strike", "Backstab", "Ambush" }, body = [[
        #showtooltip
        /startattack [nostealth]
        /use [stealth] Ambush
        /use [nostealth] Backstab
        /use [nostealth] Sinister Strike
    ]] },

    { name = "Bleed", spells = { "Garrote", "Rupture" }, body = [[
        #showtooltip
        /use [stealth] Garrote; Rupture
        /startattack [nostealth]
    ]] },

    { name = "Eviscerate", spells = { "Eviscerate" }, body = [[
        #showtooltip
        /use Eviscerate
        /startattack
    ]] },

    { name = "SnD", spells = { "Slice and Dice" }, body = [[
        #showtooltip
        /use Slice and Dice
    ]] },

    -- Sap from stealth, Gouge in combat.
    { name = "Sap", spells = { "Sap", "Gouge" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead,stealth] [stealth] Sap; [@mouseover,harm,nodead] [] Gouge
    ]] },

    { name = "Kick", spells = { "Kick" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead,nostealth] [nostealth] Kick
    ]] },

    { name = "Evasion", spells = { "Evasion" }, body = [[
        #showtooltip
        /use Evasion
    ]] },

    { name = "Sprint", spells = { "Sprint" }, body = [[
        #showtooltip
        /use Sprint
    ]] },

    -- Later levels.
    { name = "Vanish", spells = { "Vanish" }, body = [[
        #showtooltip Vanish
        /use [nostealth,combat] Vanish; [nostealth,nocombat] Stealth
    ]] },

    { name = "Blind", spells = { "Blind" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Blind
    ]] },

    { name = "CS", spells = { "Cheap Shot" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Cheap Shot
    ]] },

    { name = "KS", spells = { "Kidney Shot" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Kidney Shot
    ]] },
}
