-- Shaman macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- One spell per macro, no modifier branches: Shift and Ctrl are their own
-- bars (Shift+1-7, Ctrl+1-7). Totems and weapon imbues come from mikey-ring,
-- so auto mode makes no macros for them (exclude list at the bottom).

local _, ns = ...

ns.Collection("Mikey").SHAMAN = {
    -- Your nuke target: a mouseover becomes the target.
    { name = "LB", spells = { "Lightning Bolt" }, body = [[
        #showtooltip
        /target [@mouseover,harm,nodead]
        /startattack
        /use Lightning Bolt
    ]] },

    -- Shocks: mouseover, else target. They share one cooldown.
    { name = "Earth Shock", spells = { "Earth Shock" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,harm,nodead] [] Earth Shock
    ]] },

    { name = "Flame Shock", spells = { "Flame Shock" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,harm,nodead] [] Flame Shock
    ]] },

    { name = "Frost Shock", spells = { "Frost Shock" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,harm,nodead] [] Frost Shock
    ]] },

    -- Cures: mouseover friend, else you.
    { name = "Cure Poison", spells = { "Cure Poison" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [@player] Cure Poison
    ]] },

    { name = "Cure Disease", spells = { "Cure Disease" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [@player] Cure Disease
    ]] },
}

-- Mikey's characters only (on top of Default's list): mikey-ring drops these.
ns.Exclude("SHAMAN", {
    -- Weapon imbues
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
}, "Mikey")
