# code (languages)

Which language for which job, how code is shaped in each, and the data-oriented C manifest. Three parts: the language table, per-language engineering preferences, data-oriented design.

## Which language for which job

### His table (updated 2026-11-15; the older lines come from his manifest.md: "use language as a tool, not a philosophy")

Values: atomicity, reliability, readability, impact. An explicit request always wins (he has asked for a Rust CLI, a
batch of Go single-binary tools); the table is the fallback when he doesn't say.

| Job | Language |
|---|---|
| Low-level work, performance, things worth owning for ten years (allocators, data layout, small libraries, kernels) | C89 (`code (languages)` (dod)) |
| Proofs about the optimized C and its algorithms: bounds, equivalence to a plain reference, invariants | Lean 4 (`code (lean4)`) |
| Ecosystem-heavy work and quick MVPs where C makes no sense: wgpu and graphics, backends, tools built on good crates; often compiled to WASM for the web | Rust (see below) |
| AI/ML MVPs, quick automation, micro-tools, plugins, AI glue | Python |
| Quick one-liners on text and files | Perl (`perl -ne`, `-pe`, `-i`) |
| Glue, repeatable ops, build and test tooling | Bash |
| Web back ends, p2p, single-file stb-style programs for SaaS and CRUD, anything web; a CLI or TUI only when it serves a web thing | Go (see below) |
| Game logic inside Godot: scenes, nodes, UI, tools in the editor | GDScript (`godot`) |
| His own language, scripting for the game engine and the editor | gael (see below) |
| The web front | WASM as the main target (Rust or C compiled to it), TypeScript for the page and the glue around it, plain HTML/CSS first (`ui (webdev)`) |
| CRUD web apps | Go in one file first; Rails stays an option (`code (saas)`) |
| Python syntax at C speed | Mojo |
| avoid by default | Java, JavaScript alone (TypeScript instead), Haskell |

Emacs language list (2026-10-18): C, C++, Rust, Go, Bash, Perl, Python, GDScript, Ruby on Rails, TypeScript, Lisp.
Lean 4 and gael join it as he works in them.

### Bash

- POSIX `sh` when it costs nothing, bash when its features are needed; `fn() {...}` with tabs, like his `bash` repo.
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
- Rust is the C++ of his stack: take a good crate or a higher abstraction and ship faster, and keep it maintainable.
  It is for the ecosystem (wgpu, async back ends, parsers, serialization), for a quick MVP, and for the places where
  writing it in C would mean rebuilding a library that already exists. It is also the usual way to WASM for the web
  (`wasm-bindgen`, `wasm-pack`, a plain `wasm32` target), with TypeScript around it. Count the dependency tree (`rules (zero-cost)`).
- Python, Go and Rust all start from the well-used library, the opposite bias from C. Flat data, indices and batch
  processing still apply (`code (languages)` (dod)).

### Go

- Where: web back ends, p2p, SaaS and CRUD as one stb-style file or one static binary, other web things; a CLI or TUI
  only to serve such a thing (an admin tool for the service), not as a general tool language.
- No Go toolchain on his system. Build and run Go in a container or in CI and ship the static binary; a tool that
  must live on his machine is written in C, Rust, Bash or Python instead.

### gael

His own language (`Gucixdev/gael`, C89 compiler, bytecode VM, s-expressions): the scripting language of his game engine
and of the Emacs-like editor written in it. Written mainly by models, so the rules are `gael` (the skill): check-fix-test
loop, gems for reusable code, `./test` on every build. Use it for what it is for (engine scripts, editor extensions,
experiments in the language); not a replacement for C, Rust or Python elsewhere. Open question for him: how static
(`questions.md`, decisions).

### GDScript

The language of everything that lives inside a Godot project: node scripts, UI, editor tools and addons. Static types
(`var x: int`, typed arrays and signals) wherever they cost nothing, since they make it faster and catch mistakes in
the editor. Heavy loops go to a C library (GDExtension) or to gael only when profiling shows the need. Conventions and
the safety rules for his live editor: `godot`.

### Lean 4

Formal verification and tests in Lean for the optimized C: proofs that a bound holds, that a fast version equals the
plain reference, that an invariant survives each step; kept in the project's `lean4/` and checked in its `run`. It
is a step of every round (`workflow (afk-loop)`); the recipes are in `code (lean4)`. Prove what can be proved, test
the rest, and keep the C code tested against the proved model.

### Perl

Quick one-liners on text and files, where awk or sed get clumsy: `perl -ne`, `-pe`, `-i`, `-lane`. Nothing that has to
stay readable or grow (Python then).

### Emacs Lisp and Lisp

- Elisp: `-*- lexical-binding: t; -*-` on line 1, `;;; Section` headers (not `;; --`), a few well-chosen packages over
  home-made machinery, comments for the non-obvious why only. Check a change by batch-loading the config and
  `batch-byte-compile` (free variables, a `let` of a variable whose package isn't loaded yet binds it lexically: declare
  it with `(defvar NAME)`). use-package installs an `:ensure`d package even when `:if` is false - wrap it in a plain
  `when` to keep it off machines that don't need it.
- Common Lisp (Nyxt, SBCL): the same plain-functions style; a REPL (SLY or SLIME in Emacs) for exploration, a file for
  anything kept.

### TypeScript

Kept (2026-11-15: "wnosi sporo"): the typed layer of the web front - the page, the glue around WASM modules, and a Node
tool or service when the project is already web. Strict mode, no framework unless the project has one, types at the
boundaries (I/O, API, the WASM interface), plain data inside. JavaScript alone is not used; the back end is Go and
the heavy part is WASM.

Principles and techniques (composition over inheritance, YAGNI, kaizen and the others): `code (thinking)`.

## Per-language preferences and the C manifest

### C: strict, manual, no hidden allocation

Reach for arenas/pools over ad-hoc malloc/free when a piece of code has
a clear allocate-then-reset-together lifetime (see this session's real
example: `nnn`'s `dentfill()` switched to an arena to kill an O(n^2)
pointer-fixup bug and a heap-fragmentation footgun in one move). Prefer
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

POSIX `sh` when it costs nothing (portable, same `fn(){...}` + tabs
style as this session's own `ez*`/nnn scripts), bash when you actually
need its features. Every script should degrade gracefully when an
optional dependency is missing rather than hard-failing (the user's own
stated rule, from this session: "all scripts need to have fallback so
it works everywhere no matter what"). Influence: Dave from "You Suck at
Programming" (YSAP) - real bash mastery, not cargo-culted incantations.

`run` is his hot-reload convention: a file named `run` (no `.sh`) in
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
machinery from scratch - see this session's own `emac.el` as the
reference shape. Comments explain non-obvious WHY only, same rule as
every other language here.

### GDScript / Godot: see the dedicated `godot` skill

### Editing files: Emacs, not the built-in file tools

Read, search, create and edit text files through `cemacs` (the same Emacs daemon the user runs, one config) - see the `machine (emacs)` skill. The built-in
Read/Write/Edit/Grep are for what Emacs cannot show: binaries, images, PDFs, notebooks.

### Shell environment: the .bashrc conveniences

`~/.bashrc` starts with `[[ $- != *i* ]] && return`, so the Bash tool (non-interactive) does NOT get his aliases, functions or
interactive-only exports. Use them deliberately:

- Need them? Run `bash -ic '<cmd>'`, or just apply the same effect yourself. PATH already has `~/.local/bin` first (his own
  tools live there: `cemacs`, his C `fzf`, the nnn fork, `godot`, `claude`).
- `tree` is aliased to `tree -I ".git|.venv|__pycache__|node_modules|.pytest_cache|.mypy_cache|_retired"` - use those excludes
  whenever you print a tree, so listings match what he sees. `ls` is `ls -p --color=auto`, `grep` colours.
- Search with `fd` (files) and `rg` (content), both installed - the same tools behind his `fcd`/`fman` fzf helpers. `n`
  (nnn cd-on-quit), `fman`, `fcd` are interactive-only functions; do not call them from scripts.
- `EDITOR=VISUAL=smart-edit` opens a GUI Emacs and returns immediately, so it never blocks: for `git commit` pass `-m`, for
  anything wanting an editor set `GIT_EDITOR=true`/use non-interactive flags.
- `FLATPAK_USER_DIR=/data/flatpak`, `MANPAGER=less` with `GROFF_NO_SGR=1` (plain `man` output), unlimited timestamped history
  (`HISTSIZE=-1`, `~/.bash_history` is a real record of what he runs).
- `~/.bashrc` exports `GH_TOKEN` in plain text: never `cat` the file or echo env vars into output; read it with
  `grep -v GH_TOKEN ~/.bashrc`. (Worth moving it to `gh auth` / a keyring - mention it once, don't nag.)

### Stylistic influences

tsoding (Alexey Kutepov) - from-scratch, minimal, educational, own
tools over frameworks, plain C89-style discipline. Linus Torvalds -
"good taste" in code, pragmatism over purity, no over-engineering.
John Carmack - performance-conscious, simple over clever, measure
before optimizing. Dave (YSAP) - bash specifically, see above. Terry
Davis (TempleOS) - from-scratch purism taken to its limit: own
compiler, own OS, own language, nothing borrowed. Doesn't mean rebuild
everything from zero (see the Rust/Go/Python rule above) - it's the
spirit of actually understanding what you depend on, not a license to
reinvent.

These influences are for Claude's own calibration only - never write
"inspired by tsoding" or similar namedrops into a README, doc comment
or commit message (caveman skill: trim that kind of filler from
written output, not just chat).

### Related skills

Sits next to personal (who he is) - this is how to write code for him.
See also caveman (trim namedropping like the above from committed
docs), emacs (edit through `cemacs`), godot (GDScript-specific rules).

## Data-oriented design (dod)

### Start from the data

Before code: what are the inputs and outputs, how many of each (10, 10k, 100M), how they are accessed (all at once,
by key, in order), what changes together and what is read together. The structure follows from that, not from nouns
in the problem. Transform arrays in batches; an "object" with methods is usually one row of several arrays.

- Struct of arrays for anything iterated: hot fields together, cold fields elsewhere.
- Flat buffers addressed by integer index, not pointer graphs: a tree is one node array with `first_child` /
  `next_sibling` indices (his `CTree`, rewritten from a heap tree on 2026-07-19, is the reference); a graph is node
  and edge arrays. Indices survive reallocation, serialization and mmap; pointers don't.
- Handles: index plus generation counter for anything that can be freed and reused.
- Composition by factories, generators and combinators over flat data ("data oriented jak się da, factory/generatory/
  combinatory, aby nie klepać kodu") - as much as practical, not at any cost.
- Big data: file-backed, chunked columns (mmap) instead of one heap allocation - vecindex went from an OOM kill at 7-8M
  vectors to 100M+ on a 5.84 GiB machine that way.

### Memory

Arenas over ad-hoc `malloc`/`free` when things share a lifetime: one block, a bump pointer, reset or release together;
a scratch arena per frame or request; save/restore marks for temporaries. Pools with a free list for fixed-size
objects. No hidden allocation, no implicit ownership transfer. Real case: nnn's `dentfill()` moved to an arena and lost
an O(n^2) pointer fix-up and a fragmentation footgun in one change.

No heap at all, the way Goose does it (aardappel's language, "jak goose"): an arena is a data stack - one mmap
reservation, a bump pointer, pages committed when written - and a snapshot/rewind around a scope is the free. holyc
base (2026-11-06) has no malloc in `src/` (`tests/run`'s `no_heap` check) and measured what squeezes it further:
start the reservation on a 2 MiB boundary and `madvise(MADV_HUGEPAGE)` past its first 2 MiB (first touch of 256 MiB
119 ms to 50 ms, small arenas stay on 4 KiB pages); keep a high-water mark so calloc clears only memory handed out
before (64 MiB: 27 ms to 0.39 ms); grow the last block in place on realloc (an array grown to 20M: 65 ms to 13 ms);
give pages above the position back with `MADV_DONTNEED` after a big scope; init a pool lazily with a fresh pointer, so
a big pool commits memory only as it fills (64 MiB pool init: 25 ms to 20 us). Each has a Lean proof that it returns
what the plain version would (`code (lean4)`).

A safety margin is not a bound: compute the real maximum and check it once, at the boundary. gael 0.1's VM gave each
frame a fixed 256-cell margin for its operand stack, and a 300-value print at the bottom of a deep recursion wrote past
the stack; the compiler now counts each function's deepest operand stack and the VM checks the whole frame on entry
(2026-10-19).

### His C manifest

- Pure C89: `cc -std=c89 -pedantic -Wall -Wextra`; no `//` comments, declarations at block start, no VLAs, no
  designated initializers, no `stdint.h` - his own fixed-size types instead (prefixes o/u/i/f/a with 8/16/32/64-bit
  sizes; read the project's base header for exact meanings before using one), sizes pinned by a C89 static assert
  (`typedef char assert_u32[sizeof(u32) == 4 ? 1 : -1];`). No `short`/`long` in interfaces.
- No malloc/free (arenas), no recursion (an explicit stack array), no inheritance, classes, virtual dispatch or RAII
  (plain structs and functions, a switch on a type tag), no JIT.
- Unity build: one translation unit, one `cc` call from a bash `run`/`build` script; no CMake, no GNU make (his own
  make in holyc is his tool, fine there).
- Static linking, no glibc dependency where avoidable (musl), zero external dependencies; vendored single-header
  stb-style code keeps its license next to it.
- Techniques he reaches for: bitboards, bitfields, BMI instructions, perfect hashing, sparse bitsets, SIMD (AVX2/
  AVX-512 kernels with a scalar fallback), event queues, fine-grained job systems, mmap zero-copy, deterministic replay
  by recording events.
- Branchless code only where a measurement shows the branch costs (`code (bench)`); clear code otherwise.
- Licenses: MIT, GPL or dual. His C89 + arenas + fixed types + no recursion style matches MISRA C, a paid niche
  (embedded, automotive, medical firmware).

### Other languages

- Rust, Go, Python: the ecosystem is the value - use a well-known library there (`code (languages)`); still flat data, indices,
  batch processing.
- Bash: data as TSV columns, one `awk` over the stream instead of a loop spawning a process per line.
- Python with numbers: columns as arrays (numpy, `array`), not lists of objects.
- GDScript: `PackedFloat32Array` and friends, the servers API for thousands of things instead of thousands of nodes.
- Mojo (his ash libraries): contiguous buffers, zero-copy views (address + pos + len), arena-backed allocation.

### Check

Sanitizers on every C test build (`-fsanitize=address,undefined`, a TSan build for threads) and a second compiler
(gcc and clang) - a 2026-10-18 review found signed-overflow UB in `abs_i32` (INT_MIN) and an ignored `truncate()`
return this way. Measure before and after any layout change (`code (bench)`). An optimization past the obvious version
(SIMD, bit tricks, tables, branchless) is proved equal to a plain Lean reference in the project's `lean4/` and held
to it by a differential test (`code (lean4)`).
