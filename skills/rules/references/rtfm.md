# rules (rtfm)

Flags, subcommands, config keys and APIs drift between versions and projects; what I remember may be wrong, old or
for another tool. Too lazy to debug a wrong guess later, so read once up front. Stubborn means: a plausible-looking
flag is not an answer - keep going down the list until the exact line is found, then quote it. Familiar is not
checked either: a flag that feels known still gets its line looked up when the tool is niche or fast-moving or the
version is new to me (`rules (calibration)`, base rates).

## The order

1. The installed version: `tool --version`. Docs for another version are a guess. And which implementation runs:
   `type -a tool` - a locally built replacement may shadow the standard one (a home-grown fzf, wrapper scripts), and GNU, BSD
   and busybox tools take different flags, so read the docs of the one that will run.
2. `tool --help`, `tool help SUBCOMMAND`, `tool SUBCOMMAND -h`; bash builtins: `help NAME`.
3. `man tool`, the right section (`man 5 crontab`, `man -k word`, `apropos`), `info coreutils 'ls invocation'`;
   `MANPAGER=cat man tool | grep -n -- '--flag'` to find the line instead of paging.
4. Installed docs and examples: `/usr/share/doc/PKG`, the package's own example configs.
5. Language docs offline: `python3 -m pydoc mod`, `go doc pkg.Func`, `cargo doc --open` or the crate source, `perldoc`,
   Emacs `describe-function` / `describe-variable`, Godot `godot --doctool`.
6. The source: `rg` in the tool's own repo or the installed files (`rpm -ql`/`pacman -Ql`/`equery files`), for the
   real flag table or the real default. An error message's exact text, found with `rg -F`, leads to the condition
   that prints it.
7. Upstream docs, raw form first (a docs `.md`, raw.githubusercontent.com, cdn.jsdelivr.net/gh/OWNER/REPO@REF/PATH,
   the project's API), then the rendered page.
8. The issue tracker, closed issues included, before excusing a failure.
9. Only then a small experiment, in a scratch directory or a throwaway profile, never on the user's live data.

Real cases where guessing would have been wrong: `rkhunter --cronjob` implies three separate flags; dinit's directive
is `working-dir`; `emacs --fg-daemon` and `--daemon` are two different, non-combinable modes; upstream fzf gained `--footer` and
`--id-nth` only in recent releases (fzf's CHANGELOG and `fzf --version` tell which).

## Web research

- Primary sources (official docs, man pages, source, the vendor's page) over secondhand summaries or memory.
- WebSearch: standard first for routine facts; extended when standard comes back thin, off-target or stale, or up
  front for fast-moving topics (prices, releases, recent events) and niche facts.
- A plain fetch is the default; a real browser only when a page needs rendering or a login (`rules (research)`).
- Cite briefly: the fact, the source named inline, no pasted wall of the page.

## Reporting a tool's bug upstream

Start from the real errors. Search the tracker (closed too) first - a closed fix defines intended behaviour, and
failing against it is a regression. Don't trust an error message's account of itself: vary one thing at a time to
find the real rule. No minimal reproduction, no issue - report what was tried instead. One issue per problem: what
happened, what was expected, the exact repro, version, OS; no guessing at internals.

## Writing docs and skills

Never document a command, flag, tool or path that has not been checked to exist.
