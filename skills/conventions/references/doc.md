# conventions (doc)

Docs are part of the code: a stale doc is a defect ("buduj to tak, aby można to było utrzymać i rozwijać przez
następne 10 lat").

## README

Shape, order and the folder rule: `conventions (readme)`. Wording: `conventions (docs)`.

## Three audiences, three places

Procedures for whoever works on the code (an agent or him): skills. Reference on how the thing is shaped (layout,
pipelines): `docs/`. How to use it: the README and a manual. omarchy splits them the same way (agents/skills, docs,
manual) so none of the three drifts into the others.

## Help and man pages

The header comment is the single source: `--help` prints it, his `manwriter -d man TOOL` turns it into a man page
(`name - description` becomes NAME, `@flag NAME:description` lines become OPTIONS). Change the header, regenerate.

## Changelog

From Conventional Commits: `git log --format='%s' vPREV..HEAD`, grouped by type (feat, fix, perf...), breaking changes
first. Removed things keep their history with a note - append and annotate, never scrub old entries.

## Keeping it true

After a change, grep the docs for what changed (names, flags, paths) and fix them in the same commit. A beta
toolchain (Mojo 1.0.0b2 broke builds within one tag several times) gets its volatility written down, with the advice
to rerun the whole suite and every example after an update.

## Client documents

Markdown source in the project folder; a PDF when it must look designed (HTML rendered through Playwright, `machine`),
the intermediate HTML not left behind; English for UK clients; no `[placeholders]`, no phone number as a contact.
