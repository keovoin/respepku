"""Fetch Noto Sans Khmer static weights from Google Fonts CSS API."""
import re, urllib.request, pathlib

OUT = pathlib.Path(r"C:\Users\KEOVOIN-DESKTOP\respepku\assets\fonts")
OUT.mkdir(parents=True, exist_ok=True)
UA = {"User-Agent": "Mozilla/5.0"}

def get(url):
    req = urllib.request.Request(url, headers=UA)
    return urllib.request.urlopen(req, timeout=60).read()

css = get(
    "https://fonts.googleapis.com/css2?family=Noto+Sans+Khmer:wght@400;500;600;700;800&display=swap").decode()

blocks = re.findall(r"font-weight:\s*(\d+);.*?url\((https://[^)]+)\)", css, re.S)
for wght, url in blocks:
    data = get(url)
    if data[:4] not in (b"\x00\x01\x00\x00", b"OTTO", b"true", b"ttcf"):
        print("BAD", wght, data[:16]); continue
    p = OUT / f"NotoSansKhmer-{wght}.ttf"
    p.write_bytes(data)
    print("saved", p.name, len(data))
