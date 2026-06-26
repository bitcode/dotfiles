# research.ps1 — convenience wrappers around Firecrawl + BrightData REST.
# Dot-source after load-env.ps1, then call the functions directly:
#
#   . "$HOME\.claude\skills\deep-research\scripts\load-env.ps1"
#   . "$HOME\.claude\skills\deep-research\scripts\research.ps1"
#   $hits = Search-Firecrawl -Query 'opus 4.7 release notes' -Limit 10
#   $md   = Scrape-Firecrawl -Url $hits.data[0].url

$ErrorActionPreference = 'Stop'

function _Require-FirecrawlKey {
    if (-not $env:FIRECRAWL_API_KEY) {
        throw 'FIRECRAWL_API_KEY not set. Run load-env.ps1 first.'
    }
}

function _FirecrawlHeaders {
    @{
        Authorization  = "Bearer $env:FIRECRAWL_API_KEY"
        'Content-Type' = 'application/json'
    }
}

function _FirecrawlBase {
    if ($env:FIRECRAWL_BASE_URL) { $env:FIRECRAWL_BASE_URL } else { 'https://api.firecrawl.dev' }
}

function Scrape-Firecrawl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Url,
        [string[]] $Formats = @('markdown'),
        [bool] $OnlyMainContent = $true,
        [int] $TimeoutMs = 30000,
        [ValidateSet('basic', 'enhanced', 'auto')] [string] $Proxy = 'basic'
    )
    _Require-FirecrawlKey
    $body = @{
        url             = $Url
        formats         = $Formats
        onlyMainContent = $OnlyMainContent
        timeout         = $TimeoutMs
        proxy           = $Proxy
    } | ConvertTo-Json -Depth 6
    Invoke-RestMethod -Method Post -Uri "$(_FirecrawlBase)/v2/scrape" -Headers (_FirecrawlHeaders) -Body $body
}

function Search-Firecrawl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Query,
        [int] $Limit = 10,
        [string[]] $Sources = @('web'),
        [switch] $InlineScrape,
        [string[]] $ScrapeFormats = @('markdown'),
        [switch] $Raw
    )
    _Require-FirecrawlKey
    $payload = @{ query = $Query; limit = $Limit; sources = $Sources }
    if ($InlineScrape) {
        $payload.scrapeOptions = @{ formats = $ScrapeFormats; onlyMainContent = $true }
    }
    $body = $payload | ConvertTo-Json -Depth 6
    $resp = Invoke-RestMethod -Method Post -Uri "$(_FirecrawlBase)/v2/search" -Headers (_FirecrawlHeaders) -Body $body
    if ($Raw) { return $resp }
    # Flatten: /v2/search returns data.web[], data.news[], data.images[]. Concatenate.
    $hits = @()
    foreach ($k in @('web', 'news', 'images')) {
        if ($resp.data.PSObject.Properties[$k]) { $hits += $resp.data.$k }
    }
    $hits
}

function Map-Firecrawl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Url,
        [int] $Limit = 500
    )
    _Require-FirecrawlKey
    $body = @{ url = $Url; limit = $Limit } | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "$(_FirecrawlBase)/v2/map" -Headers (_FirecrawlHeaders) -Body $body
}

function Crawl-Firecrawl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Url,
        [int] $Limit = 50,
        [string[]] $Formats = @('markdown'),
        [int] $PollIntervalSec = 5,
        [int] $MaxWaitSec = 600
    )
    _Require-FirecrawlKey
    $body = @{
        url           = $Url
        limit         = $Limit
        scrapeOptions = @{ formats = $Formats; onlyMainContent = $true }
    } | ConvertTo-Json -Depth 6
    $start = Invoke-RestMethod -Method Post -Uri "$(_FirecrawlBase)/v2/crawl" -Headers (_FirecrawlHeaders) -Body $body
    if (-not $start.id) { return $start }
    $deadline = (Get-Date).AddSeconds($MaxWaitSec)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds $PollIntervalSec
        $status = Invoke-RestMethod -Uri "$(_FirecrawlBase)/v2/crawl/$($start.id)" -Headers (_FirecrawlHeaders)
        if ($status.status -in 'completed', 'failed') { return $status }
    }
    throw "Crawl $($start.id) did not finish within $MaxWaitSec seconds."
}

function Extract-Firecrawl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string[]] $Urls,
        [Parameter(Mandatory)] [string] $Prompt,
        [Parameter(Mandatory)] [object] $Schema,
        [int] $PollIntervalSec = 4,
        [int] $MaxWaitSec = 600
    )
    _Require-FirecrawlKey
    $body = @{ urls = $Urls; prompt = $Prompt; schema = $Schema } | ConvertTo-Json -Depth 12
    $start = Invoke-RestMethod -Method Post -Uri "$(_FirecrawlBase)/v2/extract" -Headers (_FirecrawlHeaders) -Body $body
    if (-not $start.id) { return $start }
    $deadline = (Get-Date).AddSeconds($MaxWaitSec)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds $PollIntervalSec
        $status = Invoke-RestMethod -Uri "$(_FirecrawlBase)/v2/extract/$($start.id)" -Headers (_FirecrawlHeaders)
        if ($status.status -in 'completed', 'failed') { return $status }
    }
    throw "Extract $($start.id) did not finish within $MaxWaitSec seconds."
}

# --- BrightData ---

function Unlock-BrightData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Url,
        [string] $Zone = $env:BRIGHTDATA_UNLOCKER_ZONE,
        [ValidateSet('raw', 'json')] [string] $Format = 'raw',
        [string] $Country
    )
    if (-not $env:BRIGHTDATA_API_TOKEN) { throw 'BRIGHTDATA_API_TOKEN not set.' }
    if (-not $Zone) { throw 'BrightData unlocker zone missing. Set BRIGHTDATA_UNLOCKER_ZONE.' }
    $payload = @{ zone = $Zone; url = $Url; format = $Format }
    if ($Country) { $payload.country = $Country }
    $body = $payload | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri 'https://api.brightdata.com/request' `
        -Headers @{ Authorization = "Bearer $env:BRIGHTDATA_API_TOKEN"; 'Content-Type' = 'application/json' } `
        -Body $body
}

function Search-BrightDataSerp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Query,
        [string] $Engine = 'google',
        [string] $Country = 'us',
        [string] $Lang = 'en',
        [string] $Zone = $env:BRIGHTDATA_SERP_ZONE,
        [ValidateSet('parsed_light', 'markdown', '')] [string] $DataFormat = 'parsed_light'
    )
    if (-not $env:BRIGHTDATA_API_TOKEN) { throw 'BRIGHTDATA_API_TOKEN not set.' }
    if (-not $Zone) { throw 'BrightData SERP zone missing. Set BRIGHTDATA_SERP_ZONE.' }
    $url = switch ($Engine) {
        'google' { "https://www.google.com/search?q=$([uri]::EscapeDataString($Query))&hl=$Lang&gl=$Country" }
        'bing'   { "https://www.bing.com/search?q=$([uri]::EscapeDataString($Query))&cc=$Country" }
        default  { throw "Unsupported engine: $Engine" }
    }
    $payload = @{ zone = $Zone; url = $url; format = 'json' }
    if ($DataFormat) { $payload.data_format = $DataFormat }
    Invoke-RestMethod -Method Post -Uri 'https://api.brightdata.com/request' `
        -Headers @{ Authorization = "Bearer $env:BRIGHTDATA_API_TOKEN"; 'Content-Type' = 'application/json' } `
        -Body ($payload | ConvertTo-Json)
}

function Get-BrightDataProxyUser {
    [CmdletBinding()]
    param(
        [string] $Country = $env:BRIGHTDATA_COUNTRY,
        [string] $City = $env:BRIGHTDATA_CITY,
        [string] $Session = ([guid]::NewGuid().ToString('N').Substring(0, 8))
    )
    $u = $env:BRIGHTDATA_USERNAME
    if ($Country) { $u += "-country-$Country" }
    if ($City)    { $u += "-city-$City" }
    if ($Session) { $u += "-session-$Session" }
    $u
}

function Invoke-BrightDataProxied {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Url,
        [string] $Country = $env:BRIGHTDATA_COUNTRY,
        [string] $City = $env:BRIGHTDATA_CITY,
        [string] $Session
    )
    if (-not $env:BRIGHTDATA_USERNAME -or -not $env:BRIGHTDATA_PASSWORD) {
        throw 'BrightData proxy credentials missing.'
    }
    $params = @{ Country = $Country; City = $City }
    if ($Session) { $params.Session = $Session }
    $user = Get-BrightDataProxyUser @params
    $cred = [pscredential]::new($user, (ConvertTo-SecureString $env:BRIGHTDATA_PASSWORD -AsPlainText -Force))
    $proxy = "http://$env:BRIGHTDATA_PROXY_HOST`:$env:BRIGHTDATA_PROXY_PORT"
    Invoke-WebRequest -Uri $Url -Proxy $proxy -ProxyCredential $cred -UseBasicParsing
}
