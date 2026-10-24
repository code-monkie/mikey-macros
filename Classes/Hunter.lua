-- Hunter macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255.
-- Modifiers: Shift = fire / second choice, Ctrl = frost / third, Alt = fourth.
-- Pet rider on attacks: attack, defensive in a group, assist when solo.

local _, ns = ...

ns.classes.HUNTER = {
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
    ]] },

    -- Serpent; Shift Scorpid; Ctrl Viper. Mouseover, else target; the pet goes with it.
    { name = "Sting", spells = { "Serpent Sting", "Scorpid Sting", "Viper Sting" }, body = [[
        #showtooltip
        /petattack [@mouseover,harm,nodead] [pet]
        /use [mod:ctrl,@mouseover,harm,nodead] [mod:ctrl] Viper Sting; [mod:shift,@mouseover,harm,nodead] [mod:shift] Scorpid Sting; [@mouseover,harm,nodead] [] Serpent Sting
    ]] },

    { name = "Mark", spells = { "Hunter's Mark" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Hunter's Mark
    ]] },

    { name = "Conc", spells = { "Concussive Shot" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,harm,nodead] [] Concussive Shot
    ]] },

    { name = "Multi", spells = { "Multi-Shot" }, body = [[
        #showtooltip
        /startattack
        /use Multi-Shot
        /use !Auto Shot
    ]] },

    { name = "Aimed", spells = { "Aimed Shot" }, body = [[
        #showtooltip
        /startattack
        /use Aimed Shot
        /use !Auto Shot
    ]] },

    { name = "Raptor", spells = { "Raptor Strike" }, body = [[
        #showtooltip
        /startattack
        /use Raptor Strike
        /petattack [pet]
        /petdefensive [pet,group]
    ]] },

    { name = "Mongoose", spells = { "Mongoose Bite" }, body = [[
        #showtooltip
        /startattack
        /use Mongoose Bite
        /petattack [pet]
        /petdefensive [pet,group]
    ]] },

    { name = "Wing Clip", spells = { "Wing Clip" }, body = [[
        #showtooltip
        /use Wing Clip
    ]] },

    -- Hawk and Cheetah in turn; Shift Monkey.
    { name = "Aspect", spells = { "Aspect of the Hawk", "Aspect of the Cheetah", "Aspect of the Monkey" }, body = [[
        #showtooltip
        /use [mod:shift] Aspect of the Monkey
        /castsequence [nomod] Aspect of the Cheetah, Aspect of the Hawk
    ]] },

    -- Freezing; Shift Immolation; Ctrl Frost; Alt Explosive.
    { name = "Trap", spells = { "Freezing Trap", "Immolation Trap", "Frost Trap", "Explosive Trap" }, body = [[
        #showtooltip
        /use [mod:alt] Explosive Trap; [mod:ctrl] Frost Trap; [mod:shift] Immolation Trap; Freezing Trap
    ]] },

    -- Calls the pet if it's out, then sends it in.
    { name = "Pet", spells = { "Call Pet" }, body = [[
        #showtooltip
        /use [nopet] Call Pet
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Pet Stop", spells = {}, body = [[
        #showtooltip Pet Passive
        /petpassive
        /petfollow
        /petstopattack
    ]] },

    -- Revive a missing or dead pet, otherwise Mend Pet.
    { name = "Mend", spells = { "Revive Pet", "Mend Pet" }, body = [[
        #showtooltip
        /use [nopet] [@pet,dead] Revive Pet
        /use Mend Pet
    ]] },

    { name = "Tame", spells = { "Beast Training", "Tame Beast" }, body = [[
        #showtooltip
        /use [pet] Beast Training; Tame Beast
    ]] },

    { name = "DS", spells = { "Distracting Shot" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Distracting Shot
    ]] },

    { name = "Scare", spells = { "Scare Beast" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Scare Beast
    ]] },
}
