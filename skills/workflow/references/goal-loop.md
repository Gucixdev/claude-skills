# workflow (goal-loop)

His words: "petla goal az do skutku" (2026-10-29). `workflow (afk-loop)` says don't stop; goal-loop says when stopping is
allowed: when the check passes, not when the work feels done.

## The goal is a check

- "Done" written as a command that exits 0 only when the goal holds: `./test`, `bin/skills check && bats tests/`,
  `diff <(./run sample.in) sample.expected`, a benchmark script that exits 1 under its threshold. The goal in words
  goes in a comment above it.
- Check the check before the loop: it must fail now, for the reason the goal names. One that already passes, or fails
  for another reason (a missing file, a wrong path), proves nothing.
- Fast: it runs at every stop. Seconds, not minutes - a focused subset inside the loop, the full suite once at the
  end (`code (done)`).
- Constraints belong in it too: what must not change on the way, such as `git diff --quiet -- tests/`.
- A goal that cannot be a command - a look, a feel - needs a reference and a comparison (captures side by side, the
  numbers from the vibe section of `rea`), or it is a review with him, not a loop.

## The loop

1. Run the check; read only the decisive part of the failure (`code (output)`).
2. Say what the next change should do to the check (`rules (calibration)`), make one change, run it again.
3. One line per try in the log - the goal file's own `# try:` lines with goal-gate, otherwise `GOAL.md` in the
   project: what changed, what the check said. Commit each step that moves the check forward; it is a known good
   point to come back to.
4. The same failure after two different fixes: stop patching and investigate (`code (thinking)`) until one
   mechanism explains it. Three tries without progress: change the approach - a smaller step, another design, the
   docs (`rules (rtfm)`) - and log why.
5. Blocked on him or on access: questions.md, then the parts that don't depend on it (`workflow (afk-loop)`).

## Never game the check

The check is the contract. Off limits for making it pass: deleting, skipping or loosening tests; moving thresholds or
tolerances; special-casing the test input; catching and hiding the error; mocking what the goal says to run for real;
rewriting the expected output to match the actual one. If the expected output or the goal itself is wrong, that is a
finding: stop, show the evidence, let him decide (`rules (knows-unknowns)`). A goal shown to be impossible is a result too.

## Budget

20 tries unless he says otherwise, and a money cap for anything billable (`rules (zero-cost)`). Budget spent: stop with the
best state reached, the log, and what blocked it.

## The machinery

- `hooks/goal-gate` in this repo (wired as a Stop hook in `config/settings.json`, on PATH as `goal-gate`): the command
  decides and nothing is billed. `goal-gate path` prints the project's goal file - kept in
  `~/.local/state/goal-gate`, outside every repo, so a cloned repo can never plant one; a finished goal there is moved
  aside first. Write the goal in words as the first comment, then `# max: N` and `# timeout: S` if the defaults (20
  tries, 300 s) don't fit, then the check. Each time I try to stop, the hook runs the check: failing, I get the goal and
  the output tail back and keep working; passing, it appends `# met:` and lets me stop. `goal-gate show` prints the
  goal with its tries. First choice whenever the goal is a command.
- Claude Code's `/goal CONDITION` (v2.1.139 or later, typed by him): after every turn a small model judges the
  condition from the conversation only - it runs nothing - so the condition names the command and its expected
  output, and I print that output in every turn: `/goal bin/skills check exits 0 and bats tests/ shows no "not ok",
  or stop after 20 turns`. Plain `/goal` shows the status, `/goal clear` ends it, `claude -p "/goal ..."` runs one
  headless. For goals that only words can state.
- A Ralph-style loop - a Stop hook that feeds the prompt back until I print an agreed word - is self-graded; the two
  above replace it.
- A cloud session usually has neither: the loop is mine, with the same rules, the log in the repo and each green step
  pushed (`workflow (afk-loop)`).
