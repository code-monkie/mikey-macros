-- Default rogue macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.
-- Crowd control: /stopattack, so auto-attack doesn't break the effect.
-- ns.Exclude: spells auto mode never makes a macro for (any collection).

local _, ns = ...

ns.Collection("Default").ROGUE = {
    { name = "Sap", spells = { "Sap" }, body = [[
        #showtooltip
        /stopattack
        /use Sap
    ]] },
    -- /stopattack after: a melee ability switches auto-attack on as it fires,
    -- and the next swing would break the Gouge.
    { name = "Gouge", spells = { "Gouge" }, body = [[
        #showtooltip
        /use Gouge
        /stopattack
    ]] },
    { name = "Blind", spells = { "Blind" }, body = [[
        #showtooltip
        /stopattack
        /use [@mouseover,harm,nodead] [] Blind
    ]] },
    -- Off the mount and into Stealth; Pick Pocket (mouseover, else target) once you're in stealth.
    -- 2026-11-07 (Mikey's ask): in stealth with no live enemy targeted, target the nearest one first (as SS and
    -- Backstab in the Mikey collection), so a press with no target still picks a pocket.
    { name = "Stealth", spells = { "Stealth", "Pick Pocket" }, body = [[
        #showtooltip
        /dismount [mounted]
        /stopattack
        /targetenemy [stealth,noharm][stealth,dead]
        /use [stealth,@mouseover,harm,nodead] [stealth] Pick Pocket; !Stealth
    ]] },
    -- Opener (2026-11-02, Mikey's macro): Pick Pocket, then Cheap Shot, in one press from stealth (Pick Pocket
    -- doesn't trigger the global cooldown). No /startattack: the generated Cheap Shot had one, and pressed out of
    -- range it started auto-attack, whose first swing broke stealth. Made when Cheap Shot is learned, not at Pick
    -- Pocket (level 4), which would have made it early, trimmed to a second Pick Pocket button.
    { name = "Cheap Shot", learn = "Cheap Shot", spells = { "Pick Pocket", "Cheap Shot" }, body = [[
        #showtooltip
        /use [stealth] Pick Pocket
        /use Cheap Shot
    ]] },
    -- Vanish in combat; out of combat it's Stealth, so a Vanish is never wasted.
    -- The icon and cooldown always show Vanish.
    { name = "Vanish", spells = { "Vanish" }, body = [[
        #showtooltip Vanish
        /stopattack
        /use [nostealth,combat] Vanish; [nostealth,nocombat] Stealth
    ]] },
    -- Lands where the mouse points.
    { name = "Distract", spells = { "Distract" }, body = [[
        #showtooltip
        /use [@cursor] Distract
    ]] },
}

ns.Exclude("ROGUE", {
    "Pick Lock",
    "Disarm Trap",
    "Evasion",       -- 0.2.13 (Mikey's ask, 2026-11-07); the ClassicWowForever collection's own Evasion macro still wins
})
