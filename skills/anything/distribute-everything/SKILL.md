---
name: distribute-everything
description: Get a project from "works on my machine" to "someone else runs it" - the pipeline test, debug, bench, doc, pack, ship (plus webdev for web products), the per-project entry scripts (run, test, check, bench), and the definition of shipped. Use when a project nears "it works", when the user asks to release, package, publish, sell or show something, or when setting up a new project's scripts.
metadata:
  priority: "2"
  tags: "#thirdparties #distribute #release #workflow #dev"
  requires: "skill:verify skill:conventions skill:ship-anything ?skill:ui"
---

# distribute-everything

Plenty built, little shipped is a common gap. This family exists to close it: each step is a small skill, this one is
the order and the glue.

## The pipeline

1. `verify (test)` - the behaviour that matters is checked by a command, offline where possible.
2. `verify (debug)` - failures get a cause, not a workaround.
3. `verify (bench)` - speed and size claims are measured, paired, written down.
4. `conventions (doc)` - a stranger can build, run and understand it from the README.
5. `ship-anything` - one artifact per target: a static binary, a single bash file, a package, an engine export.
6. `ship-anything` - version, tag, release, verify the download, tell someone.
Web products add `ui (webdev)` (static first).

## Entry scripts in every project

Bash files without `.sh` in the project root, zero arguments, same behaviour everywhere:
- `run` - build only when sources are newer than the binary (a hot-reload habit), then start it. Several programs: build
  all, then ask which to start; the program name may be the only argument; nothing else is forwarded (forwarding `$@`
  once made a file manager treat "app" as a start path).
- `verify (test)` - every test, exit status says it all; `check` - lint and hygiene (shellcheck, duplicate basenames, stale
  docs); `verify (bench)` - the benchmark set, appending to the results log.
- Template: `#!/usr/bin/env bash`, `set -euo pipefail`, `cd "$(dirname "${BASH_SOURCE[0]}")"`, then the work; compiled
  projects `exec` the binary at the end.

## Shipped means

A stranger, on a clean machine (a podman container or VM of the target), installs it from the README, runs the example,
and removes it again - in minutes, without asking the user anything. Until then it is not shipped, whatever the tag says.

## When something reaches "it works"

Name the smallest shippable version and the step that publishes it, once, in one line - then do what the user decides.
