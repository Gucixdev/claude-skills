# Building agents well

How to make an agent (a model in a loop with tools) that works, whichever model sits inside: the loop and what makes it reliable,
the `AGENTS.md` file that tells coding agents how to work in a repo, and a map of the frameworks. It lives next to the model recipes
because the agent is only as good as the model you picked and checked ([SKILL.md](../SKILL.md) check, [distill](distill.md) for a small model that must do the job). Facts marked UNSURE come from search results or memory (2026-11-15) and were not checked against the projects' own docs.

## The loop and what makes it reliable

1. **The loop**: send messages and tool definitions, run the tool calls the model returns, append the results, repeat until it answers without a tool call. Everything else is a limit or a log around that.
2. **Hard limits**: a step limit, a token/money budget, a wall-clock timeout per tool call. An agent without them loops until the account is empty.
3. **Few tools, sharp ones**: each with a one-line description that says when *not* to use it, typed arguments, and an error message the model can act on ("file not found, did you mean X"). Prefer one `run(command)` plus a good CLI ([cli-everything](../../anything/cli-everything/SKILL.md)) to thirty thin tools.
4. **Show before doing**: writes, deletes, sends and spends are returned as a plan and executed only after an explicit yes (the `--yes` convention in his tools). Read-only tools run freely.
5. **State outside the model**: the task list, notes and results in files (TSV/JSONL/SQLite); the model re-reads them each step, so a restart or a context cut loses nothing.
6. **Keep the context small**: tool output cut to what is needed (head/tail/grep before returning), old steps summarised, no whole-file dumps ([code (output)](../../code/references/output.md)).
7. **Verify, do not trust**: a checker the agent cannot argue with (tests, Lean, a schema, a diff of the expected file) decides "done", not the agent's own claim.
8. **Log every tool call** (name, arguments, result size, time) to a file. Debugging an agent without the trace is guessing.
9. **Test with a fake model** that returns canned tool calls, so the loop, the limits and the error paths are tested without a model; then a few real runs on tasks with known answers; compare models with `scripts/gen-compare`-style fixed prompts.
10. **Pick the model for the job**: a small local model is enough for narrow, checkable steps (classify, extract, one tool call); planning over many steps wants the strongest model you can afford, checked on *your* tasks.
11. **Multi-agent only when one agent really cannot**: separate contexts for independent subtasks help; chatting agents mostly multiply cost and errors.

## AGENTS.md

- It is **plain Markdown instructions for coding agents** placed in a repo (agents.md is the site). There are **no required headings or fields**; it is the README for a machine: how to build, test and lint, code style, where things are, what never to touch, how to commit. It is not a manifest or a catalogue of agents.
- Used by many tools (Codex, Cursor, Copilot, Gemini CLI, Jules, goose and others; UNSURE of the full list). It is stewarded by the Agentic AI Foundation under the Linux Foundation, announced 2025-12-09 together with MCP and goose (UNSURE whether Anthropic donated MCP; confirm on the foundation's page before quoting).
- **Nesting**: in a monorepo put one in each package; the nearest file to the code being edited wins, and an explicit user prompt beats all of them.
- **Claude Code reads `CLAUDE.md`, not `AGENTS.md`** (UNSURE for newer versions: test it). Keep one source of truth: write `AGENTS.md` and make `CLAUDE.md` a one-liner `@AGENTS.md` (the import syntax) or a symlink. Do not keep two diverging copies.

### How to write one (for his repos)

1. **Commands first**, exact and runnable: build, one test, all tests, lint, run. `./run`, `./test`, `./check` for his repos ([distribute-everything](../../anything/distribute-everything/SKILL.md)). An agent that cannot run the checks cannot say "done".
2. **Only what an agent cannot learn by reading the code**: a convention that is not obvious, a trap that already cost time, what is generated and must not be edited, what is slow or dangerous to run (network, root, the live compositor).
3. **Rules as "never"/"always" with the reason in half a line.** A rule without a reason gets argued with or ignored.
4. Boundaries: what needs asking first (push, delete, spend money, network), where secrets live and that they are never printed ([rules](../../rules/SKILL.md)).
5. Short. Every line is read in every session; if it is long, split by folder and link. Review it when the repo changes, because stale instructions are worse than none.
6. Test it: start a clean session in the repo, ask for a small task, see whether the agent finds the commands without help.
7. Public repo: no personal paths, no secrets, no machine names ([conventions](../../conventions/SKILL.md)).

## Frameworks for building agents (own code, not the Claude Code harness)

Decide by what you need, not by popularity. Many tasks need none: a loop that calls a model, runs a tool, feeds back the result is about 50 lines. Add a framework when you need what it solves (durable state, tracing, handoffs, many tools).

| framework | what it is for | note |
|---|---|---|
| Claude Agent SDK (Anthropic; Python, TypeScript) | the Claude Code loop, tools, permissions, MCP as a library | Claude models; same harness as this CLI |
| OpenAI Agents SDK | small set: agents, tools, handoffs, guardrails, tracing | works with other providers through compatible endpoints (UNSURE how well) |
| LangGraph (LangChain) | agents as a graph/state machine with persistence, human-in-the-loop, resume | heavy, strong for long-running stateful flows |
| Pydantic AI | typed agents with validated structured output, Python | small, close to normal Python |
| smolagents (Hugging Face) | tiny library; the agent writes code as its action | pairs well with local models |
| CrewAI | role-based teams of agents, Python | quick to start, opinionated |
| LlamaIndex | retrieval first: data connectors, indexes, agents over them | choose for RAG-heavy work |
| Google ADK | Google's agent toolkit (Python, others) | favours Gemini/Vertex, supports others |
| Mastra | TypeScript agents, workflows, memory | for a TS backend |
| Vercel AI SDK | TypeScript streaming/UI and tool calling for web apps | front-end friendly |
| Microsoft Agent Framework (AutoGen lineage) | multi-agent conversations and workflows, .NET and Python | UNSURE how AutoGen and the new framework relate now |

### Protocols

- **MCP** (Model Context Protocol): how an agent reaches tools and data. Here it is the last resort after CLI and REST ([mcp](../../anything/cli-everything/references/mcp.md)).
- **A2A** (agent-to-agent, started at Google, now under the Linux Foundation, UNSURE): how separate agents talk to each other. You need it only when agents from different vendors must cooperate.

### Picking (his constraints)

- Free and local first: smolagents or a plain loop on a local llama-server; paid SDKs only when a provider is already chosen.
- No Go toolchain, Python and TypeScript fine; the repo's own state lives in files (TSV/JSONL/SQLite), see `cli-everything` shapes.
- Every agent he builds gets the same discipline as other code: a test with a fake model that returns canned tool calls, a step limit, a budget limit, tool calls logged, writes shown before they happen.
- Before adopting one: read its current README, pin the version, run its smallest example, and note in the repo why it was chosen (the field moves monthly, the note is how the choice gets revisited).
