-- mikey-macros: per-character class macros that maintain themselves.
-- Macro definitions live in Classes\<Class>.lua. /mm sync creates them all once;
-- after that each macro is rewritten automatically (out of combat) to contain
-- only the spells you know, so fall-through lines and icons always work.
-- The addon owns these macros: change them in the data file, not in game
-- (renaming one in game takes it out of the addon's hands).

local _, ns = ...
ns.classes = {}

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

local function IsLearned(def, known)
    for _, spell in ipairs(def.spells) do
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

-- What a dynamic macro body can ask about the character.
local function Context(known)
    return {
        knows = function(spell) return known[spell:lower()] == true end,
        dagger = MainHandDagger(),
    }
end

-- Strip indentation and surrounding blank space so data files stay readable.
-- Drop every clause (or whole /use or /cast line) naming one of the macro's
-- spells that isn't known yet. Anything not in def.spells is left alone.
local function KnownOnly(body, def, ctx)
    local tracked = {}
    for _, spell in ipairs(def.spells) do tracked[spell:lower()] = true end
    local out = {}
    for line in (body .. "\n"):gmatch("(.-)\n") do
        local cmd, rest = line:match("^(/%a+)%s+(.*)$")
        local lower = cmd and cmd:lower()
        if lower == "/use" or lower == "/cast" then
            local kept = {}
            for clause in (rest .. ";"):gmatch("([^;]*);") do
                clause = clause:match("^%s*(.-)%s*$")
                local name = clause:match("([^%]]*)$"):match("^%s*!?%s*(.-)%s*$")
                if clause ~= "" and (not tracked[name:lower()] or ctx.knows(name)) then
                    kept[#kept + 1] = clause
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

local function ClassList()
    local _, class = UnitClass("player")
    local list = ns.classes[class]
    if not list then Print("no macros defined for " .. class .. " yet.") end
    return list
end

local function CanEdit()
    if InCombatLockdown() then
        Print("macros can't be changed in combat; try again after the fight.")
        return false
    end
    return true
end

-- Create missing macros (all of them, or with onlyKnown just those for spells
-- you know). Existing ones are left alone.
local function Sync(onlyKnown)
    local list = ClassList()
    if not list or not CanEdit() then return end
    local known = KnownSpells()
    local ctx = Context(known)
    local have, count = CharacterMacros()
    local created, full, tooLong = {}, {}, {}
    for _, def in ipairs(list) do
        if not have[def.name] and (not onlyKnown or IsLearned(def, known)) then
            local body = Clean(def, ctx)
            if #body > MAX_BODY then
                tooLong[#tooLong + 1] = def.name
            elseif count >= CharacterMax() then
                full[#full + 1] = def.name
            else
                CreateMacro(def.name, ICON, body, true)
                count = count + 1
                created[#created + 1] = def.name
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
end

-- Rewrite existing macros to match the data file and the spells you know
-- (keeps their action bar spots).
local function Refresh()
    local _, class = UnitClass("player")
    local list = ns.classes[class]
    if not list or InCombatLockdown() then return {} end
    local ctx = Context(KnownSpells())
    local have = CharacterMacros()
    local updated = {}
    for _, def in ipairs(list) do
        local index = have[def.name]
        if index then
            local body = Clean(def, ctx)
            if #body <= MAX_BODY then
                local _, _, current = GetMacroInfo(index)
                if current ~= body then
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
    local updated = Refresh()
    if #updated > 0 then
        Print("updated " .. #updated .. ": " .. table.concat(updated, ", "))
    else
        Print("everything already matches.")
    end
end

-- Keep macros current as spells (and the main-hand weapon) change.
-- Changes wait until combat ends.
local pending = false
local events = CreateFrame("Frame")
local function Schedule()
    if pending then return end
    pending = true
    C_Timer.After(0.5, function()
        if InCombatLockdown() then return end -- PLAYER_REGEN_ENABLED retries
        pending = false
        Refresh()
    end)
end
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("SPELLS_CHANGED")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, slot)
    if event == "PLAYER_EQUIPMENT_CHANGED" and slot ~= (INVSLOT_MAINHAND or 16) then return end
    if event == "PLAYER_REGEN_ENABLED" then
        if not pending then return end
        pending = false
    end
    Schedule()
end)

-- Delete every character-specific macro on this character (not just the
-- addon's). General (account) macros are never touched.
local function Clear()
    if not CanEdit() then return end
    local _, numChar = GetNumMacros()
    local first = AccountMax() + 1
    for index = first + numChar - 1, first, -1 do -- highest first, so indexes stay valid
        DeleteMacro(index)
    end
    Print("deleted all " .. numChar .. " character macros. /mm sync creates the class set again.")
end

-- Show every macro for this class and its state.
local function List()
    local list = ClassList()
    if not list then return end
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

SLASH_MIKEYMACROS1 = "/mm"
SlashCmdList.MIKEYMACROS = function(msg)
    local cmd, arg = (msg or ""):lower():match("^%s*(%S*)%s*(%S*)")
    if cmd == "sync" then
        Sync(arg == "known")
    elseif cmd == "update" then
        Update()
    elseif cmd == "list" then
        List()
    elseif cmd == "clear" then
        Clear()
    elseif cmd == "resync" then
        if CanEdit() then Clear(); Sync() end
    else
        Print("/mm list - your class macros and their state")
        Print("/mm sync - create all your class macros (once per character; they then keep themselves current)")
        Print("/mm sync known - create only the ones for spells you know")
        Print("/mm update - force a refresh now (normally automatic)")
        Print("/mm clear - delete ALL of this character's macros (general macros are kept)")
        Print("/mm resync - clear, then sync: a fresh class set")
    end
end
