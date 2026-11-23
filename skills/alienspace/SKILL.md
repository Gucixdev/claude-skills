---
name: alienspace
description: "Alienspace of science - search for topics that are logical but untouched by others: map a field, list the neighbours that should exist, check each against papers, code and products, and keep the ones that follow from known results yet have no work on them. Use for alienspace, alien space of science, nietkniete tematy, biala plama, co nikt nie zrobil, research gap, untouched topic, find an open problem, what is missing in the field."
metadata:
  priority: "2"
  tags: "#thinking #research #ideas"
  requires: "skill:nonconformist skill:decide ?skill:scrape-everything"
---

# alienspace

The space of ideas that follow from what is known but that nobody walked into yet. Not "weird for its own sake": a
topic counts only when it is **logical** (a reason it should exist) and **untouched** (a search finds nothing close).
It is what he does anyway - a lossless model compressor, a bash shell inside a desktop, a vector index with proofs -
so the pass below makes it a method and not luck. Pairs with nonconformist (that one questions a plan, this one finds the topic).

## The pass (written down, one page)
1. **Field and edge.** One line: the field, and where its edge is (what the newest results do, what the textbooks stop at).
2. **Neighbours.** List what should exist next to the known things, by four moves:
   - *combine* two results that are never seen together (A's method on B's data, A's proof tool on B's code);
   - *invert* a known result (compress a thing that is always expanded, prove what is only tested, remove what is always added);
   - *transfer* a method from a far field with the same shape (scheduling -> memory allocation, type theory -> config files);
   - *lift a limit*: a constraint everyone keeps (float32, one machine, online only, a GPU) and what stands if it goes.
   Aim for 20 neighbours, no judging yet.
3. **Logical?** For each: the reason it should exist - a known result it follows from, a need that shows it, or a number
   that suggests it. No reason, no entry. Say how sure (low / medium / high).
4. **Untouched?** Check in this order, cheapest first, and write the query and the count next to the entry:
   - his own graph and repos first (graphify query, `rg` in the repos) - it may be half done already;
   - papers (arXiv, Semantic Scholar, Google Scholar title search with two phrasings, one with the words swapped for synonyms);
   - code (GitHub search, package registries), then products and forums.
   A hit that does the same thing kills the entry; a hit that does a neighbour only moves the entry ("prior art: X, differs by Y").
   Zero hits on one phrasing is not untouched: try the field's other name for the thing first.
5. **Why untouched?** The honest reasons: nobody saw it (good), it is hard (check the cost), it is useless (check the use),
   it was tried and failed quietly (search "negative result", "we tried", old forums), or it is called something else.
   Keep an entry only when it is the first or the second.
6. **Cheapest test.** For each survivor, the smallest experiment, proof or prototype that shows it works or does not
   (an hour to a day), with a stop condition. Prefer the test that gives a number.
7. **Pick.** At most three survivors, ranked by (logic strength x how untouched x cost to test, low cost wins). One
   goes to todo.md as a line; the unsure ones that need his taste go to questions.md with a recommendation (see decide).

## Output (a note, `alienspace/FIELD.md` in the repo it belongs to, or in the reply when it is short)
A table: `neighbour | reason | sure | queries -> hits | prior art | why untouched | test`. Under it: the three picks
and the one that goes first. Say which searches were not possible (paywall, no network) instead of guessing.

## Rules
- Never claim "nobody did this" - say "no hit in N searches (list them) on DATE". Absence of evidence is dated.
- A topic with a large market and zero work is usually dead; check why before building.
- Do not call a rename "untouched". Same idea in other words is prior art.
- Private ideas stay out of web queries: search the generic terms, not the project's name or his words.
- Free sources and his own graph before paid ones; keep raw search results next to the note (scrape-everything).
