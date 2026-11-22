---
name: skill-everything
description: Create, merge, split and maintain skills - the header standard (priority, hashtags, typed requires), turning session lessons and his corrections into skills, where a lesson belongs (skill, memory, CLAUDE.md), bin/skills check/index/install. Use when writing or editing any SKILL.md, at the end of a session with lessons worth keeping, or on skill.
metadata:
  priority: "1"
  tags: "#thirdparties #meta #skills #memory"
  requires: "skill:rules cmd:bash cmd:awk"
---

# skill-everything

Skills live in the public repo Gucixdev/claude-skills (private ones live in a second, private repo and are linked in beside them), `skills/NAME/SKILL.md`, one concern per skill (unix: small
and composable, not a monolith - thirdparties-techniques was split on 2026-10-18 for this reason).

## The header

```yaml
---
name: bash-everything
description: One line, at most 1024 characters, no angle brackets - what it does and when to use it, with the words a request would contain (Polish ones too where he uses them).
metadata:
  priority: "2"
  tags: "#thirdparties #bash #cli #rewrite"
  requires: "skill:rtfm cmd:bash ?cmd:fzf ?cmd:jq|python3 lib:ncurses py:yaml node:playwright mcp:emacs env:GH_TOKEN file:~/.secrets font:Misc+Fixed el:magit"
  upstream: "owner/repo@commit"
---
```

- Top-level keys are only those claude.ai accepts (name, description, license, allowed-tools, metadata, compatibility);
  everything of ours sits under `metadata`, as one-line strings. `name` equals the folder name, kebab-case, at most 64.
- Quote a value that contains `: ` or ` #` or starts with a symbol; tags are always quoted (a bare `#` starts a YAML
  comment and the field would be empty).
- `priority`: `0` always - loaded at the start of every session, keep these few and short; `1` high - load as soon as
  the task touches the tags; `2` normal - load when the task is one of these; `3` only when he names it. When two
  skills disagree the lower number wins; his explicit instruction and a repo's CLAUDE.md beat every skill.
- `tags`: hashtags, lowercase, one concept each: a language (`#c #rust #bash #python #gdscript #elisp`), a topic
  (`#ui #security #testing #git`), a group (`#thirdparties` for the technique skills). Reuse existing tags -
  `bin/skills tags` lists them with counts; `rg '#rust' skills/` finds them too.
- `requires`: what the skill needs, space-separated `TYPE:VALUE`; `?` in front = optional (a fallback exists);
  `cmd:a|b` = either; `+` stands for a space. Types: `skill` (in this repo; an account or plugin skill by its full
  id, `skill:anthropic-skills:mcp-builder`), `cmd` (on PATH), `lib` (pkg-config or ldconfig), `py` (importable),
  `node` (npm package), `mcp` (a configured MCP server), `env` (a set variable; the value is never printed), `file`,
  `font` (fc-list), `el` (an Emacs library).
- `upstream`: where a technique came from and which commit was read, so it can be re-checked later.

## bin/skills

`skills ls '#bash'` (TSV), `skills tags`, `skills req NAME` (checks every requirement on this machine, follows
`skill:` ones), `skills check` (the rules above, loops in `requires`, a stale index), `skills index` (rewrites the map
in `skills/claude/SKILL.md`), `skills install [-n]` (links every skill into `~/.claude/skills`; what was there goes
to the trash), `skills eval [NAME]` (runs `evals/NAME/*.case` - a prompt plus expect/forbid regexes - with the skill and
without it against a local OpenAI-compatible server such as Qwen on llama-server, `-b claude`, or `-b cmd`; prints the
pass rate and the lift; a skill change is judged by it), `skills export [NAME]` (a flat card per skill under a byte
cap, default 1500, plus an AGENTS.md router, for a small model such as Qwen; a skill over the cap needs a shorter digest), `skills find QUERY` (BM25 over every skill and part; the top chunks with
path:line, byte-capped - for a small context or when the right part is unknown), `skills retrieve TASK` (the same chunks ranked by local MiniLM sentence embeddings in numpy plus a lighter BM25 vote, byte-capped;
embeddings cached by chunk hash in `~/.cache/claude-config/skills-index`, first build minutes, then only edited chunks; without the model or with
`--lexical` it is words only; `evals/recall` prints recall@3/@5 of find and retrieve on `evals/retrieval*.tsv`). Before every commit: `bin/skills check`; after adding or
renaming: `bin/skills index`.

## Lessons from a session into skills

Every session feeds this (his wish, 2026-11-19: "z kazdej sesji robi skilla" - a small skill factory): SessionEnd
(`hooks/session-end`) queues a digest of the finished session - his corrections and wishes, all his messages,
the tools, commands and files - and `hooks/session-start` says in the next session how many wait. Take each with
`bin/skills factory next`; the factory has its own folder, `skills/factory/` (his words: "ma poprostu swoj wlasny
folder gdzie tworzy skille"): its skills are `factory-NAME/SKILL.md`, priority 2, `#factory` among the tags, and it
does not edit his skills elsewhere - he moves one out when he wants it there. Commit, then `bin/skills factory done
SID "what came of it"` ("nothing" when it held nothing lasting).

1. Collect: his corrections (his words, the date), friction that repeated, what worked and should repeat, tool
   knowledge found the hard way (a flag, a version gate, a gotcha).
2. Sort each one: about how I work - a skill; about a project (paths, state, decisions) - that project's CLAUDE.md or
   memory; a fact about him - `machine (personal)` or `machine`; a one-off - nothing.
3. Find its skill: `skills ls '#tag'`, `rg -i word skills/`. Add it there when it fits that skill's one concern;
   otherwise a new skill. Merge two skills that share most rules or triggers; split one that answers two unrelated
   triggers.
4. Write the rule, the why (his words when they carry it, with the date), how to apply it, one real example.
   Production wording (`conventions (docs)`); never a command or flag that was not checked to exist (`rules (rtfm)`).
5. `bin/skills check && bin/skills index`, commit (`feat(skills): ...`, `docs(skills): ...`, `refactor(skills): ...`),
   push. A merged or retired skill: `git mv skills/X trash/skills/X` (`rules (trash-not-rm)`).

## Body

Under 500 lines; detail beyond that goes to a file next to it (`reference.md`, never a second `SKILL.md`). Imperative,
dense, real examples with dates. A skill pays back only in sessions that hit its pattern; one that never triggers
still costs its description in every session.

## Hygiene of always-loaded text

CLAUDE.md, priority-0 skills, every skill's description, MCP tool lists - all cost every message. A rule repeated in
two skills stays in the most specific one. Context is removed only once a pointer to where it now lives exists. A
fact that changed is replaced, not contradicted by a second note. Memory files absorbed into a skill move to
`trash/memory/` with their index line removed.

## Account skills

The claude.ai skill card (`propose_skills`) keeps only name, description and body - metadata is dropped, so the repo
stays the source of truth. In a cloud session the repo is attached and its skills load from `.claude/skills`.
