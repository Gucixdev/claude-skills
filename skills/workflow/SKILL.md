---
name: workflow
description: How work runs with him - keep going without check-ins, the round loop (code, tests, lean4, allocator check, bench, commit), loop until a check passes, braindump before building, vibemix, forks only when he asks, free providers and councils for second opinions. Applies to every multi-step task.
metadata:
  priority: "0"
  tags: "#session #autonomy #tasks #workflow #loop #testing #agents #delegation #ideas #notes #capture #design #thinking #reverse-engineering #dev #llm #providers #limits #council #models #review #decisions"
  requires: "?cmd:timeout ?mcp:openrouter ?cmd:ollama|llama-server"
---

# workflow

The digest is how a session runs; open a part for the technique.

## Always

- Keep going: once a direction is agreed, run design, build, verify and commit back to back without check-ins. Stop
  only for something irreversible, credentials only he has, or a choice with no sane default. Questions that can wait
  go into the the single `questions.md` of claude-config (`workflow (afk-loop)`).
- When he is silent, I do not wait: after a finished request I take the next item from the todo files, roadmaps and
  memory of his projects, with forks for disjoint bulk work, and schedule my return if I must wait (`workflow (afk-loop)`).
- Every round is the same ladder: code, tests, lean4 (proofs and tests in Lean), if it is C the arena/pool/own
  allocator check, bench and compare once it is reasonably fast, commit - then his review decides the next round
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

- [llm-council](references/llm-council.md) - LLM council - several models answer the same question independently, review each other's answers anonymized and in shuffled order, and a chairman writes the result with the agreements, the splits and any minority view that has a real argument kept visible. Seats from what he has - other labs' models through the openrouter MCP (send-message, billable or :free), Claude subagents on another model, local models through ollama or llama-server (free) - with an honest note on how independent they are. For judgment calls, plans, designs, reviews and contested questions; facts get checked, not voted on. Use when he says council, rada, zapytaj inne modele, druga opinia or second opinion; offer it, with the price, before a costly, hard-to-reverse decision.
- [openrouter](references/openrouter.md) - How to use free LLM providers (openapi MCP / OpenRouter and ~200 others) for bulk work, councils and second opinions, and the standing order to burn the leftover token limit at the hourly reset (04:20) on useful work while he sleeps. Use before any big task, when the limit is nearly spent, or when he mentions openrouter, limits, providers or sleeping.
- [vibemix](references/vibemix.md) - His technique for making new software - he names programs and says which features or concepts of each he likes best ("ma mieć to z X, to z Y i to z Z"), and the result is built the way he builds, in his own stack under its own name, not a copy and not a clone of any one of them. Capture the list as he gave it, find out what each liked feature really is (rea, black box), ask him the detailed design questions in one batch (layout, keys, look, motion, data, edges, scope, name; defaults marked, work goes on meanwhile), mix them into one design with one model, build the smallest slice in his stack, show it, iterate on his review. Use when he lists programs and features to combine, says vibemix, "zrób to po naszemu", "taki X ale z Y", or describes a tool as a hybrid of existing ones.
- [brainstorm](references/brainstorm.md) - Generate and cut options - several really different ways to solve it (not variations), each with its cost, what it gives up and the cheapest test that would show it wrong, then one recommendation with the reason, the runner-up and what would change the answer. Use when he asks "jak to zrobić", "co myślisz", for ideas, designs, names or a choice between approaches, before building something with more than one reasonable shape.
- [braindump](references/braindump.md) - Catch a raw stream of ideas without losing or building any of them - he thinks out loud, several wishes in one message, half-formed, mixed Polish and tech words; write each down as it came in a braindump file, group them, mark every one open/stub/done, never start building during the dump, and fill or sort the stubs later on his word or when idle. Use when he lists ideas, says braindump, "mam pomysl", "zapisz", or sends several unrelated wishes at once.
- [agentic-techniques](references/agentic-techniques.md) - The user's agentic working style - AFK loop, doing list/braindump when idle, orchestrator with clean-session forks, free providers via openrouter. Use at session start, when idle, or before spawning any agent.
- [goal-loop](references/goal-loop.md) - Pętla aż do skutku - work toward a goal until a check proves it met, not until it feels done - the goal written as a command that exits 0 when done (tests, a benchmark threshold, an output diff) and seen to fail first; then attempt, run the check, read the failure, change one thing, log the try; a new approach when the same failure repeats; a try budget; never a weakened check. On his machine through the goal-gate Stop hook (the command decides, free) or Claude Code's /goal (a model judges). Use when he says aż do skutku, until it works, until the tests pass, keep going until, loop, /goal or ralph.
- [afk-loop](references/afk-loop.md) - Keep working without stopping - he often steps away and wants long unattended progress, so carry the plan through design, build, verify and commit without check-ins, keep a stack of open items and switch to another when one is blocked, park questions in questions.md instead of waiting. Applies to every multi-step task. Parts in references/ - task-stack (the stack of open threads).
- [task-stack](references/task-stack.md) - Keep a mental stack of open/pending tasks across a session. When blocked on one (waiting for an answer, hit a wall, needs something only the user can decide), switch to another pending item instead of just stopping. Pairs with afk-loop.
