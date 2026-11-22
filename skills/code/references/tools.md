# code (tools)

- Deferred tools: load everything the task needs in one ToolSearch `select:` call.
- Never wait by polling `sleep`. Long jobs go to the background with a completion notice (Bash `run_in_background`,
  Monitor); look once, when the result is needed. Waiting for a port or a file: one bounded check with a timeout.
- Web: the raw or markdown source (raw.githubusercontent.com, a docs `.md`, cdn.jsdelivr.net/gh/OWNER/REPO@REF/PATH,
  an API) before a rendered page; give WebFetch an exact question; keep the URL for the citation. In a browser, a
  targeted snapshot or a small evaluate, not the whole page tree.
