# The biggest levers (what saves the most hours)

Techniques that turn days of staring at a disassembler into minutes, ranked by how often they pay. Commands are from
the tools' usual usage and were not re-read in docs this session (UNSURE where marked); each tool prints `--help`.
All of it stays inside the boundaries of `rea`: his own files and devices, interoperability, learning.

## 1. The original is the oracle: differential testing

Before any theory, make a harness that feeds the same input to the original and to your rewrite and diffs the
outputs. Every question "does my reading of this function match?" becomes a yes/no in seconds. Generate inputs by
mutating real samples one field at a time (`scripts/fieldscan A B` finds which bytes move). When the harness is green
on 1000 mutated inputs, the spec is right; when it is red, the diff points at the next thing to read.

## 2. Record once, replay backwards (rr)

`rr record ./prog args`, then `rr replay` gives gdb with `reverse-continue`, `reverse-step`, `reverse-finish` and
watchpoints that run backwards: set a watchpoint on the corrupted/derived value and go back to the write that made
it, instead of guessing which call produced it. Deterministic: a flaky crash is recorded once and examined forever.
Needs hardware counters (`kernel.perf_event_paranoid` <= 1) and a native CPU; does not work in most VMs. UNSURE on
very new kernels - try `rr record /bin/true` first.

## 3. Trace before you read

- Library and syscall level first: `strace -f -e trace=%file,%network`, `ltrace -f`, then `scripts/trace-summary`.
- Function level without source: `uftrace record ./prog` then `uftrace report` / `uftrace replay` (needs the binary
  built with `-pg`/`-finstrument-functions`, or `--no-pltbind`-style tracing of dynamic calls; UNSURE which mode
  fits a stripped binary - try `-P .` to patch at runtime).
- Arbitrary functions on a live process: `frida-trace -f ./prog -i 'open*'` (by name or `-a` by address); in Frida
  `Interceptor.attach` logs arguments and return values. Kernel-side or whole-system: `bpftrace -e 'uprobe:/path:func
  { printf("%s\n", str(arg0)); }'` (root).
- Graphics: `apitrace trace ./app` then `apitrace dump` / `apitrace replay` (OpenGL/Vulkan/D3D calls as text); RenderDoc
  for one captured frame. Gives the draw calls of a game without touching its code.

## 4. Formats: write the description, not the parser

A format described in Kaitai Struct (`.ksy`) is a spec and a parser at once: `kaitai-struct-compiler -t python
format.ksy` makes a reader, `ksv` (visualizer) or ImHex's pattern language shows the fields over the bytes. Iterate
on the `.ksy` until `fieldscan` shows no unexplained bytes; the `.ksy` goes into the repo as the spec. Entropy and
`binwalk -E` first to separate compressed/encrypted blocks from structure.

## 5. Recognise what is not yours: match, do not read

- Most of a binary is libraries. Ghidra's function ID and its "Version Tracking" (match against a build of the same
  library you compiled with symbols), or a FLIRT-style signature set, name the standard functions so you only read the
  rest. Rebuilding the suspected library version with symbols and matching against it is the strongest trick.
  UNSURE of the exact menu names - search the Ghidra help for "Function ID" and "Version Tracking".
- `capa` (capabilities of a binary) and `yara` rules say what a sample does at a glance.

## 6. Let the machine solve the constraint

- A check like "this input must satisfy ..." in a small function: symbolic execution (angr:
  `angr.Project(p, auto_load_libs=False)`, `simgr.explore(find=ADDR, avoid=ADDR)`) finds the input; works on small
  self-contained functions, drowns on big ones. Emulate one function without running the program with Unicorn or
  Qiling: map the code, set registers, run, read the result - a way to call a function you do not understand with
  your own inputs (that is differential testing for the one function).
- For a format checksum or hash: collect ten input/output pairs from the original, then try the usual suspects
  (CRC32/CRC16 variants, Adler, FNV, sums) with a small script before reading the code at all (`crcmod`, or the
  `reveng` tool for CRC parameters - UNSURE of its current packaging).

## 7. LLM as a note-taker, never as the source of truth

Paste a decompiled function and ask for a name and a one-line purpose; use the answer as a hint to test with the
oracle (lever 1). Decompiler output goes in small, one function at a time (see `code (reading)`). Whatever a model says a
function does is a hypothesis until the harness agrees.

## Order

1 harness (oracle) -> 3 trace to find where the interesting code is -> 5 skip the library code -> read what is left
with Ghidra, one function at a time -> 6 solve a constraint if one blocks you -> write the spec (`spec`) and for a
format the `.ksy` (4). Use 2 whenever the question is "where did this value come from".
