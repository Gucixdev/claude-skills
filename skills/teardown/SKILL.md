---
name: teardown
description: "Take a product, app, site, repo or tool apart to learn how it is built, what it costs, how it earns and what is worth keeping - structure map, numbers, business model, a steal / avoid / gap verdict - and write it as one report before any rewrite. Use for teardown, rozbierz to, rozbior, how is X built, what is inside X, competitor analysis, analiza konkurencji, before cloning or vibemixing a program."
metadata:
  priority: "2"
  tags: "#thirdparties #research #design #dev #business"
  requires: "skill:rea skill:which-license ?cmd:rg ?cmd:tokei|cloc ?cmd:jq"
---

# teardown

A teardown answers one question about a thing that already exists: what is inside, and what do we take from it. It
ends in a report, not in code. The technical black-box work (formats, protocols, binaries) is `rea`; the choice of
what to build from the result is `workflow (vibemix)`; this skill is the walk in between.

## Order

1. **Question first.** One sentence: "what do I want to learn" (how it scales, how it looks and moves, how it
   earns, why people leave it). Without it a teardown is a tour. Write it at the top of the report.
2. **Public sources before anything else.** README, docs, changelog, pricing page, package manifest, release notes,
   store listing, issue tracker, the talk the author gave. Read the source of a repo only after the docs say where
   to look (`code (reading)`: search, then outline, then ranges).
3. **Map the structure.** Parts and how they talk: modules, processes, data stores, protocols, build steps. For a
   repo on this machine start from its graph (`graphify-sync REPO`, then `query_graph` / `god_nodes` with
   `project_path`), not from `ls`. One small diagram or one table; every box is something seen, not guessed.
4. **Put numbers on it.** Lines of code per language, dependency count, binary or bundle size, cold start, memory,
   build time, test count, release cadence. Measure on this machine when it can be run (`code (bench)`: median and
   spread); mark every number measured, read from a doc, or estimated (`rules (knows-unknowns)`).
5. **Business and people.** Who pays, for what, how much; licence; who maintains it and how many; what the 1-2 star
   reviews and open issues complain about (`paying-demand` for the review clustering).
6. **Decide.** Three lists, each item with its reason: **steal** (a technique worth reimplementing in our stack),
   **avoid** (a mistake we saw and can skip), **gap** (what it does not do that someone needs). Then one
   recommendation and the cheapest experiment that would prove it wrong.

## Rules

- Copy a technique, not the code: read the licence first (`which-license`); GPL is inspiration only, MIT or Apache
  is copied with the notice (`feedback_licence_copy_vs_inspire`).
- A teardown never touches the live thing: no scraping past robots.txt, no logging in with someone else's account,
  no running the binary outside a throwaway directory and temp HOME.
- Findings are claims with a source (file:line, URL, command and its output). A thing read in one place and
  contradicted in another is reported as both.
- Private or personal material found on the way stays out of the report.

## Report

One file, `NAME.md`, in the project's `references/` when it feeds a design (one file per subject), else in the
notes repo, never beside the code under teardown. Sections: Question, Structure, Numbers (table with the
measured / read / estimated column), Business, Steal, Avoid, Gap, Verdict. Short sentences; the verdict fits in
five lines.
