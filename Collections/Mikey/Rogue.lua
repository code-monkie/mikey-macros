-- Rogue macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Stealth, Vanish, Blind and Distract come from the Default collection.

local _, ns = ...

ns.Collection("Mikey").ROGUE = {
    -- 2026-11-02: "Attack" (Ambush / Backstab / Sinister Strike in one) split into SS and Backstab. In stealth both
    -- target the nearest enemy if you have none or yours is dead (/startattack would do that but breaks stealth;
    -- out of stealth it picks up a target by itself, checked in game) and pick its pocket first. The icon is named:
    -- a bare #showtooltip would show Pick Pocket on both buttons while stealthed.
    { name = "SS", learn = "Sinister Strike", spells = { "Pick Pocket", "Sinister Strike" }, body = [[
        #showtooltip Sinister Strike
        /targetenemy [stealth,noharm][stealth,dead]
        /use [stealth] Pick Pocket
        /startattack [nostealth]
        /use Sinister Strike
    ]] },

    -- Ambush from stealth, Backstab out of it. 0.2.19 (Mikey's ask, 2026-11-08): both need a dagger, so with no
    -- dagger equipped it's Sinister Strike instead. ([equipped:Daggers] is any dagger in either hand; Backstab and
    -- Ambush want it in the main hand.) 0.2.24 (Mikey, 2026-11-11: learning Ambush didn't update it): with Ambush
    -- known the body came to 273 characters, over 255, so the refresh skipped it. Then (Mikey's call, same day) Pick
    -- Pocket came out of this one (SS still picks pockets), so a bare #showtooltip shows what the last line casts:
    -- Ambush in stealth with a dagger, Backstab with one, else Sinister Strike. "worn:" is the game's own alias for
    -- "equipped:".
    { name = "Backstab", learn = "Backstab", spells = { "Ambush", "Backstab", "Sinister Strike" }, body = [[
        #showtooltip
        /targetenemy [stealth,noharm][stealth,dead]
        /startattack [nostealth]
        /use [stealth,worn:Daggers] Ambush; [worn:Daggers] Backstab; Sinister Strike
    ]] },

    { name = "Bleed", spells = { "Garrote", "Rupture" }, body = [[
        #showtooltip
        /use [stealth] Garrote; Rupture
        /startattack [nostealth]
    ]] },

    -- Sap from stealth, Gouge in combat. Named for neither: Gouge (level 6)
    -- comes before Sap (level 10) (Mikey, 2026-11-03).
    { name = "Disorient", spells = { "Sap", "Gouge" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead,stealth] [stealth] Sap; [@mouseover,harm,nodead] [] Gouge
        /stopattack
    ]] },

    { name = "Kick", spells = { "Kick" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead,nostealth] [nostealth] Kick
    ]] },

    -- Later levels. From stealth: Pick Pocket, then Cheap Shot, in one press (2026-11-02); out of it, Kidney Shot.
    -- Made at Cheap Shot, not at Pick Pocket (level 4), which would have made it early as a lone Pick Pocket.
    { name = "Stun", learn = "Cheap Shot", spells = { "Pick Pocket", "Cheap Shot", "Kidney Shot" }, body = [[
        #showtooltip
        /use [stealth] Pick Pocket
        /use [stealth] Cheap Shot; Kidney Shot
    ]] },
}
