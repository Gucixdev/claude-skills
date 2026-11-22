---
name: whiteboard-programming
description: Design before the keyboard - documentation first (describe every feature, close the scope) or proofs first (memory layout and invariants as Lean 4, then C), so risky optimizations become safe. Use when starting a project, designing a data structure, file format or interface, before a hard optimization, or on whiteboard, tablica, dowody najpierw, uklad pamieci.
metadata:
  priority: "1"
  tags: "#dev #design #architecture #lean4 #formal #memory #performance #docs #c #dod #workflow"
  requires: "skill:code ?cmd:lake"
---

# whiteboard-programming

His rule (2026-11-15): first proofs in Lean, only then code; or start from the documentation - a precise description of
every feature, decide what is needed and what is not, and close projects that way. The keyboard comes last. Two doors,
one order: **scope, layout, proof, code, close.**

<!-- digest -->

## 1. Scope (door one: documentation first)

Write `docs/DESIGN.md` before any code. One page, these parts, nothing more:

- **Purpose** in two lines, and who runs it (him, a client, an agent).
- **Features table**: one row per feature - what exactly it does (inputs, outputs, errors, the number that bounds it),
  and a verdict `need` / `maybe` / `no`. Only `need` rows are built. `maybe` rows get the cheapest check that would
  promote or kill them. `no` rows stay in the table with the reason, so the question is not asked again.
- **Interfaces**: every call, file format and command with a worked example. If an example cannot be written, the
  feature is not understood yet.
- **Limits**: sizes, counts, latency, memory as numbers (a 4 GB VRAM box, 100k rows, one file).
- **Done**: the list of checks that make the project closed. A project with no `Done` list never ends.

Then close the scope: a feature that is not in the table does not get code. New ideas go to `braindump.md`
(`workflow` part braindump), not into the build. Brainstorm options when two designs fit (`workflow` part brainstorm).

## 2. Layout (door two begins here)

Before writing a struct, write its memory layout as a table in `docs/LAYOUT.md`: field, offset, size, alignment,
the invariant it carries (sorted, unique, nonzero, < capacity). Flat records, fixed width, arena or pool owned
(`code` part languages: data-oriented design).

**The payoff is shared layout.** When two record types start with the same header (id, created, flags, same
stride, same alignment), generic code works on both with no conversion and no copy:

- a database and a tree: the tree API takes a descriptor `(base, stride, key_offset, key_len)` and the database hands
  it the users array or the posts array as it is, the same pages, the same arena, `memcpy` rows between them;
- an index over any table, a sort, a bulk load, a checksum, a snapshot: one routine, many tables;
- moving a row from one structure to another is a pointer move, not serialize and parse.

That only holds if the layouts really are equal, so the equality is a theorem and a build check, not a hope.
If two types look alike but differ in one field, decide on paper: make them equal, or keep two APIs.

## 3. Proof (Lean 4, `code` part lean4)

`lean4/` at the project root. In this order:

1. **Layout model**: a Lean structure for each record (fields with offset, size, align). Theorems: fields do not
   overlap, everything is in bounds, `size` is a multiple of `align`, and for the shared-layout trick
   `prefixEq users posts` (same header offsets and stride).
2. **Reference spec**: the obviously correct, slow version of each operation (insert, lookup, range, delete) over a
   list or a map.
3. **Optimized model**: the real algorithm (bit tricks, branchless select, unchecked indexing, reordered integer sums),
   proved equal to the spec, and the invariants proved preserved (sortedness, no duplicate keys, count <= capacity).
4. **Numbers out**: the sizes and offsets are printed by a Lean program into a generated header
   (`layout.h`), never typed twice. The C includes it and adds `_Static_assert`-style checks (C89: the negative-array
   typedef trick) that the compiler's `offsetof`/`sizeof` equal the Lean numbers.

Prove what **unlocks something**: a removed bounds check, an unchecked cast, two types sharing one routine, a SIMD
lane split, a lock-free step. Glue, UI and I/O get tests instead. No `sorry`, no `native_decide` in the audit. Say
which links of the chain are proved (spec = model) and which are tested (model = C, by the differential test on every
input where the domain is finite, seeded random elsewhere). Time-box a proof; a proof that does not close in a session
is a signal the design is too clever - simplify the layout, not the theorem.

## 4. Code

C89 from the model, step for step (`code`). The oracle executable from the same Lean definitions is diffed against the
real C. Benchmark with `code` part bench; a proof says equal, never faster, so keep the number next to the claim.

## 5. Close

Closed means: every `need` row has a test, every claimed optimization has a proof or a differential test and a
benchmark, README and `docs/DESIGN.md` say what the code does (`conventions`), `Done` list ticked, `no` rows still in
the table. Leftover ideas are in the braindump, not half-built in `src/`.

## Order when time is short

Scope always. Layout always (it is a table, minutes). Proof only where an optimization depends on it. Never code
first and document after: the doc is how the code gets small.
