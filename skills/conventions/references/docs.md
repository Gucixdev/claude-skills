# conventions (docs)

Chat is terse (`leanctx (caveman)`); text that stays is plain and complete.

- Normal full sentences - no fragments, no dropped articles. Density still applies: in goes what it is, how to build
  and run it, non-obvious purposes, real gotchas; out goes narrating what the code shows, restating a self-explanatory
  name, padding, over-explaining to someone who reads code.
- Production wording, not self-justification. Readers dislike this: no "not theater", "documented, not hidden", "a real X, not hypothetical", "honest gap".
  State the fact: "24bpp has no alpha channel; falls back to the AND mask."
- No overclaiming: "production-ready", "blazing fast", "zero bugs" only with the proof next to it. A recruiter-facing
  review once found README claims contradicted by TSan - claims are findings too (`audit-everything`).
- Existing comments in a file you edit are payload: never delete or shorten one you were not asked to change.
- No stylistic-influence namedropping ("inspired by X") in committed text; legal attribution stays.
- Commit messages: `commits`; PR comments to paste: `leanctx (review)`.

Compressing a notes or memory file: `leanctx (compress)`.
