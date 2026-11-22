---
name: ship-anything
description: Release and package for others - smallest shippable version, release checklist (tests, identity scan, semver, changelog, tag, gh release, clean-machine check), rollback, where to publish (GitHub, AUR, Flathub, Steam), static binaries, tarballs with SHA256SUMS, AUR/Flatpak/AppImage/deb. Use for release, publish, ship, sell, show, pack, or when a project reaches it works.
metadata:
  priority: "2"
  tags: "#ship #release #publishing #business #dev #pack #build #linux"
  requires: "skill:rules skill:conventions ?cmd:gh skill:code skill:code ?cmd:podman|docker ?cmd:flatpak-builder ?cmd:makepkg"
---

# ship-anything

## Smallest shippable version

The core job, working end to end, documented, installable - nothing else (`code (ponytail)`, lean build). A list of what is
left out goes in the README's status section, not into the release.

## Checklist

1. `./test` green on a clean checkout; `./check` clean.
2. `publish-anything`: `publish-check -H` clean (secrets, identity, paths, filler) over everything since the last release.
3. Version from the commits since the last tag: any `!`/`BREAKING CHANGE` - major, any `feat` - minor, else patch
   (before 1.0: breaking - minor).
4. Changelog for that range (`conventions (doc)`).
5. Annotated tag: `git tag -a vX.Y.Z -m 'vX.Y.Z'`, pushed with his go-ahead (`rules (discipline)`).
6. `gh release create vX.Y.Z dist/* --title vX.Y.Z --notes-file NOTES.md`.
7. Download the release assets on a clean container, check `SHA256SUMS`, run the README example.
8. Tell someone: the repo's README, his GitHub profile, the place the users are (AUR comments, a forum, Steam page).

## Across releases

Don't break userland: a renamed command or flag keeps an alias for at least one release with a deprecation line on
stderr. Old release assets stay up; a bad release gets a fix release (`git revert`), not a deleted tag.

## Where

GitHub Releases for everything; AUR for Arch users; Flathub for desktop apps (review process, check its current
rules); Steam for his games (he chose Steam over itch.io); a Gentoo overlay for himself. Portfolio pieces: pinned repos
with honest READMEs - a recruiter reads the README, the commit history and one source file (`audit-everything`).

## Legal basics

A LICENSE file (MIT, GPL, or dual for his C libraries); third-party licenses and notices included; no trademarked
names in his product names; patent-encumbered codecs (H.264, HEVC) only through system libraries, not his own
encoder, without checking first.

## Earning (zero-cost first)

Freelance and his IT-services business (`machine (personal)`), GitHub Sponsors, dual licensing (a commercial license for
companies that can't take GPL), selling a game on Steam, paid support for a tool clients use. Prices and platform fees
are looked up when it comes to that (`rules (zero-cost)`).

## Packaging

The smallest number of artifacts that cover the people who will install it.

### One binary

- C: `cc -std=c89 -O2 -static -s main.c -o NAME` (unity build), with musl (`musl-gcc -static`) to avoid glibc's
  static-linking traps; `file NAME` and `ldd NAME` ("not a dynamic executable") to confirm.
- Go: `CGO_ENABLED=0 go build -trimpath -ldflags='-s -w' -o NAME .`
- Rust: `cargo build --release --target x86_64-unknown-linux-musl` (`rustup target add` first).
- Reproducible: `SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)`, `-trimpath` / `-ffile-prefix-map=$PWD=.`, sorted
  archives: `tar --sort=name --mtime=@$SOURCE_DATE_EPOCH --owner=0 --group=0 --numeric-owner -czf ...`.

### Single bash tools

The file itself is the package: `install -Dm755 TOOL "$DESTDIR$PREFIX/bin/TOOL"`, the man page from `manwriter` into
`share/man/man1`, completions into `share/bash-completion/completions`; `PREFIX` defaults to `~/.local`, `DESTDIR`
for packagers. Runtime dependencies listed in the header and in the README table.

### Release files

`NAME-VERSION-linux-x86_64.tar.gz` (binary, LICENSE, README, third-party notices) plus `SHA256SUMS` from `sha256sum
*.tar.gz > SHA256SUMS`. A detached signature only once he has a signing key set up for it.

### Distro packages

- Arch/CachyOS: a `PKGBUILD` (`makepkg -si` to test, `namcap PKGBUILD *.pkg.tar.zst` to lint); AUR for others.
- Gentoo: an ebuild in his own overlay; `ebuild NAME-VER.ebuild manifest clean install` in a container.
- Flatpak: a manifest built with `flatpak-builder --user --install --force-clean build MANIFEST.yml`; one file to hand
  out: build with `--repo=repo` as well, then `flatpak build-bundle repo NAME.flatpak APP-ID`. Permissions minimal
  (`rea` the app's real needs).
- AppImage for one-file GUI apps; `.deb` with `dpkg-deb --build` when a client runs Debian (his migration stack).
- Godot: export presets in the project, `godot --headless --export-release "Linux" build/NAME.x86_64`.

### Before calling it packed

Install from the artifact on a clean container of each target (`podman run --rm -it -v "$PWD/dist:/dist:ro" IMAGE`),
run the README example, uninstall. Licenses of everything bundled are in the package.
