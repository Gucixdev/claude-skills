# ui (webdev)

## The ladder for the browser

1. Static HTML and CSS. Semantic elements do most of the work: `<dialog>`, `<details>`, `<form>` with native
   validation, `<input type="date">`, `<datalist>`, `popover`.
2. Plain JavaScript as ES modules, no bundler, no framework - unless the project already has one.
3. WASM for real compute: C with `clang --target=wasm32 -nostdlib -Wl,--no-entry -Wl,--export-dynamic -O2` (or
   Emscripten when libc is needed), Rust with `wasm-pack`, Go with `GOOS=js GOARCH=wasm` or TinyGo for small output.
4. TypeScript where JavaScript falls short (a big codebase, a shared API contract): `tsc --noEmit` as the check.

## Look

Personal projects: the look set in `ui (ui-designer)`. Client sites: plain
and readable; system font stack; one accent colour. Mobile works at 360px width with no horizontal scroll.

## Server, when there is one

- Nothing dynamic: no server - static hosting (GitHub Pages, Cloudflare Pages; free tiers change, check them).
- Small dynamic service: one static Go binary (`net/http`, `html/template`, SQLite) behind Caddy (automatic TLS).
- CRUD with accounts and payments: framework auth, a hosted checkout, SQLite to start.
- A box at home instead of a host: a tunnel (cloudflared) so no port opens on the home router.

## Must have

- Accessibility: keyboard reachable, labels on inputs, alt text, contrast checked, focus visible.
- Security: HTTPS only, `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`,
  CSRF protection on forms (the framework's), no secrets in the client.
- No third-party trackers or analytics scripts; server logs are enough. Fonts and scripts self-hosted.
- A size budget: the page works before any JavaScript loads; check the transfer size in devtools.

## Test

`curl -sI URL` for headers and redirects; flows through the user's browser with a devtools MCP or Playwright in a
scratch project; the HTML validator (`vnu`) when installed; a look at 360px and at full width.
