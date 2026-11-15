# conventions (commits)

The user's rule: Conventional Commits everywhere, in every repo.

`<type>(<scope>): <summary>` whatever the existing history looks like; pushed history is not rewritten to match.
- Type: feat, fix, refactor, perf, docs, test, chore, build, ci, style, revert. Breaking: `!` before the colon
  (`feat(api)!: ...`) and a `BREAKING CHANGE:` footer.
- Summary imperative ("add", not "added"), lowercase after the colon, no trailing period; 50 characters when possible,
  72 at most.
- Body only for a non-obvious why, a breaking change, migration notes, linked issues; wrapped at 72, `-` bullets,
  `Closes #42` / `Refs #17` at the end. Always a body for breaking changes, security fixes, data migrations, reverts.
- Never: "This commit...", "I", "we", "now", "currently", the file name the scope already gives, emoji, marketing tone,
  a list of every touched file. AI attribution only as a trailer, only where a rule asks for one.
- Write it like the developer who did the work and is in a hurry: what was tricky, what was verified, which tradeoff
  was made - the rest is in the diff.
