# workflow (openrouter)

Catalog: `$OPENAPI_DIR/providers.json` = one file, every provider with base_url, key env, signup link,
tags (free, paid, local, search, media, ...), models. Code: `$OPENAPI_DIR/src/openapi.py` (MCP `openapi`).

Standing direction (2026-11-15): the `openapi` MCP is his most important tool for me. Use it first for research and
second opinions, and keep growing it with the most useful APIs (gmail, firefox, shopify, amazon, and whatever a task
shows is missing), appended only, never removed. What a model returns through it is a lead: check names, repos and
commands before they go into a skill (a council once invented repositories and a wrong expansion of LoLCATs).
Keys: `~/.secrets` (never print, never commit). Only APPEND providers, never remove or reject one.

## CLI first, MCP second (2026-11-15)
Every `openapi` tool is also a command: `cd $OPENAPI_DIR && .venv/bin/python src/openapi.py ask|council|models|best|budget|obsidian|notion|coderabbit|image|jev|services|api`;
`dump-api` lists them as JSON. Prefer the command in scripts and loops (`ask - --json` reads stdin). Exit 0 done, 1 failed, 2 usage, 3 a write was shown, not sent.
- Cut-off answers are fixed: a stop at the token limit is continued automatically (`OPENAPI_CONTINUE`, default 8); an empty answer from a reasoning model is retried with twice the budget.
  `STILL TRUNCATED` in the footer = it hit the cap, ask again for the rest. Do not pass a tiny `max_tokens`; leave it unset.
- `api SERVICE METHOD PATH` is the one wrapper for REST APIs (`services` lists them: Hetzner, Hostinger, Fly.io, DigitalOcean, Vultr, Linode, Scaleway, Cloudflare, Netlify, GitHub, Notion, CodeRabbit ...).
  GET runs; POST/PUT/PATCH/DELETE bill or change something, so show it to him and pass `--yes` only after he agrees. Rows without a `verified` date are from memory: read the docs first.
  New service = a row in `services.json`, appended only.

## Use it a lot, not once
- Bulk or boring work (summaries, first-draft tests, translations, classification) -> `mcp__openapi__ask` with a free model, keep Claude tokens for decisions.
- Second opinion on design/risky code -> `council` (several models), then judge the answers yourself; they were mostly generic, so ask pointed questions.
- `list_models` / `best` before picking: prefer the highest-scoring free model for the task kind; `status` shows who rests after a rate limit.
- Unverified provider answers are hints, not facts: test the code, check the claim.

## Standing order: limit reset at 04:20 (set 2026-11-08)
He sleeps; unused hourly tokens are lost. At the reset a cron job fires; then spawn forks (he authorised this
explicitly, "do 8 rano") that do useful work until the limit is spent: write code, run Lean proofs/tests, work
through the braindump. Rules for that run: explicit-path `git add` only, local commits, NO push, no deletes (move to
the trash), no live network/device changes, nothing outward-facing, ownership of files split per fork,
each fork reports in <=12 lines, honest tested/untested. Leave a short summary in
`~/.claude/jobs/*/tmp/night-report.md` for him to read in the morning.
Work order: 1) finish open netmanager items (Lean models of DHCP/roaming/kill switch, tests), 2) fastwebkit gaps,
3) braindump empty-stub batches, 4) holyc tests.
