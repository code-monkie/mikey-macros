-- Default warlock macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").WARLOCK = {
    { name = "Fear", spells = { "Fear" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Fear
    ]] },
    -- The best Create Healthstone you know.
    { name = "Healthstone", spells = { "Create Healthstone (Major)", "Create Healthstone (Greater)", "Create Healthstone", "Create Healthstone (Lesser)", "Create Healthstone (Minor)" }, body = [[
        #showtooltip
        /use Create Healthstone (Major); Create Healthstone (Greater); Create Healthstone; Create Healthstone (Lesser); Create Healthstone (Minor)
    ]] },
}

ns.Exclude("WARLOCK", {
    "Eye of Kilrogg",
    "Sense Demons",
    "Detect Lesser Invisibility",
    "Detect Invisibility",
    "Detect Greater Invisibility",
    "Summon Felsteed",
    "Summon Dreadsteed",
    "Enslave Demon",
    "Ritual of Summoning",
})
