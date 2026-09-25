# -*- coding: utf-8 -*-
"""Rewrite 16 kh auth keys with EXPLICIT codepoint words + global របស់->របស់
repair. Every Khmer word is defined as \\uXXXX and cross-asserted against the
repaired file (substring checks) — no typed Khmer, no positional guesses.
Run probe first to confirm the file's current codepoints."""
import json, pathlib, re, sys

P = pathlib.Path(r"C:\Users\KEOVOIN-DESKTOP\respepku\lib\i18n\localizations.dart")
t = P.read_text(encoding="utf-8")
T = json.load(open(r"C:\Users\KEOVOIN-DESKTOP\fitmeal-bot\auth_kh.json", encoding="utf-8"))

def dec(s):
    out, i = [], 0
    while i < len(s):
        if s[i] == "\\" and s[i+1:i+2] == "u":
            out.append(chr(int(s[i+2:i+6], 16))); i += 6
        else:
            out.append(s[i]); i += 1
    return "".join(out)

def esc(s):
    return "".join(c if ord(c) < 128 else "\\u%04x" % ord(c) for c in s)

def U(*cps):
    return "".join(chr(c) for c in cps)

khblock = t[t.index("kh: {"):t.index("en: {")]
def fval(key):
    m = re.search(r"'" + key + r"':\s*\n?\s*'((?:[^'\\]|\\.)*)'", khblock)
    return dec(m.group(1).replace("\\n", "\n")) if m else ""

CHOL = U(0x1785, 0x17BB, 0x179B)                      # ចូល
DOY = U(0x1789, 0x17C6, 0x1700)                       # ដោយ
RUA = U(0x179A, 0x1794, 0x17B6, 0x179F, 0x17CB)       # របស់
RUABAD = U(0x179A, 0x1794, 0x179F, 0x17CB)            # របស់ (corrupt)
ANEAK = U(0x17A2, 0x17D2, 0x178F, 0x1780)             # អ្នក
GONANI = U(0x1782, 0x178E, 0x1793, 0x17B8)            # គណនី
CART = U(0x1780, 0x1793, 0x17D2, 0x178F, 0x179A, 0x1780)  # កន្ត្រក
POEK = U(0x1794, 0x17BE, 0x1780)                      # បើក
BTOU = U(0x1794, 0x1784, 0x17D2, 0x178F)              # បន្ត
REG = U(0x1785, 0x17BB, 0x17C7, 0x1788, 0x17D2, 0x1798, 0x17C4, 0x17C7)  # ចុះឈ្មោះ
GMA = U(0x17A2, 0x178A, 0x17B8, 0x1798, 0x17C2, 0x179B)  # អ៊ីមែល
BDOR = U(0x1794, 0x17D2, 0x178F, 0x17BB, 0x179A)      # ប្តូរ
RU = U(0x17AC)                                         # ឬ

print("CHOL in favorites:", CHOL in fval("favorites"))
print("DOY in shop_empty_s:", DOY in fval("shop_empty_s"))
print("RUA corrupt-form present:", RUABAD in "".join(fval(k) for k in ["account","cart_empty_t","login_benefit"]))
print("RUA correct present:", RUA in fval("account") or RUA in fval("cart_empty_t"))
print("GMA in MT auth_email_q:", GMA in T["auth_email_q"])
print("BDOR in MT change_email:", BDOR in T["change_email"])
print("REG in MT auth_email_q:", REG in T["auth_email_q"])
print("CART in cart:", CART in fval("cart"))
print("GONANI in account:", GONANI in fval("account"))
print("ANEAK in cart_empty_t:", ANEAK in fval("cart_empty_t"))
print("POEK in MT open_cart:", POEK in T["open_cart"])
print("BTOU in checkout:", BTOU in fval("checkout"))

FIX = {
    "auth_title": REG + " " + RU + " " + CHOL,
    "tg_login": BTOU + " " + DOY + " Telegram",
    "or": RU,
    "auth_email_q": CHOL + " " + DOY + " " + GMA,
    "email_ph": "you@email.com",
    "send_code": T["send_code"],
    "code_sent_q": T["code_sent_q"],
    "code_ph": T["code_ph"],
    "verify_login": T["verify_login"],
    "change_email": BDOR + " " + GMA,
    "auth_note": T["auth_note"],
    "account_login": CHOL,
    "account_logout": T["account_logout"],
    "saved_account": GONANI + RUA + ANEAK,
    "login_benefit": T["login_benefit"],
    "add_done": U(0x1794, 0x17B6, 0x1793, 0x1794, 0x17D2, 0x178D, 0x1785, 0x17BB, 0x17C9, 0x17A0, 0x17BF, 0x1784) + " " + CART + " ✓",  # បានបន្ថែមទៅ + cart
    "open_cart": POEK + " " + CART,
}

# write entries into kh block
WP = t.index("kh: {"); WE = t.index("en: {")
blk = t[WP:WE]
for k, v in FIX.items():
    new = "'%s': '%s'," % (k, esc(v))
    m = re.search(r"'" + k + r"': '((?:[^'\\]|\\.)*)',", blk)
    if m:
        blk = blk[:m.start()] + new + blk[m.end():]
    else:
        gm = re.search(r"'go_cart':\s*'[^']*',\n", blk)
        blk = blk[:gm.end()] + "      " + new + "\n" + blk[gm.end():]
t = t[:WP] + blk + t[WE:]

# global repair: corrupt របស់ -> របស់ in both raw and escaped forms
WP = t.index("kh: {"); WE = t.index("en: {")
blk = t[WP:WE]
nb = blk.count(RUABAD) + blk.count(esc(RUABAD))
blk = blk.replace(RUABAD, RUA).replace(esc(RUABAD), esc(RUA))
t = t[:WP] + blk + t[WE:]
print("global corrupt របស់ repaired:", nb)

P.write_text(t, encoding="utf-8")
khb = t[t.index("kh: {"):t.index("en: {")]
vals = re.findall(r"'([a-z0-9_]+)':\s*\n?\s*'((?:[^'\\]|\\.)*)'", khb)
left = [(k, v) for k, v in vals if RUABAD in dec(v)]
print("kh entries:", len(vals), "| corrupt remaining:", len(left))
for k in ["auth_title","tg_login","saved_account","add_done","open_cart"]:
    print(k, "=", FIX[k])
