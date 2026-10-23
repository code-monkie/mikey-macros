-- Shaman macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255. `icon` is a spell ID whose picture shows
-- until you know one of the macro's spells.
-- Modifiers mean the same thing everywhere: Shift = fire, Ctrl = frost.

local _, ns = ...

ns.classes.SHAMAN = {
    -- Your nuke target: a mouseover becomes the target.
    { name = "LB", icon = 403, spells = { "Lightning Bolt" }, body = [[
        #showtooltip
        /target [@mouseover,harm,nodead]
        /startattack
        /use Lightning Bolt
    ]] },

    -- Earth (interrupt, usually an off target), Shift Flame, Ctrl Frost. One shared cooldown.
    { name = "Shock", icon = 8042, spells = { "Earth Shock", "Flame Shock", "Frost Shock" }, body = [[
        #showtooltip
        /startattack
        /use [mod:ctrl,@mouseover,harm,nodead] [mod:ctrl] Frost Shock; [mod:shift,@mouseover,harm,nodead] [mod:shift] Flame Shock; [@mouseover,harm,nodead] [] Earth Shock
    ]] },

    { name = "Purge", icon = 370, spells = { "Purge" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Purge
    ]] },

    { name = "HW", icon = 331, spells = { "Healing Wave" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [] Healing Wave
    ]] },

    { name = "LHW", icon = 8004, spells = { "Lesser Healing Wave" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [] Lesser Healing Wave
    ]] },

    -- Poison; Shift Disease. Mouseover friend, else you.
    { name = "Cure", icon = 526, spells = { "Cure Poison", "Cure Disease" }, body = [[
        #showtooltip
        /use [mod:shift,@mouseover,help,nodead] [mod:shift,@player] Cure Disease; [@mouseover,help,nodead] [@player] Cure Poison
    ]] },

    { name = "LS", icon = 324, spells = { "Lightning Shield" }, body = [[
        #showtooltip
        /use Lightning Shield
    ]] },

    -- Rockbiter; Shift Flametongue; Ctrl Frostbrand; Alt Windfury.
    { name = "Imbue", icon = 8017, spells = { "Rockbiter Weapon", "Flametongue Weapon", "Frostbrand Weapon", "Windfury Weapon" }, body = [[
        #showtooltip
        /use [mod:alt] Windfury Weapon; [mod:ctrl] Frostbrand Weapon; [mod:shift] Flametongue Weapon; Rockbiter Weapon
    ]] },

    -- Stoneskin; Shift Strength of Earth; Ctrl Earthbind; Ctrl+Shift Tremor; Alt Stoneclaw.
    { name = "Earth", icon = 8071, spells = { "Stoneskin Totem", "Strength of Earth Totem", "Earthbind Totem", "Tremor Totem", "Stoneclaw Totem" }, body = [[
        #showtooltip
        /use [mod:alt] Stoneclaw Totem; [mod:ctrl,mod:shift] Tremor Totem; [mod:ctrl] Earthbind Totem; [mod:shift] Strength of Earth Totem; Stoneskin Totem
    ]] },

    -- Searing; Shift Fire Nova; Ctrl Magma; Alt Flametongue.
    { name = "Fire", icon = 3599, spells = { "Searing Totem", "Fire Nova Totem", "Magma Totem", "Flametongue Totem" }, body = [[
        #showtooltip
        /use [mod:alt] Flametongue Totem; [mod:ctrl] Magma Totem; [mod:shift] Fire Nova Totem; Searing Totem
    ]] },

    -- Healing Stream; Shift Mana Spring; Ctrl Poison Cleansing; Alt Disease Cleansing.
    { name = "Water", icon = 5394, spells = { "Healing Stream Totem", "Mana Spring Totem", "Poison Cleansing Totem", "Disease Cleansing Totem" }, body = [[
        #showtooltip
        /use [mod:alt] Disease Cleansing Totem; [mod:ctrl] Poison Cleansing Totem; [mod:shift] Mana Spring Totem; Healing Stream Totem
    ]] },

    -- Call of the Elements; Shift Totemic Recall; Ctrl Call of the Ancestors; Alt Call of the Spirits.
    { name = "Call", icon = 66842, spells = { "Call of the Elements", "Totemic Recall", "Call of the Ancestors", "Call of the Spirits" }, body = [[
        #showtooltip
        /use [mod:alt] Call of the Spirits; [mod:ctrl] Call of the Ancestors; [mod:shift] Totemic Recall; Call of the Elements
    ]] },

    { name = "Wolf", icon = 2645, spells = { "Ghost Wolf" }, body = [[
        #showtooltip
        /dismount [mounted]
        /use !Ghost Wolf
    ]] },

    -- Mouseover a dead friend, else your target.
    { name = "Rez", icon = 2008, spells = { "Ancestral Spirit" }, body = [[
        #showtooltip
        /use [@mouseover,help,dead] [] Ancestral Spirit
    ]] },
}
