# CLAUDE.md: mikey-macros

Handoff notes for Claude sessions working on this addon. The README covers what
the addon does for players; this covers how we work on it and where things
stand. Last updated 25 October 2026.

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
  run (`/mm update`, `/mm sync`, `/mm list`) and what to look for.
- **Where to edit:** `C:\Blizzard\Wow\World of Warcraft\_classic_era_\Interface\AddOns\mikey-macros`
  until Mikey says otherwise. (Earlier work happened in `_retail_`; Forever
  live will be `_forever_`.)
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
  follows one via `/mm use <name>`; Default applies under every collection.
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
  - `body`: macro text (at most 255 after trimming), or `function(c)` returning
    it. Context: `c.knows(spell)`, `c.dagger`, `c.form("Cat Form")` (the
    form's current `[form:N]` number, or nil).
- **Trimming (`KnownOnly`):** `/use`, `/cast` and `/castsequence` clauses and
  `#showtooltip` clauses naming a listed-but-unknown spell are dropped; other
  lines stay.
- **Covered spells:** a spell on a macro you *have* (a modifier or sequence
  step, not what it's made for) gets no generated macro of its own. Until that
  macro exists, it does.
- **Refresh triggers:** login, `SPELLS_CHANGED`, `UPDATE_SHAPESHIFT_FORMS`,
  main-hand changes, leaving combat.
- **Limits:** 18 character macro slots on Classic clients (30 on retail);
  collections can get close.

## Collections

| Collection | Classes | Notes |
|---|---|---|
| Default | Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock | No Warrior file yet. Prowl is a `c.form` built body. |
| Mikey | Rogue, Shaman, Hunter, Druid, Warlock, Paladin | Mikey's own; his style rules below. |
| Ulako | Shaman, Mage | Placeholder; don't review. |
| ClassicWowForever | Rogue | Snapshot of classicwowforever.com; 8 classes to go. |

**Mikey's macro style** (his collection only; others' collections are theirs):
- No Shift/Ctrl branches inside macros: Shift+1-7 and Ctrl+1-7 are separate
  bars.
- No `@player`, `@focus` or `@cursor` variants.
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

- **`/targetenemy [noharm][dead]` before `/startattack`** as the standard
  "acquire then act" pattern. It would be stealth-gated for rogue/druid and
  skipped for CC, heals and pet spells, and could go into the Mikey
  collections and `AutoBody`. Mikey wants to think about it first.
- **Hunter `/startattack`** stays as is: Forever swaps between Auto Shot and
  melee by itself.
- **Account-wide default collection** (planned; see `docs/roadmap.html`).
- **Standard slash commands** across mikey addons: `/mikeymacros` plus a
  short `/mma`.
- **Linter:** the VS Code extension tolerates `learn` but doesn't check it
  (e.g. that `learn` names a spell in `spells`). It also flags names shared
  with other collections, which is expected for ClassicWowForever.
- **Docs:** public on GitHub Pages (`docs/`, code-monkie.github.io/mikey-macros);
  the repo itself is private.
