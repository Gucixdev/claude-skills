---
name: verify
description: Proving it works - the real run before saying done, tests the user's way (real behaviour, pty, fakes, sanitizers, fuzzing), honest benchmarks with compare, debugging evidence (gdb, sanitizers, strace, bisect), audits of repos and claims, and Lean 4 verification of optimized C. Use before every done, when something breaks, is slow or must be proved.
metadata:
  priority: "1"
  tags: "#verify #testing #done #proof #dev #quality #fuzzing #coverage #bash #c #python #rust #go #godot #bench #performance #measurement #debugging #linux #lean4 #formal #verification #optimization #mathlib"
  requires: "?cmd:tmux ?cmd:bats ?cmd:inotifywait ?cmd:clang ?cmd:gcov ?cmd:hyperfine ?cmd:perf ?cmd:gdb ?cmd:strace ?cmd:valgrind ?cmd:coredumpctl cmd:lake cmd:gcc ?cmd:elan"
---

# verify

Done means shown. Pick the part by what is being proved.

<!-- digest -->

## Parts

Read the part when the task matches.

- [lean4](references/lean4.md) - Lean 4 as the standard for verification and mathematical proof (chosen over Frama-C) - every project has lean4/ at its root, and optimized C is proved or exhaustively tested equal to a plain Lean reference so optimization can go as far as it goes. Formal verification with Mathlib, TrustLean and AMO-Lean - prove that C code works this way - a Lean model per C function, theorems on the model, an axiom audit by module (no sorry, no native_decide), an oracle exe from the same definitions diffed against the real C (every input where finite, labelled grids or seeded random cases elsewhere, one build per -march), C-only property checks and a mutation test; plus the toolchain in a cloud session without Mathlib's cache, proof gotchas and the API drift of Lean 4.26. Use for any Lean, Lean 4, Mathlib, TrustLean, AMO-Lean, formal proof, dowód, udowodnij or weryfikacja formalna task.
- [debug](references/debug.md) - Debugging toolbox for the evidence a Sherlock-style investigation needs - shell tracing, gdb in batch mode, core dumps, sanitizers, valgrind, strace and ltrace, rr, git bisect run, Python faulthandler and pdb, engine logs, journald, network checks. Use when something crashes, hangs, leaks, misbehaves or got slower.
- [bench](references/bench.md) - Honest benchmarks - paired baseline and candidate runs on identical input, warmup and repetitions, median and spread, max RSS, quality measured next to speed, profiling phases before optimizing, standard datasets and known baselines, results logged with commit, machine and date. Use before claiming anything is faster, smaller or cheaper, and when optimizing.
- [test](references/test.md) - Testing the user's way - real behaviour over mocks, live tests that skip only on a real no-network signal, TUIs driven through tmux or a pty, fake binaries on PATH that record their arguments, temp HOME so nothing real is touched, sanitizers and two compilers for C, libFuzzer targets with a gcc replay driver, line coverage of unity builds, a regression test per bug proven on the old code, one CI job that runs the project's own scripts, autotest on save, small high-quality test data. Use when writing or running tests in any language, fuzzing, measuring coverage, battletesting, or setting up CI.
- [verify](references/verify.md) - Prove it is done for real before reporting it - run the actual test, read the log or exit state, drive the TUI through a pty or tmux, take the screenshot, check the generated output - not just a flag or an exit code; then stop. Use before every "done", and when the user asks to check finished work.
