---
name: conventions
description: The conventions every repo and piece of text follows - Conventional Commits and attribution, git and GitHub rules (push only when told, no history rewriting, identity scan), README and per-folder README shape, how docs are worded, man pages and changelogs, e-mail. Use for every commit, push, PR, README, doc, comment or e-mail.
metadata:
  priority: "1"
  tags: "#conventions #commits #readme #docs #email #git #writing #dev"
  requires: ""
---

# conventions

The standard forms, decided once. Procedure for each form is in the part; this page only says which part applies.

| Writing | Part |
| --- | --- |
| a commit message, a PR title | [commits](references/commits.md) |
| a README, a README for a standalone folder | [readme](references/readme.md) |
| any text that stays: docs, comments, PR and issue text, notes | [docs](references/docs.md) |
| an e-mail, an author address | [email](references/email.md) |

Everywhere: conventional, not creative. The reader should be able to predict where a thing is and how it is phrased.

- Who commits as whom, and the push rules: `rules (identity)`, `rules (discipline)`. An empty or placeholder
  project is not pushed; check what a push contains before it goes.
- The man page, `--help`, changelog and keeping docs in step with code: `conventions (doc)`.
- Chat replies are `leanctx (caveman)`; this skill is for text that stays.
- A repo's own CLAUDE.md or contributing guide overrides a part here for that repo.

## Parts

Read the part when the task matches.

- [doc](references/doc.md) - Documentation that stays true - README shape (what, build, run, real example output, principles, status, license), the header comment as --help and man page (manwriter), a README per standalone folder, changelog from Conventional Commits, docs kept in sync with code, toolchain volatility written down, client documents as Markdown plus PDF. Use when writing or updating any README, man page, changelog, guide or client document.
