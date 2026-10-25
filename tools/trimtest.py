"""Check how a collection file's macros trim at a given set of known spells.

There's no Lua runtime in the Claude sandboxes, so this is a Python copy of
Core.lua's KnownOnly (keep it in step if KnownOnly changes). It reads plain
`{ name = ..., [learn = ...,] spells = { ... }, body = [[ ... ]] }` entries;
function bodies are skipped.

    python tools/trimtest.py Collections/ClassicWowForever/Rogue.lua \
        "Sinister Strike, Eviscerate, Stealth, Backstab" ...

Each argument after the file is one stage (a comma-separated known-spell list).
Prints which macros exist at that stage and their trimmed bodies.
"""
import re
import sys

ENTRY = re.compile(
    r'\{\s*name\s*=\s*"([^"]+)",(?:\s*learn\s*=\s*"([^"]+)",)?\s*spells\s*=\s*\{([^}]*)\},'
    r'\s*body\s*=\s*\[(=*)\[\n(.*?)\n\s*\]\4\]', re.S)


def base(t):
    n = re.match(r'^\s*!?\s*(.*?)\s*$', t).group(1)
    return re.sub(r'\s*\(\s*[Rr]ank\s*\d+\s*\)$', '', n)


def known_only(body, spells, knows):
    tracked = {s.lower() for s in spells}

    def keep(t):
        return base(t).lower() not in tracked or knows(base(t))

    out = []
    for line in body.split('\n'):
        m = re.match(r'^(#showtooltip)\s+(.*?)\s*$', line, re.I)
        if m and m.group(2):
            kept = []
            for c in m.group(2).split(';'):
                c = c.strip()
                if c:
                    a = re.match(r'^.*\]\s*(.*)$', c)
                    if keep(a.group(1) if a else c):
                        kept.append(c)
            line = m.group(1) + (' ' + '; '.join(kept) if kept else '')
        m = re.match(r'^(/\w+)\s+(.*)$', line)
        low = m and m.group(1).lower()
        if low in ('/use', '/cast', '/castsequence'):
            kept = []
            for c in m.group(2).split(';'):
                c = c.strip()
                if not c:
                    continue
                mm = re.match(r'^(.*\])\s*(.*)$', c)
                conds, action = (mm.group(1), mm.group(2)) if mm else ('', c)
                if low == '/castsequence':
                    r = re.match(r'^(reset=\S+)\s+(.*)$', action)
                    reset, lst = (r.group(1), r.group(2)) if r else (None, action)
                    sp = [i.strip() for i in lst.split(',') if i.strip() and keep(i.strip())]
                    if sp:
                        kept.append(' '.join(p for p in (conds, reset, ', '.join(sp)) if p))
                elif keep(action):
                    kept.append(c)
            if kept:
                out.append(m.group(1) + ' ' + '; '.join(kept))
        else:
            out.append(line)
    return '\n'.join(out)


def main():
    src = open(sys.argv[1], encoding='utf-8').read().replace('\r\n', '\n')
    entries = ENTRY.findall(src)
    for stage in sys.argv[2:]:
        known = {k.strip().lower() for k in stage.split(',') if k.strip()}
        made = []
        for name, learn, sp, _, body in entries:
            spells = re.findall(r'"([^"]+)"', sp)
            makers = [learn] if learn else spells
            if any(s.lower() in known for s in makers):
                made.append((name, spells, body))
        print(f'== {len(made)} macros at: {stage}')
        for name, spells, body in made:
            body = re.sub(r'\n[ \t]+', '\n', body).strip()
            res = known_only(body, spells, lambda s: s.lower() in known)
            print(f'  [{name}] ({len(res)} chars)\n    ' + res.replace('\n', '\n    '))


if __name__ == '__main__':
    main()
