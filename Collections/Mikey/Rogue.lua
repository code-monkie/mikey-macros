-- Rogue macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Stealth, Vanish, Blind and Distract come from the Default collection.

local _, ns = ...

ns.Collection("Mikey").ROGUE = {
    -- Ambush from stealth; out of it, Backstab, else Sinister Strike.
    { name = "Attack", spells = { "Sinister Strike", "Backstab", "Ambush" }, body = [[
        #showtooltip
        /startattack [nostealth]
        /use [stealth] Ambush; Backstab
        /use [nostealth] Sinister Strike
    ]] },

    { name = "Bleed", spells = { "Garrote", "Rupture" }, body = [[
        #showtooltip
        /use [stealth] Garrote; Rupture
        /startattack [nostealth]
    ]] },

    -- Sap from stealth, Gouge in combat.
    { name = "Sap", spells = { "Sap", "Gouge" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead,stealth] [stealth] Sap; [@mouseover,harm,nodead] [] Gouge
        /stopattack
    ]] },

    { name = "Kick", spells = { "Kick" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead,nostealth] [nostealth] Kick
    ]] },

    -- Later levels.
    { name = "Stun", spells = { "Cheap Shot", "Kidney Shot" }, body = [[
        #showtooltip
        /use [stealth] Cheap Shot; Kidney Shot
    ]] },
}
