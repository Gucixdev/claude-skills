# code (debug)

Method first (`code (thinking)`): symptom, hypotheses ranked by evidence and cost, one variable at a time, no fix
until one mechanism explains everything. Below is how to get the evidence.

## Reproduce small

The smallest input and the fewest steps that still fail, as a script (`automate-everything`: keep it). Then `git bisect start BAD
GOOD && git bisect run ./repro` finds the commit when it used to work.

## Shell

`bash -x script` with `PS4='+ ${BASH_SOURCE##*/}:${LINENO}: '` for file and line; `set -x` around one block;
`shellcheck` before anything clever; `declare -p VAR` to see what a variable really holds.

## Native code

- Crash: `gdb -batch -ex run -ex bt -ex 'info locals' --args ./prog ARGS`; after the fact `coredumpctl list`,
  `coredumpctl gdb PID` (or `ulimit -c unlimited` and `gdb ./prog core`).
- Memory and UB: rebuild with `-g -O1 -fsanitize=address,undefined -fno-omit-frame-pointer`; data races
  `-fsanitize=thread`; `valgrind --leak-check=full --track-origins=yes ./prog`; heap growth `valgrind --tool=massif`.
- What it asks the system: `strace -f -tt -e trace=file,process,network -o trace.txt ./prog`; library calls `ltrace`;
  where time goes `strace -c`, `perf record -g` then `perf report`.
- Heisenbugs: `rr record ./prog` then `rr replay` and reverse-continue, when rr is installed.
- Hangs: `gdb -p PID -batch -ex 'thread apply all bt'`; `cat /proc/PID/stack` (root), `ls -l /proc/PID/fd`.

## Python

`python3 -X faulthandler prog.py` (a traceback on segfaults and with `faulthandler.dump_traceback_later` on hangs),
`breakpoint()` / `python3 -m pdb`, `python3 -W error` to turn warnings into the failing line, `-X importtime` for slow
imports.

## Godot

`godot --verbose`, the editor's console through `godot_get_console_log` / `godot_get_errors` (on a disposable
instance), `--debug-collisions`, `--print-fps`. A crash only while his editor is open: check for a second instance on
the same project first (`pgrep -af godot`).

## System and network

`journalctl -b -p warning`, `journalctl -u UNIT --since '10 min ago'`, his `logcollector -n`; `systemctl status UNIT`;
`ss -tlnp`, `curl -v URL`, `dig +short NAME`, his `sniff` for what talks to what; `dmesg -w` for hardware.

## Afterwards

Remove the debug prints and temporary flags; keep the repro as the regression test (`code (test)`); write the cause in the
commit body.
