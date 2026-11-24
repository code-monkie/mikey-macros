-- Warlock macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Stones, Summoning, Eye of Kilrogg and the demons come from mikey-ring, so
-- they get no managed macro at all (exclude list at the bottom).
-- Pet spells (Consume Shadows, Sacrifice) aren't in your spellbook, so their
-- macros are made when you learn Summon Voidwalker.

local _, ns = ...

-- 0.2.35: Create Soulstone ranks, best first: { spell ID, the stone it makes }. 0.2.36 (Mikey, 2026-11-18: the
-- macro asked for "Soulstone" when Nectavius knew only the first rank): by spell ID, not name. Forever's spellbook
-- calls rank 1 plain "Create Soulstone", which is the name Classic gives the middle rank, so names can't tell them
-- apart. IDs are Classic's (693, 20752, 20755, 20756, 20757).
local SOULSTONES = {
    { 20757, "Major Soulstone" },
    { 20756, "Greater Soulstone" },
    { 20755, "Soulstone" },
    { 20752, "Lesser Soulstone" },
    { 693, "Minor Soulstone" },
}
-- the names the spellbook may use, for when the macro is made (any one known) and KnownOnly
local SOULSTONE_SPELLS = { "Create Soulstone (Minor)", "Create Soulstone (Lesser)", "Create Soulstone",
    "Create Soulstone (Greater)", "Create Soulstone (Major)" }
local function KnowsID(id)
    if IsPlayerSpell then local ok, k = pcall(IsPlayerSpell, id); if ok and k then return true end end
    if IsSpellKnown then local ok, k = pcall(IsSpellKnown, id); if ok and k then return true end end
    return false
end

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

    -- 0.2.41 (Mikey's ask, 2026-11-23): auto mode's Searing Pain plus Pet Attack, so any demon goes in on the
    -- same mob (the mouseover, else your target).
    { name = "Searing Pain", spells = { "Searing Pain" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,harm,nodead] [] Searing Pain
        /petattack [@mouseover,harm,nodead] []
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

    -- Soulstone ---------------------------------------------------------------------
    -- 0.2.35 (Mikey's ask, 2026-11-18: "use the same button to create and then apply a soulstone"): with a stone in
    -- your bags, the first line uses it on the friendly mouseover, else your friendly target, else you (house rule
    -- for helpful macros); its global cooldown keeps the second line from running. With none, the first line does
    -- nothing and the second makes one (a soul shard). Both lines are your highest Create Soulstone and its own
    -- stone (each rank makes its own), rewritten as you learn a higher one. Was on the exclude list (mikey-ring's
    -- Utility ring still has the create spells).
    { name = "Soulstone", spells = SOULSTONE_SPELLS, body = function(c)
        for _, r in ipairs(SOULSTONES) do
            if KnowsID(r[1]) then
                -- the create line by the spellbook's own name for that rank (kept by KnownOnly: a name you know)
                local name = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(r[1])
                if type(name) ~= "string" or not c.knows(name) then name = "Create Soulstone" end
                return ([[
                #showtooltip %s
                /use [@mouseover,help,nodead] [@target,help,nodead] [@player] %s
                /use %s
                ]]):format(name, r[2], name)   -- 0.2.38 (Mikey's ask, 2026-11-19): the create spell's tooltip
                                               -- and icon on the button (0.2.36 showed the stone's)
            end
        end
        -- no rank found by ID: the first one, as a new warlock has
        return "#showtooltip Create Soulstone\n/use [@mouseover,help,nodead] [@target,help,nodead] [@player] Minor Soulstone\n/use Create Soulstone"
    end },
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
    -- Create Soulstone: off the list in 0.2.35 (the Soulstone macro above)
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
