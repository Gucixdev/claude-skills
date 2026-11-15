---
name: automate-everything
description: A repeated action becomes a script at once, never a terminal one-off - a script can be re-run and changed, a typed command cannot. Parameters instead of hardcoded values, prints the answer not the data, idempotent, header as help; the real capability built as a command from the start; bulk edits through grep and sed plus the project check. Use whenever a step is done twice, a task has more than one step, or a lookup repeats.
metadata:
  priority: "1"
  tags: "#automation #scripts #bash #workflow #tokens #dev"
  requires: "skill:bash-everything skill:scrape-everything"
---

# automate-everything

The user's rule (2026-11-14): repeatable actions go straight into a script, not into the terminal - a script can always be
run again and changed. The terminal is for trying; the second time it is a script.

- A check typed once is fine. Needed again, or over about 10 lines: it becomes a file - the repo's own `scripts/` or
  `bin/` when it belongs to the project, else the scratchpad - not another heredoc. Look for an existing one first; if
  one almost fits, add a parameter instead of writing a second.
- Inputs are parameters: no hardcoded paths, ids, ports or dates. It prints the answer, not the data: filter, count
  and truncate inside. Exit 0 on success, non-zero with the error on failure. Safe to re-run: no prompts, idempotent,
  cleans up after itself. A header comment: what it does, parameters, side effects, one example. Scripts call each
  other instead of copying code.
- Build the block, not the scratch file: when the work is a real capability (a merge, a scan, a conversion the user will run
  again), write it as a command or a function with a clean signature from the start - four throwaway
  `build_v1..v4.py` files are what the alternative looks like.
- The same lookup over and over (a dozen similar checks, a rename across files): write the loop once instead of a dozen
  tool calls: build the small tool right away.

## Bulk edits

Renames and include-path changes across a tree: `grep -rlE OLD | xargs sed -i -E 's/OLD/NEW/g'`, then diff-review and
run the project's own check (instead of one Edit per file). Two traps seen: a dedupe
pass that strips a deliberate second `#include` (implementation re-entry), and duplicate basenames shadowing each
other under a flat `-I` - run the project's `check` after every move, not only the tests.

## Not adopted, on purpose

The `caveman-blocks` binary and its pre-run hook.
