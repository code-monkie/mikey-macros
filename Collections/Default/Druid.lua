-- Default druid macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").DRUID = {
    { name = "Hibernate", spells = { "Hibernate" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Hibernate
    ]] },
    -- Into Cat Form first, then Prowl (out of combat); more presses don't drop it.
    -- Cat Form's number depends on which forms you have, so it's filled in.
    { name = "Prowl", learn = "Prowl", spells = { "Prowl", "Cat Form" }, body = function(c)
        local cat = c.form("Cat Form") or 3
        return ([[
        #showtooltip Prowl
        /dismount
        /use [noform:%d] Cat Form
        /use [form:%d,nostealth,nocombat] Prowl
        ]]):format(cat, cat)
    end },
    -- Out of combat Revive (where the game has it), in combat Rebirth; mouseover first, then your dead target,
    -- else the targeting hand. 0.2.27: @target named, so the friendly NPC you face (Forever's soft target) is
    -- skipped.
    { name = "Res", spells = { "Rebirth", "Revive" }, body = [[
        #showtooltip
        /use [nocombat,@mouseover,help,dead] [nocombat,@target,help,dead] [nocombat] Revive; [@mouseover,help,dead] [@target,help,dead] [] Rebirth
    ]] },
}

ns.Exclude("DRUID", {
    "Teleport: Moonglade",
    "Track Humanoids",
})
