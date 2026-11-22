# code (thinking)

The thinking tools: the working principles (kaizen, YAGNI, KISS, Chesterton's fence...) and the three investigation tools (YAGNI, Sherlock, rubber duck).

## Working principles

One place for the working principles: the Japanese ones from lean manufacturing and craft, and the Western rules of
thumb. Each says what it is and where it already shows up in how he works, so it is applied, not recited. When two
pull against each other, the order is: correct, then simple, then fast, then flexible.

### Japanese techniques

| Word | Idea | In his work |
|---|---|---|
| **kaizen** 改善 | many small improvements, continuously, not a rewrite | the round loop with no pause between rounds (`workflow (afk-loop)`); one small commit per improvement |
| **muda** 無駄 | waste. Software forms: features nobody uses, code kept "for later", waiting (slow builds), handoffs, gold plating, work started and not finished, bugs | YAGNI and the ponytail ladder (`code (ponytail)`); a build that takes seconds is a feature |
| **muri / mura** 無理 / 斑 | overburden / unevenness: a module or a person asked to do too much, work arriving in lumps | split a file as it grows; small batches, not one giant commit |
| **poka-yoke** ポカヨケ | design so the mistake cannot happen, or is caught at once | types, `set -u`, shellcheck, an error that names the fix (gael's messages), `no-rm` hook, trash instead of delete |
| **jidoka** 自働化 | the line stops itself on a defect, a human then looks | tests stop the round on the first failure; `set -e` where it fits; a failing check is never weakened (`workflow (goal-loop)`) |
| **andon** 行灯 | a visible signal that something is wrong | loud failure, exit codes that mean something, `questions.md` for what needs him |
| **genchi genbutsu** 現地現物 | go and see the real thing instead of guessing | run it before saying done (`code (done)`); `strace`, real data, the real file; reverse engineering starts at the black box (`rea`) |
| **yokoten** 横展 | when something is fixed, check everywhere the same fault can sit | after a bug, grep for its class across the repo (his two recurring bug classes in fez) |
| **hansei** 反省 | honest reflection after the work: what went wrong, what changes | lessons become a skill or a memory (`skill-everything`); "claimed without proof" is named, not hidden |
| **kanban** 看板 | show the work, limit what is in progress | the task stack (`workflow (task-stack)`); at most three forks at a time |
| **5S** (seiri, seiton, seiso, seiketsu, shitsuke) | sort, set in order, clean, standardize, sustain | remove what is unused (to `trash/`), one place per thing, READMEs and conventions kept in step with the code, the habit repeated every round |
| **shu-ha-ri** 守破離 | learn the form, then bend it, then leave it | copy a good reference first, adapt it second, own design last (`workflow (vibemix)`) |
| **kata** 型 | a practised form repeated until it is cheap | `run`, `test`, `check`, `bench` in every project (`distribute-everything`); the same round ladder every time |
| **nemawashi** 根回し | prepare the ground before the decision | braindump and brainstorm before building (`workflow`); options with costs, then one recommendation |
| **heijunka** 平準化 | level the load, small even batches | many small commits and rounds instead of one big one at the end |
| **mottainai** もったいない | do not waste what has value | reuse before writing, trash instead of rm, keep the old interface (the alias-file pattern) |
| **wabi-sabi** 侘寂 | plain and a little imperfect is fine | the smallest working version first; a rough edge that works beats a polished thing that does not exist yet |

### Western rules of thumb

| Name | Idea | In his work |
|---|---|---|
| **YAGNI** | You Aren't Gonna Need It: do not build what nobody asked for | the first question before any feature; name the cut in one line ("skipped X - add it when Y"); detail in `code (thinking)` and `code (ponytail)` |
| **KISS** | the simplest thing that works | one way to do a thing; a plain function before a class |
| **DRY, and the rule of three** | one source of truth for a fact; abstract on the third repetition, not the second | two copies are cheaper than a wrong abstraction; a table or a generator beats three near-identical blocks |
| **Make it work, make it right, make it fast** | in that order, each step checked | correct and tested first, then benchmarked against the reference (`code (bench)`), never the reverse |
| **Measure before optimizing** | premature optimization is guessing | a profile or a benchmark decides, numbers are kept (`code (done)`) |
| **Composition over inheritance** | small pieces put together, a function takes what it needs, no deep hierarchies | combinators and flat data (`code (languages)` (dod)), small tools that pipe |
| **Unix philosophy** | one tool does one thing well; text in, text out; tools compose | the `bash` and caveutils tools, `--json`, exit codes (`cli-everything`) |
| **Worse is better** | a simple implementation that ships beats a perfect one that does not | the smallest shippable version (`ship-anything`) |
| **Chesterton's fence** | do not remove what you do not understand yet | find out why a check or a quirk is there (git blame, the docs) before deleting it |
| **Gall's law** | a working complex system grew from a working simple one | start with the slice that runs end to end, then grow it |
| **Tracer bullet / walking skeleton** | thin end-to-end version first, through every layer | a command that runs, a test that passes, a page that loads, before the features |
| **Spike** | a throw-away experiment to answer one question | a scratch directory, thrown away after the answer is written down (`rea`, `workflow (brainstorm)`) |
| **Principle of least astonishment** | it behaves the way the reader expects | conventional names, predictable flags, no surprising side effects (`conventions`) |
| **Parse, don't validate / make illegal states unrepresentable** | turn raw input into a type that cannot be wrong, once, at the edge | types at the boundaries, enums and `option` instead of flags and nulls (gael, Rust, TypeScript) |
| **Fail fast** | stop at the first sign of a bad state with a clear message | validate where input arrives, a specific actionable error, no silent fallback that hides a bug |
| **Hyrum's law** | whatever can be observed will be depended on | keep old interfaces when renaming, announce a break (`rules (discipline)`) |
| **Conway's law** | the structure of the system copies the structure of the team | one owner per module, clear folders; he is the one reviewer, so keep the review surface small |
| **Pareto (80/20)** | most of the value comes from a small part of the work | do the part that gives the result, list the rest in `questions.md` or the roadmap |
| **Occam's razor** | the simplest explanation first | the first hypothesis in debugging is the dull one (`code (thinking)`, Sherlock) |
| **Boy Scout rule** | leave the code a little better than found | a small cleanup in the file being touched, in its own commit |
| **Strangler fig / expand and contract** | replace a part step by step behind the old interface | database migrations (`code (saas)`), caveutils renames that must not break userland |

### "X over Y": his standing preferences

When two ways both work, take the left one. Each has its own detail elsewhere.

| Prefer | Over | Why, and where |
|---|---|---|
| **composition** | inheritance | small pieces put together, a function takes what it needs (`code (languages)`) |
| **arena** | malloc | things that share a lifetime are freed in one step, no per-object bookkeeping, no leak; a pool for fixed-size objects, an own allocator when the access pattern needs it (`code (languages)`) |
| **flat data and indices** | pointer graphs | contiguous arrays, handles with generations, cache-friendly and trivially serializable (`code (languages)`) |
| **data tables and generators** | repeated code | one table, one loop; factory and combinator composition by default |
| **a real run** | a claim | `code (done)`: seen to fail first, then pass; no "should work" |
| **the CLI or REST API** | an MCP server | `cli-everything` |
| **text and plain files** | opaque formats | readable, diffable, greppable; TSV and JSON lines for data |
| **SQLite** | a database server | one file, backed up with a copy (`code (saas)`) |
| **a static binary** | a runtime and its packages | one file to ship (`ship-anything`) |
| **the standard library** | a dependency | then a well-known package; in C own code over a library (`rules (zero-cost)`) |
| **grep and an outline** | reading the whole file | `code (reading)` |
| **trash** | rm | nothing is deleted (`rules (trash-not-rm)`) |
| **an exit code** | a printed verdict | scripts and tools are checked by their status |
| **small commits** | one big commit | easy to review and to revert |
| **boring and proven** | new and clever | the tool still there in ten years |

### Using them

- Pick the technique that answers the situation, name it in one line when it explains a choice, and move on. A
  list of names in a reply is filler.
- Techniques are advice, his rules win: `rules` (never delete, push only when told, prove it) and an explicit request
  override any of them.
- A new technique that proves itself in a session goes in this table with its place in his work, not in a new file.

## YAGNI, Sherlock, rubber duck

### YAGNI

Before building: what is the smallest thing that does the core job? Every mode, option, provider, config key, plugin
point and "for later" layer must be justified by something he asked for or something that breaks without it. Name the
cut in one line ("skipped X - add it when Y"). A feature that is not needed is not lazy to skip, it is free. The full
ladder is in `code (ponytail)`; ultra level questions the request itself.

### Sherlock

For an unknown cause, an intermittent failure, a regression:
1. Observe before theorizing. Separate the observed symptom (exact error, exact output, exact time) from the inferred
   cause. Collect: inputs, state changes, ownership boundaries, the failure output, what changed recently (`git log`,
   `git diff`, package updates, his own parallel edits).
2. List hypotheses, rank them by evidence and by how cheaply each can be falsified. Test the cheapest decisive one
   first: one variable at a time.
3. Eliminate. "When you have eliminated the impossible, whatever remains" - but only what was actually tested is
   eliminated. Instance contention is a classic impostor: two Godot editors on one project looked like a code bug.
4. No edit until one mechanism explains all the evidence. Then the fix (`code (ponytail)`, surgical patch) and the proof.
5. Stop exploring once the cause or the exact blocker can be named. Report the cause and the proof.
Tools for the evidence: `code (debug)`.

### Rubber duck

Stuck, or about to ask him: explain the problem in plain words first - expected, actual, what I assume and why. Walk
the code path line by line as if he had never seen it, saying what each step receives and returns. The gap usually
shows up at the line I can't explain. If it doesn't, the explanation becomes the question: three lines, the options,
my default.
