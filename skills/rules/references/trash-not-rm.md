# rules (trash-not-rm)

The rule: nothing is deleted, only moved to a trash folder, and every change to a file is versioned, so it can always be
undone, even after the editor is closed.

## What counts as deleting

`rm`, `rmdir`, `unlink`, `shred`, `find -delete`, `git clean`, `git rm` of an untracked or uncommitted file, `> file`,
`truncate`, `mv` or `cp` onto an existing file, `sed -i` on a file outside git, `git reset --hard`, `git checkout --`
over uncommitted work, `git push --force`, history rewrites, `docker/podman rm` of a volume, dropping a table. Each
needs the same care as `rm`.

## What to do instead

- A file or folder that should go: the trash. A `trash FILE...` command if the system has one, else `gio trash PATH`, else `trash-put PATH`, else by hand into
  `${XDG_DATA_HOME:-~/.local/share}/Trash/files/` plus `info/NAME.trashinfo` (`[Trash Info]`, `Path=`,
  `DeletionDate=`) - the layout every file manager restores from. Never `rm`.
- Inside a repo: `git mv PATH trash/PATH` (a `trash/` folder at the repo root, same relative path), committed, so it
  is visible in the tree and in history. Merged-away skills went to `trash/skills/` this way.
- Replacing a file: the old version is stored first (see Versions below).
- Cleaning build output, caches, a scratch directory I created this session: fine to clear - it is regenerable and
  mine. Anything else is the user's.

## Before anything leaves its place (even with the user's yes)

A real case: when `make.c`/`automake.c` were lost, `git rm ... || rm -f ...` fell through to `rm` because the
files were never committed, and only afterwards a grep showed a sibling project's build calling `automake`.
1. Is it recoverable? `git ls-files --error-unmatch PATH` and `git status` on the real path, not "git rm succeeded".
2. Who depends on it? Grep the whole tree and the sibling projects, not only the folder being edited.
3. If either answer changes the question the user answered, stop and ask again - my framing was provisional.

## Versions

Keep the earlier content of a file before it is changed, so any change can be undone after the editor or the session
is closed: a commit before the edit, or a copy into a store (one folder, one numbered copy per change, dated by when
that content was written, nothing ever removed from it). A PreToolUse hook on Edit and Write can do the copy for an
agent; an editor's numbered backups do it for hand edits. A change made some other way (`sed -i`, a script) is not caught:
copy the file first.

## A hook that enforces it

A PreToolUse hook on Bash can refuse rm, rmdir, unlink, shred, `find -delete` or `-exec rm`, `git clean` and `git rm`
without `--cached` - also behind sudo, xargs, env, `bash -c` or eval - unless every path is under /tmp, and say what
to do instead (`trash PATH`, or `git mv PATH trash/PATH` in a repo). Where such a hook is installed, never work around it
(another command that deletes, a script file that does it); ask the user if a real delete is needed. A hook reads the
command as written: `rm -rf "$dir/x"` is refused even when `$dir` is under /tmp. For scratch work take a fresh
`mktemp -d` each time instead of cleaning an old one.

## Never without an explicit ask

Rewriting pushed history, force-pushing, emptying the trash, deleting a branch, a repo, a container volume or a
database, `memory_delete`.
