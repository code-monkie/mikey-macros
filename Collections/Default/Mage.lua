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
    -- Best mana gem in your bags first. The gems are items, so `spells` only
    -- holds the spell that makes the macro (Conjure Mana Agate, level 28); a
    -- gem you're not carrying is just skipped.
    { name = "Mana Gem", learn = "Conjure Mana Agate", spells = { "Conjure Mana Agate" }, body = [[
        #showtooltip Mana Ruby
        /use Mana Ruby
        /use Mana Citrine
        /use Mana Jade
        /use Mana Agate
    ]] },
}

-- Conjure Mana Agate isn't listed: the Mana Gem macro above is made for it, so
-- it gets no macro of its own anyway (and listing it would warn).
ns.Exclude("MAGE", {
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
