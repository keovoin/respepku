# -*- coding: utf-8 -*-
import re, pathlib
t = pathlib.Path(r"C:\Users\KEOVOIN-DESKTOP\respepku\lib\i18n\localizations.dart").read_text(encoding="utf-8")
def dec(s):
    o, i = [], 0
    while i < len(s):
        if s[i] == "\\" and s[i+1:i+2] == "u":
            o.append(chr(int(s[i+2:i+6], 16))); i += 6
        else:
            o.append(s[i]); i += 1
    return "".join(o)
khb = t[t.index("kh: {"):t.index("en: {")]
vals = {k: dec(v) for k, v in re.findall(r"'([a-z0-9_]+)':\s*\n?\s*'((?:[^'\\]|\\.)*)'", khb)}
for k in ["favorites", "cart", "cart_empty_t", "go_cart", "open_cart"]:
    print(k, "->", " ".join(f"{ord(c):04x}" for c in vals[k]))
# first 3 cps of favorites = ចូល?
f = vals["favorites"]
print("favorites[:3] = ", " ".join(f"{ord(c):04x}" for c in f[:3]))
# where does ច appear again?
idxs = [i for i, c in enumerate(f) if c == "\u1785"]
print("positions of 1785:", idxs)
