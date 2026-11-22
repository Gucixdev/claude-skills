# rules (trash-not-rm)

His rule (2026-10-18): "nic nie zostaje usuwane tylko przenoszone do folderu trash, a pliki co zmianę mają być
wersjonowane, by zawsze można się było cofnąć, nawet po zamknięciu edytora".

## What counts as deleting

`rm`, `rmdir`, `unlink`, `shred`, `find -delete`, `git clean`, `git rm` of an untracked or uncommitted file, `> file`,
`truncate`, `mv` or `cp` onto an existing file, `sed -i` on a file outside git, `git reset --hard`, `git checkout --`
over uncommitted work, `git push --force`, history rewrites, `docker/podman rm` of a volume, dropping a table. Each
needs the same care as `rm`.

## What to do instead

- A file or folder that should go: the trash. His own `trash FILE...` (Gucixdev/bash, the freedesktop spec without
  trash-cli), else `gio trash PATH`, else `trash-put PATH`, else by hand into
  `${XDG_DATA_HOME:-~/.local/share}/Trash/files/` plus `info/NAME.trashinfo` (`[Trash Info]`, `Path=`,
  `DeletionDate=`) - the layout every file manager restores from. Never `rm`.
- Inside a repo: `git mv PATH trash/PATH` (a `trash/` folder at the repo root, same relative path), committed, so it
  is visible in the tree and in history. Merged-away skills went to `trash/skills/` this way.
- Replacing a file: the old version goes to the versions store first (below); on his machine the Claude Code hook does
  it for Write and Edit, and his Emacs (dev-files) on every save.
- Cleaning build output, caches, a scratch directory I created this session: fine to clear - it is regenerable and
  mine. Anything else is his.

## Before anything leaves its place (even with his yes)

Lesson from 2026-09-06, when `make.c`/`automake.c` were lost: `git rm ... || rm -f ...` fell through to `rm` because the
files were never committed, and only afterwards a grep showed a sibling project's build calling `automake`.
1. Is it recoverable? `git ls-files --error-unmatch PATH` and `git status` on the real path, not "git rm succeeded".
2. Who depends on it? Grep the whole tree and the sibling projects, not only the folder being edited.
3. If either answer changes the question he answered, stop and ask again - my framing was provisional.

## Versions store

`bin/versions` in claude-config keeps the earlier content of every file changed through his Emacs (every save) or
through Claude's Edit and Write tools (the `hooks/snap-before-edit` hook), in
`${VERSIONS_STORE:-~/.local/share/versions}` - one folder, Emacs numbered-backup names
(`/home/u/dev/x/main.c` becomes `!home!u!dev!x!main.c.~7~`), each copy dated when that content was written. It
outlives the editor and the session; nothing is removed from it.

    versions ls [FILE]               a file's versions, or every file that has some
    versions show FILE [N]           version N (default: the newest)
    versions diff FILE [N]           what changed since version N
    versions restore FILE [N]        put it back; the current content is stored first, so this can be undone
    versions rewind [-n] TIME [DIR]  every file under DIR back to its content at TIME ("30 min ago", "11:30")

A change made some other way (`sed -i`, a script) is not caught: run `versions snap FILE` first.

## The hook that enforces it

On his machine `hooks/no-rm` (PreToolUse on Bash) refuses rm, rmdir, unlink, shred, `find -delete` or `-exec rm`,
`git clean` and `git rm` without `--cached` - also behind sudo, xargs, env, `bash -c` or eval - unless every path is
under /tmp. When it refuses, the reason says what to do instead: `trash PATH`, or `git mv PATH trash/PATH` in a repo.
Never work around it (another command that deletes, a script file that does it); ask him if a real delete is needed.
The hook reads the command as written: `rm -rf "$dir/x"` is refused even when `$dir` is under /tmp. For scratch work
take a fresh `mktemp -d` each time instead of cleaning an old one.

## Never without an explicit ask

Rewriting pushed history, force-pushing, emptying the trash, deleting a branch, a repo, a container volume or a
database, `memory_delete`.
