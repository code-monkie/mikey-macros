-- Default hunter macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").HUNTER = {
    -- Melee: Mongoose Bite when it's lit (after a dodge), else Raptor Strike.
    -- ! so mashing doesn't un-queue Raptor Strike (it waits for the next swing).
    { name = "Raptor Strike", learn = "Raptor Strike", spells = { "Raptor Strike", "Mongoose Bite" }, body = [[
        #showtooltip Raptor Strike
        /cast Mongoose Bite
        /cast !Raptor Strike
    ]] },

    { name = "Scare Beast", spells = { "Scare Beast" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Scare Beast
    ]] },

    -- Pet passive and home first, so it doesn't keep the mob on you; out of
    -- combat it only calls the pet back.
    { name = "Feign Death", spells = { "Feign Death" }, body = [[
        #showtooltip Feign Death
        /petpassive
        /petfollow
        /stopattack
        /stopcasting
        /cast [combat] Feign Death
    ]] },

    -- Lands where the mouse points.
    { name = "Flare", spells = { "Flare" }, body = [[
        #showtooltip Flare
        /cast [@cursor] Flare
    ]] },

    -- ! so a second press doesn't end the channel and snap the view back to
    -- you: you can recast it to move the eye, like a priest's Mind Vision.
    { name = "Eagle Eye", spells = { "Eagle Eye" }, body = [[
        #showtooltip Eagle Eye
        /cast !Eagle Eye
    ]] },

    -- All-in-one pet: Call Pet with none out, Revive Pet if it's dead, else
    -- Mend Pet (Leaku's guide). Didn't seem to work on Forever when Mikey tried
    -- it (2026-11-02); likely a dead pet counting as no pet. Test and adjust.
    { name = "Pet", learn = "Call Pet", spells = { "Call Pet", "Revive Pet", "Mend Pet" }, body = [[
        #showtooltip
        /cast [nopet] Call Pet; [@pet,dead] Revive Pet; Mend Pet
    ]] },

    -- Pet in: Assist stance (Mikey's trial, 2026-11-02), attack the mouseover,
    -- else your target, with its gap closer (Dash, Dive or a boar's Charge).
    -- Pet spells aren't in your spellbook, so they're not listed; the general
    -- Pet Stop macro puts it back on passive.
    { name = "Pet Attack", learn = "Call Pet", spells = { "Call Pet" }, body = [[
        #showtooltip
        /petassist
        /petattack [@mouseover,harm,nodead] []
        /cast Dash
        /cast Dive
        /cast [@mouseover,harm,nodead] [] Charge
    ]] },
}

ns.Exclude("HUNTER", {
    "Eyes of the Beast",
    "Beast Lore",
    "Tame Beast",
    "Track Beasts",
    "Track Humanoids",
    "Track Undead",
    "Track Hidden",
    "Track Elementals",
    "Track Demons",
    "Track Giants",
    "Track Dragonkin",
    "Dismiss Pet",
    "Feed Pet",
})
