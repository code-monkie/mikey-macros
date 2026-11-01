-- Default hunter macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").HUNTER = {
    { name = "Scare Beast", spells = { "Scare Beast" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Scare Beast
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
    "Call Pet",
    "Dismiss Pet",
    "Revive Pet",
    "Feed Pet",
    "Flare",
    "Feign Death",
})
