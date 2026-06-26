---
name: deep-research
description: Perform deep web research on any topic by combining Firecrawl (search, scrape, crawl, extract) and BrightData (residential proxy, Web Unlocker, SERP API). Use when the user asks to "research X", "deep-dive on Y", compare vendors/products across the web, ingest a docs site, extract structured data from many pages, or get past Cloudflare/CAPTCHA/geo-walls. Loads its own credentials from ~/.claude/.env.research.
allowed-tools: Bash Read Write Glob Grep
---

# Deep Research (Firecrawl + BrightData)

Combines two complementary tools so neither's limits constrain the other:

- **Firecrawl** — fast markdown extraction, search, crawl, structured-data extraction. Default workhorse.
- **BrightData** — residential proxy + Web Unlocker REST + SERP API. Used when Firecrawl can't crack a target, when you need raw Google parity, or when a page is geo-locked.

## Step 1 — Load credentials (always first)

Run this in PowerShell to populate `$env:FIRECRAWL_API_KEY` and the BrightData vars for the session:

```powershell
. "$HOME\.claude\skills\deep-research\scripts\load-env.ps1"
. "$HOME\.claude\skills\deep-research\scripts\research.ps1"
```

If `FIRECRAWL_API_KEY` ends up empty, stop and tell the user — `~/.claude/.env.research` is missing or malformed. Don't proceed with stub keys.

> BrightData REST (Web Unlocker / SERP) needs `BRIGHTDATA_API_TOKEN` and the matching `_ZONE` fields filled in. The residential proxy works without them. If a workflow needs the REST APIs and the token is empty, say so out loud rather than silently degrading.

## Step 2 — Pick a recipe

Match the user's ask to one of these and follow it. Detailed playbooks are in [`references/workflow-recipes.md`](references/workflow-recipes.md):

| User intent | Recipe |
|---|---|
| "Research X" / "deep-dive on Y" | **Topic deep-dive** — Firecrawl `/search` per sub-question → triage → parallel `/scrape` → cite-and-synthesize |
| "Pull all the docs at <site>" | **Site ingestion** — `/map` → `/crawl` async (poll until done) → save corpus |
| "Extract a table of X from these pages" | **Structured extraction** — `/extract` with JSON schema |
| "Get the content of <hardened-url>" | **Hardened target** — Firecrawl with `proxy: enhanced` first, BrightData Web Unlocker on failure |
| "What does Google rank for X?" | **Live SERP** — BrightData SERP API if available, Firecrawl `/search` otherwise |
| "Compare A/B/C/D on dimensions X/Y/Z" | **Comparison matrix** — single `/extract` call across all N URLs with a unified schema |

For anything that doesn't fit cleanly, default to the **Topic deep-dive** recipe.

## Step 3 — Execute via the helper functions

`research.ps1` exposes one function per common operation. Prefer them over hand-rolling curl:

| Function | Maps to |
|---|---|
| `Search-Firecrawl -Query "..." -Limit 10` | `POST /v2/search` |
| `Scrape-Firecrawl -Url "..." [-Proxy enhanced]` | `POST /v2/scrape` |
| `Map-Firecrawl -Url "..." -Limit 500` | `POST /v2/map` |
| `Crawl-Firecrawl -Url "..." -Limit 50` | `POST /v2/crawl` (auto-polls) |
| `Extract-Firecrawl -Urls @(...) -Prompt "..." -Schema $schema` | `POST /v2/extract` (auto-polls) |
| `Unlock-BrightData -Url "..."` | `POST /request` (Web Unlocker zone) |
| `Search-BrightDataSerp -Query "..."` | `POST /request` (SERP zone) |
| `Invoke-BrightDataProxied -Url "..."` | Residential proxy with sticky session |

The full REST surface (parameters, response shapes, doc URLs) is in [`references/firecrawl-api.md`](references/firecrawl-api.md) and [`references/brightdata-api.md`](references/brightdata-api.md). Read them when you need a parameter the helper doesn't expose.

## Step 4 — Synthesize and cite

Every non-obvious factual claim gets an inline `[N]` citation pointing to a numbered source list at the bottom of the answer. Lead with the bottom line. Date-stamp anything saved to disk.

## Operating rules

1. **Budget first.** Estimate Firecrawl credits before kicking off >50 credits of work. Hobby tier has 3000/mo total. Search = 1 credit/result, scrape = 1 credit/page, action = 5 credits, extract = variable.
2. **Parallelize within the limit.** Hobby concurrency is 5. Batch scrapes 5 at a time using `Start-ThreadJob` or `ForEach-Object -Parallel`.
3. **Cache scraped pages.** If `RESEARCH_OUTPUT_ROOT` is set in `.env.research`, save markdown there as `<host>/<path-slug>.md`. Re-use within the session instead of re-scraping.
4. **Fail loudly.** If Firecrawl returns empty markdown or 4xx, say so and try BrightData Web Unlocker. Don't fabricate content from titles or snippets.
5. **Respect targets.** Don't scrape login-walled pages without the user explicitly providing the credentials. Don't bypass paywalls for content the user hasn't paid for.
6. **Don't blend unverified BrightData with Firecrawl.** Firecrawl's `proxy` parameter is an enum (`basic|enhanced|auto`), not a URL — you cannot route Firecrawl through your BrightData proxy. Pick one tool per request.

## Quick start example

```powershell
. "$HOME\.claude\skills\deep-research\scripts\load-env.ps1"
. "$HOME\.claude\skills\deep-research\scripts\research.ps1"

$hits = Search-Firecrawl -Query 'claude opus 4.7 release notes' -Limit 8
$urls = $hits.data | Select-Object -First 5 -ExpandProperty url

$pages = $urls | ForEach-Object -Parallel {
    . "$using:HOME\.claude\skills\deep-research\scripts\load-env.ps1"
    . "$using:HOME\.claude\skills\deep-research\scripts\research.ps1"
    Scrape-Firecrawl -Url $_
} -ThrottleLimit 5

# $pages now holds markdown for each URL. Read, extract evidence, synthesize.
```

## Files in this skill

- `SKILL.md` — this file
- `scripts/load-env.ps1`, `scripts/load-env.sh` — load credentials from `~/.claude/.env.research`
- `scripts/research.ps1` — PowerShell wrappers for every Firecrawl + BrightData call this skill uses
- `references/firecrawl-api.md` — full Firecrawl v2 endpoint reference
- `references/brightdata-api.md` — BrightData proxy + Web Unlocker + SERP reference
- `references/workflow-recipes.md` — six end-to-end playbooks with cost budgets
