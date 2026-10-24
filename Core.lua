-- mikey-macros: per-character class macros that maintain themselves.
-- Macro definitions live in Collections\<Owner>\<Class>.lua. /mm sync creates them all once;
-- after that each macro is rewritten automatically (out of combat) to contain
-- only the spells you know, so fall-through lines and icons always work.
-- The addon owns these macros: change them in the data file, not in game
-- (renaming one in game takes it out of the addon's hands).

local _, ns = ...
-- Collections: whose macro lists. Each Collections\<Owner>\<Class>.lua file adds a
-- class to its owner's collection with ns.Collection("<Owner>").<CLASS> = { ... }.
local DEFAULT = "Mikey"
ns.collections = {}
function ns.Collection(owner)
    local c = ns.collections[owner]
    if not c then
        c = {}
        ns.collections[owner] = c
    end
    return c
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
-- A spell name as the macro writes it, ready for lookup: no leading !, no
-- trailing (Rank n). "Earth Shock(Rank 1)" counts as Earth Shock.
local function BaseName(text)
    local name = text:match("^%s*!?%s*(.-)%s*$")
    return (name:gsub("%s*%(%s*[Rr]ank%s*%d+%s*%)$", ""))
end

-- Drop every clause (or whole /use, /cast or /castsequence line) naming one of
-- the macro's spells that isn't known yet. In a /castsequence, unknown spells
-- are dropped from the sequence; a "#showtooltip Spell" for an unknown spell
-- becomes a bare #showtooltip. Anything not in def.spells is left alone.
local function KnownOnly(body, def, ctx)
    local tracked = {}
    for _, spell in ipairs(def.spells) do tracked[spell:lower()] = true end
    local function keep(text)
        local name = BaseName(text)
        return not tracked[name:lower()] or ctx.knows(name)
    end
    local out = {}
    for line in (body .. "\n"):gmatch("(.-)\n") do
        -- "#showtooltip Spell" naming a spell you don't know yet: bare #showtooltip
        local tip, arg = line:match("^(#[Ss][Hh][Oo][Ww][Tt][Oo][Oo][Ll][Tt][Ii][Pp])%s+(.-)%s*$")
        if tip and arg ~= "" and not keep(arg) then line = tip end
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

-- The collection name matching `name` (any case), or nil.
local function FindCollection(name)
    for owner in pairs(ns.collections) do
        if owner:lower() == name:lower() then return owner end
    end
end

-- Whose list this character follows for `class`: the one chosen with /mm use (if
-- it has the class), else Mikey's, else the first alphabetically that has it.
local function ActiveCollection(class)
    local chosen = CharDB().collection
    if chosen and ns.collections[chosen] and ns.collections[chosen][class] then return chosen end
    if ns.collections[DEFAULT] and ns.collections[DEFAULT][class] then return DEFAULT end
    local owners = {}
    for owner, c in pairs(ns.collections) do
        if c[class] then owners[#owners + 1] = owner end
    end
    table.sort(owners)
    return owners[1]
end

-- This character's macro list and its owner (nil if no collection has the class).
local function ActiveList()
    local _, class = UnitClass("player")
    local owner = ActiveCollection(class)
    if owner then return ns.collections[owner][class], owner end
end

local function ClassList()
    local list, owner = ActiveList()
    if not list then
        local _, class = UnitClass("player")
        Print("no collection has macros for " .. class .. ".")
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
    local list = ActiveList()
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

-- Delete this character's macros whose names appear in any collection's list
-- for its class (Mikey's, Ulako's, ...). Anything else (e.g. a macro called
-- "test") is kept, as are general (account) macros. A hand-made macro that
-- happens to share a name with a collection macro is deleted too.
local function Clear()
    if not CanEdit() then return end
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
local function Collections()
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
end

-- Follow another collection on this character ("default" goes back to the rules).
local function Use(name)
    if name == "" then
        Print("/mm use <name>, or /mm use default. /mm collections shows the names.")
        return
    end
    local _, class = UnitClass("player")
    if name:lower() == "default" then
        CharDB().collection = nil
    else
        local owner = FindCollection(name)
        if not owner then
            Print("no collection called " .. name .. ". /mm collections shows the names.")
            return
        end
        CharDB().collection = owner
        if not ns.collections[owner][class] then
            Print(owner .. " has no macros for " .. class .. "; using the default until it does.")
        end
    end
    Print("now following |cffffd040" .. (ActiveCollection(class) or "nobody") .. "|r's collection. "
        .. "/mm resync creates its macros; /mm clear first for a clean switch.")
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
        if Sync(arg:lower() == "known") then ShowCharacterMacros() end
    elseif cmd == "update" then
        Update()
    elseif cmd == "list" then
        List()
    elseif cmd == "collections" then
        Collections()
    elseif cmd == "docs" then
        ShowDocs()
    elseif cmd == "use" then
        Use(arg)
    elseif cmd == "clear" then
        Clear()
    elseif cmd == "resync" then
        if Sync() then
            Update()
            ShowCharacterMacros()
        end
    else
        Print("/mm list - your class macros and their state")
        Print("/mm sync - create all your class macros (once per character; they then keep themselves current)")
        Print("/mm sync known - create only the ones for spells you know")
        Print("/mm update - force a refresh now (normally automatic)")
        Print("/mm clear - delete this character's macros that come from any collection (others are kept)")
        Print("/mm resync - create anything missing and rewrite the rest (macros stay on your bars)")
        Print("/mm collections - whose macro sets are installed")
        Print("/mm use <name> - follow someone's set on this character (/mm use default to go back)")
        Print("/mm docs - the documentation's web address, ready to copy")
    end
end
