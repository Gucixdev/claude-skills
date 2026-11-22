---
name: evolve
description: Tools, scripts and templates improve every time they are used - a better solution goes into the template or fixes the script on the spot; a failure is fixed at once when small, else written to issues.md with a repro. Use after a script or tool misbehaves, after finding a better way than the one in a template, or when a step is repeated.
metadata:
  priority: "2"
  tags: "#automation #scripts #templates #workflow #quality #dev"
  requires: "skill:automate-everything"
---

# evolve

His rule (2026-11-15): tools and scripts are not finished when they work once; each use is a chance to leave them
better than found. Two triggers, one habit.

## A better way turns up

While doing a task I find a cleaner, shorter or faster solution than the template or script I started from.

- It is general (would help the next project too): put it in the template it came from (`templates/` of the repo, or
  the skill's reference), so the next copy starts better. A new template only when the pattern has been used twice.
- It is specific to this tool: fix the tool now, in the same round, with the test that shows the difference.
- Never improve silently: the commit says what got better and why (a number if it is speed or size).

## Something fails

A script or tool errors, gives a wrong answer, or needs a manual workaround.

- Small (about 15 lines or fewer, one file I own, a test can show it): fix it now, add the test, commit. That is the
  default; most failures are this size.
- Large, risky, or in code with his uncommitted changes: one line in the repo's `issues.md` - what, how to repeat it,
  the exit code or message, the date - and carry on. No half fixes.
- The same failure twice is a missing check: the fix includes the test or the `check` step that would have caught it
  (the two recurring bug classes in fez are the model).
- A wrapper that hides the failure (`|| true`, `2>/dev/null`) is the bug, not the fix.

## Limits

- Only his own tools and my own scripts. A third-party program with a flaw gets a workaround in the wrapper and a line
  in `issues.md`, not a patch in its source.
- Nothing deleted: the old version goes to the trash or stays in git.
- One improvement per round; a rewrite is a todo line, not a side effect.
