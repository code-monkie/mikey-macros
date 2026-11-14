-- Default shaman macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").SHAMAN = {
    -- Not while mounted.
    { name = "Ghost Wolf", spells = { "Ghost Wolf" }, body = [[
        #showtooltip
        /use [nomounted] !Ghost Wolf
    ]] },
    -- Dead friend under the mouse, else your dead target, else the targeting hand. 0.2.27: @target named, so
    -- the friendly NPC you face (Forever's soft target) is skipped.
    { name = "Res", spells = { "Ancestral Spirit" }, body = [[
        #showtooltip
        /use [@mouseover,help,dead] [@target,help,dead] [] Ancestral Spirit
    ]] },
}

ns.Exclude("SHAMAN", {
    "Far Sight",
    "Water Walking",
    "Astral Recall",
    -- 0.2.14 (Mikey's ask, 2026-11-07): every totem, for every collection (only the Mikey collection had
    -- them before). Totems are cast from mikey-halo's rings.
    -- Weapon imbues (0.2.15, Mikey's ask, 2026-11-07; only the Mikey collection had them before), cast from
    -- mikey-halo's imbue ring
    "Rockbiter Weapon",
    "Flametongue Weapon",
    "Frostbrand Weapon",
    "Windfury Weapon",
    -- Earth totems
    "Stoneskin Totem",
    "Earthbind Totem",
    "Stoneclaw Totem",
    "Strength of Earth Totem",
    "Tremor Totem",
    -- Fire totems
    "Searing Totem",
    "Fire Nova Totem",
    "Frost Resistance Totem",
    "Magma Totem",
    "Flametongue Totem",
    -- Water totems
    "Healing Stream Totem",
    "Mana Spring Totem",
    "Poison Cleansing Totem",
    "Disease Cleansing Totem",
    "Fire Resistance Totem",
    "Mana Tide Totem",
    -- Air totems
    "Grounding Totem",
    "Nature Resistance Totem",
    "Windfury Totem",
    "Sentry Totem",
    "Windwall Totem",
    "Grace of Air Totem",
    "Tranquil Air Totem",
    -- Totem calls
    "Call of the Elements",
    "Call of the Ancestors",
    "Call of the Spirits",
    "Totemic Recall",
})
