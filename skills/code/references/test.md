# code (test)

## What to test

- The behaviour he cares about, through the real entry point (the CLI, the public API), against real data where it is
  cheap. Mocks only at boundaries that can't run here (root, hardware, a paid API).
- Every bug fix leaves the test that would have caught it, written to fail on the old code. Prove that: build the
  previous commit next to the new one (`git archive HEAD src | tar -x -C DIR`, the same sanitizer flags) and run the
  test on both. gael's stack test made UBSan report the old VM's write past the stack; the new VM reports a stack
  overflow (2026-10-19).
- Small, high-quality test data over large noisy sets ("dane mają być najwyższej jakości, nie musi być ich dużo").

## Live tests

A test that calls a real network service skips only on a real no-network signal - `could not resolve host`,
`connection refused`, `network is unreachable`, a timeout - and fails loudly on anything else. A blanket `catch any
error, skip` turned a permanent bug (an HTTP client that rejects PROPFIND) into a green test in 2026-09. A suspiciously
convenient PASS after a refactor: check the skip path first.

## By language

- Bash: `bats tests/`; per test a temp `HOME`, `XDG_*`, `GIT_CONFIG_GLOBAL` under `$BATS_TEST_TMPDIR`; fake binaries on
  a temp PATH that write their argv to a file and print canned output (a fake `fzf`, `flatpak`, `gh`); `--help` and
  `shellcheck -S warning` for every script (Gucixdev/bash `tests/syntax.bats`).
- C: small test programs with `assert` or a tiny check macro, built by the `code (test)` script with
  `-fsanitize=address,undefined` and once with `-fsanitize=thread` when threads exist, under gcc and clang; a C89
  build with `-std=c89 -pedantic` when the project promises C89; a fuzz-ish loop over sizes and NaNs for widgets and
  parsers (his lazyui `test_robust`). Why both compilers: Ubuntu's gcc turns on `_FORTIFY_SOURCE` at -O2, and its
  headers declared `realpath` that `_POSIX_C_SOURCE 200809L` leaves out - clang refused the same code (gael,
  2026-10-19; glibc needs `_XOPEN_SOURCE 700` for it).
- C, after removing an `#include` from a header: compile every test with `-Werror=implicit-function-declaration`.
  A test that got `mkdtemp` through the header kept building under `-w`, the undeclared call returned int, and the
  pointer cut to 32 bits segfaulted (holyc base, 2026-11-06).
- Python: `unittest` from the standard library unless the project uses pytest; warnings as errors.
- Rust `cargo test`, Go `go test ./...` with `-race` where it matters.
- Godot: headless runs (`godot --headless --path PROJ -s res://tests/run.gd`), `test_assert` through the MCP on a
  disposable instance, pixel and shader checks in the windowed `tests/render_*.gd` harness - never his open editor.
- TUIs: tmux (`new -d -x 160 -y 45`, `send-keys`, `capture-pane -p`) or a pty with a set window size, realistic key
  timing; both fzf flavours for his lazytui tools.
- Emacs config: `emacs --batch -l shim.el -l early-init.el -l init.el --eval '(progn ...)'` under a temp `HOME`. Offline
  (a cloud sandbox has no MELPA), the shim overrides `package-refresh-contents` and `package-install`, puts packages
  cloned from GitHub on `load-path` and `provide`s stubs for the rest. Point `package-user-dir` at the temp dir: with
  `~/.config/emacs` linked to the repo, package.el writes `elpa/` into the working copy and starts a gpg-agent there
  (2026-10-18). Files under `/tmp` get no backups (`normal-backup-enable-predicate`), so backup tests use another
  folder.

## Fuzzing and coverage (C)

From vecindex's `tests/fuzz_*.c`, `tools/fuzz`, `tools/cov` and `tests/battle_damage.c` (2026-11-06), where a few
hours of this found a data-loss bug the hand-written tests missed (an HTTP id of 20 digits wrapped into another row's
id and `/delete` removed that row).

- One libFuzzer target per input from outside (a protocol, a file format). It includes the unity `.c` (`#define main
  NAME_main_` first), builds fresh state per input and frees it (`arena_free`, not reset, so ASan sees stale
  pointers), and checks an oracle beyond crashes: replies that split into whole frames, a checksummed file that never
  returns an id it does not hold. Judge only what the format promises (an old format without checksums: memory
  safety only). Define `fork()` in the target to fail, so background children take their refusal path instead.
- A `-DFUZZ_MAIN` driver (`tests/fuzz_main.h`) runs the target once per file with gcc and its sanitizers alone, so the
  project's own test script replays the seeds and every input that once failed without clang. Seeds of mostly zeros
  go in gzipped (`gzip -9n`) and are unpacked into the build dir.
- clang in a cloud sandbox may come without compiler-rt: `apt-get update`, then `apt-get install libclang-rt-18-dev`
  (without the update it has "no installation candidate"). Always `-artifact_prefix=.build/fuzz/`, or crash files land
  in the working directory; ignore `/crash-*` and friends anyway.
- An ENOMEM under ASan that the gcc replay does not show is a lead, not noise: watch `/proc/PID/maps` and `VmSize`
  while it fuzzes. A spike of 9,000 mappings was a 16 TB spill file reserved from a damaged row count; `ulimit -v` a
  little above ASan's own reservation (about 21 TB) turns such a spike into a saved crash input.
- Coverage of a unity build: build a copy of the tree with `--coverage -fprofile-update=atomic` (TSan reports plain
  counters as races), merge `gcov --json-format --stdout` over every binary, and count lines, not functions (gcc
  inlines statics, which then read as never called). A process killed by SIGKILL writes no counts; an instrumented
  `.so` exports `__gcov_*` and `mangle_path`.
- gcc's `-fsanitize=undefined` leaves out `float-cast-overflow` (clang's has it): add it, or a NaN converted to int
  passes every gcc build. A NaN can come from finite input: a component past about 1.8e19 squares past f32's range,
  and an inf length normalises a vector into NaNs - feed parsers and math huge, tiny and denormal numbers, not only NaN.
- Test the test: one `sed` on a `mktemp -d` copy of `src/` (the rebuild refusing at exactly m damaged blocks) must make
  it fail.

## Conventions worth copying (basecamp/omarchy, 532 bash commands under test, read 2026-10-18)

- Stub the world, run the real code: a scratch `bin/` of stubs that log their arguments, first on PATH; assert on the
  log and the files written. A `bash -l` rereads `/etc/profile` and drops the stubs - stub `bash` itself when the code
  under test starts login shells.
- Assert the invariant the test is named for, not a snapshot of whole structures.
- Background processes a test starts: output to a log or `/dev/null`, killed on exit - an inherited pipe keeps the
  runner hanging.
- One `test/all` that runs every suite, keeps going past a failing one and lists the failed suites at the end.
- Performance guards: prefer a count that is the same on every machine (processes started, calls made) over wall-clock;
  when timing, take the fastest of several runs and scale the budget by this machine's speed (how long 100 fork/execs
  take); skip on a far slower machine instead of guessing.
- A migration's test builds the old state in a fake `HOME`, runs the migration twice (idempotent) and once on state
  that is already new (his customizations untouched).

## CI

One GitHub Actions job that runs the project's own entry scripts (shellcheck, `./test`), nothing CI-only; free for
public repos (gael `.github/workflows/test.yml`). `actions/checkout@v5` or newer: v4 runs on the deprecated Node 20
and every run gets a warning (2026-10). Watch a run with `gh run watch ID --exit-status`, not a sleep loop.

## Autotest

Rerun on save: in Emacs `C-c A` repeats the last compile after every save under its directory (his dev-compile
module), or in a terminal `while inotifywait -qq -r -e close_write src tests; do ./test; done`.

## Safety

Tests never touch his real config, keys or live sessions. Globs in cleanup are dangerous: `rm -f tests/test_*` once
deleted the test sources along with the binaries in a folder without git (2026-09-27) - build outputs go to their own
directory, and anything else goes to the trash (`rules (trash-not-rm)`).
