# rules (discipline)

Git and agents: what is done only when he says so.

## Git

## Commit and push

- Commit as work lands, small and often. **Standing go-ahead (2026-11-22, "wolę pushować niż na dysku kisić"):** his own
  repos get finished work pushed right after the commit (`PUSH_OK=1 git push`, which `push-gate` lets through), so
  nothing waits on the disk. The limits, all still in force:
  - only finished, checked work: tests green, the project's own check passes, nothing half-moved; a dirty tree is
    never pushed around, only commits are
  - a repo with no remote yet gets a **private** one first (`gh repo create --private`); public is a separate ask, then
    `publish-anything` and the identity scan run before the first public push
  - the empty-project rule below, the identity scan, no force-push, no history rewrite, no branch delete stand
  - not his repo, a PR, a release or a tag: still only when he asks
  Earlier per-repo go-aheads, kept for the record: Gucixdev/bash and dotfiles (2026-10-10/11), vecindex ("pushuj
  odrazu", 2026-10-18), claude-config skills ("skille spushuj na githuba, one muszą być w repo", 2026-10-18).
- "Is this ready to push?" is still a question, not an ask.
- A cloud session's container is thrown away at the end: a commit that is not pushed is lost. When he hasn't said
  anything about a repo there, ask once at the first commit.
- Do not push an empty project. A repo that holds only a README, a one-line idea or a placeholder file is not
  published (2026-11-15: `ginit` went up with a 57-byte file and he did not want that). It stays local, committed,
  until it builds or runs and a reader gets something from it; if it was asked for explicitly, say it is a stub
  and ask once. Before any push, look at what the push contains (`git ls-tree -r HEAD`, `wc -c`), not only at its
  name.
- Before any public push: the identity scan (`rules (identity)`). Never force-push, rewrite pushed history or delete a branch
  unasked (`rules (trash-not-rm)`).

### Commit messages

Conventional Commits in every repo, written the `conventions (commits)` way.

### Mechanics learned the hard way

- His machine: ssh to github.com:22 sometimes hangs - push over `ssh://git@ssh.github.com:443/Gucixdev/REPO.git`
  (`-i ~/.ssh/github -o IdentitiesOnly=yes`, known_hosts checked against `gh api meta`).
- His gh token has no `workflow` scope: an HTTPS push that touches `.github/workflows` is refused
  (`gh auth refresh -s workflow` fixes it; ask first). A cloud session's credentials for an attached repo did push a
  workflow (gael, 2026-10-19). Either way, commit a workflow on a local branch and push it with `git push origin
  ci:main`: a refusal then leaves `main` as it was.
- Cloud sessions can't create repos (`gh repo create` and the API return 403); only attached repos work, so he
  creates an empty one in the web UI. A new repo with a default README: `git merge --allow-unrelated-histories`, keep
  the real README.
- Pulling a subproject out with its history: `git subtree split --prefix=PATH -b NAME`, then push that branch into the
  new repo.
- Pushing from a shallow clone: fetch the default branch first, so the push sends a thin pack.
- Tests never touch the real global git config: `HOME` and `GIT_CONFIG_GLOBAL` point at a temp dir (a test overwrote
  his credential helpers once, 2026-10-17).

## Agents (forks)

He said "nie rób zbyt dużo agentów" (2026-08-01) after two parallel forks touched the same files - a real race, not
only double cost.

- Work through a large but well-specified task directly, file by file, checking against the project's tests.
- Fork only when he asks, or the task is genuinely too large for the context and nothing overlaps other work in
  flight. Several forks in one tree: partition file ownership before they start.
- Redirect a running fork with SendMessage to its id or name; a new Agent call "to continue" spawns an unrelated
  duplicate.
- Not a fork: an HTTP or CLI call to a local model (llama.cpp's `llama-server`, ollama, cavellama) - normal tool use.
- A council he asked for (`workflow (llm-council)`) is a fork he asked for: one subagent per seat, the same brief for each,
  answers kept within the brief's length cap.

### When a subagent is used

Its result lands in this context verbatim, so ask for compressed returns:
- Locating: fan out in the first turn, stop once the places can be named, cite only ranges actually read:
  `path:START-END  reason` (grouped Defs / Callers / Tests, a totals line), or `no relevant locations found`.
- A builder gets one or two known files; three or more means do it here. Receipt: `path:range - change` and
  `verified: re-read OK`; otherwise `too-big`, `needs-confirm`, `ambiguous` or `regressed` as the first word.
- A reviewer returns findings only, sorted by file and line, with a totals line, or `No issues.`
- Re-check cited line ranges before editing on them. The same receipt shape works for reporting my own edits.
