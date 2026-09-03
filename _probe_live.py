import json, urllib.request, uuid

PIN = "751024"
VID = str(uuid.uuid4())
def hdrs():
    return {
        "Content-Type": "application/json",
        "Accept": "application/json, text/plain, */*",
        "Origin": "https://www.jiomart.com",
        "Referer": "https://www.jiomart.com/cart/bag",
        "User-Agent": "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36",
        "pincode": PIN, "x-pincode": PIN, "glo_pincode": PIN, "x-glo-pincode": PIN,
        "X-Location-Detail": json.dumps({"country": "INDIA", "country_iso_code": "IN", "pincode": PIN}),
        "X-Geolocation": json.dumps({"polygon_ids": []}),
        "x-visitor-id": VID, "visitor-id": VID, "X-Visitor-Id": VID,
        "x-channel": "MOB", "clientId": "mweb",
    }

def probe(name, url, headers=None, data=None):
    try:
        req = urllib.request.Request(url, headers=headers or {"User-Agent": "Mozilla/5.0"},
                                     data=json.dumps(data).encode() if data else None,
                                     method="POST" if data else "GET")
        with urllib.request.urlopen(req, timeout=15) as r:
            body = r.read().decode("utf-8", "replace")
            print(f"[{name}] HTTP {r.status}")
            try:
                j = json.loads(body)
                print(f"  keys: {list(j.keys())[:10]}")
                print(f"  snippet: {json.dumps(j)[:400]}")
                return j
            except Exception:
                print(f"  body: {body[:200]}")
                return None
    except urllib.error.HTTPError as e:
        print(f"[{name}] HTTP {e.code} :: {e.read()[:300]}")
        return None
    except Exception as e:
        print(f"[{name}] ERROR: {e}")
        return None

# 1. Search WITH pincode headers
j = probe("SEARCH+headers", "https://www.jiomart.com/api/service/application/catalog/v1.0/products?q=amul+mozarella&page_size=5&page_no=1", headers=hdrs())

slug = None
items = (j or {}).get("items") or []
print(f"\nTotal items: {len(items)}")
if items:
    it = items[0]
    print(f"ITEM[0] keys: {sorted(it.keys())}")
    print(json.dumps(it, indent=1)[:1500])

# 2. Sizes API with headers
if slug:
    j2 = probe("SIZES+headers", f"https://www.jiomart.com/api/service/application/catalog/v2.0/products/{slug}/sizes", headers=hdrs())
    if j2:
        sizes = j2.get("sizes") or (j2.get("data") or {}).get("sizes") or []
        print(f"  top keys: {list(j2.keys())[:12]}")
        if sizes:
            print(f"  first size keys: {list(sizes[0].keys())[:18]}")
            print(f"  seller_ids: {[s.get('seller_id') for s in sizes[:5]]}")
            print(f"  stock flags: {[s.get('is_available', s.get('available', '?')) for s in sizes[:5]]}")


j3 = probe('SIZES-NEW', f'https://www.jiomart.com/api/service/application/catalog/v2.0/products/{slug}/sizes', headers=hdrs())
if j3:
    print('  keys:', sorted(j3.keys()))
    szs = j3.get('sizes') or []
    if szs:
        print('  size[0]:', json.dumps(szs[0])[:800])

j4 = probe('DETAIL-OLD', f'https://www.jiomart.com/api/service/application/catalog/v1.0/products/{slug}', headers=hdrs())

