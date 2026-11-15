---
name: workflow
description: How work runs with the user - keep going without check-ins, the round loop (code, tests, lean4, allocator check, bench, commit), loop until a check passes, braindump before building, brainstorm options, vibemix (a mix of named programs), forks only when the user asks, free providers and councils for second opinions. Applies to every multi-step task.
metadata:
  priority: "0"
  tags: "#session #autonomy #tasks #workflow #loop #testing #agents #delegation #ideas #notes #capture #design #thinking #reverse-engineering #dev #llm #providers #limits #council #models #review #decisions"
  requires: "?cmd:timeout ?cmd:ollama|llama-server"
---

# workflow

The digest is how a session runs; open a part for the technique.

## Always

- Keep going: once a direction is agreed, run design, build, verify and commit back to back without check-ins. Stop
  only for something irreversible, credentials only the user has, or a choice with no sane default. Questions that can wait
  go into the questions file (`workflow (afk-loop)`).
- When the user is silent, I do not wait: after a finished request I take the next item from the todo files, roadmaps and
  notes of the user's projects, with forks for disjoint bulk work, and schedule my return if I must wait (`workflow (afk-loop)`).
- Every round is the same ladder: code, tests, lean4 (proofs and tests in Lean), if it is C the arena/pool/own
  allocator check, bench and compare once it is reasonably fast, commit - then the user's review decides the next round
  (`workflow (afk-loop)`).
- Done is a command that exits 0, seen to fail first; loop until it passes, never weaken it (`workflow (goal-loop)`).
- A repeated action becomes a script at once, not another terminal one-off (`automate-everything`).
- Several wishes in one message: write them down as they came, build nothing during the dump (`workflow (braindump)`).
  More than one reasonable shape: options with costs and one recommendation (`workflow (brainstorm)`). Programs and
  liked features named: `workflow (vibemix)`.
- Keep the stack of open threads; when blocked, switch to another and close the first later (`workflow (task-stack)`).
- Bulk or boring work and second opinions go to free providers (`workflow (openrouter)`); a contested decision to a
  council (`workflow (llm-council)`).

## Parts

Read the part when the task matches.

- [llm-council](references/llm-council.md) - LLM council - several models answer the same question independently, review each other's answers anonymized and in shuffled order, and a chairman writes the result with the agreements, the splits and any minority view that has a real argument kept visible. Seats from what the user has - other labs' models through an OpenRouter-style API (billable or :free), Claude subagents on another model, local models through ollama or llama-server (free) - with an honest note on how independent they are. For judgment calls, plans, designs, reviews and contested questions; facts get checked, not voted on. Use when the user says council, ask other models or second opinion; offer it, with the price, before a costly, hard-to-reverse decision.
- [openrouter](references/openrouter.md) - How to use free LLM providers (OpenRouter and others) for bulk work, councils and second opinions, and optionally spending leftover free limits on background work while the user is away. Use before any big task, when the limit is nearly spent, or when the user mentions openrouter, limits or providers.
- [vibemix](references/vibemix.md) - A technique for making new software - the user names programs and says which features or concepts of each the user likes best ("this from X, that from Y and those from Z"), and the result is built the way the user builds, in the user's own stack under its own name, not a copy and not a clone of any one of them. Capture the list as the user gave it, find out what each liked feature really is (rea, black box), ask the user the detailed design questions in one batch (layout, keys, look, motion, data, edges, scope, name; defaults marked, work goes on meanwhile), mix them into one design with one model, build the smallest slice in the user's stack, show it, iterate on the user's review. Use when the user lists programs and features to combine, says vibemix, "make it our way", "like X but with Y", or describes a tool as a hybrid of existing ones.
- [brainstorm](references/brainstorm.md) - Generate and cut options - several really different ways to solve it (not variations), each with its cost, what it gives up and the cheapest test that would show it wrong, then one recommendation with the reason, the runner-up and what would change the answer. Use when the user asks "how should I do this", "what do you think", for ideas, designs, names or a choice between approaches, before building something with more than one reasonable shape.
- [braindump](references/braindump.md) - Catch a raw stream of ideas without losing or building any of them - the user thinks out loud, several wishes in one message, half-formed, write each down as it came in a braindump file, group them, mark every one open/stub/done, never start building during the dump, and fill or sort the stubs later on the user's word or when idle. Use when the user lists ideas, says braindump, "I have an idea", "write this down", or sends several unrelated wishes at once.
- [agentic-techniques](references/agentic-techniques.md) - Agentic working style - AFK loop, doing list/braindump when idle, orchestrator with clean-session forks, free providers via openrouter. Use at session start, when idle, or before spawning any agent.
- [goal-loop](references/goal-loop.md) - Loop until it works - work toward a goal until a check proves it met, not until it feels done - the goal written as a command that exits 0 when done (tests, a benchmark threshold, an output diff) and seen to fail first; then attempt, run the check, read the failure, change one thing, log the try; a new approach when the same failure repeats; a try budget; never a weakened check. On the user's machine through the goal-gate Stop hook (the command decides, free) or Claude Code's /goal (a model judges). Use when the user says until it works, until the tests pass, keep going until, loop, /goal or ralph.
- [afk-loop](references/afk-loop.md) - Keep working without stopping - the user often steps away and wants long unattended progress, so carry the plan through design, build, verify and commit without check-ins, keep a stack of open items and switch to another when one is blocked, park questions in a questions file instead of waiting. Applies to every multi-step task. Parts in references/ - task-stack (the stack of open threads).
- [task-stack](references/task-stack.md) - Keep a mental stack of open/pending tasks across a session. When blocked on one (waiting for an answer, hit a wall, needs something only the user can decide), switch to another pending item instead of just stopping. Pairs with afk-loop.
