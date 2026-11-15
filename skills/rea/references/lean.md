# rea (lean)

`rea` says how to find out; the lean part says how little to read on the way. RE tools print megabytes - `objdump -d` of a
2 MB binary, an strace of a GUI starting up, a pcap, a decompiled project. Read them like logs: search, count,
compare; never page through them.

## Stop early

- Write the question first, one line in `re/NOTES.md`: "where does it store the theme", "what are bytes 0x10-0x1f".
  The work ends when that line has an answer with evidence, not when the program is understood.
- Take the cheapest rung that can answer it (the order in `rea`). Most questions end at the black box: the file it
  writes, the request it sends, the command it runs.
- Two samples that differ in one setting beat one sample read closely: `cmp -l a.bin b.bin` (every differing offset
  with both bytes, in octal), a `diff` of two `xxd` dumps, a `diff` of two filtered strace logs.
- Stop when the spec line is written and checked on the samples. Whatever else turned up on the way is a note in
  `re/NOTES.md`, not a new task.

## Dumps go to files

Everything big is written under `re/`; only the decisive lines come back (`leanctx (output)`).

- strace: `strace -f -y -e trace=file,network -o re/trace.txt CMD`; the paths it opens, counted:
  `grep -o 'openat([^,]*, "[^"]*"' re/trace.txt | sort | uniq -c | sort -rn | head -30`. `strace -c -o re/sum.txt
  CMD` shows which syscalls dominate before any of them is read.
- Binaries: symbols and strings first - `nm -D --defined-only BIN`, `strings -t x -n 8 BIN > re/strings.txt` then
  `grep -n -i WORD re/strings.txt` (the offset leads to the code that uses it). One function, never the whole file:
  `objdump -d --no-show-raw-insn --disassemble=SYMBOL BIN`. Decompiled code one function at a time (Ghidra MCP, or a
  headless script that prints one), never a whole-program export into the context.
- Hex: a range, not the file - `xxd -s 0x10 -l 64 FILE`.
- Network: the per-flow summary first, `tshark -r re/cap.pcap -q -z conv,tcp`; then only the fields the question
  needs, `tshark -r re/cap.pcap -Y http.request -T fields -e http.request.method -e http.request.uri`.
- Extracted trees (asar, jadx, gdsdecomp output, an unpacked firmware): `rg -l` for the string or the setting name
  across the tree, then open the one file it points at.
- Frames (the vibe in `rea`): cut only the span that moves (`ffmpeg -ss START -t SECONDS`), work from the per-frame
  numbers, and look at two or three frames, not fifty.

## Probes are scripts

A probe run twice becomes `re/probe-NAME.sh` that sets one thing, captures, and prints the diff (`automate-everything`).
The probes and `re/NOTES.md` - the question, each claim with its evidence and the samples it was checked on, the open
questions - are the trail: a fresh session continues from them instead of redoing the hunt. `re/` stays out of the
shipped code; the finished spec moves to `docs/FORMAT.md` or the tool's header (`rea`).

## What comes back

The spec lines and how sure each one is - checked on N samples, inferred, open (`rules (knows-unknowns)`) - not the story of
the investigation.
