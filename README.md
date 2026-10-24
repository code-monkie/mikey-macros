# mikey-macros

Per-character class macros that build themselves as you level.

Write a class's macros once, in full, the way you want them at max level. On
each new character the addon creates them all, then keeps every macro
trimmed to the spells that character actually knows. Learn a spell and the
macros that use it update on their own: no rewriting macros every level, no
ranks, no broken fall-through lines.

Part of a small library of KISS addons built for WoW: Forever. Developed and
tested on Classic Era (1.15.9) and retail (12.1.5).

## Features

- **Set up once per character.** One command creates the whole class set, so
  you can lay out your action bars at level 1.
- **Always correct for your level.** Unlearned spells are left out of each
  macro until you train them; macros update automatically (after combat) and
  keep their places on your bars.
- **Plain macro text.** Class lists are ordinary macro bodies in Lua files,
  easy to read and edit, with combined keys, modifiers, stance and form
  conditions, `/castsequence` and deliberate rank-1 copies all supported.
- **Collections.** Macro lists belong to a person. Friends can each keep
  their own set, and every character chooses whose to follow.

## Quick start

1. Install: put the `mikey-macros` folder in `Interface\AddOns` and restart
   the game.
2. On a character, run `/mm sync`. The macro window opens on the character
   tab with the class's macros; keys you haven't learned yet show a
   question mark.
3. Drag the macros onto your action bars.
4. Play. Each macro fills in as you train its spells.

To follow someone else's set on a character: `/mm collections` to see what's
installed, `/mm use <name>`, then `/mm resync`.

## Commands

| Command | |
|---|---|
| `/mm list` | Macros for this character's class and their state |
| `/mm sync` | Create the class set (once per character) |
| `/mm resync` | Create anything missing and rewrite the rest; nothing leaves your bars |
| `/mm update` | Rewrite now (normally automatic) |
| `/mm clear` | Delete this character's collection macros (by name) |
| `/mm collections` | Installed collections and the one this character follows |
| `/mm use <name>` | Follow a collection on this character (`default` to go back) |

Details, including how `/mm clear` matches names: [Commands](docs/commands.html).

## Included collections

| Collection | Classes |
|---|---|
| Mikey | Rogue, Shaman, Hunter, Druid |
| Ulako | Shaman, Mage |

Classes with no collection aren't supported yet. Adding one is a single file:
see the [Collections guide](docs/collections-guide.html).

## Documentation

- [Collections guide](docs/collections-guide.html): edit an existing collection,
  start your own, switch between them, clearing and name collisions, sharing.
- [Writing macros](docs/writing-macros.html): the macro entry format, trimming
  rules, combined macros, conventions and limits.
- [Commands](docs/commands.html): every command in detail.
- [How it works](docs/how-it-works.html): lifecycle, automatic updates, saved
  data, limits and troubleshooting.
- [Roadmap](docs/roadmap.html): planned work and ideas.

## Future development

Planned next:

- **An account-wide default collection**: choose which collection comes first
  for every class, with `/mm use` still overriding it per character.

Ideas being kept for later (trade-offs in the [Roadmap](docs/roadmap.html)):

- dirty-macro detection, so hand edits in the macro window are respected;
- an in-game editor that saves overrides on top of a collection;
- creating each macro only when its first spell is learned.

## Repository layout

```
mikey-macros.toc                  load order; every collection file is listed here
Core.lua                          spell detection, trimming, collections, commands
Collections/<Owner>/<Class>.lua   one person's macro list for one class
docs/                             guides
```
