---
name: which-license
description: Pick a licence for his code and judge the licence of code he wants to reuse - MIT by default for maximum integration, 0BSD/Unlicense or MIT-or-public-domain for stb-style headers, Apache-2.0 only for the patent grant, GPL kept out of the tree. Use for LICENSE, SPDX, copyright, can I copy this code, fork, dwl/GPL, MIT, Apache, pizzaware.
metadata:
  priority: "2"
  tags: "#license #legal #publish #thirdparties #dev"
  requires: "skill:publish-anything skill:rules ?cmd:reuse"
---

# which-license

Not legal advice; I say how sure I am and name the file to read to confirm. His wish (2026-11-15): the most
integration possible, mostly MIT, GPL 2/3 avoided, Apache maybe, joke licences like pizzaware asked about.

## For his own code

| Case | Licence | Why |
|---|---|---|
| Default for any repo | MIT | everyone can use it, short, compatible with nearly everything |
| stb-style single-file header (holyc) | MIT, or "MIT or public domain" (Unlicense) like stb | people paste one file; public domain removes even the notice |
| Tiny snippet, no attribution wanted | 0BSD or Unlicense | no notice duty at all |
| A bigger library where users or firms fear patents | Apache-2.0 | explicit patent grant; adds NOTICE and "changed files" duties; not compatible with GPL-2.0-only |
| Wants changes to one library shared back, but usable in closed apps | MPL-2.0 (file-level) or LGPL | only if he ever wants that; not his default |
| Joke: pizzaware, beerware | MIT with the joke in the README | joke licences are not OSI-approved and lawyers/distros may refuse them; the README carries the pizza, LICENSE stays MIT |

Avoid for his own code: GPL-2.0/3.0 and AGPL (they force every user to the same terms and block MIT/Apache mixing).

## Code he wants to reuse (inbound)

- MIT, BSD, ISC, 0BSD, Zlib, Unlicense/CC0: copy freely into an MIT project; keep the copyright line and licence
  text (holyc keeps them in `THIRD_PARTY/` plus `THIRD_PARTY.md`).
- Apache-2.0: fine in an MIT/Apache project, keep NOTICE; makes the combined work effectively Apache-governed.
- GPL/AGPL/LGPL: do not copy or fork into an MIT tree; the whole result must then be GPL. Calling such a program as
  a separate process (CLI, socket) is fine. A fork of GPL code stays GPL: that is why forking dwl (GPLv3, check its
  `LICENSE`) blocks MIT; wlroots, sway and tinywl are MIT/permissive, so an own compositor built on wlroots can be MIT.
- No licence file means all rights reserved: do not copy it, ask or write it from scratch (`rea` for the idea only).
- Clean-room: reimplement from the behaviour or spec, never from reading GPL source side by side.

## Doing it in a repo

1. `LICENSE` at the root with the full text; copyright line `Copyright (c) YEAR Gucixdev` (the handle, never a real name
   or e-mail, `publish-anything`).
2. One `SPDX-License-Identifier: MIT` line at the top of each source file (cheap, machine-readable); stb-style header:
   the licence block at the end like stb does.
3. `THIRD_PARTY.md`: every ported or vendored piece, its source URL, author and licence.
4. Before a push: `grep -rIL 'SPDX-License-Identifier' src` finds files without a tag; `reuse lint` if installed;
   `audit-everything` checks dependencies' licences.
5. Changing a licence later needs every contributor's consent: decide before the first outside pull request.

## When unsure

Contested or irreversible (relicensing a public repo, using GPL code): one line in `questions.md` through `decide`,
safe default meanwhile = do not copy it.
