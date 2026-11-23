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
- Documentation (README, man page, guides) follows the main rules of ASD-STE100, Simplified Technical English, to about
  80 %. No strict dictionary; the rules are what count:
  - Short sentences: at most about 20 words for a procedure, 25 for a description.
  - Active voice: "The daemon writes the log", not "The log is written".
  - One command per sentence in a procedure; each step is one action, numbered when the order matters.
  - One word, one meaning: pick one name for a thing (the config file, not "settings file" in one place and "rc" in
    another) and keep it; one word for one action ("start", not "launch" and "run" mixed).
  - Say it plainly: simple verbs, no idioms, no phrasal verbs where a plain verb exists ("remove", not "get rid of").
  - Warnings and cautions come before the step they protect, in their own sentence.
  - A noun stack of more than three words is split ("the file that stores the session", not "session storage file path").
  The 20 % that is free: names of commands, flags and APIs stay as they are, and a term of the domain needs no
  replacement.

Compressing a notes or memory file: `code (compress)`.
