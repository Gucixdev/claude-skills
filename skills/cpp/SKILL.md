---
name: cpp
description: How C++ is written for him - he does not read the code, so use every abstraction C++ gives (classes, RAII, templates, concepts, views, ranges, variant/optional, lambdas, constexpr) instead of typing boilerplate; build a helper the second time, keep it zero-cost, prove it with the compiler and the project checks. Use for any .cpp/.hpp file, C++ projects like symbiotecpp, or when code feels repetitive.
metadata:
  priority: "2"
  tags: "#cpp #dev #templates #raii #performance #abstractions"
  requires: "skill:code cmd:g++|clang++ ?cmd:ninja ?cmd:cmake"
---

# cpp

He does not read the C++ and has not the years to learn its corners. So the code is written for the compiler and the
checks, and the abstractions carry the work. Typing the same loop, index arithmetic or load-and-check block again is the
mistake, not using a template. (The C manifest in `code (languages)` is for C; here C++ is allowed to be C++.)

## Always

- Use the language: classes with RAII for anything that owns (file, map, buffer, thread), `std::span` / `string_view`
  for borrowed data, `optional` / `variant` / `expected`-style results instead of sentinel values, `enum class`,
  structured bindings, lambdas, `constexpr`, `<algorithm>` and ranges over hand loops, `std::format` where the project has it.
- Second time you type something, make the helper; third time is already late. Typical helpers: a strided view
  (`View2D<T>`, `Img(c,y,x)` with `operator()`), `parallel_for`, a scoped timer / progress, a table of commands
  registered by data, a `Config` read from JSON by one generic function, a shared encoder loop taking a name prefix
  instead of one copy per model.
- Templates and concepts for "same algorithm, different element or layout"; `static_assert` and `requires` so a wrong
  use is one readable error. Heavy templates get an explicit instantiation in one `.cpp` (compile time is a cost too).
- Operators: overload them wherever the meaning is the obvious one - `+ - * /` and `+=` on vectors, matrices, tensors
  and views; `operator()(c,y,x)` / `[]` for indexing; `<=>` and `==` defaulted for keys and configs; `operator|` to chain
  steps (`x | norm | silu`) or ranges; `operator()` on small structs as zero-cost function objects; `operator<<` or a
  `std::formatter` so a type prints itself; `explicit operator bool` for "ok"; user-defined literals for units
  (`4_GiB`). Never an operator whose meaning surprises (`+` that mutates, `<<` that does not stream/shift).
- Composition first: a type has parts (`Decoder` has a `Cache`, a `Tokenizer`, a `Rope`). Inheritance only for a true
  runtime interface with few implementations and calls outside hot loops (`Weights` -> Map / Checkpoint / Cached), with
  `final` on leaves and a virtual destructor on the base. Same algorithm over many types -> template / concept / CRTP,
  not a base class. Different alternatives known at compile time -> `std::variant` + `std::visit`, not a hierarchy.
- Pick the abstraction by the cost of being wrong: a small value type (copyable, no virtuals) is always safe; a
  hierarchy, a global singleton or a deep template metaprogram is not - choose those only when no simpler one fits.
- No raw `new`/`delete`, no manual `malloc` in new code, no `void*` plumbing, no macros that a `constexpr` or template does.
- Errors: the project's one `fail(...)` / result type, with the name of the thing that was wrong in the message.

## Runs everywhere, specialised by anyone

- Standard: read the project's (`CMAKE_CXX_STANDARD`) and stay inside it. For software others build on their own
  machines the baseline is C++20 (GCC 11+, Clang 13+, Apple Clang, MSVC 2022); C++23 only behind a fallback, and CUDA /
  nvcc code stays C++17. A newer library feature that is 50 lines to write (mdspan-like `View`) is written, not required.
- No compiler extensions, no `-march=native` in the default build, no inline asm without a plain-C++ twin. SIMD and
  GPU code are optional backends; the plain f32 reference kernel always exists and defines the right answer.
- Kernels sit behind the project's registry (symbiotecpp: `ops::registry()`, one table per slot, key = op id + backend
  name). Anyone adds a kernel for their hardware by registering one function under the same id; selection is resolved
  once (cpuid / device probe), never a virtual call per element. New ops get a slot + a reference + a test hook
  from the start, and the header says how to add a backend.

## Zero-cost or it does not ship

- Abstractions in hot loops must compile away: no `virtual`, no `std::function`, no allocation per iteration, no
  `shared_ptr` there. Use templates / `inline` / function objects; check with a `-O2` build and a bench
  (`code (bench)`), not a guess. A view must not copy; a helper must not hide a copy.
- Keep data flat and contiguous (`std::vector<T>` of structs of arrays as the project does); abstraction sits around
  the data, it does not turn it into a pointer graph.

## Because he does not read it

- The header comment says what, the maths, the layout, who uses it, who tests it (symbiotecpp rule); the names say the
  rest. Cleverness that needs a comment to survive is cut; cleverness the compiler checks stays.
- Proof lives outside the code: warnings as errors (`-Wall -Wextra`), a sanitizer build, the project's `check` / `test`
  scripts, two compilers when cheap. Report what was compiled / run, never "looks right".
- A project's own rules win (symbiotecpp: one file per algorithm, config in data files, no tests unless he says,
  never commit).

## Symbiotecpp helpers that exist already

`core/view.hpp` (View2/View3, `Img(c,y,x)`, `transpose`), `core/parallel.hpp` (`parallel_for(n, f, min_parallel)`),
`model/layer_names.hpp` (`Path` with `/`, `names::` presets, `count_numbered`), `model/linear_layer.hpp` (`Linear`, `Bias`),
`model/conv1d_layer.hpp` (`Conv1d`), `model/transformer_layer.hpp` (`LayerNorm`, `RmsNorm`, `Attention`, `Ffn`, `Encoder`,
`DecoderLayer`: pre- and post-norm), `ops/layers/kernels.hpp` (swappable layer kernels), `model/transformer_ops.hpp`
(`tf::` blocks, `tf::add_into`), `model/vit_tokens.hpp` (the ViT encoder, `patchify`). Verify a refactor with a golden run:
synthetic weights from a name hash, checksums and the list of requested tensors before and after, bit-exact or explained.
Use them; add the next repeated thing next to them.

## Refactor when it pays

When a new feature repeats an old one (two ViT encoders, three attention wrappers), fold the old one onto the shared
piece in the same change - dedupe is part of the feature, not a later chore. Rename, move, keep old interfaces working.
