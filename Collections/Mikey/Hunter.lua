-- Hunter macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Modifiers: Shift = fire / second choice, Ctrl = frost / third, Alt = fourth.
-- Pet rider on attacks: attack, defensive in a group, assist when solo.

local _, ns = ...

ns.Collection("Mikey").HUNTER = {
    { name = "AS", spells = { "Auto Shot" }, body = [[
        #showtooltip
        /startattack
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Arcane", spells = { "Arcane Shot" }, body = [[
        #showtooltip
        /startattack
        /use Arcane Shot
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    -- Serpent; Shift Scorpid; Ctrl Viper. Mouseover, else target; the pet goes for your target.
    { name = "Sting", spells = { "Serpent Sting", "Scorpid Sting", "Viper Sting" }, body = [[
        #showtooltip
        /use [mod:ctrl,@mouseover,harm,nodead] [mod:ctrl] Viper Sting; [mod:shift,@mouseover,harm,nodead] [mod:shift] Scorpid Sting; [@mouseover,harm,nodead] [] Serpent Sting
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    -- The opener: a mouseover becomes your target, marked, and the pet goes in.
    { name = "Mark", spells = { "Hunter's Mark" }, body = [[
        #showtooltip
        /target [@mouseover,harm,nodead]
        /use Hunter's Mark
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Multi", spells = { "Multi-Shot" }, body = [[
        #showtooltip
        /startattack
        /use Multi-Shot
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Aimed", spells = { "Aimed Shot" }, body = [[
        #showtooltip
        /startattack
        /use Aimed Shot
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Raptor", spells = { "Raptor Strike" }, body = [[
        #showtooltip
        /startattack
        /use Raptor Strike
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Mongoose", spells = { "Mongoose Bite" }, body = [[
        #showtooltip
        /startattack
        /use Mongoose Bite
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    -- Hawk and Cheetah in turn; Shift Monkey; Ctrl Pack.
    { name = "Aspect", spells = { "Aspect of the Hawk", "Aspect of the Cheetah", "Aspect of the Monkey", "Aspect of the Pack" }, body = [[
        #showtooltip
        /use [mod:ctrl] Aspect of the Pack; [mod:shift] Aspect of the Monkey
        /castsequence [nomod] Aspect of the Cheetah, Aspect of the Hawk
    ]] },

    -- Freezing; Shift Immolation; Ctrl Frost; Alt Explosive.
    { name = "Trap", spells = { "Freezing Trap", "Immolation Trap", "Frost Trap", "Explosive Trap" }, body = [[
        #showtooltip
        /use [mod:alt] Explosive Trap; [mod:ctrl] Frost Trap; [mod:shift] Immolation Trap; Freezing Trap
    ]] },

    { name = "Pet Stop", spells = {}, body = [[
        #showtooltip Pet Passive
        /petpassive
        /petfollow
        /petstopattack
    ]] },

    -- Cooldowns together (Bestial Wrath is a talent).
    { name = "Burn", spells = { "Rapid Fire", "Bestial Wrath" }, body = [[
        #showtooltip
        /use Rapid Fire
        /use Bestial Wrath
    ]] },

    -- Talent.
    { name = "Intimidation", spells = { "Intimidation" }, body = [[
        #showtooltip
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
        /use Intimidation
    ]] },
}
