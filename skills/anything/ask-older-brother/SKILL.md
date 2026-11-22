---
name: ask-older-brother
description: Hand a hard question to a stronger Claude model (Fable) as a fresh subagent with a self-contained brief, and bring back a recommendation. Use when stuck after two failed attempts, for a risky design, a proof, a hard bug, or when he says older brother, starszy brat, zapytaj fable.
metadata:
  priority: "2"
  tags: "#agents #delegation #models #decisions #review #thinking"
  requires: "skill:orchestrator skill:decide ?cmd:claude"
---

# ask-older-brother

His idea (2026-11-15): when I am out of my depth, a bigger model takes a look - a "starszy brat". It is a second pair of
eyes, not an autopilot: I stay the orchestrator and verify what comes back.

## When

- Two honest attempts failed and the third would be the same idea again.
- A design or interface that is expensive to undo, a proof or an invariant, a subtle concurrency or memory bug.
- A contested choice where `decide` cannot settle it and a council of free models gave a split answer.
- Not for routine edits, lookups or anything a test can settle: that is wasted quota.

## How

1. Write the brief so it stands alone, because the brother starts cold (a `fork` inherits my context but always runs on
   my model, so it cannot be the brother): the goal in one sentence, what was tried and how it failed (exact error,
   command, numbers), the relevant file paths and the few lines that matter, the constraints (his rules: no push, no
   delete, MIT, bash first, flat files), and the exact question with the shape of answer wanted ("recommend one of
   A/B/C with the reason, and the first three steps").
2. Start one Agent, `subagent_type: general-purpose`, `model: fable`, in the background; read-only unless the brief
   says which paths it may edit. Its prompt repeats the safety rules: no push, no delete, no `pkill -f`.
3. Strip secrets and personal data from the brief (keys, e-mail, real names, machine paths in text that leaves the box
   - the Agent tool stays inside Claude, but the habit costs nothing).
4. While it runs, work on something else (`workflow (task-stack)`), do not poll.
5. Treat the answer as a strong opinion, not as an order: run its suggested check, try the first step, and say in my
   report what the brother advised and what I verified. If it contradicts a rule of his, his rule wins.

## Cost

A Fable call is the expensive rung of the ladder in `orchestrator`: say in one line why before spending it when the
brief is long. At most one brother running at a time, and the two-agent limit still counts it.

## Write it down

A decision that came from the brother goes into the commit message or `questions.md` with the reason, so the next
session does not ask the same question again.
