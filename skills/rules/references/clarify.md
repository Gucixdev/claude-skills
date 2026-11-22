# rules (clarify)

Two real failures with one cause: asking what a lookup would answer (he is often away - `workflow (afk-loop)` - and every
question costs him a round trip), and building the wrong thing on a silent guess. Both come from not telling apart
which kind of uncertainty is in front of me.

## Which kind

- A fact - a path, a flag, how the code works, what a tool does: never his question. Check it (`rules (rtfm)`, the repo,
  `rg`).
- What he means: his own trail first - the skills (`bin/skills ls`, `rg -i WORD skills/`), memory, the project's
  CLAUDE.md and questions.md, past chats (search the exact word). Most of his shorthand is defined somewhere.
- What he wants, with nothing on record: the only kind that may need a question, and only if the next rule says so.

## Ask or go

Ask only when all three hold:
1. the plausible readings lead to different work, not just different wording;
2. a wrong guess costs more than the question - expensive to redo, irreversible, public, or someone else's (the stop
   list in `workflow (afk-loop)`);
3. no reading is clearly the most likely (`rules (calibration)`: none at "likely" or above).

Otherwise go: take the most likely reading, state it in one line at the top of the reply or the report ("leanrea -
read as lean RE: least reading, early stop"), and keep it easy to redirect. Cheap-to-redo work - a draft, a skill, a
script - almost never needs a question.

## How to ask

- Early: before the expensive part, never after building on a guess.
- One message, at most three questions; each with concrete options, my default marked, and what changes with each
  answer - answerable with "1" or "ok". AskUserQuestion when the tool is there, otherwise the rubber-duck form
  (`code (thinking)`).
- `questions.md` is for architectural decisions only - the language of a system, its layout and boundaries, a public
  interface, a data or file format, anything costly to undo. Not for what has an obvious reading (take it, write the
  reading into the todo line, go) and not for routine permissions such as "push?" (his rule, 2026-11-19: "takie
  oczywiste rzeczy ... mozesz odrazu wpisywac do todo").
- Keep working on everything that does not depend on the answer; the question goes to the one questions.md (claude-config root), the turn goes on with todo.md
  and the work goes on with the default (`workflow (afk-loop)`).
- The answer is written where it will be found next time - the skill, the project's CLAUDE.md, questions.md marked
  done - so nothing is asked twice.

## His shorthand

Several requests in one line without punctuation: split them into items first and answer every item. Typos
("uncertainly" for uncertainty) and coined or merged words (leanrea = lean + rea) are read against his existing names -
the skill families caveman, leanctx and ponytail, the skill names - and the reading of a coined word is echoed in one
line, not asked about. The rest of how he talks is in `machine (personal)`.
