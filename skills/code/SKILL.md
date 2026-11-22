---
name: code
description: Everything about doing the work - short answers and cheap reads (search before whole files), how code is written (his C manifest, data-oriented design, language choice, YAGNI ladder), and proving it works (real run before done, tests, benchmarks, Lean 4 for optimized C). Applies to every reply, read, code or config change and every done.
metadata:
  priority: "0"
  tags: "#dev #c #c89 #dod #performance #memory #bash #emacs #rust #go #mojo #architecture #code #python #perl #elisp #lisp #typescript #ruby #rails #thirdparties #ponytail #minmax #8020 #yagni #thinking #debugging #investigation #saas #crud #sqlite #business #webdev #leanctx #context #tokens #reading #caveman #output #chat #verify #testing #done #proof #quality #fuzzing #coverage #bench #measurement #lean4 #formal #verification #optimization"
  requires: "?cmd:tmux ?cmd:bats ?cmd:inotifywait ?cmd:clang ?cmd:gcov ?cmd:hyperfine ?cmd:perf ?cmd:gdb ?cmd:strace ?cmd:valgrind ?cmd:coredumpctl ?cmd:lake cmd:gcc ?cmd:elan"
---

# code

Say less, read less, write less, prove it. The digest applies always; the parts have the detail.

## Always

- Answer first, without ceremony, with the exact payload (paths, commands, numbers), short words, one idea per
  sentence. Text that stays in a file is not chat: `conventions (docs)`.
- Read by intent: search before whole files, an outline before a range, the diff after an edit; batch independent
  lookups in one turn; never re-read what is already in context; point at code by path and line (`code (reading)`).
- Big output goes to a file, then grep, count, head - only the decisive lines come back (`code (output)`). Waiting,
  deferred tools and web reads: `code (tools)`. Count before reading, quiet flags, a repeated lookup becomes a
  script: `code (budget)`.
- Write less: does it need to exist, is it installed, is it one line (`code (ponytail)`). Unknown cause: investigate
  from evidence before a fix (`code (thinking)`).
- Done means shown: run the real test, read the log or exit state, drive the TUI, see the output; then stop
  (`code (done)`). Faster means measured (`code (bench)`); equal means proved or exhaustively tested
  (`code (lean4)`).

<!-- digest -->

## Parts

Read the part when the task matches.

### Say less, read less

- [caveman](references/caveman.md) - Say less in chat - every reply answers first, without ceremony, with exact payload, short words and one idea per sentence; normal and ultra switch it. Applies to every reply; text that stays in files follows `conventions (docs)`, commit messages `conventions (commits)`.
- [reading](references/reading.md) - Read less - pick the read by intent (search before whole files, outline before ranges, the diff after an edit), batch independent lookups in one turn, never re-read what is already in context, point at code by path and line. Applies to every file read and search.
- [output](references/output.md) - Shrink output before it lands in the context - the full output to a file, only the decisive part shown (failing test names, the first real error, the shape of JSON before its fields, counts for JSONL), quiet flags, uniform arrays as a header plus rows. Applies to every command run and tool result.
- [tools](references/tools.md) - Waiting and tools without waste - load deferred tools in one select call, never poll with sleep (background jobs with a completion notice, one bounded check), read the web from raw sources with an exact question. Applies to every tool load, long job and web fetch.
- [budget](references/budget.md) - Where the tokens go and what cuts them - count before reading (wc, grep -c, git diff --stat, jq shape), quiet exact commands with hard ceilings, repeated lookups as scripts, a stable prompt-cache prefix, notes files that survive compaction, delegating skimmable bulk to free models with a word-capped report, measuring with skilltree -s and /context. Applies to every long or expensive session.
- [compress](references/compress.md) - Compress a prose file he names (notes, memory, a long README section) - cut filler and hedging while keeping code, paths, numbers, headings exact; the original goes to the trash first. Only when asked, only for a named file.
- [review](references/review.md) - Review comments to paste into a PR - one line per finding with its line, the problem and the fix, severity prefixes bug, risk, nit and q, no hedging or praise padding. Use when he wants PR comments rather than a report.

### Write code


- [ponytail](references/ponytail.md) - Build less - the lazy senior developer's ladder (does it need to exist, reuse, stdlib, installed dependency, one line, minimum code), the rules for the change itself and what is never cut; levels lite, full, ultra; 80/20 and "minmax it" (name the numbers, max them, cut the rest, measure). Also in the file - the four change modes (surgical patch, safe refactor, lean build, migration), review of a diff as a report (Must fix, Should fix, Nice to have), whole-repo audit, the shortcut-debt ledger. Use for every code or config change, a review, an audit or "what was simplified".
- [languages](references/languages.md) - Which language for which job (his table: bash with fallbacks, Python as composable blocks, C vs Rust, Go for web, Lean 4, gael, GDScript, Perl, Elisp, TypeScript, Ruby on Rails), the per-language engineering preferences (strict manual memory in C, always reach for a library in Rust/Go/Python, composition over inheritance, shell environment, the `run` convention), and data-oriented design with his C manifest (flat arrays, arenas, SoA, no recursion, unity builds, C89, zero dependencies). Use when picking a language, writing code in one, or designing data structures or performance-sensitive code.
- [saas](references/saas.md) - Small SaaS and CRUD products the cheap, boring way - data model first with account scoping from day one, SQLite, Rails (or one Go binary), framework auth, hosted checkout, jobs, one-box deploy with tested backups, UK GDPR basics, expand-and-contract migrations, his product ideas (Cyber Essentials evidence tool, DMARC and MTA-STS scanner). Use for any app with users, records and payments.
- [thinking](references/thinking.md) - The working principles in one table (kaizen, muda, poka-yoke, jidoka, andon, genchi genbutsu, kanban, 5S, shu-ha-ri, YAGNI, KISS, DRY and the rule of three, Unix philosophy, Chesterton's fence, Gall's law, fail fast, Hyrum's and Conway's laws) plus three thinking tools - YAGNI, Sherlock (investigate from evidence, rank hypotheses, no fix until one mechanism explains everything), rubber duck. Use when choosing between approaches, for any bug with an unknown cause, a stuck problem, or before asking him a question.

### Prove it

- [lean4](references/lean4.md) - Lean 4 is his standard for verification and mathematical proof (chosen over Frama-C, 2026-11-06) - every project has lean4/ at its root (tools/leaninit in holyc), and optimized C is proved or exhaustively tested equal to a plain Lean reference so optimization can go as far as it goes. Formal verification with Mathlib, TrustLean and AMO-Lean - prove that C code works the way vecindex/lean4 does it - a Lean model per C function, theorems on the model, an axiom audit by module (no sorry, no native_decide), an oracle exe from the same definitions diffed against the real C (every input where finite, labelled grids or seeded random cases elsewhere, one build per -march), C-only property checks and a mutation test; plus the toolchain in a cloud session without Mathlib's cache, proof gotchas and the API drift of Lean 4.26. Use for any Lean, Lean 4, Mathlib, TrustLean, AMO-Lean, formal proof, dowód, udowodnij or weryfikacja formalna task.
- [debug](references/debug.md) - Debugging toolbox for the evidence a Sherlock-style investigation needs - shell tracing, gdb in batch mode, core dumps, sanitizers, valgrind, strace and ltrace, rr, git bisect run, Python faulthandler and pdb, Godot logs, journald, network checks. Use when something crashes, hangs, leaks, misbehaves or got slower.
- [bench](references/bench.md) - Honest benchmarks - paired baseline and candidate runs on identical input, warmup and repetitions, median and spread, max RSS, quality measured next to speed, profiling phases before optimizing, standard datasets and known baselines, results logged with commit, machine and date. Use before claiming anything is faster, smaller or cheaper, and when optimizing.
- [test](references/test.md) - Testing his way - real behaviour over mocks, live tests that skip only on a real no-network signal, TUIs driven through tmux or a pty, fake binaries on PATH that record their arguments, temp HOME so nothing real is touched, sanitizers and two compilers for C, libFuzzer targets with a gcc replay driver, line coverage of unity builds, a regression test per bug proven on the old code, one CI job that runs the project's own scripts, autotest on save, small high-quality test data. Use when writing or running tests in any language, fuzzing, measuring coverage, battletesting, or setting up CI.
- [done](references/done.md) - Prove it is done for real before reporting it - run the actual test, read the log or exit state, drive the TUI through a pty or tmux, take the screenshot, check the generated output - not just a flag or an exit code; then stop. Use before every "done", and when he asks to check finished work.
