-- mikey-macros: per-character class macros that maintain themselves.
-- Macro definitions live in Collections\<Owner>\<Class>.lua. /mm sync creates them all once;
-- after that each macro is rewritten automatically (out of combat) to contain
-- only the spells you know, so fall-through lines and icons always work.
-- The addon owns these macros: change them in the data file, not in game
-- (renaming one in game takes it out of the addon's hands).

local _, ns = ...
-- Collections: whose macro lists. Each Collections\<Owner>\<Class>.lua file adds a
-- class to its owner's collection with ns.Collection("<Owner>").<CLASS> = { ... }.
-- The Default collection (Collections\Default) holds the exceptions to auto
-- mode's generated macros and applies under every collection: the followed
-- collection wins where it has a macro for the spell. New characters start on
-- Default; /mm use <name> picks another.
local DEFAULT = "Default"
local PREFERRED = "Mikey" -- only used to adopt characters set up before opting in existed
ns.collections = {}
function ns.Collection(owner)
    local c = ns.collections[owner]
    if not c then
        c = {}
        ns.collections[owner] = c
    end
    return c
end

-- Spells auto mode never makes a macro for, by class.
-- ns.Exclude("HUNTER", { "Eyes of the Beast", ... }) in Collections\Default
-- applies whatever the collection. A collection can add its own on top, for
-- characters following it: ns.Exclude("SHAMAN", { ... }, "Mikey").
ns.excluded = {}      -- [class] = set, every collection
ns.excludedBy = {}    -- [owner][class] = set, only that collection's followers
function ns.Exclude(class, spells, owner)
    local root = ns.excluded
    if owner then
        ns.excludedBy[owner] = ns.excludedBy[owner] or {}
        root = ns.excludedBy[owner]
    end
    local set = root[class] or {}
    for _, spell in ipairs(spells) do set[spell:lower()] = true end
    root[class] = set
end

local ICON = 134400 -- question mark; #showtooltip supplies the real icon
local MAX_BODY = 255

local function Print(...)
    print("|cff33ff99mikey-macros|r:", ...)
end

local function AccountMax()
    return MAX_ACCOUNT_MACROS or 120
end

local function CharacterMax()
    return MAX_CHARACTER_MACROS or (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and 30 or 18)
end

-- Names (lowercased) of every spell in the player's spellbook that is actually
-- learned: no future spells, no off-spec spells.
local function KnownSpells()
    local known = {}
    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then -- retail
        local bank = Enum.SpellBookSpellBank.Player
        for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
            if info then
                for i = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
                    local item = C_SpellBook.GetSpellBookItemInfo(i, bank)
                    if item and item.name and not item.isOffSpec
                        and item.itemType == Enum.SpellBookItemType.Spell then
                        known[item.name:lower()] = true
                    end
                end
            end
        end
    else -- classic-based clients
        for tab = 1, GetNumSpellTabs() do
            local _, _, offset, count = GetSpellTabInfo(tab)
            for i = offset + 1, offset + count do
                local kind = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
                local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
                if kind == "SPELL" and name then
                    known[name:lower()] = true
                end
            end
        end
    end
    return known
end

-- name -> index of this character's macros, plus how many there are.
local function CharacterMacros()
    local byName = {}
    local _, numChar = GetNumMacros()
    local first = AccountMax() + 1
    for index = first, first + numChar - 1 do
        local name = GetMacroInfo(index)
        if name then byName[name] = index end
    end
    return byName, numChar
end

-- The spells that create a macro when learned: def.learn (one name or a list)
-- if given, else every spell in def.spells. def.spells is always the trimming
-- list; learn only narrows which of them make the macro appear. Lets a macro
-- that names several spells (finishers on modifiers) be made once, for its
-- main spell, instead of for each spell in it.
local function LearnSpells(def)
    if def.learn == nil then return def.spells end
    if type(def.learn) == "table" then return def.learn end
    return { def.learn }
end

local function IsLearned(def, known)
    for _, spell in ipairs(LearnSpells(def)) do
        if known[spell:lower()] then return true end
    end
    return false
end

-- Is a dagger in the main hand?
local function MainHandDagger()
    local id = GetInventoryItemID("player", INVSLOT_MAINHAND or 16)
    if not id then return false end
    local getInfo = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    local _, _, _, _, _, classID, subclassID = getInfo(id)
    return classID == 2 and subclassID == 15 -- Weapon, Dagger
end

-- The number of a shapeshift form or stance as [form:N] sees it, or nil if you
-- don't have it. Form numbers follow the stance bar, so they shift as forms are
-- learned (Cat Form is 2 before Aquatic Form, 3 after); a macro built with this
-- is rewritten when they change.
local function FormIndex(name)
    local low = name:lower()
    for i = 1, (GetNumShapeshiftForms and GetNumShapeshiftForms() or 0) do
        local _, _, _, spellID = GetShapeshiftFormInfo(i)
        local formName = spellID and (
            (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellID))
            or (GetSpellInfo and GetSpellInfo(spellID)))
        if formName and formName:lower() == low then return i end
    end
end

-- What a dynamic macro body can ask about the character.
local function Context(known)
    return {
        knows = function(spell) return known[spell:lower()] == true end,
        dagger = MainHandDagger(),
        form = FormIndex,
    }
end

-- Strip indentation and surrounding blank space so data files stay readable.
-- A spell name as the macro writes it, ready for lookup: no leading !, no
-- trailing (Rank n). "Earth Shock(Rank 1)" counts as Earth Shock.
local function BaseName(text)
    local name = text:match("^%s*!?%s*(.-)%s*$")
    return (name:gsub("%s*%(%s*[Rr]ank%s*%d+%s*%)$", ""))
end

-- Drop every clause (or whole /use, /cast or /castsequence line) naming one of
-- the macro's spells that isn't known yet. In a /castsequence, unknown spells
-- are dropped from the sequence; #showtooltip loses its clauses for unknown
-- spells the same way ("#showtooltip [mod:shift] Rupture; Eviscerate" before
-- Rupture is "#showtooltip Eviscerate"), and becomes a bare #showtooltip when
-- none are left. Anything not in def.spells is left alone.
local function KnownOnly(body, def, ctx)
    local tracked = {}
    for _, spell in ipairs(def.spells) do tracked[spell:lower()] = true end
    local function keep(text)
        local name = BaseName(text)
        return not tracked[name:lower()] or ctx.knows(name)
    end
    local out = {}
    for line in (body .. "\n"):gmatch("(.-)\n") do
        -- #showtooltip: drop clauses for spells you don't know yet
        local tip, arg = line:match("^(#[Ss][Hh][Oo][Ww][Tt][Oo][Oo][Ll][Tt][Ii][Pp])%s+(.-)%s*$")
        if tip and arg ~= "" then
            local kept = {}
            for clause in (arg .. ";"):gmatch("([^;]*);") do
                clause = clause:match("^%s*(.-)%s*$")
                if clause ~= "" then
                    local action = clause:match("^.*%]%s*(.-)$") or clause
                    if keep(action) then kept[#kept + 1] = clause end
                end
            end
            line = #kept > 0 and (tip .. " " .. table.concat(kept, "; ")) or tip
        end
        local cmd, rest = line:match("^(/%a+)%s+(.*)$")
        local lower = cmd and cmd:lower()
        if lower == "/use" or lower == "/cast" or lower == "/castsequence" then
            local kept = {}
            for clause in (rest .. ";"):gmatch("([^;]*);") do
                clause = clause:match("^%s*(.-)%s*$")
                if clause ~= "" then
                    -- split "[conditions] reset=x " from the action
                    local conds, action = clause:match("^(.*%])%s*(.-)$")
                    if not conds then conds, action = "", clause end
                    if lower == "/castsequence" then
                        local reset, list = action:match("^(reset=%S+)%s+(.*)$")
                        list = list or action
                        local spells = {}
                        for item in (list .. ","):gmatch("([^,]*),") do
                            item = item:match("^%s*(.-)%s*$")
                            if item ~= "" and keep(item) then spells[#spells + 1] = item end
                        end
                        if #spells > 0 then
                            local parts = {}
                            if conds ~= "" then parts[#parts + 1] = conds end
                            if reset then parts[#parts + 1] = reset end
                            parts[#parts + 1] = table.concat(spells, ", ")
                            kept[#kept + 1] = table.concat(parts, " ")
                        end
                    elseif keep(action) then
                        kept[#kept + 1] = clause
                    end
                end
            end
            if #kept > 0 then out[#out + 1] = cmd .. " " .. table.concat(kept, "; ") end
        else
            out[#out + 1] = line
        end
    end
    return table.concat(out, "\n")
end

local function Clean(def, ctx)
    local body = def.body
    if type(body) == "function" then body = body(ctx) end
    body = body:gsub("\r", ""):gsub("\n[ \t]+", "\n"):gsub("^%s+", ""):gsub("%s+$", "")
    return KnownOnly(body, def, ctx)
end

local function CharDB()
    MikeyMacrosCharDB = MikeyMacrosCharDB or {}
    return MikeyMacrosCharDB
end

local Collections -- prints the installed collections; defined further down

-- The collection name matching `name` (any case), or nil.
local function FindCollection(name)
    for owner in pairs(ns.collections) do
        if owner:lower() == name:lower() then return owner end
    end
end

-- Whose list this character follows for `class`: the collection chosen with
-- /mm use, if it has the class. Nothing is followed until you opt in.
local function ActiveCollection(class)
    local chosen = CharDB().collection
    if chosen and ns.collections[chosen] and ns.collections[chosen][class] then return chosen end
end

-- The spells auto mode skips for this character: every collection's list plus
-- the followed collection's own.
local function Excluded(class)
    local set = {}
    for low in pairs(ns.excluded[class] or {}) do set[low] = true end
    local owner = ActiveCollection(class)
    local own = owner and ns.excludedBy[owner] and ns.excludedBy[owner][class]
    for low in pairs(own or {}) do set[low] = true end
    return set
end

-- This character's macro list and its owner (nil if no collection has the class).
local function ActiveList()
    local _, class = UnitClass("player")
    local owner = ActiveCollection(class)
    if owner then return ns.collections[owner][class], owner end
end

-- The Default collection's macros this character gets on top of the collection
-- it follows (on Default, ActiveList already has them): each one whose spells
-- and name the followed collection doesn't already have. A spell on the
-- followed collection's own exclude list counts as taken too: that collection
-- doesn't want a managed macro for it, so Default's is dropped as well.
local function DefaultList()
    local _, class = UnitClass("player")
    local defaults = ns.collections[DEFAULT] and ns.collections[DEFAULT][class]
    local list, owner = ActiveList()
    if not defaults or owner == DEFAULT then return {} end
    local taken = {}
    for _, def in ipairs(list or {}) do
        taken[def.name] = true
        for _, spell in ipairs(LearnSpells(def)) do taken[spell:lower()] = true end
    end
    local own = owner and ns.excludedBy[owner] and ns.excludedBy[owner][class]
    for low in pairs(own or {}) do taken[low] = true end
    local out = {}
    for _, def in ipairs(defaults) do
        local free = not taken[def.name]
        for _, spell in ipairs(LearnSpells(def)) do
            if taken[spell:lower()] then free = false end
        end
        if free then out[#out + 1] = def end
    end
    return out
end

-- Every collection macro this character gets, followed collection first, then
-- the Default collection's under it.
local function Definitions()
    local out = {}
    for _, def in ipairs(ActiveList() or {}) do out[#out + 1] = def end
    for _, def in ipairs(DefaultList()) do out[#out + 1] = def end
    return out
end

local function ClassList()
    local list, owner = ActiveList()
    if not list then
        local _, class = UnitClass("player")
        local chosen = CharDB().collection
        if chosen and ns.collections[chosen] then
            Print(chosen .. "'s collection has no " .. class:lower() .. " macros. Pick another with /mm use <name>:")
        else
            Print("this character doesn't follow a collection (auto mode makes its macros). To use one, /mm use <name>:")
        end
        Collections()
    end
    return list, owner
end

local function CanEdit()
    if InCombatLockdown() then
        Print("macros can't be changed in combat; try again after the fight.")
        return false
    end
    return true
end

-- Open Blizzard's macro window on the character-specific tab.
local function ShowCharacterMacros()
    if InCombatLockdown() then return end
    if not (MacroFrame and MacroFrame:IsShown()) and ShowMacroFrame then ShowMacroFrame() end
    if MacroFrameTab2 then MacroFrameTab2:Click() end
end

-- Rewrite existing macros to match the data file and the spells you know
-- (keeps their action bar spots). Normally only changed bodies are rewritten;
-- force rewrites every macro.
local function Refresh(force)
    local defs = Definitions()
    if #defs == 0 or InCombatLockdown() then return {} end
    local ctx = Context(KnownSpells())
    local have = CharacterMacros()
    local updated = {}
    for _, def in ipairs(defs) do
        local index = have[def.name]
        if index then
            local body = Clean(def, ctx)
            if #body <= MAX_BODY then
                local _, _, current = GetMacroInfo(index)
                if force or current ~= body then
                    EditMacro(index, def.name, ICON, body)
                    updated[#updated + 1] = def.name
                end
            end
        end
    end
    return updated
end

local function Update()
    if not ClassList() or not CanEdit() then return end
    local updated = Refresh(true)
    if #updated > 0 then
        Print("updated " .. #updated .. ": " .. table.concat(updated, ", "))
    else
        Print("everything already matches.")
    end
end

-- Auto mode ---------------------------------------------------------------------
-- With /mm auto on, every class spell this character learns from then on gets a
-- macro, by priority: the followed collection's macro for the spell, else the
-- Default collection's, else a generated one (see AutoBody), unless the spell
-- is excluded. /mm sync does the same for every spell you already know. Spells are matched by name, so
-- only a new spell (rank 1 or unranked) counts, never a higher rank. These
-- macros are yours: the addon never rewrites or clears them.

-- Names (lowercase -> as shown) of the usable spells on the class tabs of the
-- spellbook: no General tab (Attack, racials, professions, mounts), no
-- passives, no off-spec or future spells.
local function ClassSpells()
    local spells = {}
    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then -- retail
        local bank = Enum.SpellBookSpellBank.Player
        for line = 2, C_SpellBook.GetNumSpellBookSkillLines() do -- line 1 is General
            local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
            if info and not info.isGuild and not (info.offSpecID and info.offSpecID ~= 0) then
                for i = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
                    local item = C_SpellBook.GetSpellBookItemInfo(i, bank)
                    if item and item.name and not item.isPassive and not item.isOffSpec
                        and item.itemType == Enum.SpellBookItemType.Spell then
                        spells[item.name:lower()] = item.name
                    end
                end
            end
        end
    else -- classic-based clients
        for tab = 2, GetNumSpellTabs() do -- tab 1 is General
            local _, _, offset, count = GetSpellTabInfo(tab)
            for i = offset + 1, offset + count do
                local kind = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
                local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
                if kind == "SPELL" and name and not IsPassiveSpell(i, BOOKTYPE_SPELL) then
                    spells[name:lower()] = name
                end
            end
        end
    end
    return spells
end

-- A macro name for a spell: the name itself, or its initials when it's longer
-- than 16 characters (Blessing of Might -> BoM).
local function AutoName(spell)
    if #spell <= 16 then return spell end
    local initials = ""
    for word in spell:gmatch("[^%s%-]+") do initials = initials .. word:sub(1, 1) end
    return initials:sub(1, 16)
end

-- What the game says about a spell, on classic-based and retail clients alike.
local function SpellFacts(spell)
    local id, maxRange, harmful, helpful, repeating, desc, subtext
    -- Classic clients first: their C_Spell.GetSpellInfo swaps minRange and maxRange.
    if not GetSpellInfo and C_Spell and C_Spell.GetSpellInfo then -- retail
        local info = C_Spell.GetSpellInfo(spell)
        if not info then return {} end
        id, maxRange = info.spellID, info.maxRange
        harmful, helpful = C_Spell.IsSpellHarmful(id), C_Spell.IsSpellHelpful(id)
        repeating = C_Spell.IsAutoRepeatSpell and C_Spell.IsAutoRepeatSpell(id)
        desc = C_Spell.GetSpellDescription and C_Spell.GetSpellDescription(id)
        subtext = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(id)
    else
        local _
        _, _, _, _, _, maxRange, id = GetSpellInfo(spell)
        if not id then return {} end
        harmful, helpful = IsHarmfulSpell(spell), IsHelpfulSpell(spell)
        repeating = IsAutoRepeatSpell(spell)
        desc = GetSpellDescription and GetSpellDescription(id)
        subtext = GetSpellSubtext and GetSpellSubtext(id)
    end
    desc, subtext = (desc or ""):lower(), (subtext or ""):lower()
    return {
        harmful = harmful and true or false,
        helpful = helpful and true or false,
        ranged = (maxRange or 0) > 6, -- melee reach is 5 yards
        -- only ever lands on your pet or demon (Mend Pet, Health Funnel, Dark Pact)
        petOnly = desc:find("your pet") ~= nil or desc:find("caster's pet") ~= nil
            or desc:find("summoned demon") ~= nil,
        -- a second press shouldn't switch it off: stances, forms, stealth, aspects,
        -- seals, auras, auto-repeat shots
        toggle = repeating and true or subtext:find("shapeshift") ~= nil
            or desc:find("until cancel") ~= nil
            or desc:find("only one [%a%s]- can be active") ~= nil
            or desc:find("only one [%a%s]- at a time") ~= nil
            or desc:find("only one [%a%s]- at any one time") ~= nil,
    }
end

-- The macro auto mode writes for a newly learned spell:
--   harmful        -> /startattack first
--   ranged harmful -> [@mouseover,harm,nodead] [] (mouseover, else target)
--   ranged helpful -> [@mouseover,help,nodead] []
--   pet-only       -> no mouseover (the spell picks your pet itself)
--   toggles        -> ! so a second press doesn't cancel it
local function AutoBody(spell)
    local f = SpellFacts(spell)
    local body = "#showtooltip\n"
    if f.harmful then body = body .. "/startattack\n" end
    local target = ""
    local ranged = f.ranged and not f.petOnly
    if ranged and f.harmful then
        target = "[@mouseover,harm,nodead] [] "
    elseif ranged and f.helpful then
        target = "[@mouseover,help,nodead] [] "
    end
    return body .. "/use " .. target .. (f.toggle and "!" or "") .. spell
end

-- Put each new macro on the action buttons holding the spell it was made for
-- (the starting spells at level 1; on retail, spells the game places as you
-- learn them). Empty buttons are never filled. Out of combat, empty cursor only.
-- Returns the names of the macros it placed.
-- General (account) macro swapped onto a new character's Attack button; made if missing.
-- Slot 16 is the main hand, so the button shows your weapon.
local ATTACK_MACRO = "Attack"
local ATTACK_BODY = "#showtooltip 16\n/startattack"

local function SwapIntoBars(made)
    local placed = {}
    if #made == 0 or InCombatLockdown() or GetCursorInfo() then return placed end
    local bySpell = {}
    for _, m in ipairs(made) do
        if m.swap ~= false then bySpell[m.spell:lower()] = m.name end
    end
    for slot = 1, 180 do
        local kind, id = GetActionInfo(slot)
        if kind == "spell" and id then
            local spell = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id))
                or (GetSpellInfo and GetSpellInfo(id))
            local macro = spell and bySpell[spell:lower()]
            local index = macro and GetMacroIndexByName(macro)
            if index and index > 0 then
                PickupMacro(index)
                PlaceAction(slot) -- the spell comes back on the cursor
                ClearCursor()
                placed[macro] = true
            end
        end
    end
    return placed
end

-- The Attack macro onto ATTACK_SLOT, and the Attack spell off the rest of bar 1.
-- Out of combat, empty cursor only. A button 9 already holding something else is
-- left alone (said in chat), and then the Attack spell stays where it is too.
local ATTACK_SLOT = 9 -- bar 1, button 9 (7 until Mikey moved it, 2026-10-29)
local function PlaceAttack()
    local index = GetMacroIndexByName(ATTACK_MACRO)
    if index == 0 or InCombatLockdown() or GetCursorInfo() then return end
    local kind, id = GetActionInfo(ATTACK_SLOT)
    local isAttackSpell = function(k, i)
        local name = k == "spell" and i and ((C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(i))
            or (GetSpellInfo and GetSpellInfo(i)))
        return name and name:lower() == "attack"
    end
    local mine = kind == "macro" and id == index
    if kind and not mine and not isAttackSpell(kind, id) then
        Print("bar 1 button " .. ATTACK_SLOT .. " is taken; drag the " .. ATTACK_MACRO .. " macro onto your bar by hand.")
        return
    end
    if not mine then
        PickupMacro(index)
        PlaceAction(ATTACK_SLOT)
        ClearCursor()
    end
    for slot = 1, 12 do
        if slot ~= ATTACK_SLOT and isAttackSpell(GetActionInfo(slot)) then
            PickupAction(slot)
            ClearCursor()
        end
    end
end

local function AutoCreate()
    local db = CharDB()
    if db.auto == false or InCombatLockdown() then return end -- on unless switched off
    local current = ClassSpells()
    local brandNew = false
    if not db.autoKnown then
        -- First time the addon sees this character: a brand-new (level 1) one gets
        -- macros for its starting spells; an existing one is left as it is.
        if UnitLevel("player") > 1 then
            if not next(current) then return end -- spellbook not loaded yet; try again later
            db.autoKnown = {}
            for low in pairs(current) do db.autoKnown[low] = true end
            return
        end
        db.autoKnown = {}
        brandNew = true
    end
    local known = db.autoKnown
    -- Collection macros by the spells that make them (followed collection first,
    -- then Default's). A spell can make several macros (e.g. Summon Voidwalker
    -- gates both pet-spell macros); learning it makes all of them. A spell on a
    -- collection macro you have (as a modifier or sequence step, not the spell
    -- it's made for) is covered: no generated macro of its own. Until that
    -- macro exists, the spell gets one as usual.
    local defs, covered, ctx = {}, {}, nil
    for _, def in ipairs(Definitions()) do
        if IsLearned(def, current) then
            for _, spell in ipairs(def.spells) do covered[spell:lower()] = true end
        end
        for _, spell in ipairs(LearnSpells(def)) do
            local low = spell:lower()
            defs[low] = defs[low] or {}
            table.insert(defs[low], def)
        end
    end
    local _, class = UnitClass("player")
    local excluded = Excluded(class)
    local have, count = CharacterMacros()
    local created, full, skipped = {}, {}, {}
    local made = {} -- { name = macro, spell = the spell just learned }, for SwapIntoBars
    local spellsInOrder = {}
    for low, name in pairs(current) do
        if not known[low] then
            if excluded[low] and not defs[low] then -- a macro you follow still wins
                known[low] = true -- reported once, never made
                skipped[#skipped + 1] = name
            else
                spellsInOrder[#spellsInOrder + 1] = name
            end
        end
    end
    table.sort(skipped)
    table.sort(spellsInOrder)
    for _, spell in ipairs(spellsInOrder) do
        known[spell:lower()] = true -- remembered either way, so it's only ever handled once
        local list = defs[spell:lower()]
        if list then
            for _, def in ipairs(list) do
                if have[def.name] then
                    -- already made (for another of its spells); Refresh keeps it current
                elseif count >= CharacterMax() then
                    full[#full + 1] = spell
                else
                    ctx = ctx or Context(KnownSpells())
                    local body = Clean(def, ctx)
                    CreateMacro(def.name, ICON, body, true)
                    have[def.name] = true
                    count = count + 1
                    created[#created + 1] = def.name
                    -- swap onto the spell's buttons only if the macro casts it
                    -- (not a pet-spell macro gated on Summon Voidwalker)
                    local swap = body:lower():find(spell:lower(), 1, true) ~= nil
                    made[#made + 1] = { name = def.name, spell = spell, swap = swap }
                end
            end
        elseif covered[spell:lower()] then
            -- on another collection macro (a modifier or sequence step): no macro of its own
        else
            local name = AutoName(spell)
            if have[name] then
                local n = 2 -- name taken (e.g. two spells with the same initials)
                while have[name:sub(1, 15) .. n] do n = n + 1 end
                name = name:sub(1, 15) .. n
            end
            if count >= CharacterMax() then
                full[#full + 1] = spell
            else
                CreateMacro(name, ICON, AutoBody(spell), true)
                have[name] = true
                count = count + 1
                made[#made + 1] = { name = name, spell = spell }
                created[#created + 1] = (name == spell) and spell or (name .. " (" .. spell .. ")")
            end
        end
    end
    -- Anything that didn't land on a bar: open the macro window to drag it there.
    local placed = SwapIntoBars(made)
    for _, m in ipairs(made) do
        if not placed[m.name] then
            ShowCharacterMacros()
            break
        end
    end
    -- A brand-new character gets the general (account) macro "Attack" on bar 1
    -- button 9, made first if the account doesn't have it yet (an existing one is
    -- used as it is, whatever its body). The game's own Attack spell is cleared
    -- from bar 1, so Attack lives only on button 9 (Mikey's layout, 2026-10-29).
    if brandNew then
        if GetMacroIndexByName(ATTACK_MACRO) == 0 then
            local numAccount = GetNumMacros()
            if numAccount < AccountMax() then
                CreateMacro(ATTACK_MACRO, ICON, ATTACK_BODY, false)
                Print("new general macro: " .. ATTACK_MACRO)
            else
                Print("|cffff6060no free general slots|r for the " .. ATTACK_MACRO .. " macro")
            end
        end
        PlaceAttack()
    end
    if #created > 0 then Print("new spell macro: " .. table.concat(created, ", ")) end
    if #skipped > 0 then Print("no macro (excluded): " .. table.concat(skipped, ", ")) end
    if #full > 0 then
        Print("|cffff6060no free character slots|r for new spell macros: " .. table.concat(full, ", "))
    end
end

-- /mm sync: what auto mode would have made for every spell you already know
-- (collection macro, else Default's, else generated unless excluded; generated
-- only while auto mode is on). With all, collection macros for spells not
-- learned yet are created too, as placeholders. Existing macros are left alone.
local function Sync(all)
    if not CanEdit() then return end
    local known = KnownSpells()
    local ctx = Context(known)
    local have, count = CharacterMacros()
    local created, full, tooLong, covered = {}, {}, {}, {}
    local function add(name, body, label)
        if #body > MAX_BODY then
            tooLong[#tooLong + 1] = name
        elseif count >= CharacterMax() then
            full[#full + 1] = name
        else
            CreateMacro(name, ICON, body, true)
            have[name] = true
            count = count + 1
            created[#created + 1] = label or name
        end
    end
    for _, def in ipairs(Definitions()) do
        if all or IsLearned(def, known) then
            for _, spell in ipairs(def.spells) do covered[spell:lower()] = true end
            if not have[def.name] then add(def.name, Clean(def, ctx)) end
        end
    end
    if CharDB().auto ~= false then
        local _, class = UnitClass("player")
        local excluded = Excluded(class)
        local spells = {}
        for low, name in pairs(ClassSpells()) do
            if not covered[low] and not excluded[low] then spells[#spells + 1] = name end
        end
        table.sort(spells)
        for _, spell in ipairs(spells) do
            local name = AutoName(spell)
            if not have[name] then
                add(name, AutoBody(spell), (name == spell) and spell or (name .. " (" .. spell .. ")"))
            end
        end
    end
    if #created > 0 then
        Print("created " .. #created .. ": " .. table.concat(created, ", "))
    else
        Print("nothing new to create.")
    end
    if #full > 0 then
        Print("|cffff6060no free character slots|r for: " .. table.concat(full, ", "))
    end
    if #tooLong > 0 then
        Print("|cffff6060over 255 characters, skipped|r: " .. table.concat(tooLong, ", "))
    end
    return true
end

-- /mm auto [on|off]
local function Auto(arg)
    local db = CharDB()
    arg = (arg or ""):lower()
    if arg == "on" then
        db.auto = true
        db.autoKnown = {}
        for low in pairs(ClassSpells()) do db.autoKnown[low] = true end -- what you know now is left alone
        Print("auto mode |cff60ff60on|r: each new class spell you learn gets its own macro (unless your collection has one).")
    elseif arg == "off" then
        db.auto = false
        Print("auto mode |cffff6060off|r. Macros it made are kept.")
    else
        Print("auto mode is " .. (db.auto ~= false and "|cff60ff60on|r" or "|cffff6060off|r") .. ". /mm auto on, /mm auto off.")
    end
end

-- A brand-new (level 1) character starts on the Default collection.
-- Characters set up before collections were opt-in followed one by default. If
-- this character has never chosen, but already has a collection's macros, it
-- keeps following that collection (Mikey's first).
local function Adopt()
    local db = CharDB()
    if db.collection or db.adopted then return end
    local have, numChar = CharacterMacros()
    if numChar == 0 then
        if UnitLevel("player") == 1 then db.collection, db.adopted = DEFAULT, true end
        return -- otherwise nothing to go on (or macros not loaded yet); check again later
    end
    db.adopted = true
    local _, class = UnitClass("player")
    local owners = {}
    for owner, c in pairs(ns.collections) do
        if c[class] then owners[#owners + 1] = owner end
    end
    table.sort(owners, function(a, b)
        if a == PREFERRED or b == PREFERRED then return a == PREFERRED end
        return a < b
    end)
    for _, owner in ipairs(owners) do
        for _, def in ipairs(ns.collections[owner][class]) do
            if have[def.name] then
                db.collection = owner
                Print("this character keeps following |cffffd040" .. owner .. "|r's collection (/mm use none to stop).")
                return
            end
        end
    end
end

-- A spell shouldn't be both excluded and part of a macro in the same
-- collection's file (the followed collection's macros against its own exclude
-- list; Default's against Default's). A followed collection's macro for a
-- spell Default excludes is a deliberate override, not a conflict. Said once
-- per session in chat, so the data files can be fixed.
local conflictsChecked = false
local function CheckConflicts()
    if conflictsChecked then return end
    conflictsChecked = true
    local _, class = UnitClass("player")
    local function check(defs, owner, excluded)
        if not excluded then return end
        for _, def in ipairs(defs) do
            for _, spell in ipairs(def.spells) do
                if excluded[spell:lower()] then
                    Print("|cffff6060conflict|r: " .. spell .. " is excluded but is in "
                        .. owner .. "'s " .. def.name .. " macro.")
                end
            end
        end
    end
    local list, owner = ActiveList()
    if list then
        local own = ns.excludedBy[owner] and ns.excludedBy[owner][class]
        if owner == DEFAULT then own = ns.excluded[class] end
        check(list, owner, own)
    end
    check(DefaultList(), DEFAULT, ns.excluded[class])
end

-- Keep macros current as spells, forms (form numbers) and the main-hand weapon change.
-- Changes wait until combat ends.
local pending = false
local events = CreateFrame("Frame")
local function Schedule()
    if pending then return end
    pending = true
    C_Timer.After(0.5, function()
        if InCombatLockdown() then return end -- PLAYER_REGEN_ENABLED retries
        pending = false
        Adopt()
        CheckConflicts()
        Refresh()
        AutoCreate()
    end)
end
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("SPELLS_CHANGED")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, slot)
    if event == "PLAYER_EQUIPMENT_CHANGED" and slot ~= (INVSLOT_MAINHAND or 16) then return end
    if event == "PLAYER_REGEN_ENABLED" then
        if not pending then return end
        pending = false
    end
    Schedule()
end)

-- Delete this character's macros whose names appear in any collection's list
-- for its class (Mikey's, Ulako's, ...). Anything else (e.g. a macro called
-- "test") is kept, as are general (account) macros. A hand-made macro that
-- happens to share a name with a collection macro is deleted too.
-- /mm clear -a: every character macro, whatever made it, after a Yes/No popup.
StaticPopupDialogs.MIKEYMACROS_CLEAR_ALL = {
    text = "Delete all %d of this character's macros, hand-made ones too?",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        if not CanEdit() then return end
        local _, numChar = GetNumMacros()
        local first = AccountMax() + 1
        for index = first + numChar - 1, first, -1 do DeleteMacro(index) end
        Print("deleted all " .. numChar .. " character macros. /mm sync makes yours again.")
    end,
    showAlert = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function Clear(all)
    if not CanEdit() then return end
    if all then
        local _, numChar = GetNumMacros()
        StaticPopup_Show("MIKEYMACROS_CLEAR_ALL", numChar)
        return
    end
    local _, class = UnitClass("player")
    local names = {}
    for _, c in pairs(ns.collections) do
        for _, def in ipairs(c[class] or {}) do names[def.name] = true end
    end
    local have = CharacterMacros()
    local indexes = {}
    for name, index in pairs(have) do
        if names[name] then indexes[#indexes + 1] = index end
    end
    table.sort(indexes, function(x, y) return x > y end) -- highest first, so indexes stay valid
    for _, index in ipairs(indexes) do DeleteMacro(index) end
    Print("deleted " .. #indexes .. " collection macros; other character macros were kept.")
end

-- Show every macro for this class and its state.
local function List()
    local list, owner = ClassList()
    if not list then return end
    Print("following |cffffd040" .. owner .. "|r's collection.")
    local known = KnownSpells()
    local have, count = CharacterMacros()
    for _, def in ipairs(list) do
        local state
        if have[def.name] then
            state = "|cff60ff60have|r"
        elseif IsLearned(def, known) then
            state = "|cffffd040ready|r"
        else
            state = "|cff909090not learned|r"
        end
        Print(state, def.name, "(" .. table.concat(def.spells, ", ") .. ")")
    end
    Print(count .. " of " .. CharacterMax() .. " character slots used.")
end

-- Every installed collection and the classes it covers.
function Collections()
    local _, class = UnitClass("player")
    local active = ActiveCollection(class)
    local owners = {}
    for owner in pairs(ns.collections) do owners[#owners + 1] = owner end
    table.sort(owners)
    for _, owner in ipairs(owners) do
        local classes = {}
        for c in pairs(ns.collections[owner]) do classes[#classes + 1] = c:sub(1, 1) .. c:sub(2):lower() end
        table.sort(classes)
        local mark = (owner == active) and " |cff60ff60(this character)|r" or ""
        Print(owner .. mark .. ": " .. table.concat(classes, ", "))
    end
    if not active then Print("this character follows no collection.") end
end

-- Follow a collection on this character, or none ("/mm use none").
local function Use(name)
    if name == "" then
        Print("/mm use <name>, or /mm use none. The collections:")
        Collections()
        return
    end
    local _, class = UnitClass("player")
    if name:lower() == "none" then
        CharDB().collection = nil
        CharDB().adopted = true
        Print("this character follows no collection now. Its collection macros are kept but no longer updated; /mm clear -a, then /mm sync for a clean switch.")
        return
    else
        local owner = FindCollection(name)
        if not owner then
            Print("no collection called " .. name .. ". /mm collections shows the names.")
            return
        end
        CharDB().collection = owner
        if not ns.collections[owner][class] then
            Print(owner .. "'s collection has no " .. class:lower() .. " macros yet; nothing to follow until it does.")
            return
        end
    end
    Print("now following |cffffd040" .. ActiveCollection(class) .. "|r's collection. "
        .. "For a clean switch: /mm clear -a, then /mm sync.")
end

-- The documentation's web address, shown ready to copy. Addons can't use the
-- clipboard themselves, so the box selects the address for Ctrl+C and closes
-- itself once you've copied.
local DOCS_URL = "https://code-monkie.github.io/mikey-macros/"
local docsBox

local function ShowDocs()
    if not docsBox then
        local f = CreateFrame("Frame", "MikeyMacrosDocs", UIParent, "BackdropTemplate")
        f:SetSize(440, 112)
        f:SetPoint("CENTER", 0, 120)
        f:SetFrameStrata("DIALOG")
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 },
        })
        f:EnableMouse(true)
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        tinsert(UISpecialFrames, "MikeyMacrosDocs") -- Escape closes it

        local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        title:SetPoint("TOP", 0, -20)
        title:SetText("mikey-macros documentation")

        local hint = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        hint:SetPoint("BOTTOM", 0, 20)
        hint:SetText("Ctrl+C (or Ctrl+X) to copy, then paste it into your browser.")

        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -6, -6)

        local box = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        box:SetSize(380, 24)
        box:SetPoint("CENTER", 0, -2)
        box:SetAutoFocus(false)
        local function selectAll(self)
            self:SetText(DOCS_URL)
            self:SetFocus()
            self:HighlightText()
        end
        box:SetScript("OnTextChanged", function(self, userInput)
            if userInput then selectAll(self) end -- read-only: typing puts the address back
        end)
        box:SetScript("OnMouseUp", selectAll)
        box:SetScript("OnEscapePressed", function() f:Hide() end)
        box:SetScript("OnKeyDown", function(_, key)
            -- Ctrl+X copies too (the text comes straight back, the box is read-only)
            if (key == "C" or key == "X") and IsControlKeyDown() then
                C_Timer.After(0.2, function()
                    f:Hide()
                    Print("documentation address copied: paste it into your browser.")
                end)
            end
        end)
        f:SetScript("OnShow", function() selectAll(box) end)
        f:SetScript("OnHide", function() box:ClearFocus() end)
        f:Hide() -- new frames start shown; hide so the Show() below fills the box
        docsBox = f
    end
    docsBox:Show()
    docsBox:Raise()
end

SLASH_MIKEYMACROS1 = "/mm"
SlashCmdList.MIKEYMACROS = function(msg)
    local cmd, arg = (msg or ""):match("^%s*(%S*)%s*(%S*)")
    cmd = cmd:lower()
    if cmd == "sync" then
        if Sync(arg:lower() == "all") then ShowCharacterMacros() end
    elseif cmd == "update" then
        Update()
    elseif cmd == "list" then
        List()
    elseif cmd == "collections" then
        Collections()
    elseif cmd == "auto" then
        Auto(arg)
    elseif cmd == "docs" then
        ShowDocs()
    elseif cmd == "use" then
        Use(arg)
    elseif cmd == "clear" then
        Clear(arg == "-a")
    elseif cmd == "resync" then
        if Sync(true) then
            Update()
            ShowCharacterMacros()
        end
    else
        Print("/mm list - your class macros and their state")
        Print("/mm sync - create the macros for the spells you know (normally automatic as you learn them)")
        Print("/mm sync all - also create collection macros for spells you haven't learned yet")
        Print("/mm update - force a refresh now (normally automatic)")
        Print("/mm clear - delete this character's macros that come from any collection (others are kept)")
        Print("/mm clear -a - delete all of this character's macros, whatever made them")
        Print("/mm resync - create anything missing and rewrite the rest (macros stay on your bars)")
        Print("/mm collections - whose macro sets are installed")
        Print("/mm use <name> - follow someone's collection on this character (/mm use none to stop)")
        Print("/mm auto on or off - make a macro for each new class spell you learn (this character)")
        Print("/mm docs - the documentation's web address, ready to copy")
    end
end
