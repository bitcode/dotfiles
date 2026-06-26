# Deep-research workflow recipes

Concrete end-to-end playbooks. Pick one based on user intent.

## Recipe 1 — Topic deep-dive (default)

User asks: *"Research X and give me a synthesis."*

1. **Plan** — write the question down. Decide 2–4 sub-questions that, if answered, would answer the parent.
2. **Discover** — Firecrawl `/v2/search` per sub-question (`limit: 10`, `sources: ["web"]`, no inline scrape yet — cheap recon).
3. **Triage** — read titles + snippets. Keep the top 3–5 URLs per sub-question. Drop obvious spam, SEO farms, and stale (>2 yr) results unless the question is historical.
4. **Fetch in parallel** — `/v2/scrape` each kept URL with `formats: ["markdown"]`. Cap at 5 concurrent (Hobby tier limit). For Cloudflare/JS-walled URLs that fail, retry via BrightData Web Unlocker.
5. **Read & extract** — pull quotes + numbers + dates with source URL. Keep a short evidence list per sub-question.
6. **Synthesize** — write the answer in markdown with inline citations `[1]` `[2]` mapping to a numbered source list at the bottom. Lead with the bottom line; details follow.
7. **Save** — write to `$RESEARCH_OUTPUT_ROOT/<slug>-<yyyymmdd>.md` if `RESEARCH_OUTPUT_ROOT` is set; otherwise leave it inline in the chat.

Cost budget: ~30 credits per sub-question (10 search + ~5 scrape × 4 sub-questions = ~80 credits per topic).

## Recipe 2 — Site / docs ingestion

User asks: *"Pull all the X docs and tell me Y."*

1. `/v2/map` the root URL → URL list (limit 500 by default).
2. Filter URLs by path pattern relevant to the question (`/api/`, `/guides/`, etc.).
3. `/v2/crawl` (async) on the filtered prefix, or just batch `/v2/scrape` if <50 URLs.
4. For crawl: poll `GET /v2/crawl/{id}` every 5–10s until `status` is `completed`. Stream partial results from `data[]` as they arrive.
5. Save to `$RESEARCH_OUTPUT_ROOT/<site-slug>/<page-slug>.md`. Maintain a top-level `index.md` mapping URL → local path.
6. Then answer the user's actual question against the saved corpus.

Cost: 1 credit per page. A 200-page docs site = 200 credits.

## Recipe 3 — Structured extraction (tables, listings, prices)

User asks: *"Extract all the X from these pages into a table."*

1. Define a JSON schema for the rows. Keep fields atomic (string/number/bool); avoid nested arrays unless necessary.
2. `/v2/extract` with `urls` (supports wildcards like `https://example.com/products/*`) + `schema` + a one-line `prompt`.
3. Poll `GET /v2/extract/{id}` until done.
4. Format the result as a markdown table or save as JSON / CSV per user request.

Use this *instead of* scrape+regex when the data is semi-structured but laid out inconsistently across pages.

## Recipe 4 — Hardened target (Cloudflare, paywall, geo-wall)

User asks: *"Get the content of <hardened-url>."*

1. Try Firecrawl `/v2/scrape` with `proxy: "enhanced"` first. Cheaper, returns markdown.
2. If response is empty, all-CAPTCHA, or 403 — fall back to BrightData Web Unlocker (`POST /request`, `format: "raw"`). Returns raw HTML.
3. If the page is geo-locked to a specific country/city — use BrightData residential proxy with the relevant geo flags in the username. Returns raw HTML.
4. Pipe HTML through a markdown converter or pull only the chunks the user actually needs.

## Recipe 5 — Live SERP comparison

User asks: *"What does Google rank for <query> right now?"*

1. If `BRIGHTDATA_SERP_ZONE` is set: BrightData SERP API → full Google parity (ads, PAA, knowledge panels, rich snippets).
2. Otherwise: Firecrawl `/v2/search` → top organic + summaries. Note that Firecrawl strips ads/SERP features.
3. For repeated runs, pin geo with `country` (Firecrawl) or `-country-us-city-newyork` (BrightData) so results are reproducible.

## Recipe 6 — Comparison matrix across N sources

User asks: *"Compare X across vendors A/B/C/D."*

1. For each vendor, identify the canonical source page (their pricing page, docs page, etc.). Use `/v2/search` with site-restricted queries (`pricing site:vendora.com`) if needed.
2. `/v2/extract` once with all N URLs and a single schema covering every comparison dimension.
3. Render as a markdown table with vendors as columns, dimensions as rows, source URLs in footnotes.

## Operational rules

- **Always set a budget.** State the credit estimate before kicking off >50 credits of work; ask if unsure.
- **Cache aggressively.** Save scraped markdown to disk on first fetch; re-use for follow-up questions in the same session.
- **Cite every claim.** Every non-obvious factual claim in the synthesis gets an inline citation that points to a source URL.
- **Date-stamp outputs.** Web data goes stale — header every saved research doc with capture date and source URLs.
- **Surface failures.** If BrightData credentials are missing and the workflow needs them, say so explicitly — don't silently degrade to a worse Firecrawl-only path.
