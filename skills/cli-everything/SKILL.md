---
name: cli-everything
description: Drive any program through its CLI or a REST API, MCP only as the last resort. Order - the program own CLI, a REST API, a wrapper CLI of ours (one bash file or small daemon, --json, exit codes), and only then a found, read and registered MCP server. Use to connect or drive a program, wrap a GUI, expose a tool to agents, or before adding any MCP server.
metadata:
  priority: "2"
  tags: "#cli #rest #mcp #agents #bash #dev #thirdparties #automation #integration"
  requires: "skill:rea skill:rules skill:audit-everything ?skill:anthropic-skills:mcp-builder ?cmd:claude ?cmd:node|python3"
---

# cli-everything

His decision (2026-11-08, restated 2026-11-14): CLI and REST are far better than MCP; MCP only as a last resort.

Order of preference: 1. the program's own CLI; 2. its REST API (curl and jq); 3. a wrapper CLI of ours, one bash file
for a GUI that only drives a CLI or files (`bash-everything`); 4. an MCP server, with the checks in `mcp`.
A repeated call becomes a script (`automate-everything`).

He wants CLI-Anything (https://github.com/HKUDS/CLI-Anything) to become the standard way tools are exposed to me, instead of MCP.

Why: an MCP server is dead weight - one more process to run, its tool schemas sit in every context whether used or
not, it adds an auth surface and a thing to trust, and it can only do what its author exposed. A CLI is composable (pipes,
scripts, cron), self-documenting (`--help`), testable and costs nothing until it is called.

A CLI is not limited to stateless one-shot commands. It can hold and manage state, in any of these shapes:

- **State in files**: a config file, a JSON or TSV store, SQLite (`tool add`, `tool ls`, `tool done N` over one file; the
  file is the state, every call is still a plain command).
- **A session you name**: `tool open NAME` returns an id or sets a current session in a state file; later commands work
  on it (`tool --session ID ...`), `tool close` ends it. This is how browsers, editors, DAWs and games are driven.
- **A daemon plus a client**: `tool start` forks a long-running process that owns the live object (an editor, a
  game, a device connection) and listens on a Unix socket; every other command is a thin client that sends one
  request and prints the answer. `tool status`, `tool stop`, a pid file and a socket path in `$XDG_RUNTIME_DIR` are
  the whole lifecycle. This replaces what people reach for MCP for.
- **A REPL**: `tool repl` for stateful exploration (a shared session, history); same commands as the one-shot form.
- **Streams**: `tool watch` / `--follow` prints events as JSON lines until interrupted, so another process can read them.

What stays the rule whatever the shape: `--json` for machine output and human text otherwise, exit codes that mean
something (0 done, 1 failed, 2 bad usage), `--help` that is the whole manual, idempotent where it can be, show before
doing for anything destructive, and no secrets in output.

Rules:
- Default to a plain CLI over a new MCP server. A wrapped app gets: a `--json` mode, a `repl` where state matters, and a
  `help --all` / `--dump-api` listing of its commands.
- Skills (SKILL.md) describe the CLI; the CLI does the work. Install harnesses from the CLI-Hub / plugin marketplace
  (`/plugin marketplace add HKUDS/CLI-Anything`) only when he asks; otherwise write our own in the same shape.
- Existing MCPs (godot, graphify, blender) stay until a CLI replaces them; do not remove them unasked. `openapi` already is a CLI first (`src/openapi.py ask|api|services|...`, `dump-api`, `--json`, exit codes 0/1/2/3) with the MCP server as a thin wrapper over the same code: the shape to copy. One generic REST caller (`api SERVICE METHOD PATH`, a registry file, writes shown until `--yes`) beats one wrapper per API.
- Same shape as our own tools: `bash-everything` for bash wrappers, C for fast ones.
- Verify the upstream README before claiming specifics (features change); only confirmed so far for CLI-Anything: a
  `--json` flag, a shared REPL, harnesses for GIMP/Blender/Inkscape/Audacity/LibreOffice/OBS, SKILL.md under top-level
  `skills/`.

## Parts

- [mcp](references/mcp.md) - The last resort: does it need an MCP server at all, existing servers first, read it before it runs as him, building one on the program's scripting surface, registering and testing it.
