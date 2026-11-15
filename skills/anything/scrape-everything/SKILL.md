---
name: scrape-everything
description: Get data out of anything - the ladder from official API, hidden JSON API, feeds and sitemaps, raw files and static HTML down to a headless browser and OCR; politeness (robots.txt, rate limits, caching); raw responses kept next to parsed TSV or JSONL; and the rule that the scraper is the product - build it instead of probing by hand. Use for any task that pulls data from websites, APIs, apps or documents.
metadata:
  priority: "2"
  tags: "#thirdparties #scraping #web #data #api #automation #dev"
  requires: "skill:rea skill:rules cmd:curl ?cmd:jq|python3 ?cmd:xmllint ?cmd:pdftotext ?cmd:tesseract ?mcp:firefox-devtools"
---

# scrape-everything

## The scraper is the product

A user's correction on a forum-mapping project: the assistant is not meant to scrape the forums by hand, the engine is. One or two
requests to confirm a response shape before coding are expected; many turns of hand-probing an undocumented API are
not. If the shape isn't quickly found, make discovery a feature of the tool (`TOOL categories PREFIX` lists real
names instead of me guessing them), or stop and state the limit.

## The ladder: first rung that has the data

1. An official API or export (JSON, CSV, a data dump). Read its docs and limits.
2. The site's own JSON API: the Network tab or a HAR shows what the page calls; call it with `curl`.
3. Feeds and indexes: RSS/Atom, `sitemap.xml`, MediaWiki `api.php`, GitHub's API, `raw.githubusercontent.com`.
4. Static HTML: `curl` plus a real parser - `xmllint --html --xpath`, Python's `html.parser`, `htmlq`/`pup` if
   installed. Regex on HTML only for one known, stable line.
5. A browser for pages that only render with JavaScript or need the user's login: the user's browser through
   a devtools MCP, or Playwright in a scratch project; a targeted evaluate, not the whole DOM.
6. Documents and images: `pdftotext -layout`, `tesseract IMG out` for scans, `ffmpeg` for frames.

## Politeness and cost

- `robots.txt` and the terms of service; an API key over scraping a page that offers one.
- One request at a time by default, a delay between pages, `If-None-Match`/`If-Modified-Since` (ETag) and a local
  cache so a rerun costs nothing; back off on 429 and honour `Retry-After`.
- A descriptive User-Agent with a contact; never rotate identities to dodge a block.
- Logins and cookies stay on the user's machine; tokens from the environment, never on a command line.
- In a cloud sandbox the shell usually can't reach the web: WebFetch there, `curl` on the user's machine.

## Data

- Keep the raw response (`raw/DATE/URL-SAFE-NAME.json`) next to the parsed output, so a parser fix reruns offline.
- Parsed data as TSV or JSONL with a header or a stable key order; one record per line (`code (languages)` (dod)).
- Make it resumable: a list of done keys, atomic writes (temp file + `mv`), a queue for parallel downloads (the user's
  `lib/dspq`).
- Validate on the way in: counts per page, empty fields, a sample checked against the page by eye once.
