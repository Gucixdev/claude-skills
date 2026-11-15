---
name: publish-anything
description: "Make anything safe and clean to put on GitHub or anywhere public - secrets scan, the user's identity and machine paths out of files, comments and commits (a username or home path becomes $USER, $HOME or a path relative to the script), comments and READMEs that read like a person wrote them, not like generated filler. Runs scripts/publish-check over a repo. Use before every push of a public repo, a release, a paste, a demo recording or a post, and whenever the user says publish, push, public, secrets, slop."
metadata:
  priority: "1"
  tags: "#publish #secrets #privacy #comments #github #release #security #quality"
  requires: "skill:rules skill:conventions cmd:git cmd:grep ?cmd:gitleaks"
---

# publish-anything

Nothing goes public before `scripts/publish-check` is clean. It reads the repo, changes nothing, prints `file:line`.

```sh
publish-check [-H] [REPO]    # -H: also the unpushed commits (author e-mails, names, messages)
```

It looks for four things; each has a fix.

## Secrets

gitleaks when installed, else token shapes and `password/token/secret/api_key = value` lines; values are masked in
the report. Fix: the value comes from the environment or `~/.secrets` (mode 600), the repo ships `.env.example` with
empty values. A secret already committed is a leaked secret: revoke it at the provider first, then remove it from
history before anything is pushed. History rewriting is only for commits that were never pushed, and only with the user's
go-ahead (`rules (discipline)`).

## The user's identity and paths

The login name, the home directory and the git name and e-mail are read at run time from the machine, so nothing
personal is written into the check. In files, comments and docs:

| Instead of | Write |
|---|---|
| `/home/<login>/x` | `$HOME/x`, `~/x`, `${XDG_CONFIG_HOME:-$HOME/.config}/x` |
| the login name as a user | `$USER`, `$(id -un)`, or a neutral `alice` / `user` in examples |
| `/data/project/...`, a mount of the user's disk | a path relative to the script: `$(dirname "$(readlink -f "$0")")`, or an overridable variable with a default |
| the user's name or e-mail | the public handle and the noreply address (`rules (identity)`) |

Test fixtures that need a fixed user (a VM image, a fake PAM) get a made-up name such as `demo`, not the user's login.
In comments the same rule holds: "run as the user", not "run as" plus the login.

## Comments that do not read as generated

The tells people mock, and the check flags: emoji in comments, "Let's", "Certainly", "robust", "seamless",
"comprehensive", "leverage", "delve", "It's important to", "Note that", "blazing", "production-ready", and the
self-justifying lines ("not theater", "honest gap", "documented, not hidden"). Beyond the list:

- A comment says why, or what is not obvious; it never repeats the line under it (`i++ // increment i`).
- No banners, no section art, no step numbering of obvious code, no history in comments (git has it), no
  `TODO: improve`.
- One header comment per file: what it is, how it is used, the gotcha. Plain sentences, the tone of a man's notes
  to themselves, not a sales page.
- The README opens with what the tool does and one real command with its real output (`autodemo` records it).
  Claims need the number next to them or they go (`conventions (docs)`, `audit-everything`).
- Commit messages: Conventional Commits, one line of substance, no filler (`conventions (commits)`).

A deliberate mention (this skill's own examples) carries `publish-check: ok` on the line and is skipped.

## Order

1. `publish-check -H .` - fix everything it prints, run it again until `clean`.
2. The tests and `./check` still pass after the edits (`verify`).
3. `git fetch` and look at whether the remote has something newer before pushing (`rules (discipline)`).
4. Push only with the user's go-ahead for that repo; then `ship-anything` for the release.
