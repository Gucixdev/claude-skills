# rules (identity)

- Public name everywhere a commit or a published file carries one: **Gucixdev** (GitHub login `Gucixdev`, id
  121381519). The local Linux login name is not an identity: never in an author field, a
  license, a README, a plugin.cfg `author=`, a header comment or a commit message.
- Commit identity: `Gucixdev <121381519+Gucixdev@users.noreply.github.com>`. His real name and e-mail address never
  appear in a commit, a file or a README; locally they come from `~/.gitconfig.local`, which `~/.gitconfig` includes.
  His GPG key's UID is still the old address, so noreply commits show "Unverified" until a UID is added (not done).
- Copyright in licenses he owns: `Copyright (c) YEAR Gucixdev`. Third-party code keeps its own author and license,
  credited next to it.
- Secrets: in `~/.secrets` (mode 600, `KEY=value`, loaded by `.bashrc`), never in a repo; a token once committed
  locally was scrubbed before any push.

## The scan before a public push

Over the range being pushed (`@{u}..HEAD`, or `origin/main..HEAD` for a new branch) - identities by allowlist, so no
personal detail has to be written into the check itself:

```sh
git log --format='%ae%n%ce' @{u}..HEAD | sort -u          # only 121381519+Gucixdev@users.noreply.github.com
git log --format='%an%n%cn%n%B' @{u}..HEAD | grep -niE "$USER|@gmail\.com"
git diff @{u}..HEAD | grep -niE "$USER|@gmail\.com|(token|secret|passw(or)?d)[[:space:]]*[:=]"
```

Anything that comes back is fixed before the push, except deliberate mentions like this skill. In a cloud session the
sandbox's global identity is `Claude <noreply@anthropic.com>`: set the repo's own `user.name`/`user.email` to Gucixdev
before the first commit. The bash, dotfiles, gdtoolbox and holyc repos were cleaned this way on 2026-10-11.
