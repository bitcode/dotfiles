# BrightData API reference (deep-research skill)

Two products are wired into this skill, with different auth models:

1. **Residential proxy** — username/password basic-auth on an HTTP CONNECT tunnel. Already configured in `.env.research`.
2. **REST APIs (Web Unlocker, SERP, Datasets)** — Bearer token. **Optional**: only works if `BRIGHTDATA_API_TOKEN` and the matching `_ZONE` vars are filled in.

## Residential proxy

- Endpoint: `brd.superproxy.io:33335` (modern). The legacy `zproxy.lum-superproxy.io:22225` still works on old zones; new code should target `brd.superproxy.io`.
- Username syntax (hyphen-delimited flags appended to the base username):
  ```
  brd-customer-<CUSTID>-zone-<ZONE>[-country-us][-city-newyork][-state-ca][-asn-56386][-os-windows][-session-<RAND>]
  ```
- Sticky session: append `-session-<arbitrary-string>` — same string = same exit IP for the zone's session window. Rotate the string to get a new IP.
- The base username and password are in `BRIGHTDATA_USERNAME` / `BRIGHTDATA_PASSWORD`. Compose the geo/session flags inline per request.

### Curl through the residential proxy
```bash
curl --proxy "$BRIGHTDATA_PROXY_HOST:$BRIGHTDATA_PROXY_PORT" \
     --proxy-user "${BRIGHTDATA_USERNAME}-country-us-session-rand7421:$BRIGHTDATA_PASSWORD" \
     -k https://lumtest.com/myip.json
```

### PowerShell
```powershell
$proxy = "http://$env:BRIGHTDATA_PROXY_HOST`:$env:BRIGHTDATA_PROXY_PORT"
$user = "$env:BRIGHTDATA_USERNAME-country-us-session-$(Get-Random)"
$cred = [pscredential]::new($user, (ConvertTo-SecureString $env:BRIGHTDATA_PASSWORD -AsPlainText -Force))
Invoke-WebRequest -Uri 'https://lumtest.com/myip.json' -Proxy $proxy -ProxyCredential $cred
```

> **Note:** Firecrawl's `proxy` parameter is an enum (`basic|enhanced|auto`), not a URL. You cannot route Firecrawl through your BrightData proxy. They are independent tools — pick one per request.

## Web Unlocker (REST)

For JS-rendered / Cloudflare / CAPTCHA-walled pages where you only want HTML.

- `POST https://api.brightdata.com/request`
- Auth: `Authorization: Bearer $BRIGHTDATA_API_TOKEN`
- Body: `{"zone":"<unlocker_zone>","url":"<target>","format":"raw"}`
- `format`: `raw` returns HTML body; `json` wraps it.
- Optional: `country`, `method`, `headers`, `data`.
- Billing: per-success only.

```bash
curl -X POST https://api.brightdata.com/request \
  -H "Authorization: Bearer $BRIGHTDATA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"zone\":\"$BRIGHTDATA_UNLOCKER_ZONE\",\"url\":\"https://target.example/protected\",\"format\":\"raw\"}"
```

## SERP API

Same `POST /request` endpoint, different zone — Google/Bing/etc. parity.

```bash
curl -X POST https://api.brightdata.com/request \
  -H "Authorization: Bearer $BRIGHTDATA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"zone\":\"$BRIGHTDATA_SERP_ZONE\",
    \"url\":\"https://www.google.com/search?q=opus+4.7+release&hl=en&gl=us\",
    \"format\":\"json\",
    \"data_format\":\"parsed_light\"
  }"
```

`data_format`: `parsed_light` (top-10 organic, fastest) | `markdown` | omit for full parsed JSON.
Engines: Google, Bing, DuckDuckGo, Yandex, Baidu, Yahoo, Naver.

## Web Scraper API (Datasets)

For structured pulls of LinkedIn, Amazon, Instagram, etc. via prebuilt collectors.

- Trigger: `POST https://api.brightdata.com/datasets/v3/trigger?dataset_id=<gd_xxx>&format=json`
  Body: `[{"url":"https://www.linkedin.com/in/..."}]`
  Returns: `{snapshot_id}`
- Poll: `GET https://api.brightdata.com/datasets/v3/progress/{snapshot_id}`
- Download: `GET https://api.brightdata.com/datasets/v3/snapshot/{snapshot_id}?format=json`

Verify the exact path against the dataset's "API" tab in the BrightData control panel before shipping — paths vary slightly per collector.

## When to reach for BrightData

| Situation | Use |
|---|---|
| Well-behaved doc/blog/news page | Firecrawl `/scrape` (default `proxy: basic`) |
| Mild anti-bot (basic Cloudflare, rate limiting) | Firecrawl `/scrape` with `proxy: "enhanced"` |
| Hard anti-bot (Turnstile, perimeter-x, hard geo-wall) | BrightData Web Unlocker (HTML only) |
| Need raw Google SERP (ads, PAA, knowledge panels) | BrightData SERP API |
| Geo-locked content from a specific city | BrightData residential proxy with `-country-` / `-city-` flags |
| Structured pull from a supported site (LinkedIn, Amazon) | BrightData Datasets (Web Scraper API) |

## Doc URLs
- Residential configure: https://docs.brightdata.com/proxy-networks/residential/configure-your-proxy
- Web Unlocker: https://docs.brightdata.com/scraping-automation/web-unlocker/introduction
- SERP API: https://docs.brightdata.com/scraping-automation/serp-api/introduction
- Datasets: https://docs.brightdata.com/datasets/marketplace/faqs
