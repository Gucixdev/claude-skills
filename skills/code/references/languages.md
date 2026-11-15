# code (languages)

Which language for which job, how code is shaped in each, and the data-oriented C manifest. Three parts: the language table, per-language engineering preferences, data-oriented design.

## Which language for which job

### The table (a default; adjust it to the user)

Use a language as a tool, not a philosophy.

Values: atomicity, reliability, readability, impact. An explicit request always wins (the user has asked for a Rust CLI, a
batch of Go single-binary tools); the table is the fallback when the user doesn't say.

| Job | Language |
|---|---|
| Low-level work, performance, things worth owning for ten years (allocators, data layout, small libraries, kernels) | C89 (`code (languages)` (dod)) |
| Proofs about the optimized C and its algorithms: bounds, equivalence to a plain reference, invariants | Lean 4 (`verify (lean4)`) |
| Ecosystem-heavy work and quick MVPs where C makes no sense: wgpu and graphics, backends, tools built on good crates; often compiled to WASM for the web | Rust (see below) |
| AI/ML MVPs, quick automation, micro-tools, plugins, AI glue | Python |
| Quick one-liners on text and files | Perl (`perl -ne`, `-pe`, `-i`) |
| Glue, repeatable ops, build and test tooling | Bash |
| Web back ends, p2p, single-file stb-style programs for SaaS and CRUD, anything web; a CLI or TUI only when it serves a web thing | Go (see below) |
| Game logic inside Godot: scenes, nodes, UI, tools in the editor | GDScript (static types wherever they cost nothing; heavy loops go to a C library) |
| The web front | WASM as the main target (Rust or C compiled to it), TypeScript for the page and the glue around it, plain HTML/CSS first (`ui (webdev)`) |
| CRUD web apps | Go in one file first; Rails stays an option |
| Python syntax at C speed | Mojo |
| avoid by default | Java, JavaScript alone (TypeScript instead), Haskell |


### Bash

- POSIX `sh` when it costs nothing, bash when its features are needed; `fn() {...}` with tabs, like the user's `bash` repo.
- Every script degrades gracefully when an optional dependency is missing ("all scripts need to have fallback so it
  works everywhere no matter what").
- `shellcheck -S warning` clean, `set -u`, quoted expansions, `mktemp` plus `trap` for cleanup, `--help` from the
  header comment. Real mastery over cargo cult (Dave, YSAP). Single-file apps: `bash-everything`.

### Python

- Build composable blocks from the start: a CLI command or a function with a clean signature that can be chained, not
  a scratch script ("buduj sobie klocki").
- Real error handling in every module: validate inputs where they are used, raise a specific actionable message, not a
  bare KeyError from deep inside a library.
- Split a module into a package as soon as its scope divides; don't wait for it to sprawl.
- Standard library first (`unittest`, `argparse`, `json`, `urllib`), then a well-known package.

### When C and when Rust

- C when the point is to own the thing: memory layout, arenas and pools, a small library that must stay readable and
  buildable in ten years, a hot kernel, anything that gets a Lean proof.
- Rust is the C++ of the user's stack: take a good crate or a higher abstraction and ship faster, and keep it maintainable.
  It is for the ecosystem (wgpu, async back ends, parsers, serialization), for a quick MVP, and for the places where
  writing it in C would mean rebuilding a library that already exists. It is also the usual way to WASM for the web
  (`wasm-bindgen`, `wasm-pack`, a plain `wasm32` target), with TypeScript around it. Count the dependency tree (`rules (zero-cost)`).
- Python, Go and Rust all start from the well-used library, the opposite bias from C. Flat data, indices and batch
  processing still apply (`code (languages)` (dod)).

### Go

- Where: web back ends, p2p, SaaS and CRUD as one stb-style file or one static binary, other web things; a CLI or TUI
  only to serve such a thing (an admin tool for the service), not as a general tool language.
- If the system has no Go toolchain, build and run Go in a container or in CI and ship the static binary; a tool that
  must live on the user's machine is then written in C, Rust, Bash or Python instead.

### Lean 4

Formal verification and tests in Lean for the optimized C: proofs that a bound holds, that a fast version equals the
plain reference, that an invariant survives each step; kept in the project's `lean4/` and checked in its `run`. It
is a step of every round (`workflow (afk-loop)`); the recipes are in `verify (lean4)`. Prove what can be proved, test
the rest, and keep the C code tested against the proved model.

### Perl

Quick one-liners on text and files, where awk or sed get clumsy: `perl -ne`, `-pe`, `-i`, `-lane`. Nothing that has to
stay readable or grow (Python then).

### Emacs Lisp and Lisp

- Elisp: `-*- lexical-binding: t; -*-` on line 1, `;;; Section` headers (not `;; --`), a few well-chosen packages over
  home-made machinery, comments for the non-obvious why only. Check a change by batch-loading the config and
  `batch-byte-compile` (free variables, a `let` of a variable whose package isn't loaded yet binds it lexically: declare
  it with `(defvar NAME)`). use-package installs an `:ensure`d package even when `:if` is false - wrap it in a plain
  `when` to keep it off installs that don't need it.
- Common Lisp (Nyxt, SBCL): the same plain-functions style; a REPL (SLY or SLIME in Emacs) for exploration, a file for
  anything kept.

### TypeScript

The typed layer of the web front - the page, the glue around WASM modules, and a Node
tool or service when the project is already web. Strict mode, no framework unless the project has one, types at the
boundaries (I/O, API, the WASM interface), plain data inside. JavaScript alone is not used; the back end is Go and
the heavy part is WASM.

Principles and techniques (composition over inheritance, YAGNI, kaizen and the others): `code (thinking)`.

## Per-language preferences and the C manifest

### C: strict, manual, no hidden allocation

Reach for arenas/pools over ad-hoc malloc/free when a piece of code has
a clear allocate-then-reset-together lifetime (real example: a file manager's
directory-entry fill switched to an arena and lost an O(n^2) pointer-fixup bug and a heap-fragmentation footgun in
one move). Prefer
explicit, visible memory control over anything that hides what it's
doing - no surprise reallocation, no implicit ownership transfer.

### Rust/Go/Python: always use a library when one exists

Default to an existing, well-used crate/module/package over
reimplementing - the opposite bias from C. Don't hand-roll what the
ecosystem already solved well; the value in these languages is the
ecosystem, use it.

### Composition over inheritance

Across languages, prefer composing small pieces over deep inheritance
hierarchies. Applies even in languages without classical OOP - prefer a
function that takes what it needs over a type that tries to be
everything.

### Bash: glue code, automation, repeatable build/test

POSIX `sh` when it costs nothing (portable, `fn(){...}` with tabs), bash when you actually need its features. Every
script degrades gracefully when an optional dependency is missing instead of hard-failing, so it works everywhere.

`run` as a hot-reload convention: a file named `run` (no `.sh`) in
the project root that rebuilds only when sources are newer than the
binary (skip the build when nothing changed, just start), then starts
the program. Several programs in one repo → `run` builds all of them,
then asks which to start (menu, or the program name as the only
argument). No other arguments passed through. Default style for every
new project's `run`.

### Perl: text-munging only, keep it short

Reach for it only for quick one-off text processing where awk/sed
would be clunkier - not for anything that needs to stay readable long
term or grow into a real program (Python takes over there).

### Emacs Lisp: sectioned, lexical, minimal

`;;; Section` headers (not `;; --`), always `-*- lexical-binding: t; -*-`
on line 1, prefer a small number of well-chosen packages over building
machinery from scratch. Comments explain non-obvious WHY only, same rule as
every other language here.

## Data-oriented design (dod)

### Start from the data

Before code: what are the inputs and outputs, how many of each (10, 10k, 100M), how they are accessed (all at once,
by key, in order), what changes together and what is read together. The structure follows from that, not from nouns
in the problem. Transform arrays in batches; an "object" with methods is usually one row of several arrays.

- Struct of arrays for anything iterated: hot fields together, cold fields elsewhere.
- Flat buffers addressed by integer index, not pointer graphs: a tree is one node array with `first_child` /
  `next_sibling` indices (a heap tree rewritten this way is the usual reference); a graph is node
  and edge arrays. Indices survive reallocation, serialization and mmap; pointers don't.
- Handles: index plus generation counter for anything that can be freed and reused.
- Composition by factories, generators and combinators over flat data, so the code is not written by hand each time -
  as much as practical, not at any cost.
- Big data: file-backed, chunked columns (mmap) instead of one heap allocation - a vector index went from an OOM kill at
  7-8M vectors to 100M+ on a 6 GiB machine that way.

### Memory

Arenas over ad-hoc `malloc`/`free` when things share a lifetime: one block, a bump pointer, reset or release together;
a scratch arena per frame or request; save/restore marks for temporaries. Pools with a free list for fixed-size
objects. No hidden allocation, no implicit ownership transfer. Real case: a directory reader moved to an arena and lost
an O(n^2) pointer fix-up and a fragmentation footgun in one change.

No heap at all, the way the Goose language does it: an arena is a data stack - one mmap
reservation, a bump pointer, pages committed when written - and a snapshot/rewind around a scope is the free. A base
library with no malloc in its sources (checked by a test) measured what squeezes it further:
start the reservation on a 2 MiB boundary and `madvise(MADV_HUGEPAGE)` past its first 2 MiB (first touch of 256 MiB
119 ms to 50 ms, small arenas stay on 4 KiB pages); keep a high-water mark so calloc clears only memory handed out
before (64 MiB: 27 ms to 0.39 ms); grow the last block in place on realloc (an array grown to 20M: 65 ms to 13 ms);
give pages above the position back with `MADV_DONTNEED` after a big scope; init a pool lazily with a fresh pointer, so
a big pool commits memory only as it fills (64 MiB pool init: 25 ms to 20 us). Each has a Lean proof that it returns
what the plain version would (`verify (lean4)`).

A safety margin is not a bound: compute the real maximum and check it once, at the boundary. A VM that gave each
frame a fixed 256-cell margin for its operand stack wrote past the stack on a 300-value print at the bottom of a deep
recursion; the fix was to count each function's deepest operand stack and check the whole frame on entry.

### A C manifest

- Pure C89: `cc -std=c89 -pedantic -Wall -Wextra`; no `//` comments, declarations at block start, no VLAs, no
  designated initializers, no `stdint.h` - the project's own fixed-size types instead (read its base header for the exact
  meanings before using one), sizes pinned by a C89 static assert
  (`typedef char assert_u32[sizeof(u32) == 4 ? 1 : -1];`). No `short`/`long` in interfaces.
- No malloc/free (arenas), no recursion (an explicit stack array), no inheritance, classes, virtual dispatch or RAII
  (plain structs and functions, a switch on a type tag), no JIT.
- Unity build: one translation unit, one `cc` call from a bash `run`/`build` script; no CMake, no GNU make (a project's own make is fine there).
- Static linking, no glibc dependency where avoidable (musl), zero external dependencies; vendored single-header
  stb-style code keeps its license next to it.
- Techniques to reach for: bitboards, bitfields, BMI instructions, perfect hashing, sparse bitsets, SIMD (AVX2/
  AVX-512 kernels with a scalar fallback), event queues, fine-grained job systems, mmap zero-copy, deterministic replay
  by recording events.
- Branchless code only where a measurement shows the branch costs (`verify (bench)`); clear code otherwise.
- Licenses: MIT, GPL or dual. C89 + arenas + fixed types + no recursion matches MISRA C, a paid niche
  (embedded, automotive, medical firmware).

### Other languages

- Rust, Go, Python: the ecosystem is the value - use a well-known library there (`code (languages)`); still flat data, indices,
  batch processing.
- Bash: data as TSV columns, one `awk` over the stream instead of a loop spawning a process per line.
- Python with numbers: columns as arrays (numpy, `array`), not lists of objects.
- GDScript: `PackedFloat32Array` and friends, the servers API for thousands of things instead of thousands of nodes.
- Mojo: contiguous buffers, zero-copy views (address + pos + len), arena-backed allocation.

### Check

Sanitizers on every C test build (`-fsanitize=address,undefined`, a TSan build for threads) and a second compiler
(gcc and clang) - a review once found signed-overflow UB in an `abs` (INT_MIN) and an ignored `truncate()` return
this way. Measure before and after any layout change (`verify (bench)`). An optimization past the obvious version
(SIMD, bit tricks, tables, branchless) is proved equal to a plain Lean reference in the project's `lean4/` and held
to it by a differential test (`verify (lean4)`).
