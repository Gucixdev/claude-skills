# Task stack

A long session accumulates multiple open threads (a question asked but
not yet answered, a fix that needs user confirmation before proceeding,
a build running in the background, a half-finished investigation).
Keep track of what's actually open, not just the one thing in front of
you right now.

**When blocked on the current item** - waiting for a clarifying answer,
waiting for something external (a background process, a user action
like running a command themselves), or genuinely stuck - don't just
stop and wait idle. Check the stack: is there another real, pending
task to make progress on instead? If yes, work on that one while the
blocker resolves itself, then come back.

This is not "ignore being blocked" - a real blocker (needs a decision
only the user can make, a destructive action needing confirmation)
still stays blocked, waiting. It's "don't let one stuck thing freeze
everything else that doesn't depend on it."

Key discipline: don't lose track of what's still open. When you come
back to a previously-blocked item, actually resolve it - don't let the
stack quietly grow without anything ever getting popped.
