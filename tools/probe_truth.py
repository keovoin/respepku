# -*- coding: utf-8 -*-
"""ASCII-only codepoint probe of localizations.dart kh block truth."""
import re, pathlib

def U(*c): return "".join(chr(x) for x in c)

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

words = {
    "ROBAH": U(0x179A, 0x1794, 0x17B6, 0x179F, 0x17CB),
    "ROBAH_BAD": U(0x179A, 0x1794, 0x179F, 0x17CB),
    "CART": U(0x1780, 0x1793, 0x17D2, 0x178F, 0x179A, 0x1780),
    "CART2": U(0x1780, 0x1793, 0x17D2, 0x178F, 0x17D2, 0x179A, 0x1780),
    "CHOL": U(0x1785, 0x17BB, 0x179B),
    "DOY": U(0x1789, 0x17C6, 0x1700),
    "BTOU": U(0x1794, 0x1793, 0x17D2, 0x178F),
    "GONANI": U(0x1782, 0x178E, 0x1793, 0x17B8),
    "ANEAK": U(0x17A2, 0x17D2, 0x178F, 0x1780),
    "POEK": U(0x1794, 0x17BE, 0x1780),
    "GMA": U(0x17A2, 0x178A, 0x17B8, 0x1798, 0x17C2, 0x179B),
    "REG": U(0x1785, 0x17BB, 0x17C7),
    "CHMOH": U(0x1788, 0x17D2, 0x1798, 0x17C4, 0x17C7),
    "BDOR": U(0x1794, 0x17D2, 0x178F, 0x17BB, 0x179A),
    "TPHENH": U(0x1791, 0x17B8, 0x1789),
}
for name, w in words.items():
    keys_with = [k for k, v in vals.items() if w in v]
    print(name, "len", len(w), "found in:", ",".join(keys_with[:6]) or "NONE")

# the four entries I injected earlier (current on-disk truth):
for k in ["auth_email_q", "tg_login", "saved_account", "add_done", "open_cart",
          "auth_title", "change_email"]:
    if k in vals:
        print(k, "cps:", " ".join(f"{ord(c):04x}" for c in vals[k][:14]))
    else:
        print(k, "MISSING")
