-- Warlock macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Stones, Summoning, Eye of Kilrogg and the demons come from mikey-ring, so
-- they get no managed macro at all (exclude list at the bottom).
-- Pet spells (Consume Shadows, Sacrifice) aren't in your spellbook, so their
-- macros are made when you learn Summon Voidwalker.

local _, ns = ...

ns.Collection("Mikey").WARLOCK = {
    -- Damage ----------------------------------------------------------------------
    { name = "SB", spells = { "Shadow Bolt" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,nodead,harm] [] Shadow Bolt
    ]] },

    { name = "I", spells = { "Immolate" }, body = [[
        #showtooltip
        /startattack
        /petassist
        /petattack
        /use [@mouseover,nodead,harm] [] Immolate
    ]] },

    { name = "C", spells = { "Corruption" }, body = [[
        #showtooltip
        /startattack
        /petattack
        /use [@mouseover,nodead,harm] [] Corruption
    ]] },

    -- Curses ----------------------------------------------------------------------
    { name = "BoA", spells = { "Bane of Agony" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,nodead,harm] [] Bane of Agony
    ]] },

    { name = "W", spells = { "Curse of Weakness" }, body = [[
        #showtooltip
        /use [@mouseover,nodead,harm] [] Curse of Weakness
    ]] },

    { name = "CoR", spells = { "Curse of Recklessness" }, body = [[
        #showtooltip
        /use [@mouseover,nodead,harm] [] Curse of Recklessness
    ]] },

    -- Control ---------------------------------------------------------------------
    { name = "F", spells = { "Fear" }, body = [[
        #showtooltip Fear
        /stopattack
        /stopcasting
        /use [@mouseover,nodead,harm] [@target,nodead,harm] Fear
    ]] },

    -- Channels and mana -----------------------------------------------------------
    { name = "LT", spells = { "Life Tap" }, body = [[
        #showtooltip
        /stopattack
        /use Life Tap
    ]] },

    { name = "Drain", spells = { "Drain Soul" }, body = [[
        #showtooltip
        /stopattack
        /stopcasting
        /use Drain Soul
    ]] },

    { name = "HF", spells = { "Health Funnel" }, body = [[
        #showtooltip
        /stopattack
        /stopcasting
        /use Health Funnel
    ]] },

    -- Armor -----------------------------------------------------------------------
    { name = "DS", spells = { "Demon Skin", "Demon Armor" }, body = [[
        #showtooltip
        /cast Demon Armor
        /cast Demon Skin
    ]] },

    -- Voidwalker ------------------------------------------------------------------
    { name = "CS", spells = { "Summon Voidwalker" }, body = [[
        #showtooltip Consume Shadows
        /petpassive
        /cast [pet:Voidwalker] Consume Shadows
    ]] },

    { name = "VW Sac", spells = { "Summon Voidwalker" }, body = [[
        #showtooltip Sacrifice
        /stopcasting
        /petautocastoff Sacrifice
        /cast [pet:Voidwalker] Sacrifice
    ]] },
}

-- Mikey's characters only (on top of Default's list), and final: Default's
-- Healthstone macro is dropped too.
-- Summon Voidwalker isn't listed: the two Voidwalker macros above are tied to
-- it, so it gets no macro of its own anyway (and listing it would warn).
ns.Exclude("WARLOCK", {
    -- mikey-ring Utility ring
    "Create Healthstone (Minor)",
    "Create Healthstone (Lesser)",
    "Create Healthstone",
    "Create Healthstone (Greater)",
    "Create Healthstone (Major)",
    "Create Soulstone (Minor)",
    "Create Soulstone (Lesser)",
    "Create Soulstone",
    "Create Soulstone (Greater)",
    "Create Soulstone (Major)",
    "Create Firestone (Lesser)",
    "Create Firestone",
    "Create Firestone (Greater)",
    "Create Firestone (Major)",
    "Create Spellstone",
    "Create Spellstone (Greater)",
    "Create Spellstone (Major)",
    "Ritual of Summoning",
    "Eye of Kilrogg",
    -- mikey-ring Demons ring
    "Summon Imp",
    "Summon Succubus",
    "Summon Felhunter",
    "Summon Felguard",
    -- No macro wanted
    "Unending Breath",
}, "Mikey")
