# rules (identity)

Set the public identity once per user and keep it in one place; the examples below use `PUBLIC` for the public login and
`ID` for its numeric GitHub id.

- Public name everywhere a commit or a published file carries one: the user's public handle (`PUBLIC`). The local Linux
  login, an old handle, the real name and the e-mail address never go into an author field, a license, a README, a
  plugin manifest `author=`, a header comment or a commit message.
- Commit identity: `PUBLIC <ID+PUBLIC@users.noreply.github.com>`. Locally the real name and address live in a file the
  main git config includes (`~/.gitconfig.local`), never in a repo.
- If the GPG key's UID is still an old address, noreply commits show "Unverified" until a UID with the noreply address is
  added; say so instead of working around it.
- Copyright in licenses the user owns: `Copyright (c) YEAR PUBLIC`. Third-party code keeps its own author and license,
  credited next to it.
- Secrets: in `~/.secrets` (mode 600, `KEY=value`, loaded by the shell profile), never in a repo. A token that was
  committed locally is scrubbed from history before any push, and revoked if it ever left the machine.

## The scan before a public push

Over the range being pushed (`@{u}..HEAD`, or `origin/main..HEAD` for a new branch). Identities are checked by
allowlist, so no personal detail has to be written into the check itself; put the local login and the e-mail domain in
`PATTERN` from the environment, not in a file:

```sh
git log --format='%ae%n%ce' @{u}..HEAD | sort -u          # only the noreply address
git log --format='%an%n%cn%n%B' @{u}..HEAD | grep -niE "$PATTERN"
git diff @{u}..HEAD | grep -niE "$PATTERN|(token|secret|passw(or)?d)[[:space:]]*[:=]"
```

Anything that comes back is fixed before the push, except deliberate mentions like this skill. In a cloud session the
sandbox's global identity is `Claude <noreply@anthropic.com>`: set the repo's own `user.name`/`user.email` to the public
identity before the first commit. `skills/anything/publish-anything/scripts/publish-check` automates the scan.
