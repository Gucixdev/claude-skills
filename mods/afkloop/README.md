# afkloop

A mod for Claude Code that keeps a session working while you are away. `/afkloop on 8h` makes every stop a
hand-back: Claude gets the next open line of your `todo.md` and carries on, until the time runs out, the list has
nothing open, or a brake of 300 blocked stops is reached (a loop that makes no progress ends itself).

```
/afkloop on [90m|8h]   block every stop for that long (default 8h)
/afkloop off           back at the keyboard
/afkloop status        mode, minutes left, stops blocked so far
```

A line of `todo.md` is open unless it is empty, a `#` comment, holds `zrobione`, `done` or `blocked`, starts with
`[x]` (ticked) or holds `[?]` (waits for your answer). The file is the `todo` option, else `$CLAUDE_CONFIG/todo.md`,
else `~/.claude-config/todo.md`. `max` sets the brake.

This is the forced mode of the `afk-gate` hook as a mod, in one place with its command and status line. It does not
yet detect that you are idle by itself (the hook's `auto` mode) and does not pause on a usage limit (agentd's job);
both are open. State lives in the mod's store, separate from the hook's files, so run one of the two, not both.
Tests: `claude plugin test .` (8 pass).
