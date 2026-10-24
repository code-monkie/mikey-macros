-- Druid macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Bear is always [form:1] (the first form learned). Other form numbers depend
-- on the order you learn forms, so they're avoided: Aquatic uses [swimming].
-- Bear abilities shift you into Bear Form first if you aren't in it.

local _, ns = ...

ns.Collection("Mikey").DRUID = {
    -- Caster -------------------------------------------------------------------
    -- Wrath; Shift Starfire.
    { name = "Wrath", spells = { "Wrath", "Starfire" }, body = [[
        #showtooltip
        /startattack
        /use [mod:shift,@mouseover,harm,nodead] [mod:shift] Starfire; [@mouseover,harm,nodead] [] Wrath
    ]] },

    -- Moonfire; Shift rank 1 (a cheap tag or pull).
    { name = "Moonfire", spells = { "Moonfire" }, body = [[
        #showtooltip
        /startattack
        /use [mod:shift,@mouseover,harm,nodead] [mod:shift] Moonfire(Rank 1); [@mouseover,harm,nodead] [] Moonfire
    ]] },

    -- Healing Touch; Shift rank 2 (a cheap heal).
    { name = "HT", spells = { "Healing Touch" }, body = [[
        #showtooltip
        /use [mod:shift,@mouseover,help,nodead] [mod:shift] Healing Touch(Rank 2); [@mouseover,help,nodead] [] Healing Touch
    ]] },

    -- Mark of the Wild; Shift Thorns. Mouseover friend, else target.
    { name = "Buff", spells = { "Mark of the Wild", "Thorns" }, body = [[
        #showtooltip
        /use [mod:shift,@mouseover,help,nodead] [mod:shift] Thorns; [@mouseover,help,nodead] [] Mark of the Wild
    ]] },

    -- Entangling Roots; Shift Hibernate.
    { name = "Roots", spells = { "Entangling Roots", "Hibernate" }, body = [[
        #showtooltip
        /use [mod:shift,@mouseover,harm,nodead] [mod:shift] Hibernate; [@mouseover,harm,nodead] [] Entangling Roots
    ]] },

    -- Bear ---------------------------------------------------------------------
    -- Into Bear Form; in bear, Frenzied Regeneration (36).
    { name = "Bear", spells = { "Bear Form", "Frenzied Regeneration" }, body = [[
        #showtooltip
        /use [noform:1] !Bear Form; Frenzied Regeneration
    ]] },

    { name = "Maul", spells = { "Maul", "Bear Form" }, body = [[
        #showtooltip Maul
        /startattack
        /use [noform:1] !Bear Form; Maul
    ]] },

    { name = "Swipe", spells = { "Swipe", "Bear Form" }, body = [[
        #showtooltip Swipe
        /startattack
        /use [noform:1] !Bear Form; Swipe
    ]] },

    { name = "Growl", spells = { "Growl", "Bear Form" }, body = [[
        #showtooltip Growl
        /use [noform:1] !Bear Form; [@mouseover,harm,nodead] [] Growl
    ]] },

    { name = "Roar", spells = { "Demoralizing Roar", "Bear Form" }, body = [[
        #showtooltip Demoralizing Roar
        /use [noform:1] !Bear Form; Demoralizing Roar
    ]] },

    { name = "Bash", spells = { "Bash", "Bear Form" }, body = [[
        #showtooltip Bash
        /use [noform:1] !Bear Form; [@mouseover,harm,nodead] [] Bash
    ]] },

    -- Travel -------------------------------------------------------------------
    -- Aquatic Form in water; Cat Form on land (from 20).
    { name = "Forms", spells = { "Aquatic Form", "Cat Form" }, body = [[
        #showtooltip
        /use [swimming] !Aquatic Form; !Cat Form
    ]] },
}
