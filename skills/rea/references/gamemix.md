# rea (gamemix)

What: two games (or a game and a program) running at the same time on one machine and reacting to each other: a
Minecraft world and an Elden Ring run in the background, and what happens in one changes the other. The twist is not
in either game, it is in the glue.
Boundary: both games offline, mods as in [mods](mods.md); no anti-cheat, no online play; the user's own copies.

## 1. Shape

```
 game A --(events)--> [ bus ] --(events)--> game B
   ^                    |  rules.tsv, log                |
   +----(actions)-------+-----------(actions)-----------+
```

Each game gets one small adapter that does two things only: **emit** events (something happened in the game) and
**apply** actions (do this in the game). A local bus carries them. A rules table decides which event in A becomes
which action in B. Nothing else is shared; either game can be restarted without the other noticing.

## 2. Getting events out and actions in, per game

Pick the lowest rung of [mods](mods.md) that exposes it.

| Game | Events out | Actions in |
|---|---|---|
| Minecraft (Java, local server) | a Fabric or Paper plugin hooking events (player hurt, mob killed, block broken, advancement), or the server log (`logs/latest.log`) parsed line by line | RCON (`/give`, `/effect`, `/summon`, `/weather`, `/time`, `/tp`) or command blocks; a plugin for anything else |
| Elden Ring (offline, ModEngine2) | a native DLL or a script mod reading event flags, HP, boss-defeated flags; or an external reader of the same memory (rung 6) | writing the same flags and params from the DLL; an edited param table is static, so for live changes the DLL is the way |
| Unity games | BepInEx plugin patching the method that fires the event | the same plugin calling the game's own methods |
| A game with only a log or a save file | tail the log, or watch the save with `inotifywait` (`fieldscan` gives the fields) | often none: then the output is a notification or an overlay |
| No hook at all | screen and audio cues (`vibe`) | virtual input as a last resort; never to a game with an active anti-cheat |

Start with the direction that is cheap: Minecraft in both directions through RCON and the log is a few lines each, and it
is the way to prove the glue before the harder adapter exists.

## 3. The bus

Local only, simplest thing that works, as in `cli-everything` (state allowed, `--json`):

- JSON lines, one event per line: `{"t": 1731600000.12, "src": "mc", "type": "player_hurt", "n": 3}`.
- A Unix socket under `$XDG_RUNTIME_DIR` (or a plain file the adapters append to and tail); a UDP port on `127.0.0.1` when an
  adapter cannot speak a socket.
- One router process reads all events, appends them to a log (`events.jsonl`, the record of what happened for
  replay), looks them up in the rules table and sends the actions.

## 4. Rules

A TSV, one line per rule, readable without code:

```
src   type         when        dst   action                          cooldown
er    boss_dead    -           mc    /weather clear                  60
er    player_hurt  n>=10       mc    /effect give @p slowness 5      30
mc    player_hurt  -           er    heal  -5%                       15
```

- Keep the table data and the code generic: a new pairing of games is a new table and two adapters.
- Every rule has a cooldown and every action a maximum rate, so a burst of events cannot flood the other game.
- Loops: A hurts B, B hurts A, forever. Mark an event caused by a rule (`cause: rule-3`) and never turn that
  event into an action; the cooldown is the second line of defence.
- Safe mode: a single switch (a file, a key) that makes the router log and drop all actions. Used first, with
  the log read, before the actions are turned on.
- Latency: game ticks are 50 ms in Minecraft and about 16 ms per frame in a game; rules run in the router, so
  budget a few hundred milliseconds end to end and measure it (`verify (bench)`). Time-critical combinations belong in one
  adapter, not through the bus.

## 5. Testing

1. A fake game: a script that emits a recorded event list and prints the actions it receives; the router and the rules are
   tested against it without starting either game (`verify`).
2. Replay a real `events.jsonl` into the router and diff the actions it sends against the expected ones.
3. One adapter live at a time, the other faked, then both. The log answers "why did X happen".
4. Load: a modded game with both running is a big load; check memory and CPU before it ships to a weaker
   machine (check the target's specs).

## 6. Where it goes

A `gamemix` project: `adapters/NAME/`, `router`, `rules.tsv`, `events.jsonl` (log, not committed), tests with the
fake game. `scripts/rcon` in this skill is the Minecraft action side, tested against a fake server. Brainstorm the twist
first (`workflow (vibemix)`): the interesting part is the rules, not the plumbing.
