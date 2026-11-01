-- Default warrior macros: the exceptions to auto mode's generated shape. New
-- characters start on this collection. Each entry here is made (instead of a
-- generated macro) when the character learns its spell.

local _, ns = ...

ns.Collection("Default").WARRIOR = {
    -- Ranged pull: an enemy under the mouse becomes your target, then your
    -- target gets whatever the ranged slot holds (Throw, or Shoot with a bow,
    -- gun or crossbow). The icon is the ranged weapon itself. Throw and the
    -- Shoot spells are on the General tab, so auto mode never makes this
    -- one: /mma sync does.
    { name = "Ranged", spells = { "Throw", "Shoot Bow", "Shoot Gun", "Shoot Crossbow" }, body = [[
        #showtooltip 18
        /target [@mouseover,harm,nodead]
        /use [equipped:Thrown] Throw; [equipped:Bows] !Shoot Bow; [equipped:Guns] !Shoot Gun; [equipped:Crossbows] !Shoot Crossbow
    ]] },
}
