-- Hunter macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- One spell per macro, no modifier branches: Shift and Ctrl are their own
-- bars (Shift+1-7, Ctrl+1-7). Traps are dragged from the spellbook and aspects
-- come from mikey-halo's ring, so auto mode makes no macros for them (exclude list at the bottom).
-- No pet rider on attacks (2026-11-02, Mikey): Default's Pet Attack sends the
-- pet and the general Pet Stop calls it back. AP's /petattack is the one
-- exception. Macros that differed from auto mode's only by the old rider were
-- dropped (Serpent, Scorpid, Intimidation).

local _, ns = ...

ns.Collection("Mikey").HUNTER = {
    -- Clears a dead or friendly target. With no target, the mouseover becomes it
    -- (cleared again if it's friendly or dead), else the nearest enemy. Then it
    -- always shoots the target. No pet rider (Mikey, 2026-11-02).
    -- 0.2.16 (Mikey's ask, 2026-11-08): it used to shoot the mouseover over the
    -- target, so scanning around with the mouse started Auto Shot on other mobs.
    -- A target you have now always wins; the mouseover only picks one up.
    { name = "Shot", spells = { "Auto Shot" }, body = [[
        #showtooltip Auto Shot
        /cleartarget [dead][help]
        /target [noexists] mouseover
        /cleartarget [dead][help]
        /targetenemy [noexists]
        /cast !Auto Shot
    ]] },

    -- Aimed Shot opener: same targeting as Shot, Raptor Strike if in melee,
    -- then Aimed Shot, Auto Shot, and the pet goes in. Made when Aimed Shot
    -- (talent) is learned.
    { name = "AP", learn = "Aimed Shot", spells = { "Raptor Strike", "Aimed Shot", "Auto Shot" }, body = [[
        #showtooltip Aimed Shot
        /cleartarget [dead][help]
        /targetenemy [noexists]
        /cast Raptor Strike
        /cast Aimed Shot
        /cast !Auto Shot
        /petattack
    ]] },

    -- Arcane, Multi and Aimed: /startattack, then the shot (0.2.6). On Forever /startattack starts Auto Shot at
    -- range (Mikey, in game, 2026-11-05), so the old "/use !Auto Shot" line isn't needed.
    { name = "Arcane", spells = { "Arcane Shot" }, body = [[
        #showtooltip
        /startattack
        /use Arcane Shot
    ]] },

    -- The opener: a mouseover becomes your target, then marked.
    { name = "Mark", spells = { "Hunter's Mark" }, body = [[
        #showtooltip
        /target [@mouseover,harm,nodead]
        /use Hunter's Mark
    ]] },

    { name = "Multi", spells = { "Multi-Shot" }, body = [[
        #showtooltip
        /startattack
        /use Multi-Shot
    ]] },

    { name = "Aimed", spells = { "Aimed Shot" }, body = [[
        #showtooltip
        /startattack
        /use Aimed Shot
    ]] },

    -- 0.2.17 (Mikey's ask, 2026-11-08): the "Aspect" macro (Cheetah and Hawk in turn) is gone; every aspect is
    -- cast from mikey-halo's aspect ring and excluded below.
}

-- Mikey's characters only (on top of Default's list), and final.
ns.Exclude("HUNTER", {
    "Viper Sting",
    -- Traps (spellbook)
    "Freezing Trap",
    "Immolation Trap",
    "Frost Trap",
    "Explosive Trap",
    -- Aspects: all of them since 0.2.17 (mikey-halo's aspect ring); Cheetah and Hawk had a macro until then
    "Aspect of the Hawk",
    "Aspect of the Cheetah",
    "Aspect of the Monkey",
    "Aspect of the Pack",
    "Aspect of the Wild",
    "Aspect of the Beast",
}, "Mikey")
