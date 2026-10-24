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

- **Works out of the box.** Auto mode gives every class spell you learn its own
  macro (`#showtooltip`, `/use Spell`), ready to drag onto a bar and tweak.
  Great for new players and new classes.
- **Collections, opt-in.** Follow someone's hand-written set with
  `/mm use <name>` and `/mm sync`, and the whole class set is created at
  once, so you can lay out your action bars at level 1.
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

To follow a collection on a character: `/mm collections` to see what's
installed, `/mm use <name>`, then `/mm sync`. The macro window opens with the
class's macros (unlearned keys show a question mark); each fills in as you
train its spells.

## Commands

| Command | |
|---|---|
| `/mm list` | Macros for this character's class and their state |
| `/mm sync` | Create the collection's class set (once per character) |
| `/mm resync` | Create anything missing and rewrite the rest; nothing leaves your bars |
| `/mm update` | Rewrite now (normally automatic) |
| `/mm clear` | Delete this character's collection macros (by name) |
| `/mm collections` | Installed collections and the one this character follows |
| `/mm use <name>` | Follow a collection on this character (`none` to stop) |
| `/mm auto on` / `off` | Auto mode (on by default): a macro for each new class spell, unless the collection covers it |
| `/mm docs` | The documentation's web address, ready to copy |

Details, including how `/mm clear` matches names: [Commands](docs/commands.html).

## Included collections

| Collection | Classes |
|---|---|
| Mikey | Rogue, Shaman, Hunter, Druid |
| Ulako | Shaman, Mage |

Classes with no collection aren't supported yet. Adding one is a single file:
see the [Collections guide](docs/collections-guide.html).

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
- an in-game editor that saves overrides on top of a collection;
- creating each macro only when its first spell is learned.

## Repository layout

```
mikey-macros.toc                  load order; every collection file is listed here
Core.lua                          spell detection, trimming, collections, commands
Collections/<Owner>/<Class>.lua   one person's macro list for one class
docs/                             guides (also online)
tools/vscode-mikey-macros/        VS Code extension: checks, colors and autocompletes macros
```

## License

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/): free to use,
share and adapt with credit, not for commercial use, and adaptations must use
the same license. See [LICENSE](LICENSE).
