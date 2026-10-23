-- Hunter macros. Write each body in full; spells listed in `spells` are left
-- out of the live macro until you know them. Names must be unique and at most
-- 16 characters; bodies at most 255. `icon` is a spell ID whose picture shows
-- until you know one of the macro's spells.
-- Modifiers: Shift = fire / second choice, Ctrl = frost / third, Alt = fourth.
-- Pet rider on attacks: attack, defensive in a group, assist when solo.

local _, ns = ...

ns.classes.HUNTER = {
    { name = "AS", icon = 75, spells = { "Auto Shot" }, body = [[
        #showtooltip
        /startattack
        /use !Auto Shot
        /petattack [pet]
        /petdefensive [pet,group]
        /petassist [pet,nogroup]
    ]] },

    { name = "Arcane", icon = 3044, spells = { "Arcane Shot" }, body = [[
        #showtooltip
        /startattack
        /use Arcane Shot
        /use !Auto Shot
    ]] },

    -- Serpent; Shift Scorpid; Ctrl Viper. Mouseover, else target; the pet goes with it.
    { name = "Sting", icon = 1978, spells = { "Serpent Sting", "Scorpid Sting", "Viper Sting" }, body = [[
        #showtooltip
        /petattack [@mouseover,harm,nodead] [pet]
        /use [mod:ctrl,@mouseover,harm,nodead] [mod:ctrl] Viper Sting; [mod:shift,@mouseover,harm,nodead] [mod:shift] Scorpid Sting; [@mouseover,harm,nodead] [] Serpent Sting
    ]] },

    { name = "Mark", icon = 1130, spells = { "Hunter's Mark" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Hunter's Mark
    ]] },

    { name = "Conc", icon = 5116, spells = { "Concussive Shot" }, body = [[
        #showtooltip
        /startattack
        /use [@mouseover,harm,nodead] [] Concussive Shot
    ]] },

    { name = "Multi", icon = 2643, spells = { "Multi-Shot" }, body = [[
        #showtooltip
        /startattack
        /use Multi-Shot
        /use !Auto Shot
    ]] },

    { name = "Aimed", icon = 19434, spells = { "Aimed Shot" }, body = [[
        #showtooltip
        /startattack
        /use Aimed Shot
        /use !Auto Shot
    ]] },

    { name = "Raptor", icon = 2973, spells = { "Raptor Strike" }, body = [[
        #showtooltip
        /startattack
        /use Raptor Strike
        /petattack [pet]
        /petdefensive [pet,group]
    ]] },

    { name = "Mongoose", icon = 1495, spells = { "Mongoose Bite" }, body = [[
        #showtooltip
        /startattack
        /use Mongoose Bite
        /petattack [pet]
        /petdefensive [pet,group]
    ]] },

    { name = "Wing Clip", icon = 2974, spells = { "Wing Clip" }, body = [[
        #showtooltip
        /use Wing Clip
    ]] },

    -- Hawk and Cheetah in turn; Shift Monkey.
    { name = "Aspect", icon = 13165, spells = { "Aspect of the Hawk", "Aspect of the Cheetah", "Aspect of the Monkey" }, body = [[
        #showtooltip
        /use [mod:shift] Aspect of the Monkey
        /castsequence [nomod] Aspect of the Cheetah, Aspect of the Hawk
    ]] },

    -- Freezing; Shift Immolation; Ctrl Frost; Alt Explosive.
    { name = "Trap", icon = 1499, spells = { "Freezing Trap", "Immolation Trap", "Frost Trap", "Explosive Trap" }, body = [[
        #showtooltip
        /use [mod:alt] Explosive Trap; [mod:ctrl] Frost Trap; [mod:shift] Immolation Trap; Freezing Trap
    ]] },

    -- Calls the pet if it's out, then sends it in.
    { name = "Pet", icon = 883, spells = { "Call Pet" }, body = [[
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
    { name = "Mend", icon = 136, spells = { "Revive Pet", "Mend Pet" }, body = [[
        #showtooltip
        /use [nopet] [@pet,dead] Revive Pet
        /use Mend Pet
    ]] },

    { name = "Tame", icon = 1515, spells = { "Beast Training", "Tame Beast" }, body = [[
        #showtooltip
        /use [pet] Beast Training; Tame Beast
    ]] },

    { name = "DS", icon = 20736, spells = { "Distracting Shot" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Distracting Shot
    ]] },

    { name = "Scare", icon = 1513, spells = { "Scare Beast" }, body = [[
        #showtooltip
        /use [@mouseover,harm,nodead] [] Scare Beast
    ]] },
}
