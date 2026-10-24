# mikey-macros lint

Works on the WoW macro text inside `body = [[ ... ]]` in mikey-macros collection
files (any Lua file with an `ns.Collection("Owner").CLASS = { ... }` line).
The Lua around it is left alone.

**Checks as you type**

- Errors: name over 16 characters, body over 255, duplicate names, unbalanced
  or nested `[ ]`, unknown conditions or units (`nocomba`, `@mosueover`), a
  missing `;` between clauses, `#showtooltipX` with no space, unknown `#` lines,
  a collection file not listed in `mikey-macros.toc`, a `.toc` entry with no
  file (shown on the `.toc`).
- Warnings: a spell on a `/use` line that isn't in `spells` (never trimmed), a
  spell in `spells` the body never uses, unknown slash commands, the same macro
  name in another collection for the class.

**Colors** slash commands, `#showtooltip`, conditions, `@units`, values after
`:`, `;`, `!`, `reset=` and `(Rank n)`.

**Autocomplete** conditions and units after `[` or `,`, units after `@`, values
after `mod:` / `form:` / `equipped:` ..., slash commands after `/`, `#` lines,
and the macro's own `spells` where a spell goes.

**Hover** over a condition, unit, slash command or `#showtooltip` for what it
means.

Spell names aren't checked against the game. Bodies written as functions are
skipped. To see what the coloring assigned to a word, run "Developer: Inspect
Editor Tokens and Scopes" from the command palette.
