---
name: code
description: How code is written - a C manifest and data-oriented design (arenas, pools, flat data, C89), which language for which job, build less (the ponytail ladder, audits, debt, reviews), YAGNI, Sherlock and rubber duck thinking. Use for every code or config change, a language choice, a refactor or a review.
metadata:
  priority: "1"
  tags: "#dev #c #c89 #dod #performance #memory #bash #emacs #rust #go #mojo #architecture #code #python #perl #elisp #lisp #typescript #ruby #rails #thirdparties #ponytail #yagni #thinking #debugging #investigation"
  requires: ""
---

# code

Write less, in the user's style. Pick the part by the task.

<!-- digest -->

## Parts

Read the part when the task matches.

- [ponytail](references/ponytail.md) - Build less - the lazy senior developer's ladder (does it need to exist, reuse, stdlib, installed dependency, one line, minimum code), the rules for the change itself and what is never cut; levels lite, full, ultra. Also in the file - the four change modes (surgical patch, safe refactor, lean build, migration), review of a diff as a report (Must fix, Should fix, Nice to have), whole-repo audit, the shortcut-debt ledger. Use for every code or config change, a review, an audit or "what was simplified".
- [languages](references/languages.md) - Which language for which job (a default table: bash with fallbacks, Python as composable blocks, C vs Rust, Go for web, Lean 4, GDScript, Perl, Elisp, TypeScript, Ruby on Rails), the per-language engineering preferences (strict manual memory in C, always reach for a library in Rust/Go/Python, composition over inheritance, the `run` convention), and data-oriented design with a C manifest (flat arrays, arenas, SoA, no recursion, unity builds, C89, zero dependencies). Use when picking a language, writing code in one, or designing data structures or performance-sensitive code.
- [thinking](references/thinking.md) - The working principles in one table (kaizen, muda, poka-yoke, jidoka, andon, genchi genbutsu, kanban, 5S, shu-ha-ri, YAGNI, KISS, DRY and the rule of three, Unix philosophy, Chesterton's fence, Gall's law, fail fast, Hyrum's and Conway's laws) plus three thinking tools - YAGNI, Sherlock (investigate from evidence, rank hypotheses, no fix until one mechanism explains everything), rubber duck. Use when choosing between approaches, for any bug with an unknown cause, a stuck problem, or before asking the user a question.
