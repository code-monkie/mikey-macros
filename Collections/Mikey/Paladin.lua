-- Paladin macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Turn Undead and Redemption come from the Default collection.

local _, ns = ...

ns.Collection("Mikey").PALADIN = {
    -- Friend under the mouse, else your friendly target (0.2.27, Mikey's ask, 2026-11-13; mouseover only before).
    -- No [@player] step: Lay on Hands on yourself isn't wanted here.
    { name = "LoH", spells = { "Lay on Hands" }, body = [[
        #showtooltip Lay on Hands
        /use [@mouseover,help,nodead] [@target,help,nodead] Lay on Hands
    ]] },
}

-- 0.2.26 (Mikey's ask, 2026-11-13): no macros for these blessings; mikey-halo's blessing ring and its Ring 2 bar
-- macro cast them (mouseover, else a friendly target, else you).
ns.Exclude("PALADIN", {
    "Blessing of Might",
    "Blessing of Wisdom",
    "Blessing of Kings",
    "Blessing of Light",   -- Mikey, same day (Salvation is gone on Forever, so it isn't listed)
    -- 0.2.27 (Mikey's ask, same day): the seals too; mikey-halo's seal ring (Ring 1) casts them
    "Seal of Righteousness",
    "Seal of the Crusader",
    "Seal of Light",
    "Seal of Wisdom",
    "Seal of Justice",
    "Seal of Command",
    "Seal of Fury",
    -- 0.2.27 (Mikey's ask, same day): the auras too; mikey-halo's aura ring (Ring 3) casts them
    "Devotion Aura",
    "Retribution Aura",
    "Concentration Aura",
    "Shadow Resistance Aura",
    "Frost Resistance Aura",
    "Fire Resistance Aura",
    "Sanctity Aura",
}, "Mikey")
