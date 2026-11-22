---
name: distribute-everything
description: Get a project from works on my machine to someone else runs it - the pipeline test, debug, bench, doc, pack, ship, the per-project entry scripts (run, test, check, bench), the definition of shipped. Use when a project nears it works, on release, package, publish, sell or show, or when setting up a new project scripts.
metadata:
  priority: "2"
  tags: "#thirdparties #distribute #release #workflow #dev"
  requires: "skill:code skill:conventions skill:ship-anything ?skill:ui"
---

# distribute-everything

Three years of building, little shipped - the gap he names himself (`machine (personal)`). This family exists to close it: each
step is a small skill, this one is the order and the glue.

## The pipeline

1. `code (test)` - the behaviour he cares about is checked by a command, offline where possible.
2. `code (debug)` - failures get a cause, not a workaround.
3. `code (bench)` - speed and size claims are measured, paired, written down.
4. `conventions (doc)` - a stranger can build, run and understand it from the README.
5. `ship-anything` - one artifact per target: a static binary, a single bash file, a package, a Godot export.
6. `ship-anything` - version, tag, release, verify the download, tell someone.
Web products add `ui (webdev)` (static first) and `code (saas)` (data, auth, payments, deploy).

## Entry scripts in every project

Bash files without `.sh` in the project root, no arguments (except the two noted), same behaviour everywhere:
- `build` - one of the two most important scripts (his words, 2026-11-15): every project has its own, never build
  steps inlined in `run` or `install`. Idempotent and incremental: compiles only when a source is newer than the
  output, prints `built: ...` or `up to date`; `BUILD_FORCE=1 ./build` rebuilds everything. No arguments.
- `run` - calls `./build` (so a changed source rebuilds, an unchanged one starts at once: "taki hot reload"), then
  starts the program. Several programs: build all, then ask which to start; the program name may be the only argument;
  nothing else is forwarded (forwarding `$@` once made nnn treat "app" as a start path). Reference: his `steamdeck/run`.
- `install` - an app he runs installs itself for the user: calls `./build` (a no-op when up to date), then binary to
  `~/.local/bin`, man page and licence under `~/.local/share`, `PREFIX`/`DESTDIR` from the environment, a note when
  the target is not in `PATH`. The one flag is `-rebuild`: it sets `BUILD_FORCE=1` so the install starts from a full
  rebuild; any other argument is an error. He asked for it on frost (2026-11-15: "frost powinien miec bash install
  odrazu"); reference: `frost/install`.
- `code (test)` - every test, exit status says it all; `check` - lint and hygiene (shellcheck, duplicate basenames, stale
  docs); `code (bench)` - the benchmark set, appending to the results log.
- Template: `#!/usr/bin/env bash`, `set -euo pipefail`, `cd "$(dirname "${BASH_SOURCE[0]}")"`, then the work; compiled
  projects `exec` the binary at the end.

## Shipped means

A stranger, on a clean machine (a podman container or VM of the target), installs it from the README, runs the example,
and removes it again - in minutes, without asking him anything. Until then it is not shipped, whatever the tag says.

## When something reaches "it works"

Name the smallest shippable version and the step that publishes it, once, in one line - then do what he decides.
