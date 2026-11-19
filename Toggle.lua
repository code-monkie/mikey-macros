-- ~Toggle (0.2.37, Mikey's ask, 2026-11-19): one character macro that swaps between a two-hander and
-- sword and board, kept up to date by itself so it never has to be rewritten by hand for a new weapon.
--   * Paladin, warrior and shaman only (CLASSES).
--   * Remembers the last one-hander (main hand), two-hander and shield you had on, per character
--     (MikeyMacrosCharDB.toggle), read from your equipped items at login and on every weapon change.
--   * Once all three are known, makes the character macro "~Toggle" (question-mark icon, #showtooltip
--     supplies the real one) and rewrites it whenever one of them changes. Changes wait until combat ends;
--     the macro itself works in combat (weapons may be swapped in combat by a macro).
--   * Wearing a shield: puts on the two-hander. Otherwise: the one-hander in the main hand and the shield.
--     Going to the two-hander needs a free bag slot for the shield.
--   * It isn't placed on a bar; drag it from /macro's character tab once. Edits in game don't last.
-- Born from a Righteous Fury idea (swap on cast / cancel), dropped because addons can't change weapons in
-- combat, and picking up a mob mid-fight was the point. Not yet checked in game.

local _, ns = ...

local CLASSES = { PALADIN = true, WARRIOR = true, SHAMAN = true }
local NAME = "~Toggle"
local ICON = 134400
local MH, OH = INVSLOT_MAINHAND or 16, INVSLOT_OFFHAND or 17
local ONE_HAND = { INVTYPE_WEAPON = true, INVTYPE_WEAPONMAINHAND = true }
local TWO_HAND = { INVTYPE_2HWEAPON = true }
local SHIELD = { INVTYPE_SHIELD = true }

local function ForMe()
    local _, class = UnitClass("player")
    return CLASSES[class]
end

local function Store()
    local db = ns.CharDB()
    db.toggle = db.toggle or {}
    return db.toggle
end

-- The item in a slot: its name (from the link, so a "of the Bear" suffix is kept) and its equip spot.
local function Worn(slot)
    local id = GetInventoryItemID("player", slot)
    if not id then return end
    local link = GetInventoryItemLink("player", slot)
    local name = link and link:match("%[(.-)%]")
    if not name or name == "" then return end
    local instant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    local loc = instant and select(4, instant(id))
    return name, loc
end

-- Note what's on now. Safe in combat (it only reads).
local function Record()
    local t = Store()
    local name, loc = Worn(MH)
    if name then
        if ONE_HAND[loc] then t.oneHand = name
        elseif TWO_HAND[loc] then t.twoHand = name end
    end
    name, loc = Worn(OH)
    if name and SHIELD[loc] then t.shield = name end
end

local function Body(t)
    return ("#showtooltip [equipped:Shields] %s; %s\n"
        .. "/equip [equipped:Shields] %s\n"
        .. "/equipslot [noequipped:Shields] %d %s\n"
        .. "/equipslot [noequipped:Shields] %d %s")
        :format(t.twoHand, t.shield, t.twoHand, MH, t.oneHand, OH, t.shield)
end

local waiting = false   -- a change seen in combat, written at PLAYER_REGEN_ENABLED
local said = {}         -- chat messages said once a session

local function Write(loud)
    if InCombatLockdown() then waiting = true return end
    waiting = false
    local t = Store()
    if not (t.oneHand and t.twoHand and t.shield) then
        if loud then ns.Print(NAME .. " waits until you've worn a one-hander, a two-hander and a shield.") end
        return
    end
    local body = Body(t)
    if #body > 255 then
        if loud or not said.long then ns.Print("|cffff6060" .. NAME .. " would be over 255 characters|r; weapon names too long.") end
        said.long = true
        return
    end
    local have, count = ns.CharacterMacros()
    local index = have[NAME]
    if index then
        local _, icon, current = GetMacroInfo(index)
        current = current and current:gsub("\r", ""):gsub("%s+$", "")
        if current ~= body then
            EditMacro(index, NAME, icon or ICON, body)
            ns.Print("updated " .. NAME .. ".")
        elseif loud then
            ns.Print(NAME .. " is up to date.")
        end
    elseif count < ns.CharacterMax() then
        CreateMacro(NAME, ICON, body, true)
        ns.Print("created " .. NAME .. " (character tab in /macro; drag it to a bar).")
    elseif loud or not said.full then
        ns.Print("|cffff6060no free character slots|r for " .. NAME .. " (" .. count .. " of " .. ns.CharacterMax() .. " used).")
        said.full = true
    end
end

-- /mma toggle: what it remembers, and write the macro now.
function ns.ToggleCommand()
    if not ForMe() then ns.Print(NAME .. " is for paladins, warriors and shamans.") return end
    Record()
    local t = Store()
    ns.Print(("%s: one-hander %s, two-hander %s, shield %s."):format(NAME,
        t.oneHand or "none yet", t.twoHand or "none yet", t.shield or "none yet"))
    Write(true)
end

local pending = false
local function Soon()
    if pending then return end
    pending = true
    C_Timer.After(0.5, function()
        pending = false
        Record()
        Write(false)
    end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, slot)
    if not ForMe() then return end
    if event == "PLAYER_LOGIN" then
        C_Timer.After(1, Soon)   -- after Core's own login pass, with macros and gear loaded
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if slot == MH or slot == OH then Soon() end
    elseif waiting then
        Soon()
    end
end)
