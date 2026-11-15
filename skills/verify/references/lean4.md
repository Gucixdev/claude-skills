# verify (lean4)

For a user who wants proof that a project works both logically and technically. The reference shape is a project's
`lean4/` folder with a few hundred theorems about a store's integrity math, CRC-32C, fast-scan kernels, codes, a rotation
and a top-k insertion, and a `run` script that holds the C code to them.

## The standard

Lean 4 is the verification and proof language (chosen over Frama-C, which needs annotations in the C itself); the aim is
optimization that can go very far because equality is checked by machine. End-to-end tests in Python stay Python.

- Every project gets `lean4/` at its root, never one per subfolder. A small init script (`leaninit PROJECT`) can start it:
  core Lean 4.26 without Mathlib (builds in seconds), the module-based audit, a `run` with build, audit and source
  scan. Mathlib goes into `lakefile.lean` only when a proof needs it.
- The optimization loop: a plain Lean reference that is obviously right (the spec); the optimized algorithm modelled
  in Lean and proved equal to it (bit tricks, tables, SIMD lane splits, branchless selects, reordered exact integer
  sums); the C held to that model by the differential test, on every input where the domain is finite; the speed
  measured with `verify (bench)`. A proof says equal, never faster. With equality checked by machine, the C can be pushed as
  far as the hardware allows.

## What "proved" means for C code

A theorem about a Lean definition says nothing about C by itself. Build the whole chain and say which links are
proved and which are tested:

1. **Model.** One Lean definition per C function, step for step; the file's header names the C function and the C
   file. Constants come from the C tables as literals printed by a program, never typed by hand (a hand-typed GF log
   table was wrong), with `logTab = logLit` by `decide +kernel`.
2. **Theorems** on the model: the property the C code exists for (the parity rebuilds any m damaged blocks, the SIMD
   trick equals the scalar sum, no 16-bit sum wraps, the top-k array is the k best), not restatements of the code.
3. **Axiom audit** (`Audit.lean`, run by `lake env lean Audit.lean`): every theorem constant whose defining module
   is the project's (`env.getModuleIdxFor?`, `env.header.moduleNames`), `collectAxioms` on each, only `propext`,
   `Classical.choice` and `Quot.sound` allowed. Select by module, not by name prefix: the name filter missed 66 of 558
   theorems (TrustLean equation lemmas generated in our modules, private match equations) and a planted
   root-namespace `sorry`. Count written theorems (`findDeclarationRanges?` is some) apart from generated ones. Plant a
   `sorry` and a `native_decide` once and see the audit fail. Add a source grep for sorry, admit, native_decide,
   bv_decide and axiom.
4. **Oracle against the C code.** A `lean_exe` runs the very definitions the theorems are about; a C89 harness
   `#include`s the project's unity `.c`, so static functions are callable; `cmp` the two outputs. Every input where
   the domain is finite (all 65,536 GF(2^8) products), ranges or grids where it is not - labelled as such, a grid
   printed as "every input" was an overclaim - and seeded random cases (seed in the output) for the rest. Build the C
   side once per `-march` (native, haswell, x86-64) so every SIMD path and every compile-time dispatch
   (`__SSE4_2__`) meets the same oracle.
5. **Floats.** Prove sums and rotations over a field; the C adds in f32, so compare it with a double-precision
   computation within a tolerance and say so - never claim bit equality there.
6. **C-only properties** where a Lean oracle is overkill: the store end to end (write files, damage up to m blocks
   per group, expect byte-for-byte recovery; m + 1 must be reported, not passed off as rebuilt).
7. **Mutation test** (`mutants`): each mutant is one `sed` on a `mktemp -d` copy of `src/`; the step that covers the
   kernel must fail. A survivor is a finding - unreachable code or a hole in the test - and stays listed with its
   reason (for example the row swap of a GF matrix inversion, never reached because Cauchy matrices have nonzero leading minors).
   Separate the fields with `@`, since C has `|`, and write `||` as `[|][|]` in the sed regex.
8. **One `run`**: build, audit, source scan, regenerated files compared with the committed ones, the diff per arch,
   the properties, a summary table, exit non-zero on any failure; hook it into the project's own `./run`.

A system test that checks a limit (a run of m G damaged blocks rebuilt, m G + 1 refused) gets that limit proved as a
small corollary (`burst_within_parity`, `burst_beyond_parity` from `layout_burst`) and cites it: the theorem is the
test's prediction, and the test checks it on real files (`tests/battle_damage.c`).

What stays trusted goes into the README in one paragraph: Lean's kernel, the Lean compiler (it builds the oracle),
gcc, libc, and the model-to-C step, which is tested, not proved.

## Toolchain

- Pin `lean-toolchain` and the Mathlib tag to the same release (`leanprover/lean4:v4.26.0`, Mathlib `v4.26.0`), the
  other libraries by commit (`require X from git "URL" @ "COMMIT"`), and `autoImplicit := false`.
- On a normal machine: `lake exe cache get` first; it fetches Mathlib's `.olean` files.
- Cloud session (checked 2026-11): the proxy refuses releases.lean-lang.org and every Mathlib cache host
  (lakecache.blob.core.windows.net, mathlib4.lean-cache.cloud, the R2 bucket); github.com works. Install elan from its
  GitHub release, take the toolchain asset `lean-VERSION-linux.zip` or `.tar.zst` from
  github.com/leanprover/lean4/releases, unpack it to `~/.elan/toolchains/lean-VERSION-linux` and link it as
  `leanprover--lean4---vVERSION`. Mathlib then compiles locally: about 1,400 modules with its dependencies, about 30
  minutes on 2 vCPUs, so start `lake build` in the background first and write the C harness meanwhile.

## Proof gotchas (Lean 4.26, Mathlib v4.26.0)

- Finite facts: `decide +kernel`. Plain `decide` on a 256-entry table stops with "maximum recursion depth has been
  reached". Never `native_decide` or `bv_decide` - they add `Lean.ofReduceBool` and `Lean.trustCompiler`, so the
  proof trusts the compiler.
- `rfl` stops the same way on a 512-entry table definition (`expTab.length = 512`). Prove a few `decide +kernel`
  facts about the table once and rewrite with them (`simp only`, structured `rw`).
- Names and signatures drift between Mathlib versions; find the current one (`rg` in `.lake/packages/mathlib`,
  `#check`, `exact?`) before trusting memory. At v4.26.0 `Finset.card_le_card_of_injOn` takes a `Set.MapsTo`.
- Prefer core when it has the lemmas: `Nat.log2` with `Nat.log2_self_le` instead of Mathlib's `Nat.log`, whose
  module (`Mathlib.Data.Nat.Log`) the rest of the project did not need, so it was one more module to build.
- A core-only project's `Audit.lean` needs `import Lean` (Mathlib brings it in otherwise; without it: "unknown
  namespace `Command`").
- Bit tricks on `Nat` in core 4.26: `Nat.shiftLeft_eq` (`a <<< b = a * 2 ^ b`), `Nat.shiftRight_eq_div_pow`,
  `Nat.and_two_pow_sub_one_eq_mod`, `Nat.two_pow_add_eq_or_of_lt` (an OR of disjoint fields is a sum),
  `Nat.or_lt_two_pow`, `Nat.shiftLeft_or_distrib`; byte-sized facts by `decide +kernel`, div and mod by literals by
  `omega`.
- `Equiv.Perm` multiplication composes right to left (`(σ * τ) x = σ (τ x)`); write `Equiv.trans` when order matters.

## TrustLean and AMO-Lean

- **TrustLean** (MIT per its README, no LICENSE file): MicroC, a small C subset with u32 semantics
  (`evalMicroC_uint32`) and a printer (`microCToString`). Write a kernel as MicroC, prove that its evaluation is the
  model, print it to `gen/*.c`, commit that file, make `run` fail when the printed text changes, and diff the printed
  kernel against the hand-written C on every input: a second implementation tied to the specification by a proof. Its
  printer-parser round trip (`TrustLean/MicroC/RoundtripExpr.lean`) does not build at aaf67f6 on 4.26.0 (missing
  cases for the cast operators), so do not depend on `master_roundtrip`.
- **AMO-Lean** (MIT): `AmoLean.Matrix.strideIndex` with `strideIndex_lt` and `stride_inverse_eq` - the stride
  permutation, which is what a column-major SIMD block layout is. It declares 8 axioms (Radix-4 NTT): import only the
  module needed (`AmoLean.Matrix.Perm`) and let the audit show none leaks in.
- Both use `native_decide` hundreds of times; harmless while no audited theorem depends on those lemmas.

## The README of a proof folder

The chain above with what is proved, tested and trusted; how to run; the real summary output with machine and date;
a table of C function, Lean file and theorem; findings (unreachable code, values never read, preconditions callers
must keep, upstream breakage); what is not covered; the libraries' licenses (fetched by lake, not vendored).
