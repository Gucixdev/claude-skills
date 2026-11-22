# code (budget)

Where the tokens actually go, and what cuts them. Input dominates: every turn re-sends the whole window (cheap when
the prefix is cached, full price when it is not). So the saving is in what enters the window and in keeping the
prefix stable - not in shaving words off replies.

## Count before reading

- Size first, content second: `wc -l`, `grep -c`, `git diff --stat`, `ls -S | head`, `du -sh`. A 40-line answer
  needs no read; a 4000-line file needs a range.
- `git diff --stat` -> then `git diff -- path` for the one file that matters. `git log --oneline -n 10` before
  `git log -p`. `git show --stat`.
- Structure before text: `jq 'keys'` / `jq 'map(type)'`, `head -1 | jq`, CSV `head -1`, `wc -l`; a function list
  (`rg -n '^[a-z_]+\('`, `ctags -x`) before any body.
- Logs: `tail -n 40`, then `grep -n -m5 -i 'error\|fail\|panic'` with `-B2 -A5` around the first hit; the first real
  error, not the cascade after it.
- Tests: the runner's summary and the failing names; rerun only the failing one with its verbose flag.

## Make the command quiet and exact

- Flags that cut noise: `-q`, `--quiet`, `--no-progress`, `--porcelain`, `-s`, `--short`, `--json` (then `jq`),
  `-o name`, `--format`, `2>&1 | tail`. A build: `make -s`; cargo: `--message-format short`; npm/pip: `--silent`.
- `rg -l` (names only) before `rg -n`; `rg -m3` caps hits per file; `rg --max-columns 160 --max-columns-preview`
  keeps minified lines from flooding.
- `head -c 2000` as a hard ceiling on anything of unknown size (curl, logs, generated files, `cat` of a data file).
- Pipe through `cut -c1-200` when lines can be huge (JSON on one line, lockfiles, bundles).

## A repeated lookup is a script

- The second time a pipeline is typed, it becomes a file in `~/.local/bin` or the repo (`automate-everything`) that
  prints the answer, not the data. One short call then replaces a five-step probe, forever.
- Prefer a CLI that prints one line over an MCP tool that returns a blob: an MCP server also adds its tool schemas to
  every turn's prefix (`cli-everything`). Disabled or unused servers cost nothing; a loaded but idle one costs
  every turn.

## Keep the prefix stable (prompt cache)

- The cache matches from the start of the context: anything that changes early invalidates everything after it.
  Do not edit CLAUDE.md, switch models, or add/remove MCP servers or tools mid-session; do it between sessions.
- Keep always-loaded text small: skill descriptions (`skilltree -s` shows the total), CLAUDE.md, the memory index.
  Every character is paid on every turn of every session. Detail lives in references, loaded when the task needs it.
- Same-topic work in one session beats many cold starts (a cold start re-pays the full prefix and re-reads the same
  files); unrelated work goes to a new session (a long window is also slower and drifts).
- The compaction window (`autoCompactWindow` in settings) is a lever: smaller means summaries sooner, larger means
  more re-sent input per turn. Set it deliberately; his is 250000.

- Skills too: `skills find QUERY` returns the best few chunks of all skill text (path:line, byte-capped) when the
  right part is unknown, instead of loading a skill and then every part.

## Notes survive the window, scrollback does not

- Long task: a small notes file (`todo.md`, a checkpoint, `cemacs checkpoint`) with state, decisions and the next
  step. After compaction or in a new session, read the notes (200 tokens), not the history (200k).
- A decision, a root cause or a verified fact is written down once where it belongs (skill, memory, repo doc) so it
  is never derived again. Re-deriving is the most expensive repeat there is.
- Intermediate results go to files under the scratchpad; the answer quotes the path and the one number.

## Delegate by size, not by habit

- Output you will only skim (a big search, summarising a long file, a second opinion) can go to a free or cheap
  model through the openapi tools (`workflow (openrouter)`); only its short answer comes back. Verify what matters.
- A fork or subagent is for when he asks (`rules`); when one runs, its prompt says what to return: "report in under
  150 words: file:line list, no code" - the report is what enters the window, and its working context never does.
- Bulk mechanical edits are a `sed`/`rg -l | xargs` or a script with the project check, not N Edit calls.

## Do not pay twice

- Edit with the smallest unique `old_string` (a line or two), not a whole block; several edits to one file in one
  turn. Rewrite the whole file only when most of it changes.
- Do not paste tool output back into the reply or into a file you are writing; quote the path and the line.
- Do not restate the plan after doing it, do not summarise a diff he can see, do not repeat a question already in
  `questions.md`.
- A skill is loaded once per session; do not load it again, and load the hub's one part, not all parts.
- Images, PDFs, screenshots and rendered pages are expensive: a text source (`pdftotext`, DOM text, `--json`,
  `get_page_text`) first, a screenshot only when layout is the question, at a small size.

## Measure

- `skilltree -s` - the always-loaded cost of skills. `claude_maintain` - memory/skills/settings rot and the
  weight of `~/.claude`. In a session, `/context` shows what fills the window; trim the biggest block first.
- A rule that does not move a number is noise: when a habit is added here, say what it saves.
