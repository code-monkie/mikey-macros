// Builds Collections/ClassicWowForever/<Class>.lua from classicwowforever.com.
// Run in a browser tab on https://classicwowforever.com/ (any page; it fetches
// the class pages same-origin). The site's spec sections only exist in the
// rendered page, so a plain HTTP fetch from a script won't see them.
//
//   await cwfSnapshot("rogue", "ROGUE", { "macro-id": "Short Name" })
//
// returns { errs, text }: the full file text (header included) and any problems
// (names over 16 characters, duplicate names, bodies over 255). Names default
// to the macro's main spell; pass overrides keyed by the site's macro id
// (article.mc id) when that's too long or collides.
//
// Rules (agreed for this collection, see CLAUDE.md):
// - bodies exactly as published; PvP section skipped;
// - main spell = last clause of #showtooltip, else the default (last) clause
//   of the first /cast|/use line, else the first step of a /castsequence;
// - one macro per main spell: class-wide first, then site order; the rest are
//   listed at the bottom of the file;
// - macros whose main spell is an item or slot (trinkets, poisons, stones)
//   are skipped, since nothing is learned to make them;
// - learn = main spell; spells = every spell in the body (items left out).

async function cwfSnapshot(cls, CLS, names = {}, snapshotDate = new Date().toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" })) {
  const html = await fetch(`/macros/${cls}/`).then(r => r.text());
  const doc = new DOMParser().parseFromString(html, "text/html");
  const reviewed = (doc.body.textContent.match(/Reviewed (\d+ \w+ \d{4})/) || [])[1] || "unknown date";

  const macros = []; let section = null;
  for (const el of doc.querySelectorAll("h2, article.mc")) {
    if (el.tagName === "H2") { section = el.textContent.trim(); continue; }
    if (section === "PvP") continue;
    const meta = el.querySelector(".mc-meta");
    macros.push({
      section, id: el.id,
      title: el.querySelector("h3")?.textContent.trim(),
      code: el.querySelector("pre code")?.textContent.replace(/\r/g, "").trim(),
      meta: meta ? [...meta.querySelectorAll(":scope > span")].map(s => s.textContent.trim()) : [],
    });
  }

  const base = x => x.trim().replace(/^!/, "").replace(/\s*\(\s*rank\s*\d+\s*\)$/i, "").trim();
  const lastClause = s => { const p = s.split(";"); return base(p[p.length - 1].replace(/^(\[[^\]]*\]\s*)+/, "")); };
  const ITEM = /(Potion|Poison|Stone|stone|Healthstone|Soulstone|Mana (Ruby|Citrine|Jade|Agate)|Meat)$/;
  const isItem = n => /^\d+$/.test(n) || (ITEM.test(n) && !/^(Create|Conjure) /.test(n));

  function mainSpell(code) {
    const lines = code.split("\n");
    for (const l of lines) { const m = l.match(/^#showtooltip\s+(.+)$/i); if (m && !/^\d+$/.test(m[1].trim())) return lastClause(m[1]); }
    for (const l of lines) {
      const m = l.match(/^\/(cast|use|castsequence)\s+(.*)$/i); if (!m) continue;
      if (m[1].toLowerCase() === "castsequence") return base(m[2].replace(/^(\[[^\]]*\]\s*)+/, "").replace(/^reset=\S+\s+/, "").split(",")[0]);
      const a = lastClause(m[2]); if (a && !/^\d+$/.test(a)) return a;
    }
    return null;
  }
  function spellList(code) {
    const s = []; const add = x => { x = base(x); if (x && !isItem(x) && !s.includes(x)) s.push(x); };
    for (const line of code.split("\n")) {
      const m = line.match(/^\/(cast|use|castsequence)\s+(.*)$/i); if (!m) continue;
      for (const cl of m[2].split(";")) {
        let a = cl.trim().replace(/^(\[[^\]]*\]\s*)+/, "").trim();
        if (m[1].toLowerCase() === "castsequence") a.replace(/^reset=\S+\s+/, "").split(",").forEach(add); else add(a);
      }
    }
    return s;
  }

  const seen = {}, kept = [], dropped = [], skipped = [];
  for (const m of macros) {
    const ms = mainSpell(m.code);
    if (!ms || isItem(ms)) { skipped.push(m); continue; }
    const k = ms.toLowerCase();
    if (seen[k]) { dropped.push([m, seen[k]]); continue; }
    seen[k] = m; kept.push([m, ms]);
  }

  const errs = [], used = {}, lua = []; let sec = null;
  for (const [m, ms] of kept) {
    const name = names[m.id] || ms;
    if (name.length > 16) errs.push(`name over 16: ${name} (id ${m.id})`);
    if (used[name]) errs.push(`duplicate name: ${name} (id ${m.id})`); used[name] = 1;
    if (m.code.length > 255) errs.push(`body over 255: ${m.title} (${m.code.length})`);
    const sp = spellList(m.code);
    if (!sp.some(x => x.toLowerCase() === ms.toLowerCase())) sp.unshift(ms);
    if (m.section !== sec) { sec = m.section; lua.push("", `    -- ${sec} ${"-".repeat(Math.max(3, 72 - sec.length))}`); }
    lua.push(`    -- ${m.title} (${[...m.meta].reverse().join(", ")})`);
    const [open, close] = m.code.includes("]]") ? ["[=[", "]=]"] : ["[[", "]]"];
    lua.push(`    { name = ${JSON.stringify(name)}, learn = ${JSON.stringify(ms)},`);
    lua.push(`        spells = { ${sp.map(x => JSON.stringify(x)).join(", ")} }, body = ${open}`);
    for (const l of m.code.split("\n")) lua.push("        " + l);
    lua.push(`    ${close} },`);
  }

  const Cls = cls[0].toUpperCase() + cls.slice(1);
  const header = [
    `-- ClassicWowForever: ${Cls} macros from classicwowforever.com, as published.`,
    `-- Source: https://classicwowforever.com/macros/${cls}/ (reviewed there`,
    `-- ${reviewed}; snapshot taken ${snapshotDate}). The site says these are`,
    `-- not yet tested in the live Forever client.`,
    `-- Credit: macros by Classic WoW Forever (https://classicwowforever.com/),`,
    `-- licensed CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). Bodies`,
    `-- are unchanged; only the macro names are ours (16-character limit).`,
    `--`,
    `-- One macro per main spell (the spell on its unmodified button), made when`,
    `-- that spell (\`learn\`) is learned; other spells in it are trimmed out until`,
    `-- you know them. Class-wide macros win; otherwise the first in site order.`,
    `-- PvP macros aren't included. What was left out is listed at the bottom.`,
    ``, `local _, ns = ...`, ``,
  ];
  const foot = ["", "-- Not made: no spell to learn (items or equipment slots only):"];
  for (const m of skipped) foot.push(`--   ${m.title} (${m.section})`);
  foot.push("-- Not made: another macro above already has the same main spell:");
  for (const [m, w] of dropped) foot.push(`--   ${m.title} (${m.section}) -> same main spell as "${w.title}"`);

  const text = header.join("\n") + "\n" + `ns.Collection("ClassicWowForever").${CLS} = {` +
    lua.join("\n").replace(/^\n/, "\n") + "\n}\n" + foot.join("\n") + "\n";
  return { errs, text };
}
