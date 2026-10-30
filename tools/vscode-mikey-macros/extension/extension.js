// mikey-macros lint: checks the macro text inside `body = [[ ... ]]` in
// mikey-macros collection files as you type, and explains macro conditions,
// units and commands on hover.
//
// The rules live in plain functions (lintText, hoverAt) with no VS Code
// dependency; activate() only wires them to the editor.

"use strict";

const MAX_NAME = 16;
const MAX_BODY = 255;

// ------------------------------------------------------------------ reference data
// Macro conditions: name -> what it means. "no" + any of these is its opposite.
const CONDITIONS = {
    mod: "`[mod]` true while Shift, Ctrl or Alt is held. `[mod:shift]`, `[mod:ctrl]`, `[mod:alt]` for one key; `[mod:ctrl/shift]` for either.",
    modifier: "Same as `mod`: a modifier key is held. `[modifier:shift]` etc.",
    combat: "You are in combat.",
    stealth: "You are stealthed (Stealth, Prowl, Shadowmeld).",
    harm: "The unit can be attacked by you.",
    help: "The unit can be helped (healed, buffed) by you.",
    dead: "The unit is dead.",
    exists: "The unit exists (e.g. you have a target, or something is under the mouse).",
    pet: "You have a pet out. `[pet:Voidwalker]` checks the pet's name or family.",
    group: "You are in a group. `[group:party]` or `[group:raid]` for one kind.",
    party: "You are in a party.",
    raid: "You are in a raid.",
    mounted: "You are mounted.",
    swimming: "You are swimming.",
    flying: "You are flying.",
    flyable: "You are somewhere you could fly.",
    advflyable: "You are somewhere dynamic flying works (retail).",
    indoors: "You are indoors.",
    outdoors: "You are outdoors.",
    resting: "You are resting (in an inn or city).",
    form: "You are in a shapeshift form or stance. `[form:1]` checks one by number; `[form:1/3]` either. Druid: only Bear is reliably 1. `[form]` alone means any form.",
    stance: "Same as `form`: a stance or form, by number. `[stance:1]`.",
    shapeshift: "You are shapeshifted (a temporary form such as a quest disguise).",
    channeling: "You are channeling a spell. `[channeling:Spell Name]` for one spell.",
    channel: "Same as `channeling`.",
    equipped: "An item of that type is equipped in **any** slot. `[equipped:Daggers]`, `[equipped:Shields]`. Note: an off-hand dagger counts.",
    worn: "Same as `equipped`.",
    known: "You know a spell. `[known:Spell Name]` or `[known:12345]` (retail).",
    spec: "Your active talent group (dual spec). `[spec:1]`, `[spec:2]`.",
    talent: "You have a talent. `[talent:row/column]` (retail).",
    pvptalent: "You have a PvP talent (retail).",
    actionbar: "The current action bar page. `[actionbar:2]`.",
    bar: "Same as `actionbar`.",
    bonusbar: "A bonus action bar is active (e.g. a form or vehicle bar). `[bonusbar:1]`.",
    button: "Which mouse button clicked the macro. `[button:2]` is right-click.",
    btn: "Same as `button`.",
    cursor: "Something is held on the cursor.",
    extrabar: "The extra action button is shown.",
    overridebar: "An override bar is active.",
    possessbar: "The possess bar is active.",
    vehicleui: "You are in a vehicle with its own bar.",
    unithasvehicleui: "The unit is in a vehicle with its own bar.",
    canexitvehicle: "You can leave the vehicle you're in.",
    petbattle: "You are in a pet battle (retail).",
    target: "`target=unit` is the older spelling of `@unit`.",
};

const UNITS = {
    player: "You.",
    target: "Your current target.",
    focus: "Your focus target.",
    mouseover: "Whatever is under the mouse: a character in the world, or a unit frame.",
    pet: "Your pet.",
    cursor: "Cast at the cursor's position (ground-targeted spells), without the targeting circle.",
    none: "No unit: the spell asks for a target (or uses the targeting circle).",
    npc: "The NPC you're talking to.",
    vehicle: "The vehicle you're in.",
};
const UNIT_PATTERNS = [
    [/^party[1-4]$/, "A party member, by position (party1 to party4)."],
    [/^raid([1-9]|[1-3][0-9]|40)$/, "A raid member, by position (raid1 to raid40)."],
    [/^arena[1-5]$/, "An arena opponent (arena1 to arena5)."],
    [/^boss[1-5]$/, "A boss (boss1 to boss5)."],
    [/^partypet[1-4]$/, "A party member's pet."],
    [/^raidpet([1-9]|[1-3][0-9]|40)$/, "A raid member's pet."],
];

const SLASH = {
    "/use": "Use a spell, an item, or an equipment slot number (`/use 13`). The house style uses `/use` for everything.",
    "/cast": "Cast a spell. Works the same as `/use` for spells; the house style prefers `/use`.",
    "/castsequence": "Cast the listed spells in turn, one per press. `reset=3` restarts after 3 s idle; `reset=combat/target` on leaving combat or changing target.",
    "/castrandom": "Cast one of the listed spells at random.",
    "/userandom": "Use one of the listed items or spells at random.",
    "/startattack": "Start auto-attack on your target (or the given unit). Often `/startattack [nostealth]` for stealth openers.",
    "/stopattack": "Stop auto-attack.",
    "/stopcasting": "Stop the spell you're casting, so the next line goes off at once.",
    "/stopspelltarget": "Cancel a spell that's waiting for a target.",
    "/target": "Target a unit or a name. `/target [@mouseover,harm,nodead]` makes the mouseover your target.",
    "/tar": "Short for `/target`.",
    "/targetexact": "Target by exact name only.",
    "/targetenemy": "Cycle to the next enemy (like Tab).",
    "/targetfriend": "Cycle to the next friendly unit.",
    "/targetlasttarget": "Go back to your previous target.",
    "/cleartarget": "Clear your target.",
    "/focus": "Set your focus to a unit.",
    "/clearfocus": "Clear your focus.",
    "/assist": "Target your target's (or a unit's) target.",
    "/petattack": "Send your pet to attack your target (or the given unit).",
    "/petfollow": "Pet follows you.",
    "/petpassive": "Pet passive: it won't attack on its own.",
    "/petdefensive": "Pet defensive: it attacks what attacks you.",
    "/petaggressive": "Pet aggressive: it attacks anything nearby.",
    "/petassist": "Pet assist: it attacks what you attack.",
    "/petstay": "Pet stays where it is.",
    "/petmoveto": "Move the pet to a spot.",
    "/petautocaston": "Turn a pet spell's autocast on.",
    "/petautocastoff": "Turn a pet spell's autocast off.",
    "/petautocasttoggle": "Toggle a pet spell's autocast.",
    "/petstopattack": "Pet stops attacking.",
    "/dismount": "Get off your mount. `/dismount [mounted]`.",
    "/cancelaura": "Remove a buff from yourself by name.",
    "/cancelform": "Leave your shapeshift form.",
    "/stopmacro": "Stop the macro here (when the conditions match).",
    "/click": "Click a button by its frame name.",
    "/run": "Run Lua code.",
    "/script": "Run Lua code (same as `/run`).",
    "/equip": "Equip an item by name.",
    "/equipslot": "Equip an item into a slot number.",
    "/equipset": "Equip a saved equipment set.",
    "/say": "Say something.", "/s": "Say something.",
    "/yell": "Yell something.", "/y": "Yell something.",
    "/party": "Party chat.", "/p": "Party chat.",
    "/guild": "Guild chat.", "/g": "Guild chat.",
    "/raid": "Raid chat.", "/rw": "Raid warning.",
    "/emote": "Custom emote.", "/e": "Custom emote.", "/me": "Custom emote.",
    "/targetmarker": "Put a raid marker on a unit. `/tm 6`.", "/tm": "Put a raid marker on a unit.",
    "/worldmarker": "Place a world marker.", "/wm": "Place a world marker.",
    "/follow": "Follow a unit.", "/f": "Follow a unit.",
    "/invite": "Invite a player to your group.",
    "/console": "Change a console variable (CVar).",
    "/dump": "Print a Lua value (debugging).",
    "/leavevehicle": "Leave the vehicle you're in.",
    "/changeactionbar": "Switch to an action bar page.",
    "/swapactionbar": "Swap between two action bar pages.",
    "/point": "Point emote.", "/no": "No emote.", "/cheer": "Cheer emote.", "/wave": "Wave emote.",
};
const USE_COMMANDS = new Set(["/use", "/cast", "/castsequence", "/castrandom", "/userandom"]);

const META = {
    "#showtooltip": "Shows the spell's tooltip and live icon on the button. With no name, the first spell the macro would use; `#showtooltip Spell` for a fixed one. mikey-macros drops the name while that spell isn't known yet.",
    "#show": "Shows the spell's live icon (no tooltip). Same naming rules as `#showtooltip`.",
};

// ------------------------------------------------------------------ helpers
function unitInfo(unit) {
    let u = unit.toLowerCase();
    let suffix = 0;
    while (u.endsWith("target") && u !== "target") { u = u.slice(0, -6); suffix++; }
    let desc = UNITS[u];
    if (!desc) for (const [re, d] of UNIT_PATTERNS) if (re.test(u)) { desc = d; break; }
    if (!desc) return null;
    if (suffix) desc = "The target of: " + desc.charAt(0).toLowerCase() + desc.slice(1) + (suffix > 1 ? " (" + suffix + " levels deep)" : "");
    return desc;
}

function baseName(text) {
    return text.trim().replace(/^!\s*/, "").replace(/\s*\(\s*rank\s*\d+\s*\)$/i, "").trim();
}

function conditionInfo(token) {
    const t = token.trim();
    if (t.startsWith("@")) {
        const d = unitInfo(t.slice(1));
        return d ? { ok: true, text: "**`" + t + "`**: act on " + d.charAt(0).toLowerCase() + d.slice(1) } : { ok: false, text: "unknown unit '" + t + "'" };
    }
    if (/^target=/i.test(t)) {
        const d = unitInfo(t.split("=")[1]);
        return d ? { ok: true, text: "**`" + t + "`** (old spelling of `@`): " + d } : { ok: false, text: "unknown unit in '" + t + "'" };
    }
    const name = t.split(":")[0].trim().toLowerCase();
    if (CONDITIONS[name]) return { ok: true, text: "**`" + name + "`**: " + CONDITIONS[name] };
    if (name.startsWith("no") && CONDITIONS[name.slice(2)]) {
        const base = CONDITIONS[name.slice(2)];
        return { ok: true, text: "**`" + name + "`**: true when `" + name.slice(2) + "` is false. (`" + name.slice(2) + "`: " + base.charAt(0).toLowerCase() + base.slice(1) + ")" };
    }
    return { ok: false, text: "unknown condition '" + t + "'" };
}

// Every `{ name = "...", spells = { ... }, body = [[ ... ]] }` entry in a collection file.
function findEntries(text) {
    const entries = [];
    const re = /\{\s*name\s*=\s*"([^"]*)"\s*,([\s\S]*?)\bbody\s*=\s*(\[(=*)\[|function)/g;
    let m;
    while ((m = re.exec(text))) {
        const nameStart = m.index + m[0].indexOf('"') + 1;
        const sm = /spells\s*=\s*\{([\s\S]*?)\}/.exec(m[2]);
        const spells = sm ? [...sm[1].matchAll(/"([^"]*)"/g)].map((x) => x[1]) : [];
        const entry = { name: m[1], nameStart, nameEnd: nameStart + m[1].length, spells, bodyStart: null, bodyEnd: null };
        if (m[3] === "function") { entries.push(entry); continue; }
        const close = "]" + m[4] + "]";
        const start = m.index + m[0].length;
        const end = text.indexOf(close, start);
        if (end < 0) break;
        entry.bodyStart = start;
        entry.bodyEnd = end;
        entries.push(entry);
        re.lastIndex = end + close.length;
    }
    return entries;
}

// The body's non-blank lines: { start (offset of the first non-space char), text }.
function bodyLines(text, entry) {
    const lines = [];
    let pos = entry.bodyStart;
    for (const raw of text.slice(entry.bodyStart, entry.bodyEnd).split("\n")) {
        const line = raw.replace(/\r$/, "");
        const lead = line.length - line.trimStart().length;
        const t = line.trim();
        if (t) lines.push({ start: pos + lead, text: t });
        pos += raw.length + 1;
    }
    return lines;
}

// ------------------------------------------------------------------ lint
// Returns [{ start, end, severity: "error" | "warning", message }] as offsets into text.
function lintText(text) {
    const out = [];
    const add = (start, end, severity, message) => out.push({ start, end: Math.max(end, start + 1), severity, message });
    if (!/ns\.Collection\(\s*"[^"]+"\s*\)\s*\.\s*[A-Z]+\s*=/.test(text)) return out;

    const entries = findEntries(text);
    const seen = new Map();
    for (const e of entries) {
        if (seen.has(e.name)) add(e.nameStart, e.nameEnd, "error", "Duplicate macro name '" + e.name + "' in this class.");
        else seen.set(e.name, true);
        if (e.name.length > MAX_NAME) add(e.nameStart, e.nameEnd, "error", "Name is " + e.name.length + " characters (max " + MAX_NAME + ").");
        if (e.bodyStart === null) continue;

        const lines = bodyLines(text, e);
        const length = lines.reduce((n, l) => n + l.text.length, 0) + Math.max(lines.length - 1, 0);
        if (length > MAX_BODY) add(e.nameStart, e.nameEnd, "error", "Body is " + length + " characters (max " + MAX_BODY + ").");

        const tracked = new Map(e.spells.map((s) => [s.toLowerCase(), s]));
        const used = new Set();

        for (const { start, text: t } of lines) {
            if (t.startsWith("#")) {
                const word = t.split(/\s/)[0];
                const low = word.toLowerCase();
                if (low.startsWith("#showtooltip") && low !== "#showtooltip") add(start, start + word.length, "error", "Needs a space after #showtooltip.");
                else if (!META[low]) add(start, start + word.length, "error", "Unknown macro line '" + word + "'.");
                const arg = t.slice(word.length).trim();
                if (arg) used.add(baseName(arg).toLowerCase());
                continue;
            }
            if (!t.startsWith("/")) { add(start, start + t.length, "warning", "Line doesn't start with / or #."); continue; }

            const cmd = t.split(/\s/)[0];
            const low = cmd.toLowerCase();
            if (!SLASH[low]) add(start, start + cmd.length, "warning", "Unknown slash command '" + cmd + "'.");

            // brackets: balanced and not nested
            let depth = 0, open = -1, broken = false;
            for (let i = 0; i < t.length; i++) {
                if (t[i] === "[") { depth++; if (depth > 1) { add(start + i, start + i + 1, "error", "Nested '['."); broken = true; } else open = i; }
                else if (t[i] === "]") { depth--; if (depth < 0) { add(start + i, start + i + 1, "error", "']' without a matching '['."); depth = 0; broken = true; } }
            }
            if (depth > 0) { add(start + open, start + t.length, "error", "'[' is never closed."); continue; }
            if (broken) continue;

            // conditions
            for (const g of t.matchAll(/\[([^\]]*)\]/g)) {
                let pos = g.index + 1;
                for (const tok of g[1].split(",")) {
                    const trimmed = tok.trim();
                    const tokStart = start + pos + (tok.length - tok.trimStart().length);
                    if (trimmed) {
                        const info = conditionInfo(trimmed);
                        if (!info.ok) add(tokStart, tokStart + trimmed.length, "error", info.text.charAt(0).toUpperCase() + info.text.slice(1) + ".");
                    }
                    pos += tok.length + 1;
                }
            }

            if (!USE_COMMANDS.has(low)) continue;
            // clauses
            let pos = cmd.length;
            for (const clause of t.slice(cmd.length).split(";")) {
                const lead = clause.length - clause.trimStart().length;
                const c = clause.trim();
                const cStart = start + pos + lead;
                pos += clause.length + 1;
                if (!c) continue;
                const condPart = /^(\s*\[[^\]]*\]\s*)*/.exec(c)[0];
                let action = c.slice(condPart.length);
                let actionStart = cStart + condPart.length;
                if (action.includes("[")) {
                    add(cStart, cStart + c.length, "error", "Conditions after a spell name: missing ';' between clauses?");
                    continue;
                }
                let names;
                if (low === "/castsequence") {
                    const r = /^reset=\S+\s+/.exec(action);
                    if (r) { action = action.slice(r[0].length); actionStart += r[0].length; }
                    names = [];
                    let p = 0;
                    for (const part of action.split(",")) { names.push({ text: part, at: actionStart + p }); p += part.length + 1; }
                } else {
                    names = [{ text: action, at: actionStart }];
                }
                for (const n of names) {
                    const b = baseName(n.text);
                    if (!b || /^\d+$/.test(b)) continue; // equipment slot
                    used.add(b.toLowerCase());
                    if (!tracked.has(b.toLowerCase())) {
                        const at = n.at + (n.text.length - n.text.trimStart().length);
                        add(at, at + n.text.trim().length, "warning", "'" + b + "' isn't in spells, so it's never trimmed (fine for an item, or a spell known from level 1).");
                    }
                }
            }
        }
        for (const [low, s] of tracked) {
            if (!used.has(low)) add(e.nameStart, e.nameEnd, "warning", "'" + s + "' is in spells but the body never uses it.");
        }
    }
    return out;
}

// ------------------------------------------------------------------ hover
// Markdown explaining the condition, unit, command or # line at `offset`, or null.
function hoverAt(text, offset) {
    if (!/ns\.Collection\(/.test(text)) return null;
    const entry = findEntries(text).find((e) => e.bodyStart !== null && offset >= e.bodyStart && offset <= e.bodyEnd);
    if (!entry) return null;
    const line = bodyLines(text, entry).find((l) => offset >= l.start && offset <= l.start + l.text.length);
    if (!line) return null;
    const i = offset - line.start;
    const t = line.text;

    // inside [ ... ]
    const open = t.lastIndexOf("[", i), close = t.lastIndexOf("]", i - 1);
    if (open !== -1 && open > close) {
        const end = t.indexOf("]", open);
        const inner = t.slice(open + 1, end === -1 ? t.length : end);
        let pos = open + 1;
        for (const tok of inner.split(",")) {
            if (i >= pos && i <= pos + tok.length && tok.trim()) {
                const info = conditionInfo(tok.trim());
                return { start: line.start + pos, end: line.start + pos + tok.length, markdown: info.ok ? info.text : "⚠ " + info.text };
            }
            pos += tok.length + 1;
        }
        return null;
    }
    // the first word: a command or # line
    const word = t.split(/\s/)[0];
    if (i <= word.length) {
        const low = word.toLowerCase();
        const desc = SLASH[low] || META[low];
        if (desc) return { start: line.start, end: line.start + word.length, markdown: "**`" + low + "`**: " + desc };
        return null;
    }
    // reset= in a castsequence
    const r = /reset=\S+/.exec(t);
    if (r && i >= r.index && i <= r.index + r[0].length) {
        return { start: line.start + r.index, end: line.start + r.index + r[0].length,
            markdown: "**`reset=`**: when the sequence starts over. Seconds idle (`reset=3`), or `combat`, `target`, `shift`, `ctrl`, `alt`, joined with `/`." };
    }
    return null;
}

// ------------------------------------------------------------------ completion
// Values offered after "condition:".
const CONDITION_VALUES = {
    mod: ["shift", "ctrl", "alt"],
    modifier: ["shift", "ctrl", "alt"],
    form: ["1", "2", "3", "4", "5", "6"],
    stance: ["1", "2", "3", "4", "5", "6"],
    group: ["party", "raid"],
    button: ["1", "2", "3", "4", "5"],
    btn: ["1", "2", "3", "4", "5"],
    spec: ["1", "2"],
    equipped: ["Daggers", "Shields", "One-Handed Swords", "Two-Handed Swords", "One-Handed Axes", "Two-Handed Axes", "One-Handed Maces", "Two-Handed Maces", "Staves", "Fist Weapons", "Polearms", "Bows", "Guns", "Crossbows", "Wands", "Thrown"],
};
CONDITION_VALUES.worn = CONDITION_VALUES.equipped;
const COMMON_UNITS = ["mouseover", "player", "target", "focus", "pet", "cursor", "targettarget", "focustarget", "pettarget",
    "party1", "party2", "party3", "party4", "none"];

// Suggestions at `offset`: { start, end, items: [{ label, kind, detail, doc, insert }] } or null.
// kind is one of "condition", "unit", "value", "command", "meta", "spell".
function completionsAt(text, offset) {
    if (!/ns\.Collection\(/.test(text)) return null;
    const entry = findEntries(text).find((e) => e.bodyStart !== null && offset >= e.bodyStart && offset <= e.bodyEnd);
    if (!entry) return null;
    const lineStart = Math.max(text.lastIndexOf("\n", offset - 1) + 1, entry.bodyStart);
    const prefix = text.slice(lineStart, offset).replace(/\r$/, "");
    const lead = prefix.length - prefix.trimStart().length;
    const body = prefix.trimStart();

    // # lines and slash commands at the start of a line
    if (/^#[A-Za-z]*$/.test(body)) {
        return { start: lineStart + lead, end: offset, items: Object.keys(META).map((m) => ({ label: m, kind: "meta", doc: META[m] })) };
    }
    if (body === "" || /^\/[A-Za-z]*$/.test(body)) {
        return { start: lineStart + lead, end: offset,
            items: Object.keys(SLASH).map((c) => ({ label: c, kind: "command", doc: SLASH[c] })) };
    }

    // inside [ ... ]
    const open = prefix.lastIndexOf("["), close = prefix.lastIndexOf("]");
    if (open > close) {
        const inner = prefix.slice(open + 1);
        const tokRaw = inner.slice(inner.lastIndexOf(",") + 1);
        const tok = tokRaw.trimStart();
        const tokStart = offset - tok.length;
        const colon = tok.indexOf(":");
        if (colon !== -1) {
            const cond = tok.slice(0, colon).trim().toLowerCase().replace(/^no/, "");
            const values = CONDITION_VALUES[cond];
            if (!values) return null;
            const after = tok.slice(colon + 1);
            const slash = after.lastIndexOf("/");
            return { start: offset - (after.length - slash - 1), end: offset,
                items: values.map((v) => ({ label: v, kind: "value", doc: CONDITIONS[cond] || "" })) };
        }
        if (tok.startsWith("@")) {
            return { start: tokStart, end: offset,
                items: COMMON_UNITS.map((u) => ({ label: "@" + u, kind: "unit", doc: unitInfo(u) || "" })) };
        }
        const items = [];
        for (const c of Object.keys(CONDITIONS)) {
            if (c === "target") continue; // target= is the old unit syntax; offered as @units
            items.push({ label: c, kind: "condition", doc: CONDITIONS[c] });
            items.push({ label: "no" + c, kind: "condition", doc: "True when `" + c + "` is false. (`" + c + "`: " + CONDITIONS[c] + ")" });
        }
        for (const u of COMMON_UNITS) items.push({ label: "@" + u, kind: "unit", doc: unitInfo(u) || "" });
        return { start: tokStart, end: offset, items };
    }

    // the spell part of a /use clause: this macro's own spells
    const cmd = (body.split(/\s/)[0] || "").toLowerCase();
    if (!USE_COMMANDS.has(cmd) || body.length <= cmd.length) return null;
    const rest = body.slice(cmd.length);
    const clause = rest.slice(rest.lastIndexOf(";") + 1);
    let action = clause.replace(/^(\s*\[[^\]]*\]\s*)*/, "");
    if (cmd === "/castsequence") action = action.replace(/^reset=\S+\s+/, "").split(",").pop();
    action = action.replace(/^\s*!?\s*/, "");
    if (/^reset=/.test(action)) return null;
    return { start: offset - action.length, end: offset,
        items: entry.spells.map((s) => ({ label: s, kind: "spell", doc: "From this macro's `spells` list." })) };
}

// ------------------------------------------------------------------ checks across files
// Needs the addon folder (the one with mikey-macros.toc). io: { exists, read, list } on real paths.
// Returns { doc: [problems in this file], toc: { path, problems: [{ line, message, severity }] } } or null.
function crossFileProblems(docPath, text, io, path) {
    let root = path.dirname(docPath);
    for (let i = 0; i < 6 && !io.exists(path.join(root, "mikey-macros.toc")); i++) {
        const up = path.dirname(root);
        if (up === root) return null;
        root = up;
    }
    const tocPath = path.join(root, "mikey-macros.toc");
    if (!io.exists(tocPath)) return null;
    const norm = (p) => p.replace(/\\/g, "/").toLowerCase();
    const rel = norm(path.relative(root, docPath));
    if (!rel.startsWith("collections/")) return null;

    const doc = [];
    const toc = [];
    const listed = new Set();
    io.read(tocPath).split(/\r?\n/).forEach((raw, i) => {
        const line = raw.trim();
        if (!line || line.startsWith("#") || !/^collections[\\/]/i.test(line)) return;
        listed.add(norm(line));
        if (!io.exists(path.join(root, ...line.split(/[\\/]/)))) {
            toc.push({ line: i, message: "Listed in the .toc but the file doesn't exist: " + line, severity: "error" });
        }
    });
    if (!listed.has(rel)) {
        const end = text.indexOf("\n") === -1 ? text.length : text.indexOf("\n");
        doc.push({ start: 0, end, severity: "error", message: "Not listed in mikey-macros.toc, so the game won't load this file. Add: " + path.relative(root, docPath).replace(/\//g, "\\") });
    }

    // the same macro name in another collection for this class
    const own = /ns\.Collection\(\s*"([^"]+)"\s*\)\s*\.\s*([A-Z]+)\s*=/.exec(text);
    if (own) {
        const others = new Map(); // name -> [owners]
        const collections = path.join(root, "Collections");
        for (const ownerDir of io.list(collections)) {
            const dir = path.join(collections, ownerDir);
            for (const f of io.list(dir)) {
                if (!f.toLowerCase().endsWith(".lua")) continue;
                const p = path.join(dir, f);
                if (norm(p) === norm(docPath)) continue;
                const t = io.read(p);
                const m = /ns\.Collection\(\s*"([^"]+)"\s*\)\s*\.\s*([A-Z]+)\s*=/.exec(t);
                if (!m || m[2] !== own[2] || m[1] === own[1]) continue;
                for (const e of findEntries(t)) {
                    if (!others.has(e.name)) others.set(e.name, []);
                    others.get(e.name).push(m[1]);
                }
            }
        }
        for (const e of findEntries(text)) {
            if (others.has(e.name)) {
                doc.push({ start: e.nameStart, end: e.nameEnd, severity: "warning",
                    message: "'" + e.name + "' is also a " + own[2].toLowerCase() + " macro in " + others.get(e.name).join(", ") +
                        "'s collection; /mma clear and switching collections treat them as the same macro." });
            }
        }
    }
    return { doc, toc: { path: tocPath, problems: toc } };
}

// ------------------------------------------------------------------ VS Code wiring
function activate(context) {
    const vscode = require("vscode");
    const fs = require("fs");
    const path = require("path");
    const diagnostics = vscode.languages.createDiagnosticCollection("mikey-macros");
    context.subscriptions.push(diagnostics);

    const io = {
        exists: (p) => { try { return fs.existsSync(p); } catch (e) { return false; } },
        read: (p) => {
            const open = vscode.workspace.textDocuments.find((d) => d.uri.scheme === "file" && path.resolve(d.uri.fsPath) === path.resolve(p));
            if (open) return open.getText();
            try { return fs.readFileSync(p, "utf8"); } catch (e) { return ""; }
        },
        list: (p) => { try { return fs.readdirSync(p); } catch (e) { return []; } },
    };
    const severity = (s) => (s === "error" ? vscode.DiagnosticSeverity.Error : vscode.DiagnosticSeverity.Warning);
    const tocProblems = new Map(); // toc path -> problems, shared by every collection file

    const isCollection = (doc) => doc.languageId === "lua" && /ns\.Collection\(/.test(doc.getText());
    const refresh = (doc) => {
        if (!isCollection(doc)) { diagnostics.delete(doc.uri); return; }
        const text = doc.getText();
        let problems = lintText(text);
        if (doc.uri.scheme === "file") {
            const cross = crossFileProblems(doc.uri.fsPath, text, io, path);
            if (cross) {
                problems = problems.concat(cross.doc);
                tocProblems.set(cross.toc.path, cross.toc.problems);
                const tocUri = vscode.Uri.file(cross.toc.path);
                diagnostics.set(tocUri, cross.toc.problems.map((p) => {
                    const d = new vscode.Diagnostic(new vscode.Range(p.line, 0, p.line, 1000), p.message, severity(p.severity));
                    d.source = "mikey-macros";
                    return d;
                }));
            }
        }
        diagnostics.set(doc.uri, problems.map((p) => {
            const d = new vscode.Diagnostic(new vscode.Range(doc.positionAt(p.start), doc.positionAt(p.end)), p.message, severity(p.severity));
            d.source = "mikey-macros";
            return d;
        }));
    };
    const refreshAll = () => vscode.workspace.textDocuments.forEach(refresh);

    const timers = new Map();
    const later = (doc) => {
        const key = doc.uri.toString();
        clearTimeout(timers.get(key));
        timers.set(key, setTimeout(() => { timers.delete(key); refresh(doc); }, 300));
    };

    refreshAll();
    const KIND = {
        condition: vscode.CompletionItemKind.Keyword,
        unit: vscode.CompletionItemKind.Variable,
        value: vscode.CompletionItemKind.EnumMember,
        command: vscode.CompletionItemKind.Function,
        meta: vscode.CompletionItemKind.Keyword,
        spell: vscode.CompletionItemKind.Value,
    };
    const DETAIL = { condition: "macro condition", unit: "unit", value: "value", command: "slash command", meta: "macro line", spell: "spell (this macro)" };
    context.subscriptions.push(
        vscode.workspace.onDidOpenTextDocument(refresh),
        vscode.workspace.onDidChangeTextDocument((e) => later(e.document)),
        vscode.workspace.onDidSaveTextDocument(() => refreshAll()), // a saved .toc or collection can change other files' problems
        vscode.workspace.onDidCloseTextDocument((doc) => diagnostics.delete(doc.uri)),
        vscode.languages.registerHoverProvider({ language: "lua" }, {
            provideHover(doc, position) {
                const h = hoverAt(doc.getText(), doc.offsetAt(position));
                if (!h) return null;
                return new vscode.Hover(new vscode.MarkdownString(h.markdown),
                    new vscode.Range(doc.positionAt(h.start), doc.positionAt(h.end)));
            },
        }),
        vscode.languages.registerCompletionItemProvider({ language: "lua" }, {
            provideCompletionItems(doc, position) {
                const c = completionsAt(doc.getText(), doc.offsetAt(position));
                if (!c) return null;
                const range = new vscode.Range(doc.positionAt(c.start), doc.positionAt(c.end));
                return c.items.map((it, i) => {
                    const item = new vscode.CompletionItem(it.label, KIND[it.kind]);
                    item.range = range;
                    item.detail = DETAIL[it.kind];
                    if (it.doc) item.documentation = new vscode.MarkdownString(it.doc);
                    item.sortText = String(i).padStart(4, "0");
                    return item;
                });
            },
        }, "[", ",", "@", "/", "#", ":", ";"),
    );
}

function deactivate() {}

module.exports = { activate, deactivate, lintText, hoverAt, completionsAt, crossFileProblems };
