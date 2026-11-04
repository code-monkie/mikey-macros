-- Mage macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Mana Gem comes from the Default collection.

local _, ns = ...

ns.Collection("Mikey").MAGE = {
    -- Polymorph through the focus (2026-11-04, Mikey's ask): the living enemy
    -- under the mouse, else your target, becomes your focus (replacing any focus
    -- you had), and Polymorph goes on the focus. /stopattack only when it's your
    -- target being sheeped (the mouseover clause failed), so a sheep on another
    -- mob leaves your attack running.
    { name = "Polymorph", spells = { "Polymorph" }, body = [[
        #showtooltip Polymorph
        /focus [@mouseover,harm,nodead][]
        /stopattack [@mouseover,noexists][@mouseover,noharm][@mouseover,dead]
        /use [@focus] Polymorph
    ]] },
}
