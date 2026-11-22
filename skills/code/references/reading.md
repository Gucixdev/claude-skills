# code (reading)

Reading more is not understanding more; the window is shared with everything else in the session, and most of the
bill is input. lean-ctx ships an MCP server, hooks and a proxy; as a tool layer it reaches about 5% of the window and
adds a fixed per-turn prefix, so only its rules are kept.

## Reads

- Fewer round trips beat smaller outputs. One call that answers the question beats three small ones; never add a call
  to save a few hundred tokens. Independent lookups go out in the same turn, in parallel.
- Pick the read by intent: "where / how is X handled" -> a search (`mcp__emacs__grep`, `rg`), not whole files; "who
  calls this / what breaks" -> search the callers before editing; a file needed only for context -> its outline or
  signatures, then the one range that matters; a file about to be edited, or a small one -> whole; after an edit ->
  the diff, not the file again.
- Files go through the read and search tools (`mcp__emacs__*` on his machine, else the built-ins), not `cat`/`sed`/
  `grep` in the shell.
- Point at code by `path:line` instead of pasting it. Replacing a large block just read: by line range, only right
  after reading those exact lines (line numbers drift).
- What is in context is not read again. A long output saved to a file is sliced (`head`, `grep`, `jq`), never re-read
  line by line, and the command is not re-run to see it again.
- Leave vendored, generated and build directories out of searches.

## Not adopted, on purpose

The lean-ctx MCP server and its `ctx_*` tools (compose, anchored patching, callgraph and semantic index, knowledge
graph, ledgers, dashboards, addons), shell hooks, the request proxy, its density levels with abbreviations, symbols and
token budgets.
