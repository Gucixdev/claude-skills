# workflow (afk-loop)

Keep working without check-ins. Typical words from a user who wants this: "keep going", "don't stop", "I'm going to
sleep, there is a questions file, put things there".

## Keep going

- After the user agrees to a direction (even with "ok" or "exactly"), go through the remaining steps back to back -
  design, build, verify, commit - without a check-in after each one.
- The bar for stopping is high, higher than it feels. Stopping over wiring a function its siblings were already wired
  like, or over a large multi-file port with an obvious starting point, is a failure. If a sensible default or starting
  point exists, take it, say so afterwards, and let the user redirect.
- Stop only for: an irreversible or destructive action (`rules (trash-not-rm)`), credentials or access only the user has,
  or a choice with no sane default at all. Code organization - merge or split, rename, where a file lives - is for me to
  decide, not a stopping point. Whether a doubt is worth a question at all, and how to ask it: `rules (clarify)`.
- A task with a checkable finish line (tests green, a benchmark threshold, "until it works") runs as a
  `workflow (goal-loop)`: it ends when the check passes, not when it feels done.
- Never send a turn that only says "still waiting". Each turn carries new information (a log, a status, a result) or
  new action (other bounded work). With nothing new and nothing else to do, stay quiet.
- When the user asked for continuous work, finishing one item means taking the next real improvement from the stack.
  When the user asked for one thing, stop when it is done (`code (ponytail)`).

## When the user is silent

When the user does nothing and writes nothing, keep implementing - from what is known of the projects, their todo files
and roadmaps - and do not sit and wait. Stopping after a finished request with a report and then idling for 40 minutes
is the failure this section prevents.

- A finished request with no new message is not the end. Report in one line, then take the next item (below) in the
  same turn. A turn that ends with work left is a wasted turn.
- A session cannot wake itself. When waiting is unavoidable (a long build, a fork running, a rate limit), schedule the
  return (`ScheduleWakeup`, 1200 s or more, the same prompt) or run in `/loop` dynamic mode; background jobs and forks
  notify, so do not poll them.
- Where the next item comes from, in this order:
  1. The open threads of this session (the stack, below).
  2. The project's `TODO`/`ROADMAP`/`PLAN` files (`rg -il 'todo|roadmap'` at each repo root and `docs/`). Take the item
     that is small, checkable and does not need the user.
  3. Held-back work that needs the user's decision goes to the questions file, not into the queue.
- Forks only when the user has allowed them: disjoint bulk items - one project per fork, a clean self-contained prompt
  (goal, paths, conventions, what not to touch, report of 14 lines at most), at most three at once
  (`workflow (agentic-techniques)`). Read their reports and verify the claim before believing it. Small items are done
  directly.
- Limits stay on: nothing pushed unless the user said to push that repo; nothing deleted (trash); nothing live
  (compositor, editor, network); never overwrite what the user is editing now (check `git status` before touching a
  repo); repos with the user's uncommitted changes are read-only.
- What the user finds on return: each finished round is a commit, and one line per round is appended to `afk-log.md` in
  the project (what, check that passed, commit). Questions in the questions file. No wall of text in chat.

## The working loop

For a user who reviews and directs ("you write code, I review and say what to fix"), and now and then restructures -
split, merge, move files or whole projects. No pause between rounds: the next improvement starts as soon as the last
one is committed. Every round runs the same ladder:

1. **Code**, the smallest working version first.
2. **Tests** for it, run for real (`verify`).
3. **Lean 4**, where it pays: proofs for what can be proved - bounds, equivalence to a plain reference, invariants
   (`verify (lean4)`).
4. **If it is C: are the techniques in?** Arena for things that share a lifetime, pool for fixed-size objects, flat
   data, no hidden allocation (`code (languages)`). When the project's access pattern needs it, write a special
   allocator for that project - not a generic malloc replacement, and with the same test and proof treatment.
5. **Bench and compare** once the code is reasonably fast: against the previous version and against the reference
   or the tool it replaces, same input, numbers kept (`verify (bench)`). A regression is fixed before the next feature.
6. Commit, then the user's review decides the next round.

## The stack

A long session has several open threads: a question asked, a fix waiting for the user's yes, a build in the background, a
half-done investigation. Keep them listed (the task list), not only the one in front of me. Blocked on one - switch to
another that doesn't depend on it, come back when it clears, and actually close it; the stack must not only grow.

## The questions file

Something that needs the user's decision or an install: one line in the questions file, then keep working on what
doesn't depend on it. Keep ONE questions file and ONE todo file (at the root of the user's config or notes repo), not one
per project: a project file made earlier is merged into them and removed. The user's next ideas and the queue go to the
todo file. Asking in chat and then waiting is not the protocol: a question in chat is also a line in the questions file,
and the turn continues with the next todo item. Ending a turn with "want me to...?" while the todo file has items is the
failure to avoid.

## Still

Verify real changes for real before calling them done (`verify`). In a cloud session the container is thrown away
when the session ends: push each finished batch to the repos the user said to push (`rules (discipline)`), or the work is gone.
