-- Ulako's mage macros: a first guess to start from (Forever spell levels; Fire
-- and Frost levels from Classic). Write each body in full; spells listed in
-- `spells` are left out of the live macro until you know them. Names must be
-- unique and at most 16 characters; bodies at most 255.
-- Modifiers: Shift = fire, Ctrl = frost, where a key has both.

local _, ns = ...

ns.Collection("Ulako").MAGE = {
    -- Damage -------------------------------------------------------------------
    { name = "Fireball", spells = { "Fireball" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Fireball
    ]] },

    { name = "Frostbolt", spells = { "Frostbolt" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Frostbolt
    ]] },

    { name = "Missiles", spells = { "Arcane Missiles" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Arcane Missiles
    ]] },

    { name = "Fire Blast", spells = { "Fire Blast" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Fire Blast
    ]] },

    { name = "Nova", spells = { "Frost Nova" }, body = [[
        #showtooltip
        /use Frost Nova
    ]] },

    { name = "AE", spells = { "Arcane Explosion" }, body = [[
        #showtooltip
        /use Arcane Explosion
    ]] },

    { name = "Cone", spells = { "Cone of Cold" }, body = [[
        #showtooltip
        /use Cone of Cold
    ]] },

    { name = "Flamestrike", spells = { "Flamestrike" }, body = [[
        #showtooltip
        /use Flamestrike
    ]] },

    -- Control ------------------------------------------------------------------
    { name = "Poly", spells = { "Polymorph" }, body = [[
        #showtooltip
        /stopcasting
        /use [@mouseover,harm,nodead] [] Polymorph
    ]] },

    -- Stops your own cast so it goes off at once.
    { name = "Counterspell", spells = { "Counterspell" }, body = [[
        #showtooltip
        /stopcasting
        /use [@mouseover,harm,nodead] [] Counterspell
    ]] },

    -- Self ---------------------------------------------------------------------
    -- Ice Armor (or Frost Armor before it); Shift Mage Armor.
    { name = "Armor", spells = { "Mage Armor", "Ice Armor", "Frost Armor" }, body = [[
        #showtooltip
        /use [mod:shift] Mage Armor
        /use [nomod] Ice Armor
        /use [nomod] Frost Armor
    ]] },

    -- Fire Ward; Ctrl Frost Ward.
    { name = "Ward", spells = { "Fire Ward", "Frost Ward" }, body = [[
        #showtooltip
        /use [mod:ctrl] Frost Ward; Fire Ward
    ]] },

    { name = "Mana Shield", spells = { "Mana Shield" }, body = [[
        #showtooltip
        /use Mana Shield
    ]] },

    { name = "Blink", spells = { "Blink" }, body = [[
        #showtooltip
        /use Blink
    ]] },

    { name = "Evocation", spells = { "Evocation" }, body = [[
        #showtooltip
        /use Evocation
    ]] },

    -- Friendly: mouseover friend, else friendly target, else you -------------------
    { name = "Int", spells = { "Arcane Intellect" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [help,nodead] [@player] Arcane Intellect
    ]] },

    -- Dampen Magic; Shift Amplify Magic.
    { name = "Magic", spells = { "Dampen Magic", "Amplify Magic" }, body = [[
        #showtooltip
        /use [mod:shift,@mouseover,help,nodead] [mod:shift,help,nodead] [mod:shift,@player] Amplify Magic; [@mouseover,help,nodead] [help,nodead] [@player] Dampen Magic
    ]] },

    { name = "Slow Fall", spells = { "Slow Fall" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [help,nodead] [@player] Slow Fall
    ]] },

    { name = "Decurse", spells = { "Remove Lesser Curse" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [help,nodead] [@player] Remove Lesser Curse
    ]] },

    -- Utility ------------------------------------------------------------------
    -- Water; Shift Food; Ctrl mana gem.
    { name = "Conjure", spells = { "Conjure Water", "Conjure Food", "Conjure Mana Agate" }, body = [[
        #showtooltip
        /use [mod:ctrl] Conjure Mana Agate; [mod:shift] Conjure Food; Conjure Water
    ]] },

    -- Your faction's capital; Shift and Ctrl the other two. The other faction's
    -- line is trimmed away, since you'll never know those spells.
    { name = "Teleport", spells = { "Teleport: Stormwind", "Teleport: Ironforge", "Teleport: Darnassus",
        "Teleport: Orgrimmar", "Teleport: Undercity", "Teleport: Thunder Bluff" }, body = [[
        #showtooltip
        /use [mod:ctrl] Teleport: Darnassus; [mod:shift] Teleport: Ironforge; Teleport: Stormwind
        /use [mod:ctrl] Teleport: Thunder Bluff; [mod:shift] Teleport: Undercity; Teleport: Orgrimmar
    ]] },

    { name = "Portal", spells = { "Portal: Stormwind", "Portal: Ironforge", "Portal: Darnassus",
        "Portal: Orgrimmar", "Portal: Undercity", "Portal: Thunder Bluff" }, body = [[
        #showtooltip
        /use [mod:ctrl] Portal: Darnassus; [mod:shift] Portal: Ironforge; Portal: Stormwind
        /use [mod:ctrl] Portal: Thunder Bluff; [mod:shift] Portal: Undercity; Portal: Orgrimmar
    ]] },
}
