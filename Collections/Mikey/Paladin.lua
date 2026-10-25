-- Paladin macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Turn Undead and Redemption come from the Default collection.

local _, ns = ...

ns.Collection("Mikey").PALADIN = {
    -- Friend under the mouse only.
    { name = "LoH", spells = { "Lay on Hands" }, body = [[
        #showtooltip Lay on Hands
        /cast [@mouseover,help,nodead] Lay on Hands
    ]] },
}
