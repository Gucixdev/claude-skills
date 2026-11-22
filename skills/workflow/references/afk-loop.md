# workflow (afk-loop)

His words, many times: "dawaj zapierdalaj", "nie wiem czemu się zatrzymujesz", "chodzi o to byś się nie zatrzymywał,
ja zaraz idę spać", "masz plik questions.md, tam możesz wrzucać".

## The hard gate (afk-gate)

Everything below is text, and text does not stop a model from ending its turn: 2026-11-15 he said the skill "nadal tak
naprawde nie dziala". Found why: the Stop hooks lived only in the repo's `config/settings.json`, the live
`~/.claude/settings.json` had no `hooks` at all. The enforcement is `hooks/afk-gate`, a Stop hook: while AFK mode is on,
ending the turn is refused and the first open line of `todo.md` comes back as the next task.

- Normal use: `! afk-gate auto 10m` once; from then on the hook measures his silence itself (newest human entry in the
  transcript) and, after 10 min (any N), blocks stops and hands back the next open `todo.md` line. A message from him
  ends the wait. `afk-gate on 8h` is the manual force (blocks regardless of idle, switches itself off after 8 h);
  `afk-gate off` when back; `afk-gate status`. Cap of 300 blocked stops, then it switches itself off and says so.
- Open line = a line of `todo.md` without "zrobione", "done" or "blocked". So tick a finished item with `-> zrobione`
  and mark a hardware/account-blocked one `(blocked: why)` (and a line in `questions.md`), or the gate sends me back
  to it. A `todo.md` with no open line lets me stop.
- It is live only after `tools/hooks-install` (links `hooks/`, copies the hooks section of `config/settings.json`).
  I do not edit the hooks section of my own settings (the auto-mode classifier refuses it, rightly): he runs it.
- It cannot wake a session that is not running (rate limit, closed terminal): that needs a message or `/loop`.

## Keep going

- After he agrees to a direction (even "dokladnie" or "xD"), go through the remaining steps back to back - design,
  build, verify, commit - without a check-in after each one.
- The bar for stopping is high, higher than it feels. He asked "czemu się zatrzymujesz?" after I stopped over wiring a
  function its siblings were already wired like, and again over a large multi-file port with an obvious starting point.
  If a sensible default or starting point exists, take it, say so afterwards, and let him redirect.
- Stop only for: an irreversible or destructive action (`rules (trash-not-rm)`), credentials or access only he has, or a
  choice with no sane default at all. Code organization - merge or split, rename, where a file lives - is mine to
  decide, not a stopping point. Whether a doubt is worth a question at all, and how to ask it: `rules (clarify)`.
- A task with a checkable finish line (tests green, a benchmark threshold, "aż do skutku") runs as a `workflow (goal-loop)`: it
  ends when the check passes, not when it feels done.
- Never send a turn that only says "still waiting". Each turn carries new information (a log, a status, a result) or
  new action (other bounded work). With nothing new and nothing else to do, stay quiet.
- When he asked for continuous work, finishing one item means taking the next real improvement from the stack ("zawsze
  jest co rozwinąć, ulepszyć, zoptymalizować"). When he asked for one thing, stop when it is done (`code (ponytail)`).

## When he is silent

He said (2026-11-15): when he does nothing and writes nothing, I implement - from what I know of his projects, from
their todo files and roadmaps, with forks - and I do not sit and wait. After a finished request I once stopped with a
report and 40 minutes passed with nothing done; that is the failure this section prevents.

- A finished request with no new message is not the end. Report in one line, then take the next item (below) in the
  same turn. A turn that ends with work left is a wasted turn.
- A session cannot wake itself. When I must wait (a long build, a fork running, a rate limit), I schedule the return
  (`ScheduleWakeup`, 1200 s or more, the same prompt) or run in `/loop` dynamic mode; background jobs and forks notify
  me, so I do not poll them.
- Where the next item comes from, in this order:
  1. The open threads of this session (the stack, below).
  2. The project's `TODO`/`ROADMAP`/`PLAN` files (`rg -il 'todo|roadmap'` at each repo root and `docs/`) and the
     "next"/"queued" lines of its memory entry. Take the item that is small, checkable and does not need him.
  3. Held-back work that needs his decision goes to `questions.md` (claude-config root), not into the queue.
- Forks: he asked for them here, so use them for disjoint bulk items - one project per fork, a clean self-contained
  prompt (goal, paths, conventions, what not to touch, report of 14 lines at most), at most three at once
  (`workflow (agentic-techniques)`). I read their reports and verify the claim before believing it. Small items I do myself.
- Limits stay on: nothing pushed unless he said to push that repo; nothing deleted (trash); no `symbiote`, no
  `holyc/notcoreutils`, nothing live (compositor, editor, network); never overwrite what he is editing now (check
  `git status` before touching a repo); repos with his uncommitted changes are read-only for me.
- What he finds on return: each finished round is a commit, and one line per round is appended to `afk-log.md` in
  the project (what, check that passed, commit). Questions in `questions.md`. No wall of text in chat.

## The working loop

His description (2026-11-14): "ty piszesz kod, ja oceniam, mówię co poprawić"; now and then he restructures - split,
merge, move files or whole projects. No pause between rounds: the next improvement starts as soon as the last one is
committed, even if it means looping all night. Every round runs the same ladder:

1. **Code**, the smallest working version first.
2. **Tests** for it, run for real (`code (done)`).
3. **Lean 4**: proofs for what can be proved - bounds, equivalence to a plain reference, invariants - and tests
   written in Lean, in the project's `lean4/` (`code (lean4)`).
4. **If it is C: are our techniques in?** Arena for things that share a lifetime, pool for fixed-size objects, flat
   data, no hidden allocation (`code (languages)`). When the project's access pattern needs it, write a special
   allocator for that project, the way vecindex has its own - not a generic malloc replacement, and with the same
   test and proof treatment.
5. **Bench and compare** once the code is reasonably fast: against the previous version and against the reference
   or the tool it replaces, same input, numbers kept (`code (bench)`). A regression is fixed before the next feature.
6. Commit, then his review decides the next round.

## The stack

A long session has several open threads: a question asked, a fix waiting for his yes, a build in the background, a
half-done investigation. Keep them listed (the task list), not only the one in front of me. Blocked on one - switch to
another that doesn't depend on it, come back when it clears, and actually close it; the stack must not only grow.

## questions.md

Something that needs his decision or an install: one line in `questions.md` at the root of claude-config
(`$CLAUDE_CONFIG/questions.md`), then keep working on what doesn't depend on it. There is ONE
`questions.md` and ONE `todo.md` (same place), not one per project: a project file made earlier is merged into
them and removed. His next ideas and the queue go to `todo.md`. Asking him in chat and then waiting is not the
protocol: a question in chat is also a line in `questions.md`, and the turn continues with the next `todo.md` item.
Ending a turn with "want me to...?" while todo.md has items is the failure he named on 2026-11-15 ("20 min minelo, a ty czekasz").

## Still

Verify real changes for real before calling them done (`code (done)`). In a cloud session the container is thrown away
when the session ends: push each finished batch to the repos he said to push (`rules (discipline)`), or the work is gone.
