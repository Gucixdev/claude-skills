---
name: seed
description: "Start a new project or skill from a GitHub repo as a seed - shallow clone with no history, renamed, with his conventions (README Origin section, ./test, ./install, MIT licence beside the upstream one); refuses copyleft and unlicensed code. Runs scripts/seed. Use for seed, ziarno, zaloz projekt z repo, start from this repo, fork without history, clone and rename, template from github, skill from a repo."
metadata:
  priority: "2"
  tags: "#scaffold #github #license #skills #dev"
  requires: "skill:conventions skill:which-license skill:publish-anything cmd:git cmd:perl cmd:tar"
---

# seed

A repo he likes becomes the first commit of his own project. `scripts/seed` does the mechanical part, the rest
(what to keep, what the README says) is mine.

```sh
seed [-s] [-f] [-d DIR] SOURCE NAME     # SOURCE: owner/repo, a git URL, a local repo; SOURCE//path = one folder
seed -s Gucixdev/claude-skills//skills/nonconformist mycritic     # a skill as the seed
```

## What it does, in order

1. **Licence first**, before anything is created (`which-license`): MIT, BSD, ISC, 0BSD, Unlicense - go on. Apache-2.0
   stays Apache-2.0 (LICENSE as it is, NOTICE with the changes), it is not relicensed. Copyleft (GPL, AGPL, LGPL, MPL,
   EPL), an unrecognised text or no licence file at all - refused: no licence means all rights reserved, copyleft would
   put his project under it. `-f` seeds copyleft or unknown anyway and keeps the upstream licence untouched; use it only
   when he said so.
2. `git clone --depth 1`, copy without `.git`, so no history and no upstream remote. `//path` takes one folder.
3. **Rename** the old name (repo or folder name, for a skill the `name:` in SKILL.md) in file names and contents, in
   six spellings (`foo`, `Foo`, `FOO`, and `foo_bar` forms of `foo-bar`). It is a substring replace, so `foolib`
   becomes `newlib`. Left alone: LICENSE/NOTICE/COPYING files and URLs inside files (they point at the original).
4. **LICENSE**: his MIT on top, the upstream text below it, so the upstream notice is kept (MIT requires it). Holder is
   `$SEED_HOLDER`, else `git config user.name`.
5. **README**: an `## Origin` section (upstream, commit, rename, licence); a README is created with a TODO line when the
   seed had none. **`./test` and `./install`** are written from what the project has (`make test|install`, cargo, go,
   npm, bats, pytest), never overwriting the seed's own; with nothing to run they say so and exit 1, on purpose, so a
   green status never means "nothing was checked". A Makefile gets `.PHONY: test` so that `./test` next to a `test:` target works.
6. `git init`, **one commit** `feat: seed from NAME@sha`. Nothing is pushed (`rules`: push only when told).
7. For `-s`: SKILL.md gets `name: NEW` and `metadata.upstream: "repo@sha"` (the header standard of `skill-everything`);
   then `bin/skills check`.

## What I do after it ran

- Read the README Origin and the result of `./test` - run it, the seed may not build here.
- The rename is blind: grep the new tree for leftovers that still make sense only for the old project (author names,
  product names that are not the repo name, a hard-coded path), and for wrong substring hits.
- Run `publish-check` before the first push (the seed may carry the original author's e-mail in files; that is theirs and
  stays, but nothing of his own should be in there that he did not mean to publish).
- A real project needs more than the seed: write the README's one paragraph, then `distribute-everything` for the
  entry scripts (`run`, `check`).

## Limits

Does not understand a project's build, only renames text; a seed with generated code that embeds the name in hashes or
binary files is wrong after the rename (binary files are skipped). Tests: `tests/seed.bats` (11, with a local git
repo as the upstream); also run once against a real GitHub repo (Cargo project: `./test` and `./install` became
`cargo test` and `cargo install`; the project itself was not built).
