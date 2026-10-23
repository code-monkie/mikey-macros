-- Rogue macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255. `icon` is a spell ID whose picture shows
-- until you know one of the macro's spells.

local _, ns = ...

ns.classes.ROGUE = {
    { name = "Stealth", icon = 1784, spells = { "Stealth", "Pick Pocket" }, body = [[
        #showtooltip
        /dismount [mounted]
        /stopattack
        /use [nostealth] !Stealth; [@mouseover,harm,nodead] [harm,nodead] Pick Pocket
    ]] },

    { name = "SS", icon = 1752, spells = { "Sinister Strike" }, body = [[
        #showtooltip
        /startattack
        /use Sinister Strike
    ]] },

    -- Ambush from stealth, Backstab otherwise.
    { name = "BS", icon = 53, spells = { "Backstab", "Ambush" }, body = [[
        #showtooltip
        /startattack [nostealth]
        /use [stealth] Ambush; Backstab
    ]] },

    { name = "Bleed", icon = 703, spells = { "Garrote", "Rupture" }, body = [[
        #showtooltip
        /use [stealth] Garrote; Rupture
        /startattack [nostealth]
    ]] },

    { name = "Eviscerate", icon = 2098, spells = { "Eviscerate" }, body = [[
        #showtooltip
        /use Eviscerate
    ]] },

    { name = "SnD", icon = 5171, spells = { "Slice and Dice" }, body = [[
        #showtooltip
        /use Slice and Dice
    ]] },

    -- Sap from stealth, Gouge in combat.
    { name = "Sap", icon = 6770, spells = { "Sap", "Gouge" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead,stealth] [stealth] Sap; [@mouseover,harm,nodead] [] Gouge
        /stopattack
    ]] },

    { name = "Kick", icon = 1766, spells = { "Kick" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead,nostealth] [nostealth] Kick
    ]] },

    { name = "Evasion", icon = 5277, spells = { "Evasion" }, body = [[
        #showtooltip
        /use Evasion
    ]] },

    { name = "Sprint", icon = 2983, spells = { "Sprint" }, body = [[
        #showtooltip
        /use Sprint
    ]] },

    -- Later levels.
    { name = "Vanish", icon = 1856, spells = { "Vanish" }, body = [[
        #showtooltip Vanish
        /use [nostealth,combat] Vanish; [nostealth,nocombat] Stealth
    ]] },

    { name = "Blind", icon = 2094, spells = { "Blind" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Blind
    ]] },

    { name = "CS", icon = 1833, spells = { "Cheap Shot" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Cheap Shot
    ]] },

    { name = "KS", icon = 408, spells = { "Kidney Shot" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Kidney Shot
    ]] },
}
