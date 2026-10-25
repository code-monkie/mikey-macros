-- Hunter macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- One spell per macro, no modifier branches: Shift and Ctrl are their own
-- bars (Shift+1-7, Ctrl+1-7). Traps and the other aspects are dragged from
-- the spellbook, so auto mode makes no macros for them (exclude list at the bottom).
-- Pet rider on attacks: attack, defensive in a group, assist when solo.

local _, ns = ...

ns.Collection("Mikey").HUNTER = {
    { name = "AS", spells = { "Auto Shot" }, body = [[
        #showtooltip
        /startattack
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Arcane", spells = { "Arcane Shot" }, body = [[
        #showtooltip
        /startattack
        /use Arcane Shot
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    -- Stings: mouseover, else target; the pet goes for your target.
    { name = "Serpent", spells = { "Serpent Sting" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Serpent Sting
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Scorpid", spells = { "Scorpid Sting" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Scorpid Sting
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    -- The opener: a mouseover becomes your target, marked, and the pet goes in.
    { name = "Mark", spells = { "Hunter's Mark" }, body = [[
        #showtooltip
        /target [@mouseover,harm,nodead]
        /use Hunter's Mark
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Multi", spells = { "Multi-Shot" }, body = [[
        #showtooltip
        /startattack
        /use Multi-Shot
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Aimed", spells = { "Aimed Shot" }, body = [[
        #showtooltip
        /startattack
        /use Aimed Shot
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Raptor", spells = { "Raptor Strike" }, body = [[
        #showtooltip
        /startattack
        /use Raptor Strike
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Mongoose", spells = { "Mongoose Bite" }, body = [[
        #showtooltip
        /startattack
        /use Mongoose Bite
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    -- Cheetah and Hawk in turn.
    { name = "Aspect", spells = { "Aspect of the Hawk", "Aspect of the Cheetah" }, body = [[
        #showtooltip
        /castsequence Aspect of the Cheetah, Aspect of the Hawk
    ]] },

    -- Lands where the mouse points.
    { name = "Flare", spells = { "Flare" }, body = [[
        #showtooltip Flare
        /cast [@cursor] Flare
    ]] },

    { name = "Pet Stop", spells = {}, body = [[
        #showtooltip Pet Passive
        /petpassive
        /petfollow
        /petstopattack
    ]] },

    -- Talent.
    { name = "Intimidation", spells = { "Intimidation" }, body = [[
        #showtooltip
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
        /use Intimidation
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
