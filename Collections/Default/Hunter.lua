-- Default hunter macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").HUNTER = {
    -- Melee: Mongoose Bite when it's lit (after a dodge), else Raptor Strike.
    -- ! so mashing doesn't un-queue Raptor Strike (it waits for the next swing).
    { name = "Raptor Strike", learn = "Raptor Strike", spells = { "Raptor Strike", "Mongoose Bite" }, body = [[
        #showtooltip Raptor Strike
        /use Mongoose Bite
        /use !Raptor Strike
    ]] },

    -- The opener (0.2.4, from the Mikey collection, 2026-11-05): an enemy under the mouse becomes your target, then
    -- it's marked. No /startattack (auto mode's generated macro had one): marking comes before the pull, so it
    -- shouldn't start shooting (on Forever /startattack starts Auto Shot).
    { name = "Hunter's Mark", spells = { "Hunter's Mark" }, body = [[
        #showtooltip
        /target [@mouseover,harm,nodead]
        /use Hunter's Mark
    ]] },

    { name = "Scare Beast", spells = { "Scare Beast" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Scare Beast
    ]] },

    -- Pet passive and home first, so it doesn't keep the mob on you; out of
    -- combat it only calls the pet back.
    { name = "Feign Death", spells = { "Feign Death" }, body = [[
        #showtooltip Feign Death
        /petpassive
        /petfollow
        /stopattack
        /stopcasting
        /use [combat] Feign Death
    ]] },

    -- Lands where the mouse points.
    { name = "Flare", spells = { "Flare" }, body = [[
        #showtooltip Flare
        /use [@cursor] Flare
    ]] },

    -- ! so a second press doesn't end the channel and snap the view back to
    -- you: you can recast it to move the eye, like a priest's Mind Vision.
    { name = "Eagle Eye", spells = { "Eagle Eye" }, body = [[
        #showtooltip Eagle Eye
        /use !Eagle Eye
    ]] },

    -- All-in-one pet: Revive Pet if it's dead, Call Pet with none out, else
    -- Mend Pet (Leaku's guide). It first failed because the spellbook lists
    -- Call Pet as "Call <pet's name>"; fixed in Core (RealName) and checked on
    -- Classic Era 2026-11-03 (Mikey).
    -- 0.2.9 (Forever, 2026-11-05): a dead pet that has despawned counts as no
    -- pet, so [nopet] Call Pet fired and failed ("your pet is dead") and Revive
    -- was never reached. Revive comes first now, and a second line revives when
    -- Call Pet fails (a failed cast doesn't stop the next line). No modifier
    -- (Mikey's Shift and Ctrl are bars). Checked in game on Forever (Mikey).
    { name = "Pet", learn = "Call Pet", spells = { "Call Pet", "Revive Pet", "Mend Pet" }, body = [[
        #showtooltip
        /use [@pet,dead] Revive Pet; [nopet] Call Pet; Mend Pet
        /use [nopet] Revive Pet
    ]] },

    -- Pet in: Assist stance (Mikey's trial, 2026-11-02), attack the mouseover,
    -- else your target, with its gap closer (Dash, Dive or a boar's Charge).
    -- Pet spells aren't in your spellbook, so they're not listed; the general
    -- Pet Stop macro puts it back on passive. #showtooltip can't show pet
    -- spells, so it has the pet bar's Attack icon.
    -- 0.2.10 (Mikey's ask, 2026-11-06): with no target, the mouseover becomes it, so you and the pet are on the
    -- same mob ([noexists] checks your target; an existing target is kept).
    { name = "Pet Attack", learn = "Call Pet", spells = { "Call Pet" }, icon = "Ability_GhoulFrenzy", body = [[
        #showtooltip
        /target [noexists] mouseover
        /petassist
        /petattack [@mouseover,harm,nodead] []
        /use Dash
        /use Dive
        /use [@mouseover,harm,nodead] [] Charge
    ]] },
}

ns.Exclude("HUNTER", {
    "Eyes of the Beast",
    "Beast Lore",
    "Tame Beast",
    "Track Beasts",
    "Track Humanoids",
    "Track Undead",
    "Track Hidden",
    "Track Elementals",
    "Track Demons",
    "Track Giants",
    "Track Dragonkin",
    "Dismiss Pet",
    "Feed Pet",
})
