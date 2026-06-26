# Firecrawl API reference (deep-research skill)

Base URL: `https://api.firecrawl.dev` — current API is **v2**.
Auth header: `Authorization: Bearer $env:FIRECRAWL_API_KEY`.

## Endpoints

| Endpoint | Verb | Use for |
|---|---|---|
| `/v2/scrape` | POST | Single URL → markdown / html / json / screenshot |
| `/v2/crawl` | POST | Async multi-page crawl. Returns `{success, id, url}`; poll `GET /v2/crawl/{id}`; cancel `DELETE /v2/crawl/{id}` |
| `/v2/map` | POST | Fast site-map URL discovery (up to 100k links) |
| `/v2/search` | POST | Web/news/image search; can inline-scrape each result |
| `/v2/extract` | POST | LLM-driven structured extraction with JSON schema; async — poll `GET /v2/extract/{id}` |
| `/v2/deep-research` | POST | **Deprecated.** Don't build new code on it. Use `/search` + parallel `/scrape` instead. |

## Common parameters

- `formats`: array — `markdown | html | rawHtml | links | screenshot | summary | json | branding | changeTracking | highlights`
- `onlyMainContent` (bool, default true)
- `waitFor` ms, `timeout` ms (default 60000, max 300000), `maxAge` ms (cache hit window)
- `proxy`: enum `basic | enhanced | auto` — Firecrawl picks egress; `enhanced` is the anti-bot tier. **There is no field to inject your own proxy URL.**
- `actions`: array of `{type: wait|click|write|press|scroll|screenshot|executeJavascript|pdf|scrape, ...}`
- `location`: `{country: "US", languages: ["en"]}`, `mobile` (bool)
- `includeTags` / `excludeTags`, `blockAds`, `removeBase64Images`, `skipTlsVerification`, `headers`

## Credits & rate limits (Hobby tier — $16/mo, 3000 credits)

- Scrape: **1 credit / page**
- Search: **1 credit / result**
- Action: **5 credits / action**
- PDF parse: 1 credit / page
- Extract & deep-research: variable
- Hobby concurrency: **5**; crawl rate: **3 rpm**

## Curl recipes

### Scrape → markdown
```bash
curl -X POST "$FIRECRAWL_BASE_URL/v2/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com","formats":["markdown"],"onlyMainContent":true,"timeout":30000}'
```

### Search → top-N with inline scrape
```bash
curl -X POST "$FIRECRAWL_BASE_URL/v2/search" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"opus 4.7 release notes","limit":10,"sources":["web"],"scrapeOptions":{"formats":["markdown"]}}'
```

### Map → URL list
```bash
curl -X POST "$FIRECRAWL_BASE_URL/v2/map" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://docs.example.com","limit":500}'
```

### Crawl (async)
```bash
# kick off
curl -X POST "$FIRECRAWL_BASE_URL/v2/crawl" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://docs.example.com","limit":50,"scrapeOptions":{"formats":["markdown"]}}'
# poll
curl "$FIRECRAWL_BASE_URL/v2/crawl/<id>" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY"
```

### Extract with JSON schema
```bash
curl -X POST "$FIRECRAWL_BASE_URL/v2/extract" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "urls":["https://news.ycombinator.com/*"],
    "prompt":"top 10 stories",
    "schema":{"type":"object","properties":{"stories":{"type":"array","items":{"type":"object","properties":{"title":{"type":"string"},"url":{"type":"string"},"points":{"type":"integer"}}}}}}
  }'
```

## PowerShell equivalents

Use `Invoke-RestMethod` — it auto-deserializes JSON:

```powershell
$body = @{ url = 'https://example.com'; formats = @('markdown'); onlyMainContent = $true } | ConvertTo-Json
$headers = @{ Authorization = "Bearer $env:FIRECRAWL_API_KEY"; 'Content-Type' = 'application/json' }
Invoke-RestMethod -Method Post -Uri "$env:FIRECRAWL_BASE_URL/v2/scrape" -Headers $headers -Body $body
```

For long polls (`crawl`, `extract`), wrap in a `do { Start-Sleep 3 } until ($status.status -in 'completed','failed')` loop.

## Doc URLs
- Introduction: https://docs.firecrawl.dev/api-reference/introduction
- Scrape: https://docs.firecrawl.dev/api-reference/endpoint/scrape
- Crawl: https://docs.firecrawl.dev/api-reference/endpoint/crawl-post
- Map: https://docs.firecrawl.dev/api-reference/endpoint/map
- Search: https://docs.firecrawl.dev/api-reference/endpoint/search
- Extract: https://docs.firecrawl.dev/api-reference/endpoint/extract
- Rate limits: https://docs.firecrawl.dev/rate-limits
- Pricing: https://www.firecrawl.dev/pricing
