-- Druid macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Bear is always [form:1] (the first form learned). Other form numbers depend
-- on the order you learn forms, so they're avoided: Aquatic uses [swimming].
-- Bear abilities shift you into Bear Form first if you aren't in it.
-- One spell per macro, no modifier branches: Shift and Ctrl are their own
-- bars (Shift+1-7, Ctrl+1-7).

local _, ns = ...

ns.Collection("Mikey").DRUID = {
    -- Caster -------------------------------------------------------------------
    -- Wrath, Starfire, Mark of the Wild and Thorns: auto mode's generated macros
    -- (/startattack + mouseover for damage, mouseover friend for buffs).
    -- Moonfire and Healing Touch are spelled out because their low-rank macros
    -- below cover the spells (auto mode would otherwise skip them).
    { name = "Moonfire", spells = { "Moonfire" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,harm,nodead] [] Moonfire
    ]] },

    -- Rank 1: a cheap tag or pull.
    { name = "MF1", spells = { "Moonfire" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,harm,nodead] [] Moonfire(Rank 1)
    ]] },

    { name = "HT", spells = { "Healing Touch" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [] Healing Touch
    ]] },

    -- Rank 2: a cheap heal.
    { name = "HT2", spells = { "Healing Touch" }, body = [[
        #showtooltip
        /use [@mouseover,help,nodead] [] Healing Touch(Rank 2)
    ]] },

    -- Hibernate comes from the Default collection (/stopattack, mouseover).
    { name = "Roots", spells = { "Entangling Roots" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Entangling Roots
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
