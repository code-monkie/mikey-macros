# mikey-macros

Per-character class macros that build themselves as you level.

Write a class's macros once, in full, the way you want them at max level. On
any character that follows them, the addon creates them all, then keeps every
macro trimmed to the spells that character actually knows. Learn a spell and
the macros that use it update on their own: no rewriting macros every level,
no ranks, no broken fall-through lines.

Out of the box, auto mode gives each class spell a macro as you learn it, with
mouseover targeting, `/startattack` on attacks, and safe versions of crowd
control, stealth and resurrection.

Part of a small library of KISS addons built for WoW: Forever. Developed and
tested on Classic Era (1.15.9) and retail (12.1.5).

## Features

- **Works out of the box.** Auto mode gives every class spell you learn a
  macro, shaped for the spell: mouseover targeting on ranged spells,
  `/startattack` on attacks, `!` on toggles. At level 1 the starting spells on
  your bar become their macros in place; later, the macro window opens so you
  can drag new ones on.
- **One rule for every macro.** For each spell: the macro from the collection
  you follow, else the **Default** collection's (hand-picked exceptions such as
  crowd control, stealth and resurrection), else a generated one, unless the
  spell is on the class's exclude list (Eyes of the Beast, tracking, ...).
- **Collections, opt-in.** Follow someone's hand-written set with
  `/mm use <name>`. Its macros appear as you learn their spells, or all at
  once with `/mm sync all` so you can lay out your action bars at level 1.
- **Always correct for your level.** Collection macros leave out spells you
  haven't trained and update themselves (after combat) as you learn them,
  keeping their places on your bars.
- **Plain macro text.** Collections are ordinary macro bodies in Lua files,
  with combined keys, modifiers, stance and form conditions, `/castsequence`
  and deliberate rank-1 copies all supported.

## Quick start

1. Install: put the `mikey-macros` folder in `Interface\AddOns` and restart
   the game.
2. Play. Each class spell you learn gets its own macro; drag it onto a bar.

A character that's already leveled when the addon first sees it is left as it
is: `/mm sync` gives it macros for everything it knows.

To follow a collection on a character: `/mm collections` to see what's
installed, `/mm use <name>`, then `/mm sync` (or `/mm clear -a` first, for a
clean switch). `/mm sync all` also creates the macros for spells you haven't
learned yet (they show a question mark and fill in as you train).

## Commands

| Command | |
|---|---|
| `/mm list` | Macros for this character's class and their state |
| `/mm sync` | Create the missing macros for the spells you know (normally automatic as you learn them) |
| `/mm sync all` | The same, plus collection macros for spells you haven't learned yet |
| `/mm resync` | `/mm sync all`, then rewrite the rest; nothing leaves your bars |
| `/mm update` | Rewrite now (normally automatic) |
| `/mm clear` | Delete this character's collection macros (by name) |
| `/mm clear -a` | Delete all of this character's macros, after a confirmation |
| `/mm collections` | Installed collections and the one this character follows |
| `/mm use <name>` | Follow a collection on this character (`default`, or `none` to stop) |
| `/mm auto on` / `off` | Auto mode (on by default): a macro for each new class spell |
| `/mm docs` | The documentation's web address, ready to copy |

Details, including how `/mm clear` matches names: [Commands](docs/commands.html).

## Included collections

| Collection | Classes |
|---|---|
| Default | Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock (exceptions and exclude lists) |
| Mikey | Rogue, Shaman, Hunter, Druid, Warlock, Paladin |
| Ulako | Shaman, Mage |
| ClassicWowForever | Rogue (snapshot of [classicwowforever.com/macros](https://classicwowforever.com/macros/), CC BY 4.0) |

Every class works with auto mode; a collection is for hand-written macros on
top. Adding one is a single file: see the
[Collections guide](docs/collections-guide.html).

## VS Code extension

Editing collections in VS Code? The **mikey-macros lint** extension (in
`tools/vscode-mikey-macros/`) works on the macro text inside `body = [[ ... ]]`:

- **checks as you type**: bad conditions and units, brackets, missing `;`, name
  and length limits, files missing from the `.toc`, names shared between
  collections;
- **autocomplete** for conditions, units, condition values, slash commands and the
  macro's own spells;
- **hover** explanations of conditions, units and commands;
- **colors** for commands, conditions, units and values, in any theme.

Install: `python tools/vscode-mikey-macros/build_vsix.py`, then in VS Code
Extensions → ⋯ → **Install from VSIX…** and pick the built `.vsix`. Details in the
[VS Code extension guide](docs/vscode-extension.html).

## Documentation

Online at <https://code-monkie.github.io/mikey-macros/> (in game, `/mm docs`
gives you the address to copy).

- [Collections guide](docs/collections-guide.html): edit an existing collection,
  start your own, switch between them, clearing and name collisions, sharing.
- [Writing macros](docs/writing-macros.html): the macro entry format, trimming
  rules, combined macros, conventions and limits.
- [Commands](docs/commands.html): every command in detail.
- [How it works](docs/how-it-works.html): lifecycle, automatic updates, saved
  data, limits and troubleshooting.
- [VS Code extension](docs/vscode-extension.html): installing and using the
  editor extension (checks, autocomplete, hover, colors).
- [Roadmap](docs/roadmap.html): planned work and ideas.

## Future development

Planned next:

- **An account-wide default collection**: opt every character into a collection
  at once (for the classes it covers), with `/mm use` still overriding it per
  character.

Ideas being kept for later (trade-offs in the [Roadmap](docs/roadmap.html)):

- dirty-macro detection, so hand edits in the macro window are respected;
- an in-game editor that saves overrides on top of a collection.

## Repository layout

```
mikey-macros.toc                  load order; every collection file is listed here
Core.lua                          spell detection, trimming, collections, auto mode, commands
Collections/Default/<Class>.lua   the exceptions to generated macros, and the exclude list
Collections/<Owner>/<Class>.lua   one person's macro list for one class
docs/                             guides (also online)
tools/vscode-mikey-macros/        VS Code extension: checks, colors and autocompletes macros
tools/classicwowforever/          browser script that builds the ClassicWowForever collection files
tools/trimtest.py                 shows how a collection's macros trim at given known spells
CLAUDE.md                         working notes for Claude sessions on this repo
```

## License

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/): free to use,
share and adapt with credit, not for commercial use, and adaptations must use
the same license. See [LICENSE](LICENSE).
