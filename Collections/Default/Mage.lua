-- Default mage macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").MAGE = {
    { name = "Polymorph", spells = { "Polymorph" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Polymorph
    ]] },
}

ns.Exclude("MAGE", {
    "Conjure Mana Agate",
    "Conjure Mana Jade",
    "Conjure Mana Citrine",
    "Conjure Mana Ruby",
    "Teleport: Stormwind",
    "Teleport: Ironforge",
    "Teleport: Darnassus",
    "Teleport: Orgrimmar",
    "Teleport: Undercity",
    "Teleport: Thunder Bluff",
    "Portal: Stormwind",
    "Portal: Ironforge",
    "Portal: Darnassus",
    "Portal: Orgrimmar",
    "Portal: Undercity",
    "Portal: Thunder Bluff",
    "Slow Fall",
})
