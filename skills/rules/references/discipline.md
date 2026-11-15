# rules (discipline)

Git and agents: what is done only when the user says so.

## Git

## Commit and push

- Commit as work lands, small and often. Never push or open a PR until the user says so for that repo; a go-ahead covers
  that repo and that batch, not a later one or another repo. "Is this ready to push?" is a question, not an ask.
- A go-ahead is recorded in the project's notes with its date ("push this repo, 2026-10-18") so it is not asked again.
- A cloud session's container is thrown away at the end: a commit that is not pushed is lost. When the user hasn't said
  anything about a repo there, ask once at the first commit.
- Do not push an empty project. A repo that holds only a README, a one-line idea or a placeholder file is not
  published (a 57-byte repo once went up and the user did not want that). It stays local, committed,
  until it builds or runs and a reader gets something from it; if it was asked for explicitly, say it is a stub
  and ask once. Before any push, look at what the push contains (`git ls-tree -r HEAD`, `wc -c`), not only at its
  name.
- Before any public push: the identity scan (`rules (identity)`). Never force-push, rewrite pushed history or delete a branch
  unasked (`rules (trash-not-rm)`).

### Commit messages

Conventional Commits in every repo, written the `conventions (commits)` way.

### Mechanics learned the hard way

- When ssh to github.com:22 hangs, push over `ssh://git@ssh.github.com:443/OWNER/REPO.git`
  (`-i ~/.ssh/KEY -o IdentitiesOnly=yes`, known_hosts checked against `gh api meta`).
- A gh token without the `workflow` scope is refused on an HTTPS push that touches `.github/workflows`
  (`gh auth refresh -s workflow` fixes it; ask first). Either way, commit a workflow on a local branch and push it with `git push origin
  ci:main`: a refusal then leaves `main` as it was.
- Cloud sessions can't create repos (`gh repo create` and the API return 403); only attached repos work, so the user
  creates an empty one in the web UI. A new repo with a default README: `git merge --allow-unrelated-histories`, keep
  the real README.
- Pulling a subproject out with its history: `git subtree split --prefix=PATH -b NAME`, then push that branch into the
  new repo.
- Pushing from a shallow clone: fetch the default branch first, so the push sends a thin pack.
- Tests never touch the real global git config: `HOME` and `GIT_CONFIG_GLOBAL` point at a temp dir (a test overwrote
  the user's credential helpers once).

## Agents (forks)

Spawning many agents is not the default: two parallel forks once touched the same files - a real race, not only
double cost.

- Work through a large but well-specified task directly, file by file, checking against the project's tests.
- Fork only when the user asks, or the task is genuinely too large for the context and nothing overlaps other work in
  flight. Several forks in one tree: partition file ownership before they start.
- Redirect a running fork with SendMessage to its id or name; a new Agent call "to continue" spawns an unrelated
  duplicate.
- Not a fork: an HTTP or CLI call to a local model (llama.cpp's `llama-server`, ollama) - normal tool use.
- A council the user asked for (`workflow (llm-council)`) is a fork the user asked for: one subagent per seat, the same brief for each,
  answers kept within the brief's length cap.

### When a subagent is used

Its result lands in this context verbatim, so ask for compressed returns:
- Locating: fan out in the first turn, stop once the places can be named, cite only ranges actually read:
  `path:START-END  reason` (grouped Defs / Callers / Tests, a totals line), or `no relevant locations found`.
- A builder gets one or two known files; three or more means do it here. Receipt: `path:range - change` and
  `verified: re-read OK`; otherwise `too-big`, `needs-confirm`, `ambiguous` or `regressed` as the first word.
- A reviewer returns findings only, sorted by file and line, with a totals line, or `No issues.`
- Re-check cited line ranges before editing on them. The same receipt shape works for reporting my own edits.
