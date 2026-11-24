# whiteboard-programming (AMPL)

His decision (2026-11-23): AMPL joins whiteboard programming and "minmax it" as a standard for maximum optimization,
next to Lean 4. Final code stays C or Rust (availability), Go/Python or bash where the ecosystem asks; AMPL is **only
maths, logic and optimization**, never shipped code. It is a check that the design is right, one more technique
beside Lean, differential tests and benchmarks.

## What it is for

AMPL states an optimization problem the way it is written on the whiteboard: sets, parameters, variables, an
objective, constraints. A solver then finds the optimum or proves there is none better. Use it when the question is
"what is the best choice under these limits", not "is this code equal to its spec" (that is Lean).

| Project piece | AMPL question | Shape |
|---|---|---|
| ergokeys | best key-to-slot layout for finger cost, hand balance, reach | assignment (letters x slots); real bigram cost is quadratic assignment, so a MIP over a linearised form or a small instance as the oracle for the heuristic |
| arenas, pools | size classes, page size, slab counts that minimise waste or fragmentation for a measured size histogram | integer program over class sizes, objective = expected waste bytes |
| devframework | which checks, benches or builds to run in a time budget | knapsack / set cover |
| data layout | field order and padding for the smallest struct that keeps every alignment | small ordering problem, proves a hand layout is optimal or not |
| SIMD / threads | lane split, chunk size, thread count under a cost model | integer program on measured costs |
| "minmax it" | the axes he names (see `code` part ponytail) as objective and constraints | one objective, the other axes as constraints |

## How it fits the order

`scope, layout, proof, code, close` gets one more step between layout and code, **numbers**:

1. In `docs/DESIGN.md` the Limits table is the parameter list: every number is measured or marked assumed.
2. `ampl/` at the project root: `NAME.mod` (model), `NAME.dat` (measured data, printed by a script, never typed twice),
   `run` (solve, print the optimum, exit nonzero if the shipped constant differs from it).
3. The result is held against what the C does: the optimum goes into the generated header like Lean's `layout.h`, or
   the C constant is checked against it. A heuristic in C (ergokeys' search) is compared with the AMPL optimum on small
   instances; the gap is the number reported.
4. A solver answer is a proof only for the model as written. State the model's assumptions; a wrong cost model gives a
   perfectly optimal wrong answer. Lean says code = spec, AMPL says spec = best, benchmarks say it is fast.

## Template (assignment: letters to key slots)

```
set LETTERS;
set SLOTS;
param freq{LETTERS} >= 0;        # measured from the corpus
param cost{SLOTS}   >= 0;        # finger effort per slot

var x{LETTERS, SLOTS} binary;

minimize effort: sum{l in LETTERS, s in SLOTS} freq[l] * cost[s] * x[l,s];

s.t. one_slot{l in LETTERS}:   sum{s in SLOTS} x[l,s] = 1;
s.t. one_letter{s in SLOTS}:   sum{l in LETTERS} x[l,s] <= 1;
```

```
option solver highs;     # an open-source solver
solve;
display effort, {l in LETTERS, s in SLOTS: x[l,s] > 0.5} x[l,s];
```

## Tooling and status

- Installed 2026-11-23: `~/.local/share/ampl` (venv, `amplpy` + modules base, highs, cbc, 79 MB), run with
  `ampl-run file.run` (wrapper in `~/.local/bin` that puts the modules on PATH). The template above was run with HiGHS
  and gave the optimum (effort 54 on a 3-letter toy). `glpsol`, `scip` are not installed. `z3` is, and fits the logic
  side (does any assignment satisfy these constraints).
- Licence, as far as it was read (https://ampl.com/ce/, 2026-11-23): the AMPL engine is proprietary; `amplpy` itself is
  BSD-3. Community Edition is free, does not expire, has no model-size limit with the open-source solvers, and is "designed
  for personal learning, experimentation, and commercial prototyping". NOT stated on that page: redistribution of the
  binaries, and design-time-only use. The EULA was not found, so those two are unknown.
- The engine ran here without a registered licence. Whether that is a demo mode with limits is NOT checked; register the
  free Community Edition licence at https://portal.ampl.com/user/ampl/request/amplce/new (needs his account) and activate it
  with `python -m amplpy.modules activate <uuid>` in the venv.
- Rules that keep it clean: never commit the AMPL binaries or the licence UUID to a repo (public repos hold only
  `.mod`, `.dat`, `run`); never ship it in a product; keep the licence note in the project (`which-license`).
- Free fallbacks that read nearly the same model: GLPK's `glpsol --math` (GMPL is a subset of AMPL), HiGHS or OR-Tools
  from Python. A model written in the common subset moves between them.
