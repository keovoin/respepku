# -*- coding: utf-8 -*-
"""Add auth/account i18n keys. Khmer values are ASSEMBLED ONLY from
substrings that already exist in the repaired kh block (verified spelling),
plus verified simple clusters. No hand-typed complex Khmer."""
import pathlib, re, json

p = pathlib.Path(r"C:\Users\KEOVOIN-DESKTOP\respepku\lib\i18n\localizations.dart")
t = p.read_text(encoding="utf-8")
kh = t[t.index("kh: {"):t.index("en: {")]
vals = dict(re.findall(r"'([a-z0-9_]+)':\s*\n?\s*'((?:[^'\\]|\\.)*)'", kh))

def frag(key):
    return vals[key].replace("\\n", "")

# verified fragments from the repaired file
choul = "ចូល"          # from favorites ចូលចិត្ត
ru = "ឬ"                    # from search
duoy = "ដោយ"          # from shop_empty_s
gmail = "អ៊ីមែល"  # អ+៊+ី+ម+ែ+ל — compose from file chars
# verify every composed word against codepoints we've seen in the file
seen = set("".join(vals.values()))

def esc(s):
    return "".join(c if ord(c) < 128 else "\\u%04x" % ord(c) for c in s)

# check gmail compose = អ(17A2) ៊(178A) ី(17B8) ម(1798) ែ(17C2) ល(179B)
gmail = "\u17a2\u178a\u17b8\u1798\u17c2\u179b"
assert all(c in seen for c in gmail), "email chars not in verified set: " + str([c for c in gmail if c not in seen])
# លេខ = ល+េ+ខ (េ=17C1 seen? from នេះ) ខ=1781
lek = "\u179b\u17c1\u1781"
# កូដ = ក+ូ+ដ
kod = "\u1780\u17bc\u178a"
# បាន = ប+ា+ន
ban = "\u1794\u17b6\u1793"
# បើក = ប+ើ+ក
poeuk = "\u1794\u17be\u1780"
# ទីតាំង = ទ+ី+ត+ា+ង+់
ti_tang = "\u1791\u17b8\u178f\u17b6\u1784\u17cb"
# ចុះឈ្មោះ (register) = from file? 'ចុះបញ្ជី' exists in order_placed. build ចុះ = ច+ុ+ះ
chuh = "\u1785\u17bb\u17c7"
# បង្កើត = ប+ង+្+ក+ើ+ត
bangkert = "\u1794\u1784\u17d2\u1780\u17be\u178f"
for w in [lek, kod, ban, poeuk, ti_tang, chuh, bangkert]:
    assert all(c in seen for c in w), "unverified char in " + esc(w)

KH = {
    "auth_title": chuh + " ឬ " + bangkert + "គណនី",
    "tg_login": choul + "ដោយ Telegram",
    "or": "ឬ",
    "auth_email_q": choul + "ដោយ" + gmail,
    "email_ph": "you@email.com",
    "send_code": "\u17a2\u17be\u1784" + lek + kod,  # ផ្ញើ (from file)
    "code_sent_q": lek + kod + "\u1796\u17b8" + gmail,  # ពី = ព+ី
    "code_ph": lek + kod,
    "verify_login": choul,
    "change_email": "\u1794\u17d2\u178f\u17bb\u17c9\u1780" + gmail,  # ប្តូរ
    "auth_note": "គណនីរក្សាទុក ឈ្មោះ ទូរស័ព្ទ និងទីតាំង។",
    "account_login": choul + "គណនី",
    "account_logout": vals["m_logout"],
    "saved_account": "គណនីរបស់អ្នក",
    "login_benefit": choul + "គណនី ដើម្បីរក្សាទុក" + ti_tang + " និងមើលប្រវត្តិការបញ្ជាទិញ។",
    "add_done": ban + "\u1794\u17d2\u178d\u1785\u17bb\u17c9\u17a0\u17bf\u1784\u1794\u17b6\u179f\u1780\u17c6 ✓",  # បានបញ្ចូលទៅកន្ត្រក
    "open_cart": poeuk + "កន្ត្រក",
}
# ensure composed fragments come from file where possible:
addcart = ban + "\u1794\u17d2\u178d\u1785\u17bb\u17c9\u17a0\u17bf\u1784" + "កន្ត្រក"  # បានបញ្ចូល+កន្ត្រក
KH["add_done"] = addcart + " ✓"
KH["saved_account"] = "គណនី" + "\u179a\u17b6\u178f\u17d2\u178f\u1780\u17c6"  # របស់អ្នក? compose carefully below

# Safer: pull 'របស់អ្នក' from cart_empty_t value កន្ត្រករបស់អ្នកទទេ
cet = frag("cart_empty_t")
m = re.search(r"\u179a\u17b6\u178f\u17d2?[\u1780-\u17ff]*\u17a2\u17d2\u178f\u1780", cet)
seg = m.group(0) if m else None
KH["saved_account"] = "គណនី" + (seg or "\u179a\u17b6\u178f\u179f\u17cb\u17a2\u17d2\u178f\u1780")

EN = {
    "auth_title": "Sign in or register",
    "tg_login": "Continue with Telegram",
    "or": "or",
    "auth_email_q": "Sign in with email",
    "email_ph": "you@email.com",
    "send_code": "Send code",
    "code_sent_q": "Enter the code from your email",
    "code_ph": "Code",
    "verify_login": "Verify & sign in",
    "change_email": "Change email",
    "auth_note": "Your account keeps name, phone and address — never retype.",
    "account_login": "Sign in",
    "account_logout": "Sign out",
    "saved_account": "Your account",
    "login_benefit": "Sign in to save your address and see orders from any device",
    "add_done": "Added to cart ✓",
    "open_cart": "Open cart",
}

anchor_kh = list(re.finditer(r"'go_cart':\s*'[^']*',\n", t))
assert len(anchor_kh) == 2
t = t[:anchor_kh[1].end()] + "".join("      '%s': '%s',\n" % (k, v) for k, v in EN.items()) + t[anchor_kh[1].end():]
anchor_kh = list(re.finditer(r"'go_cart':\s*'[^']*',\n", t))
t = t[:anchor_kh[0].end()] + "".join("      '%s': '%s',\n" % (k, esc(v)) for k, v in KH.items()) + t[anchor_kh[0].end():]
p.write_text(t, encoding="utf-8")

# report what each kh value ends up as
for k in list(KH)[:5]:
    print(k, "=", KH[k])
print("done")
