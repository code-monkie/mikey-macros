# mikey-macros

Per-character class macros that build themselves as you level.

You write each class's macros once, in full, the way you want them at max
level. The addon creates them all on a new character, then keeps each one
trimmed to the spells that character actually knows. Learn a spell and the
macros that use it update on their own. No rewriting macros every level, no
ranks, no broken icons.

Part of a small library of KISS addons built for WoW: Forever. Currently
developed and tested on retail (12.1.5); the code also handles Classic-based
clients.

## How it works

- `/mm sync` creates every macro in your class's list as a character-specific
  macro. Do this once per character.
- Each macro is written with only the spells you know. Any spell from the
  macro's `spells` list that you haven't learned is dropped from its `/use`
  or `/cast` line (or the whole line goes, if nothing on it is known yet).
  Fall-through lines and `#showtooltip` icons therefore always work.
- When you learn a spell (or change your main-hand weapon), the macros are
  rewritten automatically. Changes made during combat wait until it ends.
- Macros keep their places on your action bars when they are rewritten.

**The addon owns these macros.** An edit made in the in-game macro window is
overwritten the next time a spell is learned. Make permanent changes in the
data file instead. Renaming a macro in game takes it out of the addon's hands.

General (account) macros are never touched.

## Commands

| Command | What it does |
|---|---|
| `/mm` | Show the commands. |
| `/mm list` | Every macro for your class: **have**, **ready** (spell known, macro not created) or **not learned**, plus character slots used. |
| `/mm sync` | Create all missing macros for your class. Never touches existing ones. |
| `/mm sync known` | Create only the macros for spells you already know. |
| `/mm update` | Rewrite every existing macro now, icons included (normally automatic). |
| `/mm clear` | Delete **all** of this character's macros, including hand-made ones. General macros are kept. No confirmation, and the macros come off your bars. |
| `/mm resync` | `/mm sync` plus `/mm update`: create anything missing and rewrite every macro to match the data file. Macros stay on your bars. |

## Files

```
mikey-macros.toc      load order; add new class files here
Core.lua              spell detection, trimming, commands, auto-refresh
Classes/<Class>.lua   one macro list per class (the only files you normally edit)
```

## Changing macros

1. Open `Classes/<Class>.lua` and edit the macro's `body`.
2. In game, `/reload`. Existing macros update automatically within a second
   (or run `/mm update`).

After adding macros or changing several, `/mm resync` brings a character fully
up to date without moving anything off your bars.

Renaming a macro (`name`) creates a new one on the next `/mm sync`; the old
one is left behind for you to delete. To start completely clean, `/mm clear`
then `/mm sync` (everything comes off your bars).

## Adding a macro

Add an entry to the class list:

```lua
{ name = "Kick", spells = { "Kick" }, body = [[
    #showtooltip
    /use [@mouseover,harm,nodead,nostealth] [nostealth] Kick
]] },
```

- **name**: up to 16 characters, unique within the class.
- **spells**: every spell the body uses that the character has to learn.
  These are the names the addon trims out until known. Anything not listed
  (items, other commands) is left alone.
- **icon** (optional): a spell ID. While the live macro has no `/use`,
  `/cast` or `/castsequence` line at all (you don't know any of its spells
  yet), its icon is this spell's picture. Once a spell line is in, the icon is
  the question mark and `#showtooltip` shows the live spell. Rank 1's ID is
  fine.
- **body**: the full macro, written as you'd type it. Indentation and blank
  lines at the start and end are stripped. Keep it under 255 characters.

The list's order is the order macros are created in. Then `/reload` and
`/mm resync` on each character that should get it.

### Combined macros

One key can cover several spells. List them all in `spells`; each clause is
trimmed on its own:

```lua
{ name = "Bleed", spells = { "Garrote", "Rupture" }, body = [[
    #showtooltip
    /use [stealth] Garrote; Rupture
    /startattack [nostealth]
]] },
```

With modifiers, a clause for an unlearned spell falls through to the next
one (Ctrl+Imbue gives Rockbiter until Frostbrand is learned).

### Trimming rules

- `/use`, `/cast` and `/castsequence` lines are trimmed (unknown spells drop
  out of a sequence). `#showtooltip Spell` naming an unknown spell becomes a
  bare `#showtooltip`.
- A line is split into clauses at `;`. A clause's spell is the text after its
  last `]`, ignoring a leading `!`. If that spell is in `spells` and not
  known, the clause is dropped; if no clause is left, the line is dropped.
- Spells are matched by name, so ranks don't matter. A deliberate low-rank
  copy such as `Earth Shock(Rank 1)` (a cheap interrupt) counts as Earth Shock:
  list `"Earth Shock"` in `spells`.
- Other lines (`#showtooltip`, `/startattack`, `/dismount`, `/target`, ...)
  always stay.

### Built bodies

A `body` can also be a function that returns the macro text. It's called with
a context table:

- `c.knows("Spell Name")`: whether the spell is known.
- `c.dagger`: whether a dagger is in the main hand.

```lua
{ name = "Example", spells = { "Backstab", "Sinister Strike" }, body = function(c)
    local strike = c.dagger and "Backstab" or "Sinister Strike"
    return "#showtooltip\n/use " .. strike
end },
```

The result is still trimmed like any other body. Plain text bodies are
preferred; use a function only when the text depends on more than known spells.

## Adding a class

1. Create `Classes/<Class>.lua`:

   ```lua
   local _, ns = ...

   ns.classes.MAGE = {
       { name = "Fireball", spells = { "Fireball" }, body = [[
           #showtooltip
           /use [@mouseover,harm,nodead] [] Fireball
       ]] },
   }
   ```

   The key is the game's class token: `WARRIOR`, `PALADIN`, `HUNTER`,
   `ROGUE`, `PRIEST`, `SHAMAN`, `MAGE`, `WARLOCK`, `DRUID` (retail also
   `DEATHKNIGHT`, `MONK`, `DEMONHUNTER`, `EVOKER`).

2. Add the file to `mikey-macros.toc` under the other classes:

   ```
   Classes\Mage.lua
   ```

3. `/reload` (a new file needs a full restart of the game the first time),
   then `/mm list` and `/mm sync` on a character of that class.

## Conventions

These keep the class lists consistent:

- `#showtooltip` and the question-mark icon on every macro, so the live spell
  icon shows.
- `/use`, never `/cast` (same for spells, and `/use` also takes items and slots).
  `/castsequence` is the exception; it has no `/use` form.
- No spell ranks, except a deliberate low-rank copy (`Spell(Rank 1)`).
- Mouseover with fallback for things you aim: `[@mouseover,harm,nodead] []`
  for harmful spells, `[@mouseover,help,nodead] []` for friendly ones
  (`[@player]` as the fallback for self-buffs and cures).
- No mouseover on melee abilities you spam; they act on your target.
- `/startattack` on damage; `/startattack [nostealth]` for stealth openers;
  `/stopattack` and/or `/stopcasting` for crowd control.
- `!` on toggles (`!Stealth`, `!Ghost Wolf`) so a second press doesn't cancel.
- Modifiers mean the same thing across a class (shaman: Shift = fire,
  Ctrl = frost, Alt = the fourth option).

## Limits

- Character macros: 18 per character on Classic-based clients (WoW: Forever),
  30 on retail. Keep each class list within 18. `/mm sync` reports anything
  that didn't fit.
- 255 characters per macro body; `/mm sync` skips and reports longer ones.
- Macros can't be created or changed in combat; the addon waits for combat to
  end.

## Troubleshooting

- **A key shows "?"**: you don't know any of its spells yet and it has no
  `icon`, or the icon's spell ID wasn't found on this client.
- **A macro didn't update after training**: `/mm update`. If it still hasn't,
  check the spell's name in `spells` matches the spellbook exactly.
- **Lua errors**: install BugGrabber and BugSack.

## Ideas (not planned yet)

Kept here for later; each has trade-offs that weren't worth it yet.

- **Dirty macros.** Remember, per character, the body last written to each
  macro. If the macro in game no longer matches, it was edited by hand: mark
  it dirty and stop overwriting it. `/mm list` would show it as edited, with
  `/mm diff <name>`, `/mm revert <name>` and `/mm export <name>` (a
  ready-to-paste class file entry). Blizzard's macro window becomes the
  editor. Trade-off: an in-game edit is the trimmed version, so a dirty macro
  stops gaining spells as you learn them, and it needs SavedVariables.
- **In-game editor.** A window to edit a class's macro list. Addons can't
  write files, so edits would be saved as account-wide overrides layered over
  the class file, with an Export button to fold them back into the file.
  Trade-off: two places a macro can live, and a much bigger addon.
- **Create on learn.** Instead of creating every macro up front, create each
  one the moment its first spell is learned. No "?" keys, but each new macro
  still has to be dragged onto a bar mid-level.
