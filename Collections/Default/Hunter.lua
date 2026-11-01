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
    -- Ranged pull: an enemy under the mouse becomes your target, then your
    -- target gets Throw with a thrown weapon, else Auto Shot (hunters have no
    -- Shoot spells: Auto Shot fires bows, guns and crossbows). The icon is the
    -- ranged weapon itself. If auto mode doesn't make it (Throw is on the
    -- General tab, which it skips), /mma sync does.
    { name = "Ranged", spells = { "Throw", "Auto Shot" }, body = [[
        #showtooltip 18
        /target [@mouseover,harm,nodead]
        /use [equipped:Thrown] Throw; !Auto Shot
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
