# claude-skills

A set of [Claude Code](https://claude.com/claude-code) skills for everyday engineering work: how to write and verify
code, how to ship and publish it, how to work without constant check-ins, and a few recipes for model weights and
reverse engineering. Each skill is a small folder with a `SKILL.md` and, where the topic is big, a `references/` folder
that is only read when the situation comes up, so the always-loaded part stays short.

## Install

```sh
git clone https://github.com/Gucixdev/claude-skills.git
cd claude-skills
bin/skills install -n     # show what would be linked into ~/.claude/skills
bin/skills install        # link every skill; anything in the way goes to the trash, nothing is deleted
```

Skills are read from `~/.claude/skills`; Claude Code lists their descriptions at the start of a session and loads the
body when a task matches. Start with the `claude` skill: it is the map, with each skill's priority and hashtags.

Optional hooks (wire them in Claude Code's `settings.json` yourself):

- `hooks/no-rm` - PreToolUse hook for Bash that refuses commands that delete files outside `/tmp` (moving to the
  trash instead); `hooks/goal-gate` - Stop hook: Claude keeps working until a check command passes.
- `hooks/push-gate`, `secret-guard`, `edit-check`, `snap-before-edit`, `memorize-gate` - small hooks, each tested in
  `tests/`. Settings come from the environment: `CLAUDE_CONFIG` (a folder with your `todo.md` and `questions.md`),
  `PUSH_GATE_ALLOW` (a remote that may be pushed without asking).
- The smart gates share `hooks/smartgates` (run it alone to list them); each header says what it checks and which
  event it wants, `tests/smartgates.bats` covers them. Stop: `debug_gate` (a bug fix needs a red then a green run),
  `test_gate`, `caveman_gate`, `updatedocsgate`, `knowsunknown_gate` (claims, paths), `evolve_gate` (his failed tool),
  `tokenlimitgate` (first: after the usage limit the others stand down). PreToolUse: `publish_gate` (license, README,
  identity scan, tests before a push), `leanctx_gate`, `ponytail_gate`, `graphify_gate`, `mybashtoolgate`,
  `readmegate`. Both events: `karpathy_gate` (plan before the edit, no whole-file Write over code, a named success
  criterion at the end). Sessions: `session-start`, `session-end`.
- `mods/afkloop` - a Claude Code mod: `/afkloop on|off|status` keeps a session working from the next open line of todo.md
  (the forced mode of `afk-gate` as a mod; `claude plugin test mods/afkloop`, 8 tests).
- `bin/versions` - every edit Claude makes is stored first, `versions restore` brings it back; `tools/` and `evals/`
  hold small helpers and skill evals.

## Skills

Priority 0 skills apply to every session; the others load when their tags match.

| Skill | What it is for |
|---|---|
| `claude` | the map of all skills by priority and hashtag |
| `rules` | standing rules: nothing deleted, push only when told, no leaked identity or secrets, calibrated claims, ask only when it changes the work |
| `workflow` | working without check-ins, goal loops, braindump, brainstorm, councils of models |
| `code` | short answers and cheap reads, build less (the ponytail ladder), language choice, data-oriented C, real runs, tests, benchmarks, Lean 4 for optimized C |
| `conventions` | Conventional Commits, git and GitHub rules, READMEs, docs, e-mail |
| `ui` | CLIs, TUIs, web at zero cost, images, video, audio, fonts, 3D from the command line |
| `rea` | reverse engineering: binaries, formats, protocols, apps, games, hardware, and "the feel" |
| `model-surgery` | quantize, merge, prune, fine-tune, distill, BitNet, read raw weights, with a before/after check |
| `audit-everything` | audits of repos, systems and public claims |
| `automate-everything` | a repeated action becomes a script |
| `bash-everything` | one-file bash tools and wrappers |
| `cli-everything` | drive programs through CLI or REST, MCP only as a last resort |
| `scrape-everything` | getting data out of sites, APIs and documents politely |
| `distribute-everything` | from "works on my machine" to "someone else runs it" |
| `ship-anything` | releases, packaging, where to publish |
| `publish-anything` | secrets and identity scan before anything goes public (`publish-check`) |
| `skill-everything` | writing and maintaining skills, the header standard |
| `decide`, `evolve`, `orchestrator`, `ask-older-brother` | choosing between solutions, improving tools as they are used, routing work and second opinions |
| `announce-anything`, `which-license` | posting about a repo, picking a licence |
| `hardware-anything`, `godot`, `whiteboard-programming` | CAD/PCB/RISC-V, Godot and Blender, design before code |
| `founder`, `economist`, `nonconformist`, `paying-demand` | lenses for product and market decisions |

## Header standard

Every `SKILL.md` starts with a header:

```yaml
---
name: folder-name              # kebab-case, equals the folder name
description: What it does and when to use it, with the words a request would contain.   # at most 1024 characters
metadata:
  priority: "2"                # 0 loads at once, 1 when tags match, 2 for a task type, 3 only when named
  tags: "#bash #cli #dev"
  requires: "skill:verify cmd:bash ?cmd:fzf"   # typed; a leading ? marks an optional one
---
```

`bin/skills` reads these: `ls` and `tags` to browse, `req NAME` to check what a skill needs on the machine, `check` to
validate every header and the generated map in `skills/claude/SKILL.md`, `index` to rewrite that map. The full
standard is in `skills/skill-everything/SKILL.md`.

## Tests

```sh
bin/skills check
bats tests/
```

## Contributing

Keep a skill to one concern and its body short; push detail into `references/`. Descriptions are loaded in every
session, so they cost tokens: write the trigger words, not a summary. Commands, flags and paths in a skill must have
been checked to exist; mark anything unsure as such. No personal paths, names or machine details in examples. Before a
commit run `bin/skills index && bin/skills check && bats tests/`, and
`skills/publish-anything/scripts/publish-check` over the repo. Commits follow Conventional Commits.

## License

MIT, see `LICENSE`.
