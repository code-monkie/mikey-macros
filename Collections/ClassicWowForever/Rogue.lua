-- ClassicWowForever: Rogue macros from classicwowforever.com, as published.
-- Source: https://classicwowforever.com/macros/rogue/ (reviewed there
-- 12 October 2026; snapshot taken 25 October 2026). The site says these are
-- not yet tested in the live Forever client.
-- Credit: macros by Classic WoW Forever (https://classicwowforever.com/),
-- licensed CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). Bodies
-- are unchanged; only the macro names are ours (16-character limit).
--
-- One macro per main spell (the spell on its unmodified button), made when
-- that spell (`learn`) is learned; other spells in it are trimmed out until
-- you know them. Class-wide macros win; otherwise the first in site order.
-- PvP macros aren't included. What was left out is listed at the bottom.

local _, ns = ...

ns.Collection("ClassicWowForever").ROGUE = {
    -- Class-wide --------------------------------------------------------------
    -- Mouseover Kick (As in Classic)
    { name = "Kick", learn = "Kick",
        spells = { "Kick" }, body = [[
        #showtooltip Kick
        /cast [@mouseover,harm,nodead][] Kick
    ]] },
    -- Mouseover Sap (Adapted from Classic)
    { name = "Sap", learn = "Sap",
        spells = { "Sap" }, body = [[
        #showtooltip Sap
        /cast [@mouseover,harm,nodead][] Sap
    ]] },
    -- Stealth that won't switch itself off (As in Classic)
    { name = "Stealth", learn = "Stealth",
        spells = { "Stealth" }, body = [[
        #showtooltip Stealth
        /dismount
        /cast [nostealth,nocombat] Stealth
    ]] },
    -- Mouseover Pick Pocket (As in Classic)
    { name = "Pick Pocket", learn = "Pick Pocket",
        spells = { "Pick Pocket" }, body = [[
        #showtooltip Pick Pocket
        /cast [@mouseover,harm,nodead][] Pick Pocket
    ]] },
    -- Pick Pocket, then open from Stealth (As in Classic, Level 26+)
    { name = "Cheap Shot", learn = "Cheap Shot",
        spells = { "Pick Pocket", "Stealth", "Garrote", "Ambush", "Cheap Shot" }, body = [[
        #showtooltip [stealth,mod:shift] Garrote; [stealth,mod:ctrl] Ambush; Cheap Shot
        /cast [stealth] Pick Pocket
        /cast [nostealth] Stealth; [mod:shift] Garrote; [mod:ctrl] Ambush; Cheap Shot
    ]] },
    -- Evasion and Sprint together (As in Classic)
    { name = "Evasion", learn = "Evasion",
        spells = { "Evasion", "Sprint" }, body = [[
        #showtooltip Evasion
        /cast Evasion
        /cast Sprint
    ]] },
    -- Stealth out of combat, Vanish in it (As in Classic, Level 22+)
    { name = "Vanish", learn = "Vanish",
        spells = { "Stealth", "Vanish" }, body = [[
        #showtooltip [nocombat] Stealth; Vanish
        /stopattack [combat]
        /cast [nocombat] !Stealth; Vanish
    ]] },

    -- Assassination -----------------------------------------------------------
    -- Rupture and auto attack (As in Classic)
    { name = "Rupture", learn = "Rupture",
        spells = { "Rupture" }, body = [[
        #showtooltip Rupture
        /startattack
        /cast Rupture
    ]] },
    -- Mutilate and auto attack (New in Forever, Level 30+)
    { name = "Mutilate", learn = "Mutilate",
        spells = { "Mutilate" }, body = [[
        #showtooltip Mutilate
        /startattack
        /cast Mutilate
    ]] },
    -- One key for your finishers (As in Classic)
    { name = "Eviscerate", learn = "Eviscerate",
        spells = { "Rupture", "Expose Armor", "Eviscerate" }, body = [[
        #showtooltip [mod:shift] Rupture; [mod:ctrl] Expose Armor; Eviscerate
        /startattack
        /cast [mod:shift] Rupture; [mod:ctrl] Expose Armor; Eviscerate
    ]] },
    -- Slice and Dice, or Venom with Shift (New in Forever, Level 40+)
    { name = "Slice and Dice", learn = "Slice and Dice",
        spells = { "Venom", "Slice and Dice" }, body = [[
        #showtooltip [mod:shift] Venom; Slice and Dice
        /cast [mod:shift] Venom; Slice and Dice
    ]] },
    -- Sinister Strike, or Backstab with Shift (As in Classic)
    { name = "Sinister Strike", learn = "Sinister Strike",
        spells = { "Backstab", "Sinister Strike" }, body = [[
        #showtooltip [mod:shift] Backstab; Sinister Strike
        /startattack
        /cast [mod:shift] Backstab; Sinister Strike
    ]] },

    -- Combat ------------------------------------------------------------------
    -- Blade Flurry, Shift to cancel it (As in Classic)
    { name = "Blade Flurry", learn = "Blade Flurry",
        spells = { "Blade Flurry" }, body = [[
        #showtooltip Blade Flurry
        /cancelaura [mod:shift] Blade Flurry
        /startattack [nomod]
        /cast [nomod] Blade Flurry
    ]] },
    -- Trinkets, Adrenaline Rush, then Blade Flurry (As in Classic, Level 40+)
    { name = "Adrenaline Rush", learn = "Adrenaline Rush",
        spells = { "Adrenaline Rush", "Blade Flurry" }, body = [[
        #showtooltip Adrenaline Rush
        /use 13
        /use 14
        /castsequence reset=20 Adrenaline Rush, Blade Flurry
    ]] },
    -- Backstab when you can, Sinister Strike when you can't (As in Classic)
    { name = "Backstab", learn = "Backstab",
        spells = { "Backstab", "Sinister Strike" }, body = [[
        #showtooltip Backstab
        /startattack [nostealth]
        /cast Backstab
        /cast Sinister Strike
    ]] },

    -- Subtlety ----------------------------------------------------------------
    -- Hemorrhage and auto attack (Adapted from Classic, Level 30+)
    { name = "Hemorrhage", learn = "Hemorrhage",
        spells = { "Hemorrhage" }, body = [[
        #showtooltip Hemorrhage
        /startattack
        /cast Hemorrhage
    ]] },
    -- Ambush when Cutthroat allows it, else Backstab (New in Forever)
    { name = "Ambush", learn = "Ambush",
        spells = { "Ambush", "Backstab" }, body = [[
        #showtooltip Ambush
        /cast Ambush
        /cast Backstab
        /startattack [nostealth]
    ]] },
    -- Premeditation, Cheap Shot, then Kidney Shot (Adapted from Classic, Level 30+)
    { name = "Kidney Shot", learn = "Kidney Shot",
        spells = { "Premeditation", "Cheap Shot", "Kidney Shot" }, body = [[
        #showtooltip [stealth] Cheap Shot; Kidney Shot
        /cast [stealth] Premeditation
        /cast [stealth] Cheap Shot; Kidney Shot
    ]] },
    -- Ghostly Strike when ready, else Backstab (Adapted from Classic)
    { name = "Ghostly Strike", learn = "Ghostly Strike",
        spells = { "Ghostly Strike", "Backstab" }, body = [[
        #showtooltip Ghostly Strike
        /startattack [nostealth]
        /cast Ghostly Strike
        /cast Backstab
    ]] },
    -- Burn your escapes, then Preparation (As in Classic, Level 30+)
    { name = "Preparation", learn = "Preparation",
        spells = { "Vanish", "Evasion", "Sprint", "Preparation" }, body = [[
        #showtooltip Preparation
        /stopattack [mod:shift]
        /cast [mod:shift] Vanish; Evasion
        /cast Sprint
        /cast Preparation
    ]] },
}

-- Not made: no spell to learn (items or equipment slots only):
--   Use both trinkets (Class-wide)
--   Apply a poison from one key (Class-wide)
--   Sharpen your weapons from one key (Class-wide)
-- Not made: another macro above already has the same main spell:
--   Cold Blood into Eviscerate or Mutilate (Assassination) -> same main spell as "One key for your finishers"
--   Ambush from Stealth, then Mutilate (Assassination) -> same main spell as "Mutilate and auto attack"
--   Garrote from Stealth, Rupture in the fight (Assassination) -> same main spell as "Rupture and auto attack"
--   Three Mutilates, then Eviscerate (Assassination) -> same main spell as "Mutilate and auto attack"
--   Mutilate, then Slice and Dice to start a long fight (Assassination) -> same main spell as "Mutilate and auto attack"
--   Riposte, then Sinister Strike (Combat) -> same main spell as "Sinister Strike, or Backstab with Shift"
--   Your core attacks on one key (Combat) -> same main spell as "Sinister Strike, or Backstab with Shift"
--   Garrote from Stealth, Sinister Strike after (Combat) -> same main spell as "Sinister Strike, or Backstab with Shift"
--   Two Sinister Strikes, then Slice and Dice (Combat) -> same main spell as "Slice and Dice, or Venom with Shift"
--   Five Sinister Strikes, then Eviscerate (Combat) -> same main spell as "Sinister Strike, or Backstab with Shift"
--   Slice and Dice, with a Frenzy Potion on Shift (Combat) -> same main spell as "Slice and Dice, or Venom with Shift"
--   Equip your weapons for Sinister Strike (Combat) -> same main spell as "Sinister Strike, or Backstab with Shift"
--   Cheap Shot from Stealth (Subtlety) -> same main spell as "Pick Pocket, then open from Stealth"
--   Target and Sap the nearest enemy (Subtlety) -> same main spell as "Mouseover Sap"
--   Hemorrhage, Rupture and Backstab on one key (Subtlety) -> same main spell as "Hemorrhage and auto attack"
--   Pick Pocket, then Sap from Stealth (Subtlety) -> same main spell as "Mouseover Sap"
--   Equip a dagger for Ambush or Backstab (Subtlety) -> same main spell as "Ambush when Cutthroat allows it, else Backstab"
