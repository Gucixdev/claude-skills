# code (ponytail)

The smallest change that fully solves the task. The reply ends with one or two lines: what was skipped or not checked,
as "skipped X - add it when Y", and any risk he must know.

## Before writing

Read the task and the code it touches. List every place the change must reach - callers, tests, fixtures, config,
exports - and what it could break for users: data destroyed or exposed, callers that stop working. That is the scope;
features nobody asked for are not. Before writing a helper, map what exists (top-level definitions per folder: `rg -n`
for def/func/fn/class/export, or tags).

## The ladder: take the first option that fully works

1. Does it need to exist? Skip features, options and flexibility nobody asked for, and name them in one line. A vague
   request gets the smallest version that does the core job.
2. Already in this codebase (a helper, component, pattern)? Use it the way the surrounding code does.
3. The standard library or the platform? Use it, unless the project has its own - a house component beats a native one.
4. An installed dependency? Use it. Never add a dependency for a few lines.
5. One line a reader gets at a glance? One line.
6. Otherwise the minimum code that works.

> A date picker: `<input type="date">`. A deep copy: `structuredClone`. Grouping: `Object.groupBy`. A modal:
> `<dialog>`. Query strings: `URLSearchParams`. Debounce: one timer. A file picker in a bash tool: `fzf`, not a widget.

## Rules

- Lazy about the solution, never about the change: finish every part the task needs, including the callers, tests and
  fixtures the change breaks.
- No abstraction, wrapper, type conversion, option, config, boilerplate or "for later" code nobody asked for. Values
  stay in the form the platform gives them. Deletion beats addition. Keep the structure the codebase has.
- The shortest working diff wins - once everything it must touch is known. A one-liner that needs decoding is not short.
- Counterweight: judge total complexity, clarity and ownership, not lines changed. Logic goes in the layer that owns
  the invariant; a coherent wider change beats a cramped patch or a duplicated guard. A new dependency or public
  surface is fine when it is the right design or cheaper to live with - say the tradeoff.
- Bug fix: grep every caller first; fix the root cause once, in the shared code. When his own tooling has the limit
  that causes the pain (no "this file's directory" in his make, so paths broke on every move), add the feature to the
  tool instead of patching around it again - his correction on 2026-08-14.
- Don't break userland: a rename, merge or replacement keeps the old interface reachable (an alias, the old flag, the
  old exit code) unless he decides otherwise. Surface the conflict instead of picking a side silently.
- Moved or merged code keeps its error handling and validation. Between options of the same size, take the one right
  on edge cases.
- Comment only the why the code cannot show, in one line. Little nesting, no boolean tangles, meaningful names.
- New non-trivial logic (a branch, a loop, a parser, money, security, a new script) leaves one small test or an
  assert-based self-check; trivial changes need none.
- A deliberate shortcut gets `shortcut: <the limit>, <when to upgrade>` as a comment (the ledger:
  `code (ponytail)`).
- Never cut: validation at trust boundaries, authorization, security, error handling that prevents data loss,
  accessibility, migration and rollback safety, concurrency protection, compatibility, required tests, the calibration
  real hardware needs, anything he asked for.
- Secrets live in a gitignored env file (`~/.secrets` on his machine), never in code, never printed whole.
- Ask only about material choices: public interfaces, security, data, money, things hard to reverse.
- Run the smallest proof that is enough. Report material changes, the proof, open risks. Stop when the task is
  satisfied. Never quote a saving: the code that was not written has no baseline.
- Levels when he names one: lite - build what was asked, offer the smaller option in one line; full - these rules,
  the default; ultra - also question the request and push back on any part the need doesn't justify, before building.

## 80/20 and minmax

- 80/20 first: the fifth of the work that gives four fifths of the value goes first, and conventions cover the common
  80% so configuration is only for the rest (convention over configuration). The rest of a task is named, not dropped
  silently.
- "Minmax it" (his words, 2026-11-19) is the gamer's sense: pick the few numbers the work is judged by, push them to
  the max, and cut to the minimum whatever costs without moving them. Not minimax (game theory) nor min-max
  normalisation, unless he says so.
  1. Name the axes before touching code - he names them, or the task implies them (a store: max queries/s, recall per
     byte, rows per TB; min RAM a row, bytes read a query, p99, binary size, code paths) - and say which were taken.
  2. Measure before and after every change, on the hardware it is for; a change that moves no chosen number is
     reverted (deletion beats addition). Spend where the profile points, not where it feels slow.
  3. Never buy a number with what "Never cut" protects, nor with honesty: report the numbers as measured.

## Not adopted, on purpose

Plugin hooks (activation, mode tracking, the band and board, statusline, subagent injection, the session-start codebase
map - done by hand above), the gain scoreboard.

## Reusable single-file code

Code that will be wanted again goes in a reusable block from the first day, in the stb style: one file, no dependency
beyond the standard library, public API at the top with a header comment that is also the docs, state in a struct the
caller owns (no globals), no build system needed to use it (C: one header with `#define NAME_IMPLEMENTATION` in one
file; bash/Python: one file that works as a command and as a library). Before writing, search his other projects for the
block (`rg -n` across `~/dev`, holyc's headers first) and reuse or lift it; when copying between projects, copy the file
whole and keep one source (a vendor script, as lazytui.sh is vendored), never edit two diverging copies. A function that
two projects need is moved to the shared block the second time it is needed, not the first (ponytail: no abstraction
for a single use).

A single file that needs settings keeps staying one file: the settings go in a second header next to it, named
`NAME_config.h` (`netman_config.h`), nothing but `#define`s with defaults in the program so it builds without it
(`#ifdef` / `__has_include`); the user edits that header and recompiles, as in suckless. No config parser, no config
folder (convention over configuration).

## Audit a whole repo

The `ponytail (review)` method over a whole repo instead of a diff.

- Read README, build and deploy config, dependencies, entry points, tests; trace the main flows end to end; in a big
  repo go deep where a mistake costs most and say what was not read.
- Find the expected load (one person's script or many users) and say which load was assumed.
- The report opens with "What this repo does:" and the assumed load, lists at most 20 findings (say how many were
  left out), and ends "Healthy. Nothing to fix." when nothing is found.

## Shortcut debt ledger

While building, a deliberate shortcut gets `shortcut: <the limit>, <when to upgrade>` as a comment (`code (ponytail)`). The ledger, when asked:

`git grep -nE '(#|//|/[*]) ?shortcut:'`, one row per marker grouped by file - `file:line, what was simplified. ceiling:
<limit>. upgrade: <trigger>.` - markers with no trigger tagged `no-trigger`; mentions that are not a deferral are
skipped; end with `N markers, M with no trigger.` or "No shortcut debt."

## Change modes

Pick the mode before the first edit; `code (ponytail)` decides how small the change is.

- Bug or small behaviour change - surgical patch. Reproduce first when cheap, else take the strongest evidence; change
  the narrowest layer that owns the wrong behaviour; no cleanup, renaming or abstraction outside the fix; keep his own
  changes; one regression check, run it plus the nearest affected gate.
- Restructuring - safe refactor. Fix the behaviour boundary and the check before touching structure; no feature changes
  inside; one ownership move at a time; keep interfaces, failure behaviour, ordering and compatibility; every step
  builds and tests.
- New feature with a risk of overbuilding - lean build. Derive observable acceptance and explicit non-goals; deliver one
  coherent end-to-end path; omit modes, providers, config and polish acceptance doesn't need; stop when it passes.
- Schema, data, API, config or dependency change - migration. Map readers, writers, data shape and the compatibility
  window first; a forward and a rollback path; existing data kept, destructive steps explicit and separately approved;
  expand, migrate, verify, then contract; retries idempotent; never do the destructive step implicitly.
  For his setup repos (dotfiles, bash tools) when an update must change state on machines already set up (a renamed
  path, a moved config): omarchy's pattern - `migrations/<unix-time>.sh`, run once per user by a `migrate` command that
  records each done one in `~/.local/state/APP/migrations/`, `--pending` to list, idempotent, never run silently.
- Unknown cause: investigate first (`code (thinking)`). Checking finished work: `code (done)`.

## Review a change as a report

A review is a report: findings only, no code changed, unless he asks for the fixes too.

### Understand first

- Review: what he names (staged, uncommitted, a branch, a PR), else the uncommitted changes, else the last commit.
  Read the diff, then the touched code - callers of changed functions, what they call, tests, README. A changed
  signature or behaviour means grep every caller.
- Find the expected load (one person's script or many users) and say which load was assumed.

### Look for, in this order

1. Bug: wrong result, crash, edge cases (empty, zero, last item, rounding, time zones, INT_MIN), a caller the change
   broke, a fix in one caller while the shared code stays broken.
2. Risk: injection, weak randomness, secrets, unchecked input, swallowed errors, writes in the wrong order, no
   transaction.
3. Scale: check-then-write races, every process doing the same work, ever-growing memory, a query per item, O(n^2),
   per-process state that must be shared.
4. Missing test: risky logic with no test that fails when it breaks - one good test, not coverage.
5. Speed: big slowdowns are findings, small wins are suggestions.
6. Lean: dead code and unused options, an existing helper to reuse (name its path), stdlib or native, one-implementation
   interfaces and config nobody sets, near-copies to merge.

### Check before reporting

Every finding has a concrete case ("this input leads to this wrong result") or it is not a finding. Re-read the lines.
Before calling code unused, grep the whole tree including tests, fixtures, config and string or dynamic references.
A `shortcut:` comment is a decision unless the expected load already crosses its limit. The smallest fix, preferably
one that deletes code. No style taste, no "consider", no vague worries.

### The report

Very plain language, short sentences, every technical term explained the first time. Start with "What this change
does:" (audit: "What this repo does:" plus the assumed load) in two or three sentences; then Must fix / Should fix /
Nice to have, empty groups skipped, findings numbered across groups (audit: at most 20, say how many were left out).
Each finding: title and `file:lines`, then What this is / Problem / Fix / If we skip it, one or two sentences each.
End with `Verdict:` ("Ship." or "fix 1 and 3 first"), `Lean: -N lines (-M dependencies)` when there are lean
findings, `Not checked:`. Nothing found: "Looks good. Ship." (audit: "Healthy. Nothing to fix.") plus one line on what
was checked.
