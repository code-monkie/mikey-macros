-- Hunter macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- One spell per macro, no modifier branches: Shift and Ctrl are their own
-- bars (Shift+1-7, Ctrl+1-7). Traps and the other aspects are dragged from
-- the spellbook, so auto mode makes no macros for them (exclude list at the bottom).
-- No pet rider on attacks (2026-11-02, Mikey): Default's Pet Attack sends the
-- pet and the general Pet Stop calls it back. AP's /petattack is the one
-- exception. Macros that differed from auto mode's only by the old rider were
-- dropped (Serpent, Scorpid, Intimidation).

local _, ns = ...

ns.Collection("Mikey").HUNTER = {
    -- Clears a dead or friendly target, picks the nearest enemy if there's none,
    -- then shoots the mouseover, else the target. No pet rider (Mikey, 2026-11-02).
    { name = "Shot", spells = { "Auto Shot" }, body = [[
        #showtooltip Auto Shot
        /cleartarget [dead][help]
        /targetenemy [noexists]
        /cast [@mouseover,harm,exists,nodead] !Auto Shot; !Auto Shot
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

    { name = "Arcane", spells = { "Arcane Shot" }, body = [[
        #showtooltip
        /startattack
        /use Arcane Shot
        /use !Auto Shot
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
        /use !Auto Shot
    ]] },

    { name = "Aimed", spells = { "Aimed Shot" }, body = [[
        #showtooltip
        /startattack
        /use Aimed Shot
        /use !Auto Shot
    ]] },

    -- Cheetah and Hawk in turn.
    { name = "Aspect", spells = { "Aspect of the Hawk", "Aspect of the Cheetah" }, body = [[
        #showtooltip
        /castsequence Aspect of the Cheetah, Aspect of the Hawk
    ]] },
}

-- Mikey's characters only (on top of Default's list), and final.
ns.Exclude("HUNTER", {
    "Viper Sting",
    -- Traps (spellbook)
    "Freezing Trap",
    "Immolation Trap",
    "Frost Trap",
    "Explosive Trap",
    -- Aspects other than Cheetah and Hawk (spellbook)
    "Aspect of the Monkey",
    "Aspect of the Pack",
    "Aspect of the Wild",
    "Aspect of the Beast",
}, "Mikey")
