# rea (ghidra)

Ghidra is installed at `/opt/ghidra` (`/usr/bin/ghidra` starts the GUI). The batch tool is not on PATH:
`/opt/ghidra/support/analyzeHeadless`. Run it from a throwaway project directory, never from inside the sample's folder.

## Headless: one function, never the whole program

`scripts/DecompFunc.java` (in this skill, checked on `/usr/bin/true`) prints the decompiled C of one
function, or lists function names matching a regex:

```sh
S=PATH/TO/claude-skills/skills/rea/scripts
T=$(mktemp -d)
/opt/ghidra/support/analyzeHeadless $T p -import BIN -scriptPath $S -postScript DecompFunc.java -list 'REGEX' -deleteProject > re/funcs.txt 2>&1
/opt/ghidra/support/analyzeHeadless $T p -import BIN -scriptPath $S -postScript DecompFunc.java FUNCNAME -deleteProject > re/f.txt 2>&1
sed -n '/DecompFunc.java>/,/GhidraScript/p' re/f.txt
```

- The script's own output is the lines after `DecompFunc.java>`; everything else is analysis chatter, so it goes to a
  file (`leanctx`, `lean`).
- A stripped binary has `FUN_00102490`-style names. Start from `entry`: its first argument to `__libc_start_main` is
  `main`. Then follow strings (`strings -t x`) to the function that uses them.
- Import once and keep the project (drop `-deleteProject`, add `-process BIN -noanalysis` for later runs) when several
  questions are asked of the same binary: analysis takes seconds to minutes, the questions are cheap.
- `-readOnly` with `-process` when nothing in the project should change.

## GhidraMCP

If a Ghidra MCP server is configured (not at the time of writing), ask it one function at a time (list,
decompile, xrefs, rename). Same rule as headless: a question per call, never an export of everything.

## Reading decompiled code

- `undefined8 param_1` is a guess; the real types come from the callers and the format strings.
- Rename and retype as the picture grows, but the claim goes into `re/NOTES.md` with its evidence, not just into the
  Ghidra database.
- Decompiler output is evidence of behaviour, not source: the spec (`spec`) is what gets written.
