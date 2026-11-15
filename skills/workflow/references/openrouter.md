# workflow (openrouter)

Free and cheap LLM providers (OpenRouter and others) for bulk work, councils and second opinions, so the main model's
tokens go to decisions.

Set-up: one catalog file of providers (base URL, the env var that holds the key, signup link, tags such as free, paid,
local, search, media, and the models), keys in `~/.secrets` (never printed, never committed). An OpenAI-compatible
`/v1/chat/completions` endpoint is all a provider needs; a small CLI or MCP server over the catalog is optional. Only add
providers, never silently drop one.

What a model returns through it is a lead, not a fact: check names, repos, flags and commands before they go into a
skill or a commit (a council once invented repositories and a wrong expansion of an acronym).

## Use it a lot, not once

- Bulk or boring work (summaries, first-draft tests, translations, classification): a free model, keeping the main
  model's tokens for decisions.
- Second opinion on design or risky code: several models (`workflow (llm-council)`), then judge the answers yourself;
  answers are often generic, so ask pointed questions.
- Look at the model list before picking: prefer the best-scoring free model for the kind of task; note which provider is
  resting after a rate limit.
- Cut-off answers: a stop at the token limit is continued or retried with a bigger budget; do not pass a tiny
  `max_tokens`.
- Anything that bills or changes something is shown to the user first; use a free tier with a hard cap, or a prepaid key
  (`rules (zero-cost)`).

## Using idle limits

If the user has hourly free limits that are lost when unused, a scheduled job at the reset can spend them on useful
background work - only with the user's explicit permission, and with the afk rules: explicit-path `git add`, local
commits, no push, no deletes, nothing live or outward-facing, file ownership split per fork, reports of 12 lines or fewer
with honest tested/untested, and a short summary left for the morning (`workflow (afk-loop)`).
