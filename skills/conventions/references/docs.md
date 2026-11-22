# conventions (docs)

Chat is terse (`code (caveman)`); text that stays is plain and complete.

- Normal full sentences - no fragments, no dropped articles. Density still applies: in goes what it is, how to build
  and run it, non-obvious purposes, real gotchas; out goes narrating what the code shows, restating a self-explanatory
  name, padding, over-explaining to someone who reads code.
- Production wording, not self-justification. He corrected this on 2026-08-09 ("to ma byc production ready, zadnych
  gadanek ze no theatre"): no "not theater", "documented, not hidden", "a real X, not hypothetical", "honest gap".
  State the fact: "24bpp has no alpha channel; falls back to the AND mask."
- No overclaiming: "production-ready", "blazing fast", "zero bugs" only with the proof next to it. A recruiter-facing
  review on 2026-10-18 found README claims contradicted by TSan - claims are findings too (`audit-everything`).
- Existing comments in a file you edit are payload: never delete or shorten one you were not asked to change.
- No stylistic-influence namedropping ("inspired by X") in committed text; legal attribution stays.
- Commit messages: `commits`; PR comments to paste: `code (review)`.

Compressing a notes or memory file: `code (compress)`.
