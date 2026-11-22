# cli-everything (mcp)

The last resort. Only when the program has no usable CLI or REST API and live state in a running GUI or a long-lived process is the point.

## 1. Does it need an MCP server?

Claude already has a shell. A program with a good CLI (OpenSCAD, Inkscape, ffmpeg, assimp) is often served better by
a skill with the right commands (`ui (media-cli)`) - zero new code. A server earns its place for: live state in a running
GUI (the open image in GIMP, the scene in Blender or Godot), a long-lived process, structured results that are
expensive to parse, or use from outside the shell.

## 2. Existing servers first (checked 2026-10-18 - verify before installing)

| Program | Server | How it connects |
|---|---|---|
| Emacs | his `emacs-mcp` (dotfiles `emacs/bin/emacs-mcp`, in `mcp/install`) | `emacsclient` to his daemon (`machine (emacs)`) |
| Godot | his toolbox `godot_mcp_server` + `godot-mcp-bridge.mjs` | editor plugin, WebSocket 9090 (`godot`) |
| Blender | blender-mcp add-on (his autostart, port 9876) | add-on socket, arbitrary Python - powerful, careful |
| GIMP | maorcc/gimp-mcp (GIMP 3 plug-in); PyPI `gimp3-mcp` | GIMP 3 Python plug-in + server |
| Krita | cyyprezz/krita-codex-mcp (PyPI `krita-codex-mcp`) | Krita Python plug-in |
| Inkscape | shriinivas/inkmcp, jjjsood/inkscape-mcp-server | Inkscape actions / CLI |
| Ghidra | LaurieWired/GhidraMCP | Ghidra extension + Python bridge |
| ImHex | jmpnop/imhexMCP | read its README for how it reaches ImHex |
| OpenSCAD | quellant/openscad-mcp, fboldo/openscad-mcp-server | the `openscad` CLI |
| Firefox | mozilla/firefox-devtools-mcp (`npx @mozilla/firefox-devtools-mcp@latest`) | his Firefox, own profile (`machine (browsers)`) |
| Chrome | ChromeDevTools/chrome-devtools-mcp (`npx -y chrome-devtools-mcp@latest`) | CDP, `--browser-url` or launch |
| Nyxt | none found | build one (step 4) |

Finding more: SearchMcpRegistry where the app offers it, the official registry (registry.modelcontextprotocol.io),
GitHub search `NAME mcp`, glama.ai and mcp.so listings.

## 3. Read it before it runs as him

A server runs with his user, his files and often an "execute code" tool. Before installing: read the README and the
source (`audit-everything`): what it executes, which ports it opens (bind to 127.0.0.1 only), what it sends out
(telemetry off - `rules (zero-cost)`), how it is updated. Pin a version or commit instead of `@latest` once it works.

## 4. Building one

1. Find the automation surface (`rea`): CLI flags; a scripting API - Blender `bpy`, GIMP 3 Python plug-ins (PyGObject,
   `Gimp`/`Gegl`), Krita's `krita` module, Inkscape `--actions` and `--shell`, Godot EditorPlugin + WebSocket,
   `emacsclient --eval`, Ghidra headless scripts, OpenSCAD CLI, WebDriver BiDi or CDP for browsers, a Lisp REPL for
   Nyxt (check `nyxt --help` for its remote options); D-Bus (`busctl --user introspect`).
2. Shape: for a GUI program, a small add-on inside it that listens on 127.0.0.1 and a thin stdio bridge outside
   (the Blender and Godot pattern); for a CLI program, one stdio server around the commands.
3. Tools: few and coarse, each one a real operation in the program's own terms; read-only tools separate from
   mutating ones; results short text (`code (output)`), errors as text starting `ERROR:`; a timeout on every call; never
   block the program's main thread (Godot lessons in `godot`).
4. Language: the program's own (Python in Blender/GIMP/Krita, GDScript in Godot, Elisp for Emacs); the bridge in
   whatever is already there - Node like his Godot bridge, Python, or bash + jq for a CLI wrapper (MCP over stdio is
   JSON-RPC 2.0, one message per line: `initialize`, `tools/list`, `tools/call`). Deep guidance:
   `anthropic-skills:mcp-builder`.

## 5. Register and test

- `claude mcp add -s user NAME -- CMD ARGS`, then the same line in claude-config `mcp/install` behind its "skip when
  the tool is missing" check, so a new machine gets it.
- Smoke test without a client: pipe `initialize`, `notifications/initialized` and `tools/list` into the server and
  read the reply; `npx @modelcontextprotocol/inspector CMD` for a UI.
- First real calls against a throwaway document or a disposable instance, never his open work; read-only calls first.
- Write what was learned into the program's skill (tools, safety rules), or a new one (`skill-everything`).
