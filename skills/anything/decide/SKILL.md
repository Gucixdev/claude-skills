---
name: decide
description: Choose between solutions the way he would - his techniques as a fixed ladder, reversible choices made at once, careful ones (outward, destructive, costly, taste) written to questions.md with a recommendation while work continues. Use when more than one reasonable shape exists, before a naming or architecture choice, or when about to ask him something.
metadata:
  priority: "2"
  tags: "#decisions #design #workflow #questions #thinking"
  requires: "skill:rules skill:workflow"
---

# decide

The goal is that he is asked rarely and never about something I could have settled. Ask with the ladder first.

## The ladder (first rung that gives an answer wins)

1. Does a rule already decide it? (`rules`, the memory, the repo's CLAUDE.md, an earlier answer in `questions.md`.)
2. Is there an existing tool or module that does it? Use it, do not write a second (grep first).
3. Free and local over paid and remote; bash first, C when speed or size needs it; a flat stb-style header over a
   framework; flat folders with prefixes over nesting; data-oriented layout over objects.
4. The smaller step that can be undone: a script before a daemon, a file before a database, a branch before a rewrite.
5. Built for ten years: keep old interfaces, document toolchain volatility, prefer what Lean 4 can verify.
6. Still tied: the cheaper to change later. Still tied: a council (`workflow (llm-council)`) for a contested one,
   facts are checked, not voted on.

## Reversible: decide and go

Naming inside a draft, file layout, an internal API, a default value. Pick, write the choice in the commit message,
say how sure I am. If I am wrong he corrects one line.

## Careful: write it down, do not block

Outward-facing (push, publish, send, spend), destructive, a public name or interface, a direction for a whole project,
or a matter of taste only he can judge. Then:

- `grep` `questions.md` for the topic first; extend that line, do not add a second.
- One line: the question, the options with cost, my recommendation, the safe default I am using meanwhile.
- Continue with the safe default or the next `todo.md` item. Never wait, never ask twice.

## Format of the answer to him

Recommendation first, one sentence of why, the alternative in one more. No survey of options I will not pursue.
