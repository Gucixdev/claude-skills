---
name: karpathy
description: The first standard, read before any other skill - four rules against the usual LLM coding mistakes (think before coding, simplicity first, surgical changes, goal-driven execution), from Karpathy's observations. Applies to every task that writes, reviews, refactors or plans code, and to every other change. Use also on karpathy, standard, overengineering, drive-by refactor, success criteria.
license: MIT
metadata:
  priority: "0"
  tags: "#dev #workflow #quality #code #thirdparties"
  requires: "?cmd:jq"
  upstream: "multica-ai/andrej-karpathy-skills@2c606141936f1eeef17fa3043a72095b4765b9c2"
---

# karpathy

The first standard (his words, 2026-11-26: "to jest teraz swietosc i nasz standard pierwsza rzecz"). The four rules
are the upstream text (MIT per its README and plugin.json; the repo has no LICENSE file), derived from
[Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876). They bias toward caution over
speed; for a trivial task use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## How it fits the other skills (ours, not upstream)

Another skill pulling the other way on how a change is made loses to the four rules. His instruction in the session
and a repo's own CLAUDE.md still come first.

- Ask (1) and keep going (`workflow`): "stop" means the unclear item. Look it up first, then ask the way
  `rules (clarify)` says, and keep working on what does not depend on the answer; unattended, it goes to
  `questions.md`.
- Surgical (3) and `evolve`: a broken tool that blocks the task is part of the task. Any other improvement is its own
  change and commit, named in the report, never mixed into the task's diff.
- Surgical (3) and `rules (trash-not-rm)`: orphaned lines are edited out; an orphaned file goes to the trash.
- Simplicity (2): the ladder is `code (ponytail)`; in C++ a helper built the second time (`cpp`) is not single-use.
- Goal-driven (4): the loop is `workflow (goal-loop)`, the proof is `code (done)`.

`hooks/karpathy_gate` enforces part of it (a plan before a code edit, no whole-file Write over code, a named success
criterion at the end); `KARPATHY_GATE=off` turns it off.
