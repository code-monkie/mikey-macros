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
    -- 0.2.21 (Mikey's ask, 2026-11-10): the hunter Shot's targeting. With no target
    -- (or a dead or friendly one), the mouseover becomes it, else the nearest enemy;
    -- then the bolt on the target (a target you have always wins; the mouseover
    -- only picks one up), /startattack, and the Imp (only) goes in on it too.
    { name = "SB", spells = { "Shadow Bolt" }, body = [[
        #showtooltip
        /cleartarget [dead][help]
        /target [noexists] mouseover
        /cleartarget [dead][help]
        /targetenemy [noexists]
        /use Shadow Bolt
        /startattack
        /petattack [pet:Imp]
    ]] },

    -- Immolate and Corruption differed from auto mode's macros only by a pet
    -- rider; dropped 2026-11-02 (Default's Pet Attack sends the demon).

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
    -- Life Tap was dropped 2026-11-03 (/stopattack did nothing for it), so it's
    -- auto mode's macro. Health Funnel and Drain Life come from Default (0.2.32).
    -- Drain: no melee or wand killing blow (that loses the shard). 0.2.32 (Mikey,
    -- 2026-11-14): no /stopcasting ("I don't need stop casting for drain soul";
    -- it's for CC only) and [nochanneling:Drain Soul], so a second press doesn't
    -- restart the channel. Still on the target only, as before.
    { name = "Drain", spells = { "Drain Soul" }, body = [[
        #showtooltip
        /stopattack
        /use [nochanneling:Drain Soul] Drain Soul
    ]] },

    -- Armor -----------------------------------------------------------------------
    { name = "DS", spells = { "Demon Skin", "Demon Armor" }, body = [[
        #showtooltip
        /use Demon Armor
        /use Demon Skin
    ]] },

    -- Voidwalker ------------------------------------------------------------------
    { name = "CS", spells = { "Summon Voidwalker" }, body = [[
        #showtooltip Consume Shadows
        /petpassive
        /use [pet:Voidwalker] Consume Shadows
    ]] },

    { name = "VW Sac", spells = { "Summon Voidwalker" }, body = [[
        #showtooltip Sacrifice
        /stopcasting
        /petautocastoff Sacrifice
        /use [pet:Voidwalker] Sacrifice
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
    -- mikey-ring Demons ring (Summon Imp isn't listed: Default's Pet Attack is
    -- tied to it, so it gets no macro of its own anyway, and listing it would
    -- drop Pet Attack)
    "Summon Succubus",
    "Summon Felhunter",
    "Summon Felguard",
    -- No macro wanted
    "Unending Breath",
}, "Mikey")
