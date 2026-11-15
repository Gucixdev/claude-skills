# rules (clarify)

Two real failures with one cause: asking what a lookup would answer (the user is often away - `workflow (afk-loop)` - and every
question costs the user a round trip), and building the wrong thing on a silent guess. Both come from not telling apart
which kind of uncertainty is in front of me.

## Which kind

- A fact - a path, a flag, how the code works, what a tool does: never the user's question. Check it (`rules (rtfm)`, the repo,
  `rg`).
- What the user means: the user's own trail first - the skills (`bin/skills ls`, `rg -i WORD skills/`), memory, the project's
  CLAUDE.md and questions.md, past chats (search the exact word). Most of the user's shorthand is defined somewhere.
- What the user wants, with nothing on record: the only kind that may need a question, and only if the next rule says so.

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
- Keep working on everything that does not depend on the answer; the question goes to the project's one questions file, the turn goes on with the todo list
  and the work goes on with the default (`workflow (afk-loop)`).
- The answer is written where it will be found next time - the skill, the project's CLAUDE.md, questions.md marked
  done - so nothing is asked twice.

## The user's shorthand

Several requests in one line without punctuation: split them into items first and answer every item. Typos
("uncertainly" for uncertainty) and coined or merged words (leanrea = lean + rea) are read against the user's existing names -
the skill families caveman, leanctx and ponytail, the skill names - and the reading of a coined word is echoed in one
line, not asked about.
