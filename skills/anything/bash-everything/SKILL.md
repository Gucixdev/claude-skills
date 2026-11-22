---
name: bash-everything
description: Rewrite or wrap an app as one bash file on coreutils - how a GUI becomes a single-file CLI and TUI, structure of his Gucixdev/bash tools (header as help, wrap the real program, degrade instead of dying, lazytui menus), data as TSV, safety (mktemp, trap, flock), tests with bats and fake binaries. Use for any bash tool, rewrite, wrapper or shell automation.
metadata:
  priority: "2"
  tags: "#thirdparties #bash #shell #cli #tui #rewrite #unix #dev"
  requires: "skill:rea skill:ui skill:code cmd:bash cmd:awk cmd:sed ?cmd:fzf ?cmd:jq|python3 ?cmd:shellcheck ?cmd:bats"
---

# bash-everything

His repo Gucixdev/bash is the reference: `flatseal`, `ezcontainers`, `wifi`, `gh`, `hf`, `trash`, `morph`... one
file per tool, each still running after being copied anywhere.

## From a GUI app to one file

1. Find what the app really does (`rea`): which program it calls, which files it writes. Most "managers" are a
   front end over a CLI or a config directory:
   - Flatseal: per-app permissions are `flatpak override --user APP --filesystem=...` files under
     `~/.local/share/flatpak/overrides/`, layered manifest, global override, app override (`flatpak info
     --show-permissions`).
   - ProtonUp-Qt: GE-Proton releases from `https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases`,
     a `GE-Proton*.tar.gz` (`-x86_64` or `-aarch64` in newer names) plus `NAME.sha512sum` (`sha512sum -c -`),
     unpacked into `~/.steam/steam/compatibilitytools.d/` (Flatpak Steam:
     `~/.var/app/com.valvesoftware.Steam/data/Steam/compatibilitytools.d/`). List, install, remove = three
     subcommands. Paths from the GE-Proton README, checked 2026-10-18 - check again before relying on them.
2. Map the GUI to the CLI: each screen a subcommand, each list a TSV-producing function, each toggle a flag, each
   confirmation an `lt_confirm`. The TUI is a thin layer that calls the same subcommands (`ui (ui-designer)`).
3. State lives where the real program keeps it - no own database, no cache that can disagree with the truth.

## Structure of one tool

```bash
#!/usr/bin/env bash
# name - what it does in one line.
#
#   name list                 rows as TSV
#   name install ITEM...      ...
#   name                      no arguments: the TUI
set -u
case ${1:-} in -h | --help) awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } { exit }' "$0"; exit 0 ;; esac
die() { printf 'name: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" > /dev/null || die "$1 is missing (install: $2)"; }
```

- The header comment is the help text and, through his `manwriter`, the man page - one source of truth.
- Dispatch with one `case` at the bottom; functions above; tabs; `shellcheck -S warning` clean.
- Wrap the real thing: find it with `lt_realbin NAME` (skips this script on PATH), hand unknown subcommands to it
  with `exec`. A wrapper named like the real tool (his `gh`, `hf`, `nmap`) adds commands and passes the rest through.
  Depend only on its stable surface (`gh auth token`, `gh config get git_protocol`, `hf download --repo-type`) - a
  full drop-in reimplementation changes under you and has to be chased (abandoned on 2026-10-17 for that reason).
- Degrade, don't die: optional dependency missing - a simpler path and one line saying so; required one missing -
  fail fast with the install command. `jq` missing: `python3 -c 'import json,sys ...'`; fzf missing: a numbered
  `select` list.
- Show before doing: list what a destructive action will touch, ask once; deleting goes to the trash
  (`rules (trash-not-rm)`).
- Interactive menus: the `lt_*` functions copied from `lib/lazytui` as a marked block (`# >>> lazytui ... >>>`), so
  the tool needs nothing from the repo at run time. fzf comes in two flavours (his C fzf and upstream): detect with
  `fzf --version`, gate features by version (`--footer` 0.63+, `--id-nth` 0.71+), labels on binds only in the C one.
- Inside fzf `become`/`execute` stdin and stdout are not a terminal: mark "we are inside the views" with an exported
  variable instead of trusting `[ -t 0 ]`.

## A growing collection

- Past a couple of dozen tools, put metadata in the header (`# tool:summary=`, `# tool:args=`, `# tool:group=`) and let
  one router command list and dispatch them, the way omarchy's `bin/omarchy` reads the first 80 lines of 532 commands;
  a test checks every tool has the fields.
- Hardware and platform questions go to one helper that answers with an exit code (`hw-laptop`, `hw-platform` printing
  `x86` or `aarch64`), never a `uname -m` scattered through feature code.

## Shell craft

- Data as TSV through `awk -F '\t'`; `read` with `IFS=$'\t'` squeezes empty fields - use a non-whitespace separator
  (`\037`) inside pipelines when fields can be empty.
- `mktemp -d` plus `trap 'trash or clean my own temp dir' EXIT`; `flock` on a lock file for anything run twice at
  once; atomic writes (temp file in the same directory, then `mv`).
- XDG paths: `${XDG_CONFIG_HOME:-$HOME/.config}`, `${XDG_DATA_HOME:-...}`, `${XDG_STATE_HOME:-...}`, cache likewise.
- Secrets from the environment; to curl on stdin (`curl -H @-`) so they never show up in `ps`.
- `set -u` always; `set -e` only where its traps are understood; quote every expansion; `--` before file arguments.
- `pgrep -f`/`pkill -f PATTERN` also match the shell running that very command when the pattern is on its command
  line - one killed its own shell on 2026-10-18. Select by `pgrep -x NAME`, check `/proc/PID/cmdline`, then act.
- awk portability: test with `mawk` or busybox awk too - a 2026-10-18 review found a gawk-only regex in his
  `logcollector`.
- `cmd | tee /dev/stderr` reopens the file stderr points to, with O_TRUNC: under `./run > log 2>&1` it emptied the
  log of everything before that step (vecindex, 2026-11-06). Capture into a variable and print it, or `tee >(cat >&2)`.
- Never edit a script while it runs: bash reads it as it goes, and lines inserted above the current position made a
  running `./run` execute half-lines (`pthread: command not found`, 2026-11-06). Edit after it exits, or run a copy.

## Tests

`bats tests/`: offline behaviour of every tool; fake binaries on a temp PATH that record their argv (a fake `fzf`
that prints its args and the first input line, a fake `flatpak`); `HOME`, `XDG_*` and `GIT_CONFIG_GLOBAL` in
`$BATS_TEST_TMPDIR`; `--help` and `shellcheck` for every file; TUIs in tmux with both fzf flavours (`code (test)`).

## Templates

`bash/templates/` (in the Gucixdev/bash repo) holds four starting points; copy one, then change the lines marked `EDIT`.
All pass `shellcheck -S warning`, start with the header-as-help comment, and `cd` to their own directory first.

- `run` - 0 arguments, no extension. Calls `./build` (incremental), then `exec`s the program; extras are not forwarded (`distribute-everything`).
  Matches desktop/run and frost/run.
- `build` - compile into `bin/`, only when a source is newer, `BUILD_FORCE=1` forces; `install` calls it and takes the one flag `-rebuild`. `die`/`need` helpers, `mkdir -p`, clone-if-missing third-party sources into `src/`
  (an optional part may fail, a missing result may not), ends with `built: ...`. Idempotent.
- `setup` - install dependencies. A `command|package` table, collects only what is missing, picks pacman/apt/dnf/xbps,
  prints the exact command first and asks once (`-y` skips the question); unknown systems get the list to do by hand.
- `wizard` - questions through `lib/wizard` (steps `var|prompt|a,b,c|default`, Esc = back), `eval` of the quoted answers,
  atomic write (`mktemp` beside the target, then `mv`) of the config. Cancel writes nothing.

New project script -> start from these instead of a blank file; keep the names (`run`, `build`, `setup`, `wizard`).
