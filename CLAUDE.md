# CLAUDE.md: mikey-macros

Handoff notes for Claude sessions working on this addon. The README covers what
the addon does for players; this covers how we work on it and where things
stand. Last updated 4 November 2026.

## What it is

A WoW addon that writes per-character class macros and keeps them current as
you level. Each learned spell gets the followed collection's macro, else the
Default collection's, else a generated one (auto mode), unless excluded. Macros
are trimmed to the spells you know and rewritten (out of combat) as you learn
more. Part of Mikey's KISS addon set for WoW Forever (live launch 4 Nov 2026).

## Working agreement

- **Mikey commits and pushes.** Edit code and docs, then suggest a commit
  message; never commit or push. Merges go through PRs on
  `code-monkie/mikey-macros` (trunk-based: short feature branches into `main`).
- **Mikey tests in game.** There's no WoW client in the sandbox. Say what to
  run (`/mma update`, `/mma sync`, `/mma list`) and what to look for.
- **Where to edit:** `C:\Blizzard\Wow\World of Warcraft\_forever_\Interface\AddOns\mikey-macros`
  only (Mikey, 2026-11-02). The `_classic_era_` and `_retail_` clones are
  older working copies; pull there if they're needed, but don't edit them.
- **Line endings:** the Windows checkout is CRLF and the repo stores LF. Keep
  CRLF when editing. From a Linux shell every file can show as modified; use
  `git diff --ignore-cr-at-eol` to see real changes.
- **No Lua runtime** in the sandboxes (no lua/luac, PyPI blocked). Check
  trimming with `tools/trimtest.py`, a Python copy of `KnownOnly`; keep it in
  step if `KnownOnly` changes. Re-read Core edits carefully by eye.
- **Keep it small.** Only what's asked; don't add features or macros to other
  classes unasked. Flag a concern once, then do what Mikey decides.
- **Don't review `Collections/Ulako/`**: it's a placeholder for testing a
  second collection, not Ulako's real list.

## Core.lua at a glance

- **Collections:** `ns.Collection("<Owner>").<CLASS> = { entries }`, one file
  per owner and class, every file listed in `mikey-macros.toc`. A character
  follows one via `/mma use <name>`; Default applies under every collection.
- **Default** (`Collections/Default/`): exceptions to generated macros (crowd
  control with `/stopattack`, stealth, res...) plus `ns.Exclude` lists. A
  Default macro is dropped for a character when the followed collection has a
  macro *made for* the same spell (its `learn` spells), or excludes it.
- **Entry fields:**
  - `name`: at most 16 characters, unique in the class list.
  - `spells`: every learnable spell in the body; drives trimming.
  - `learn` (optional, string or list): the spell(s) that make the macro when
    learned. Defaults to all of `spells`. Added for ClassicWowForever, where
    one macro names several spells but belongs to one.
  - `icon` (optional, 2026-11-03): a texture name for macros whose spells
    `#showtooltip` can't show (pet spells); Pet Attack uses the pet bar's
    `Ability_GhoulFrenzy`. Otherwise the question mark, so `#showtooltip`
    picks the icon. Refresh also sets it on a macro still on the question mark.
  - `body`: macro text (at most 255 after trimming), or `function(c)` returning
    it. Context: `c.knows(spell)`, `c.dagger`, `c.form("Cat Form")` (the
    form's current `[form:N]` number, or nil).
- **Trimming (`KnownOnly`):** `/use`, `/cast` and `/castsequence` clauses and
  `#showtooltip` clauses naming a listed-but-unknown spell are dropped; other
  lines stay.
- **Covered spells:** a spell on a macro you *have* (a modifier or sequence
  step, not what it's made for) gets no generated macro of its own. Until that
  macro exists, it does.
- **Real spell names (2026-11-03):** the spellbook can show a spell under
  another name: Call Pet (883) is listed as "Call <pet's name>" (Classic Era,
  Mikey's hunter). `RealName` looks the name up from the spell ID;
  `KnownSpells` keeps both names and `ClassSpells` uses the real one, so Call
  Pet makes Default hunter's Pet and Pet Attack instead of a "Call Murray"
  macro. Checked on Classic Era 2026-11-03 (Mikey): Pet and Pet Attack made
  and working, hunter ready to go. Classic Era has no Assist stance, so
  `/petassist` does nothing there; Forever has it. Not yet checked on Forever.
- **Refresh triggers:** login, `SPELLS_CHANGED`, `UPDATE_SHAPESHIFT_FORMS`,
  main-hand changes, leaving combat.
- **Attack macro (2026-10-29):** a brand-new character (the `brandNew` branch
  of `AutoCreate`) gets the general (account) macro `~Attack`
  (`#showtooltip 16` / `/startattack`), made if missing and otherwise used as
  is. `PlaceAttack` puts it on bar 1 button 9 (`ATTACK_SLOT`; was 7 until Mikey
  moved it) and clears the Attack spell from the rest of bar 1. A taken button
  9 is left alone with a chat message. Documented in `docs/commands.html#attack-macro`.
- **Ranged macro (2026-11-01):** in the same branch, a brand-new warrior or
  rogue (`RANGED_CLASSES`) also gets the general macro `~Ranged` (mouseover
  enemy becomes the target; with none, `/cleartarget [dead][help]` and
  `/targetenemy [noexists]`, added 2026-11-02; then `#showtooltip 18` and Throw / Shoot Bow /
  Gun / Crossbow, or the wand's !Shoot (added 2026-11-02), by
  `[equipped:...]`), made if missing. Only the wand clause has `!`: in Classic,
  wand Shoot repeats, but Throw and bow/gun/crossbow fire once per press
  (Mikey, 2026-11-02; checked again on Forever 2026-11-11, see 0.2.23). `PlaceRanged` puts it
  where Throw is on bar 1, else on the first empty button. It was briefly a
  Default collection macro; that was dropped because auto mode skips the
  General tab (Throw, Shoot), so it never appeared on its own. The leftover
  `Collections/Default/Warrior.lua` (not in the `.toc`) was deleted 2026-11-02.
  No Default collection has a ranged, wand or Shoot macro; only hunters get one
  (Mikey's `AS`), and everything else goes through the general `~Ranged` macro.
- **~ names (2026-11-03, Mikey):** the general macros the addon handles start
  with `~` (`~Attack`, `~Ranged`); the old `Attack` and `Ranged` names aren't
  recognised any more (no migration, Mikey's call). `PlaceCancel` puts the
  account's own `~Cancel` macro (never made by the addon) on MultiBar5 button 4
  (`MULTIACTIONBAR5BUTTON4`, slot 148, bound to X) for a brand-new character of
  any class; a taken button is left alone with a chat message.
  **By key (0.2.20, Mikey's ask, 2026-11-09):** `PlaceKeyMacros` puts account
  macros on whatever button a key is bound to, from the `KEY_MACROS` table:
  "To the Face" (`/yell To the FACE!!!`, the account's own) on the **0** key
  (`MULTIACTIONBAR3BUTTON1`, right bar button 1, on all three accounts). The key
  is looked up with `GetBindingAction` each time, the slot from the button
  (`button.action`; bar 1 through `Bar1Slot`), so a rebind moves it. Brand-new
  characters and `/mma bar`, same rules as ~Cancel. Not yet checked in game.
  Checked on Classic Era 2026-11-03 (Mikey): a new level-1 rogue got the
  right starting bar, ~Attack and ~Ranged placed, and ~Cancel on bar 5
  button 4. Everything up to this point counts as tested.
  The Mikey rogue's Sap → Disorient rename checked in game too (Mikey,
  2026-11-03), and Default hunter's Eagle Eye (`!` lets you recast it to
  move the eye without the view snapping back). Untested: `learn` on the Mikey druid's bear macros (Maul,
  Swipe, Growl, Roar, Bash).
  The bear test waits for Mikey's Forever druid to reach Bear Form (10-14):
  plain `/mma sync` should bring back no Swipe or Bash before they're learned
  (`sync all` ignores `learn`, so it can't test this).
- **`~RM` (0.2.3, Mikey's ask, 2026-11-05):** a third guaranteed general
  macro, for his three-character groups: `/tm [@player] 6` (blue square, you),
  `/tm [@party1] 5` (moon), `/tm [@party2] 4` (green triangle). `/tm` is the
  game's own marker command, not an addon call, so it isn't blocked (cf.
  mikey-castorb 0.14.1). It toggles: a second press clears the marks. Which
  follower gets moon or triangle follows that window's party order. Made if
  missing, never placed on a bar. Icon: `ability_hunter_markedfordeath`
  (236188); a `GUARANTEED` entry's third value is its icon, and an existing
  macro still wearing the question mark gets it (body untouched).
  `SetRaidTarget` is protected since 12.0 (warcraft.wiki.gg), so `/run`
  would be blocked; `/tm` is the way. The wiki also says `/tm` only marks the
  current target, but on Forever `[@player]` / `[@party1]` work: the same
  lines on mikey-follow 0.7.6's Leader right-click marked all three (Mikey,
  2026-11-05).
- **Guaranteed general macros (2026-11-02, Mikey's call):** `EnsureGeneral`
  makes `~Attack` and `~Ranged` (and `~RM` since 0.2.3) once per login (the first `Schedule` pass, out
  of combat), on any class and with auto mode on or off, if the account lacks
  them. Existing ones are used as is. Placement on bar 1 is still brand-new
  only (`PlaceAttack`, and `PlaceRanged` for `RANGED_CLASSES`). `RANGED_CLASSES`
  maps class to placement: warrior and rogue `"throw"` (Throw's button, else the
  first empty one); priest, mage and warlock button 2 if it's empty, else a chat
  message (Mikey, 2026-11-02).
- **`/mma bar` (0.2.2, Mikey's ask, Forever launch night 2026-11-04):**
  `PlaceBar` runs the brand-new placement on demand: `EnsureGeneral`, then
  `PlaceAttack`, `PlaceRanged` (`RANGED_CLASSES`) and `PlaceCancel`, out of
  combat with an empty cursor. Why: the general macros were restored after
  some characters' first login, which reordered them; action slots hold a
  general macro by index, so placed buttons showed the wrong macro, and
  `AutoCreate` only places once. Repeatable: each Place* skips a button that
  already has its macro and leaves a taken one alone (chat message).
  Documented in `docs/commands.html#mm-bar`. Not yet checked in game.
- **Pet Attack picks up a target (0.2.10, Mikey's ask, 2026-11-06):** the
  hunter and warlock Pet Attack macros start with `/target [noexists]
  mouseover`: with no target, the mouseover becomes it, so you and the pet
  are on the same mob; a target you have is kept. Pet Attack sends any
  demon (voidwalker too), unlike mikey-follow's Assist. Checked in game on
  Forever (Mikey, 2026-11-06): updated by itself and works.
- **Mikey warlock's SB acquires a target (0.2.21, Mikey's ask, 2026-11-10):**
  the hunter Shot's targeting lines (`/cleartarget [dead][help]`, `/target
  [noexists] mouseover`, `/cleartarget [dead][help]`, `/targetenemy [noexists]`),
  then a plain `/use Shadow Bolt` on the target (no mouseover cast, as Shot)
  and `/startattack`, then `/petattack [pet:Imp]` (only the Imp is sent; any
  other demon is left to Pet Attack).
  An existing SB is rewritten at the next refresh (body differs).
  **Checked in game (Mikey, 2026-11-10):** the imp goes in.
- **Mikey rogue's Backstab checks for a dagger (0.2.19, Mikey's ask, 2026-11-08):**
  Ambush in stealth and Backstab out of it only with `[equipped:Daggers]`; with no
  dagger it's Sinister Strike (in or out of stealth). `[equipped:Daggers]` is any
  dagger in either hand, while the spells want one in the main hand. An existing
  Backstab macro is rewritten at the next refresh (body differs). Not yet checked
  in game.
- **~Ranged: `!` on every shoot (0.2.22, Mikey's ask, 2026-11-11):** `!Shoot Bow`,
  `!Shoot Gun` and `!Shoot Crossbow`, as the wand's `!Shoot`, so a second press never
  stops a repeating shot (on one that fires once, `!` does nothing). To fit 255, no
  spaces after the `;`s (252 characters). `RANGED_OLD` is now a list (0.2.17's and
  0.2.18's bodies), so an unedited ~Ranged is rewritten in place at login; all three
  accounts had 0.2.18's.
- **@target named in friendly macros (0.2.27, Mikey, 2026-11-13):** 0.2.25's
  `[help,nodead] [@player]` didn't help: any clause with no `@unit` counts the
  soft-target NPC as your target. Naming it does (Mikey, in game: "naming the
  target explicitly fixed it"). Now:
  - Auto mode's helpful macros, the Mikey druid's HT / HT2 and the Mikey
    shaman's Cure Poison / Cure Disease: `[@mouseover,help,nodead]
    [@target,help,nodead] [@player]`.
  - Default Res (paladin, priest, shaman, druid's Revive / Rebirth):
    `[@mouseover,help,dead] [@target,help,dead] []`, the last `[]` kept for
    the targeting hand (Mikey's call).
  - LoH: `[@mouseover,help,nodead] [@target,help,nodead]` (Mikey's call, same
    day: mouseover, else friendly target; no `[@player]` step). Harmful `[]`
    lines and Ulako's collections are left as they are (Mikey's calls).
  - The Mikey paladin's skip list adds the seven seals (Righteousness,
    Crusader, Light, Wisdom, Justice, Command, Fury) and the seven auras
    (Devotion, Retribution, Concentration, Shadow / Frost / Fire Resistance,
    Sanctity); mikey-halo's seal and aura rings cast them.
  Collection macros are rewritten at the next refresh; generated ones already
  made keep the old body until `/mma sync -n <name>` (Mikey does those by
  hand). Not yet checked in game.
  - **`/use`, not `/cast`** (Mikey's house rule, same day): every `/cast`
    line in the Default and Mikey collections is `/use` now (hunter, druid
    Prowl, warlock, paladin LoH). Same command on Forever (spells by name,
    `!`, conditions; `/use !Stealth` etc. already worked). `/castsequence`
    stays. Ulako's and ClassicWowForever's collections left as they are.
    Rewritten at the next refresh (body differs).
- **Mikey paladin skips three blessings (0.2.26, Mikey's ask, 2026-11-13):**
  `ns.Exclude("PALADIN", { Might, Wisdom, Kings, Light }, "Mikey")` in
  `Collections/Mikey/Paladin.lua`: auto mode makes no macro for them, since
  mikey-halo's blessing ring and Ring 2 bar macro (mouseover, else friendly
  target, else you, halo 0.22.0) cast them. An existing BoM macro is left as
  it is (delete it by hand). Salvation isn't listed: Forever removed it
  (Mikey). Not yet checked in game.
- **Helpful spells fall through to you, not the NPC (0.2.25, Mikey, 2026-11-12):**
  generated helpful macros (buffs, heals) were `/use [@mouseover,help,nodead] []
  <spell>`. On Forever the bare `[]` took the interact soft target, a friendly
  NPC in front of you (`SoftTargetInteract` 3, kept for Forever Loot
  Sparkles), before self-cast; `SoftTargetFriend` was 0 and the buffs went on
  you with `SoftTargetInteract` 0 (Mikey, in game). Now `[@mouseover,help,nodead]
  [help,nodead] [@player]`: mouseover, else a friendly target, else you (the
  Ulako mage's pattern). The Mikey druid's HT and HT2 too, rewritten at the next
  refresh. Generated macros already made (BoM, Holy Light, Mark of the Wild,
  Rejuvenation...) are yours and aren't rewritten: `/mma sync -n <name>` each.
  Not yet checked in game.
- **Mikey rogue's Backstab fits again (0.2.24, Mikey, 2026-11-11):** learning
  Ambush didn't update it: with Ambush known the body came to 273 characters,
  over 255, and `Refresh` skipped over-long macros silently. Now (Mikey's call)
  Backstab has no Pick Pocket line (SS still has one), so a bare `#showtooltip`
  shows what it casts: Ambush in stealth with a dagger, Backstab with one,
  Sinister Strike otherwise; `worn:` (the game's alias for `equipped:`) replaces
  `equipped:`. 158 characters with Ambush. `Refresh` now says in chat, once a session per macro, when one is too
  long to update. Rewritten at the next refresh (body differs). Not yet checked
  in game.
- **~Ranged: `!` off the single shots again (0.2.23, Mikey, 2026-11-11):** checked in
  game, `!Shoot Crossbow` and `Shoot Crossbow` behave the same (one shot per press).
  The body is 0.2.18's again, spaces and all (253 characters). `RANGED_OLD` now holds
  0.2.17's and 0.2.22's bodies, so a ~Ranged that 0.2.22 rewrote goes back in place
  at login. Don't add `!` to Throw or the bow, gun and crossbow shots.
- **~Ranged starts melee too (0.2.18, Mikey's ask, 2026-11-08):** a last line
  `/startattack [noequipped:Wands]` after the throw or shot (not with a wand, which
  `/startattack` would swap for melee). To fit the 255-character limit, the two
  retargeting lines became one, `/targetenemy [noharm][dead]` (253 characters
  now). An existing ~Ranged whose body is exactly
  0.2.17's is rewritten in place at login (`EnsureGeneral`, the entry's 4th value:
  the old body), keeping its bar spots; a hand-edited one is left alone. Not yet
  checked in game.
- **Mikey hunter: every sting excluded (0.2.29, Mikey's ask, 2026-11-13):**
  Serpent, Scorpid and Wyvern Sting join Viper Sting on the Mikey
  collection's hunter exclude list. mikey-halo 0.23.0's sting ring (hunter
  Ring 3) casts them. Khnume follows the Mikey collection (saved
  `collection = "Mikey"`). The existing Serpent and Scorpid macros stay until
  they're deleted by hand. Not yet checked in game.
- **Mikey hunter: every aspect excluded (0.2.17, Mikey's ask, 2026-11-08):**
  Hawk and Cheetah joined Monkey, Pack, Wild and Beast on the Mikey collection's
  hunter exclude list, and its "Aspect" macro (a Cheetah/Hawk castsequence) was
  dropped, since a collection's own macro beats its exclude list. Aspects are cast
  from mikey-halo's hunter Ring 1. An existing "Aspect" macro stays until deleted.
  Not yet checked in game.
- **Mikey hunter's Shot keeps your target (0.2.16, Mikey's ask, 2026-11-08):**
  it used to shoot `[@mouseover,harm,nodead]` over the target, so scanning with
  the mouse started Auto Shot on other mobs. Now `/target [noexists] mouseover`
  (then `/cleartarget [dead][help]` again for a friendly or dead mouseover),
  `/targetenemy [noexists]`, and a plain `/cast !Auto Shot` on the target.
  Not yet checked in game.
- **Weapon imbues excluded for every shaman (0.2.15, Mikey's ask, 2026-11-07):**
  Rockbiter, Flametongue, Frostbrand and Windfury Weapon moved to Default's exclude
  list too (Mikey's shaman follows Default), so the Mikey collection has no
  shaman-only exclusions left. Not yet checked in game.
- **Totems excluded for every shaman (0.2.14, Mikey's ask, 2026-11-07):** the
  totem list (earth, fire, water, air, and the Call / Totemic Recall spells) moved
  from the Mikey collection's exclude list to Default's, so auto mode never makes a
  totem macro whatever collection a shaman follows. Totem macros already made stay
  until deleted. Not yet checked in game.
- **Evasion excluded for rogues (0.2.13, Mikey's ask, 2026-11-07):** added
  to the Default `ns.Exclude("ROGUE", ...)` list, so auto mode never generates
  an Evasion macro. A collection that defines one (ClassicWowForever's Evasion +
  Sprint) still makes it for its followers. An Evasion macro already made stays
  until deleted. Not yet checked in game.
- **`/mma sync -n <name>` (0.2.12, Mikey's ask, 2026-11-07):** one macro
  by name (any case, spaces allowed), through sync's usual fall-through
  (followed collection, Default, generated). Missing: created. Present:
  rewritten in place (keeps bar spots), generated ones included, since naming
  it is asking for it. Learned spells only, like plain sync. `SyncOne` in
  `Core.lua`; documented in `docs/commands.html#mm-sync` and the README.
  **Checked in game (Mikey, 2026-11-07):** works.
- **Default rogue Stealth picks up a target (0.2.11, Mikey's ask,
  2026-11-07):** `/targetenemy [stealth,noharm][stealth,dead]` before the
  Pick Pocket line, as the Mikey collection's SS and Backstab: in stealth with
  no live enemy targeted, it targets the nearest one; a mouseover still wins.
  Existing Stealth macros are rewritten at the next refresh (body differs).
  **Checked in game (Mikey, 2026-11-07):** updated and works.
- **No more opening the macro window (0.2.8, Mikey's call, 2026-11-05):**
  `ShowCharacterMacros` used to `ShowMacroFrame()` and click `MacroFrameTab2`
  after auto mode, `/mma sync` and `/mma resync`. That tainted Blizzard's
  macro window: switching tabs there later runs `EditMacro` (its save), which
  was blocked and blamed on mikey-macros (BugSack, wow1). Now it only prints
  "open /macro, Character tab, ...". Don't open or click Blizzard windows
  from addon code.
- **`~Focus` (0.2.7, Mikey's ask, 2026-11-05):** a fourth guaranteed
  general macro, `/focus [@mouseover,exists] []` (mouseover, else target),
  icon `ability_hunter_snipershot` (132212). For mikey-follow's Partner mode
  (a heal bot outside the group works off its focus). Focus doesn't survive a
  reload or logout (Mikey), so it's pressed once a session. Checked in game
  with mikey-follow's Partner mode (Mikey, 2026-11-05).
- **Switching collections (2026-11-05):** Mikey's rogues were on Default, so
  they had auto mode's `Sinister Strike`, not the Mikey collection's `SS` /
  `Backstab` (Pick Pocket in stealth). `/mma use mikey` + `/mma sync` made
  `SS` and `Backstab` next to the old macro (different names, and sync never
  touches existing ones); the old one is deleted by hand. Plain `/mma clear`
  wouldn't have removed it: it only deletes collection names. Worked as
  expected (Mikey).
- **`~RM` in a group of two (0.2.5, 2026-11-05):** the party lines are
  `[@party1,exists]` / `[@party2,exists]`, so a missing member is skipped
  (same change as mikey-follow 0.7.7). An existing `~RM` keeps its old body:
  delete it and `/reload` to get this one.
- **Hunter review (0.2.4 and 0.2.6, Mikey's ask, 2026-11-05):** every
  character follows Default, and Default had no Hunter's Mark.
  - Default hunter gets **Hunter's Mark** (the Mikey collection's Mark body:
    `/target [@mouseover,harm,nodead]`, `/cast Hunter's Mark`; no
    `/startattack`: marking comes before the pull).
  - **`/startattack` on a hunter starts Auto Shot at range on Forever** (as
    on Retail; on Classic it's melee). Mikey checked it in game. 0.2.4 had
    swapped a hunter's `/startattack` for `/use !Auto Shot` on Classic's
    rule; 0.2.6 put it back: `AutoBody` has no hunter case, and the Mikey
    collection's Arcane, Multi and Aimed are `/startattack` + the shot. The
    hunters' existing generated macros were already right.
- **Bar swapping (`SwapIntoBars`):** a new macro replaces its spell on every
  action slot 1-180, which takes in the stance and form bars too. Checked on
  Retail 2026-10-30 (Mikey): spells the game puts on the rogue's stealth bar get
  their macro there as well.
- **Limits:** 30 character macro slots on Classic Era now (Mikey's hunter,
  2026-11-03; was 18) and on retail; collections can get close.
  **0.2.28 (Mikey, 2026-11-13):** a hunter on Forever (Khnume) got "no free
  character slots" for Multi-Shot with 6 macros and room for more. The limits
  were read from the old globals `MAX_CHARACTER_MACROS` /
  `MAX_ACCOUNT_MACROS`. The Retail API keeps them in `Constants.MacroConsts`
  (Blizzard_MacroUI reads them there, per wow-ui-source), so on Forever the
  code likely fell back to Classic's 18. `CharacterMax` / `AccountMax` read
  `Constants.MacroConsts` first now. The "no free character slots" messages
  also say "(N of M used)". Cause not confirmed: 6 of 18 shouldn't have been
  full either, so the new message's numbers are the next clue. Not yet
  checked in game.

## Collections

| Collection | Classes | Notes |
|---|---|---|
| Default | Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock | No Warrior file yet. Prowl is a `c.form` built body. |
| Mikey | Rogue, Shaman, Hunter, Druid, Warlock, Paladin, Mage | Mikey's own; his style rules below. Mage added 2026-11-04 (Polymorph only). |
| Ulako | Shaman, Mage | Placeholder; don't review. |
| ClassicWowForever | Rogue | Snapshot of classicwowforever.com; 8 classes to go. |

**Mikey's macro style** (his collection only; others' collections are theirs):
- No Shift/Ctrl branches inside macros: Shift+1-7 and Ctrl+1-7 are separate
  bars.
- No `@player`, `@focus` or `@cursor` variants. One exception (2026-11-04,
  Mikey's ask): the mage's Polymorph sets your focus (mouseover enemy, else
  target, replacing any focus) and casts on `[@focus]`, so the sheep stays
  your focus; it pairs with mikey-focuscast's buttons.
- `/stopattack` only when the spell goes on your target, never when it goes on
  a mouseover: `/stopattack [@mouseover,noexists][@mouseover,noharm][@mouseover,dead]`
  is true exactly when `[@mouseover,harm,nodead]` fails (2026-11-04, Mikey's
  ask; the mage's Polymorph in Mikey and Default so far).
- Mouseover on harmful ranged spells (`[@mouseover,harm,nodead] []`), but not
  on melee spam.
- Lay on Hands is mouseover-only on purpose (no fallback, so it never lands on
  the wrong unit).
- `/use` rather than `/cast` in most of his files.
- Totems, weapon imbues, poisons and warlock stones/demons live in mikey-ring,
  so they're excluded from macros.
- `Collections/Mikey/Druid.lua`'s header still says form numbers other than
  Bear are avoided; that predates `c.form`. Leave it unless Mikey wants it
  revisited.

## ClassicWowForever collection

For guild members new to Forever or to a class, not Mikey's own use. Rules
agreed with Mikey:

- Bodies **exactly as published**; PvP skipped. Only names are ours.
- One macro per **main spell** (the spell on the unmodified button):
  class-wide first, then site order. Other specs' duplicates and item-only
  macros are listed at the bottom of each file with the reason.
- `learn` = main spell; `spells` = every spell in the body.
- Overlap with Default is intentional: changing Default must not change these.
- Credit header required: the site is CC BY 4.0 (credit with a link). The
  addon is CC BY-NC-SA 4.0.
- One-time snapshot (reviewed by the site 12 Oct 2026, taken 25 Oct 2026); no
  refresh process.

**Doing the remaining classes** (druid, hunter, mage, paladin, priest, shaman,
warlock, warrior):

1. Open `https://classicwowforever.com/macros/` in the built-in browser. The
   spec sections only exist in the rendered page; the sandbox network blocks
   the site, and a plain fetch from a script only sees the class-wide section.
2. Paste `tools/classicwowforever/snapshot.js` into the page, then
   `await cwfSnapshot("hunter", "HUNTER")`. It returns `{ errs, text }`; fix
   any `errs` (long or duplicate names) with the `names` override map, keyed by
   the site's macro id.
3. Write `text` to `Collections/ClassicWowForever/<Class>.lua` (CRLF), add it
   to the `.toc`, and update the README's collections table.
4. Spot-check with `tools/trimtest.py` at a few levels and against slot counts.

The script reproduces `Rogue.lua` byte for byte. Checked 25 Oct 2026: 481
macros on the site, 358 of them non-PvP.

## Parked ideas (Mikey's call when to pick up)

- **`/startattack` acquires a target by itself** (confirmed by Mikey in game
  on Classic, Retail and Forever, 2026-11-02): with no target, or a dead one,
  it picks one up. So out of stealth nothing extra is needed. In stealth, where
  `/startattack` would break stealth, the rogue's pattern is
  `/targetenemy [stealth,noharm][stealth,dead]` (stealth inside each bracket;
  `[stealth][noharm][dead]` would retarget on every press in stealth).
- **`/targetenemy [noharm][dead]` before `/startattack`** as the standard
  "acquire then act" pattern. It would be stealth-gated for rogue/druid and
  skipped for CC, heals and pet spells, and could go into the Mikey
  collections and `AutoBody`. Mikey wants to think about it first.
- **Hunter `/startattack`** stays as is: Forever swaps between Auto Shot and
  melee by itself.
- **Account-wide default collection** (planned; see `docs/roadmap.html`).
- **Slash commands (done 2026-10-30):** `/mma` and `/mikeymacros`, the mikey
  addons' standard; the old `/mm` still works as a hidden alias.
- **Linter:** the VS Code extension tolerates `learn` but doesn't check it
  (e.g. that `learn` names a spell in `spells`). It also flags names shared
  with other collections, which is expected for ClassicWowForever.
- **Docs:** public on GitHub Pages (`docs/`, code-monkie.github.io/mikey-macros);
  the repo itself is private.
