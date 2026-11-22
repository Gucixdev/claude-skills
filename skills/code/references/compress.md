# caveman-compress

caveman's compress skill done by hand: shorter text with the same facts, only when he asks and for a file he names.

- Cut articles, filler (just, really, basically, actually, simply, essentially, generally), pleasantries, hedging
  ("it might be worth", "you could consider"), connective fluff (however, furthermore, additionally); "in order to"
  becomes "to"; drop "you should" / "remember to" and state the action; merge bullets that say the same thing; one
  example per pattern.
- Keep exactly: code, URLs, paths, commands, technical terms, proper nouns, dates, versions, numbers, environment
  variables, every heading's text, list nesting, tables, frontmatter.
- Prose files only (.md .txt, extensionless); never code or config. Move the original to the trash first
  (`rules (trash-not-rm)`); refuse files that look like secrets.

Report what changed in one line: lines before and after, nothing else. A file whose compressed form is not shorter
stays as it was.
