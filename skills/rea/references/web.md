# rea (web)

What: a website or web app whose data or actions you need as a program: the API behind a page, a login flow, an export
that has no button. How: the page already shows the API to the browser; read it there, then call it with `curl`.
The API is usually the product (`scrape-everything`). Only accounts and data of his own, within the site's terms.

## 1. Record one action

Browser devtools, Network tab: tick "Preserve log", clear, do the one action, then right-click, "Save all as HAR".
One action per HAR (`search.har`, `add-item.har`). Then:

```sh
scripts/har-endpoints search.har | column -t -s$'\t'   # method, status, mime, url, query keys, body keys; most called first
jq '.log.entries[] | select(.request.url|test("/api/")) | {u:.request.url, r:.response.content.text}' search.har | head -50
```

`har-endpoints` drops images, CSS, fonts and scripts (`-a` keeps them) and shows parameter names without values, so
tokens do not end up in your notes.

## 2. Reproduce the call with curl

In the devtools Network tab: right-click the request, "Copy as cURL". Paste it into a file, then strip it down by
removing one header or parameter at a time and rerunning until it fails; what is left is the minimum the server
needs. Typically: a session cookie or `Authorization` header, a CSRF header, `Content-Type`, and the parameters.

```sh
curl -s 'https://site.example/api/items?page=2' -H "Authorization: Bearer $TOKEN" | jq '.items[0]'
```

The token comes from the environment or `~/.secrets`, never from a file in the repo (`rules (identity)`).

## 3. Read the page's own code

- Inline state first: `curl -s URL | rg -o '<script[^>]*type="application/json"[^>]*>.*?</script>'`; also
  `window.__INITIAL_STATE__`, `__NEXT_DATA__` (Next.js: the whole page data as JSON), `__NUXT__`. A page that
  embeds its data often needs no API at all.
- The bundle: `curl -s URL | rg -o 'src="[^"]+\.js"'`, download the files, then `rg -o '"/api/[^"]*"'` and
  `rg -o 'fetch\(["`][^"`]*'` for endpoint strings; `rg 'Bearer|X-[A-Za-z-]+' file.js` for the headers it sets.
- Source maps: a bundle ending `//# sourceMappingURL=app.js.map` has the original sources inside the `.map`
  (`jq -r '.sources[], .sourcesContent[]' app.js.map`); browsers load them, so they are often public.
- Minified code: `npx prettier --write bundle.js` (or `js-beautify`) first; then search for the endpoint string and read
  only the function around it.

## 4. Auth, in notes only as a shape

Find out which of these it uses: a session cookie set after a login POST; a bearer token from an OAuth or
`/token` call with an expiry and a refresh; an API key header; a signed URL. Note where it comes from, how long it
lives, how it is refreshed. The login form itself is one more request in the HAR: the field names matter, the
values do not. Two-factor, CAPTCHAs and "are you a robot" pages are the site saying no to automation: stop there
unless it is his own account and the site offers an API token instead.

## 5. Habits of real APIs

- Pagination: `page=`, `offset=`/`limit=`, or a cursor (`next`, `after`) in each response; loop until it is empty.
- GraphQL: one POST endpoint, a query in the body; the schema from introspection (`{__schema{types{name}}}`) if it is
  not disabled, else the queries the app itself sends (they are in the HAR).
- Rate limits show as 429 or a `Retry-After`/`X-RateLimit-*` header: sleep, cache the answers, do not hammer
  (`scrape-everything`).
- An HTML page with no JSON behind it: parse the HTML (Python's stdlib
  `html.parser`), and keep the raw response next to the parsed result.

## 6. Result

`docs/API.md`: base URL, auth, then per endpoint: method, path, parameters, an example request and a trimmed example
response, errors seen, rate limit. Then the client or wrapper (`bash-everything`, `cli-everything`). Example
responses in the repo have names, e-mails, tokens and ids replaced by invented ones (`publish-anything`).
