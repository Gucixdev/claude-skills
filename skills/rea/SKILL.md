---
name: rea
description: Reverse engineer anything - how a program, file format, protocol, API, GUI, board or game asset works (black box, static, dynamic) and how it feels (look, motion, game feel, sound as numbers); findings go into a spec before any rewrite. Targets in references/. Use for how does X work, make it feel like X, interoperability, undocumented formats.
metadata:
  priority: "2"
  tags: "#thirdparties #reverse-engineering #binaries #formats #protocols #hardware #security #ui #gamedev #leanctx #context #tokens #dev"
  requires: "skill:rules ?cmd:strace ?cmd:gdb ?cmd:objdump|llvm-objdump ?cmd:xxd ?cmd:ghidra ?cmd:imhex ?mcp:ghidra ?cmd:ffmpeg ?cmd:magick|convert"
---

# rea

Goal: understand it well enough to write it down, so a clean reimplementation or a wrapper can be built on the spec,
not on copied code. His `flatseal` (bash) came from knowing what Flatseal actually writes: `flatpak override` files.

## Boundaries

Fine: his own files and devices, interoperability (EU and UK law allow decompiling for it), formats and protocols for
data he owns, learning, CTFs, security review of software he runs. Not: cracking licenses or DRM, defeating
anti-cheat, exploits against systems that aren't his, redistributing someone's code. The output is a spec plus his own
code.

## What and how, by target

Pick the row, run the first move, then open the part.

| What you want to know | First move | Part | You end with |
|---|---|---|---|
| How a program behaves, where it keeps things | `scripts/trace-summary -r PROG`, `--help`, the docs | `software` | notes, then a wrapper or a spec |
| How a function or check works | strings, then Ghidra one function at a time | `ghidra`, `software` | a description of the algorithm |
| An undocumented file | two samples that differ in one setting, `scripts/fieldscan A B` | `formats` | `docs/FORMAT.md` plus a reader and writer |
| How a device or app talks on the network | `ss -tupn`, one capture per action | `network` | `docs/PROTOCOL.md` plus a client |
| The API behind a website | HAR of one action, `scripts/har-endpoints` | `web` | `docs/API.md` plus a client |
| A game's data, saves, constants | engine from the files, unpack, read scripts and tables | `games` | tables and numbers in his own code |
| A part | calipers or photos | `hardware` | parametric CAD |
| An embedded product (toothbrush, remote, sensor) | behaviour table, chips, netlist, measure, decode, firmware if open | `embedded` | a verified model: block diagram, netlist, signal catalogue; a board only after that |
| How something feels | measure the real thing frame by frame | `vibe` | constants: spring, gravity, easing, loudness |
| How to spend little on all of this | one question, cheapest step, dumps to files | `lean` | `re/NOTES.md` |

## Method

Before the first command, write down three lines in `re/NOTES.md`: the question (one sentence), what the answer is
used for (wrap, rewrite, interoperate, just learn - it decides how deep to go), and how you will know it is answered.
Reverse engineering has no natural end; the third line is the end.


Always load `lean` with the target part: one written question, the cheapest step that answers it, every dump into a
file.

1. Black box first, cheapest (`software`): docs, what it reads, writes and sends. Often the whole answer is here.
2. Static (`ghidra` for binaries), then dynamic (`software`).
3. Each finding is a claim with its evidence; inferred vs. checked stays labelled (`spec`).
4. Write the spec, then build against it and test with the real samples (`spec`).

## Parts

Read the part when the target matches; `lean` always.

- [lean](references/lean.md) - Lean reverse engineering on a budget (the former skill leanrea) - one written question, the cheapest step, dumps to files, probes as scripts, `re/NOTES.md`, stop when the spec line is written and checked.
- [levers](references/levers.md) - The techniques that save the most hours, ranked - the original as an oracle (differential testing), rr record and replay, tracing before reading (strace, uftrace, frida, bpftrace, apitrace), Kaitai Struct for formats, matching library code instead of reading it, symbolic execution and emulation for one function, a model as note-taker only. Read first when a target looks big.
- [software](references/software.md) - Programs and apps: pick the rung, black box (strace, inotify, env switches), static (nm, strings, Ghidra), dynamic (ltrace, gdb, LD_PRELOAD shim), D-Bus and Flatpak, Python/Java/.NET/Electron/WASM, safety.
- [ghidra](references/ghidra.md) - Ghidra headless: analyzeHeadless, `scripts/DecompFunc.java` for one function at a time, reading decompiled code.
- [hardware](references/hardware.md) - Physical parts to parametric CAD (calipers, tolerances, OpenSCAD/FreeCAD, test fits), circuit boards to KiCad, firmware and device buses; `examples/bracket.scad`.
- [embedded](references/embedded.md) - Embedded products mapped down to the silicon: behaviour table, chip identification, netlist, powered measurements, buses (sigrok), firmware access ladder, black-box state tables, model verified before anything is built; `scripts/pulsestat`.
- [formats](references/formats.md) - File formats: magic table, samples that differ on purpose, `fieldscan`, how to decode ints, strings, varints, TLV, checksums, compression, reader+writer round trip.
- [network](references/network.md) - Traffic and protocols: who talks to whom, tcpdump/tshark per action, TLS with a key log or mitmproxy, reading a binary protocol into a state machine, replay before claiming.
- [web](references/web.md) - Web apps: HAR to endpoints, minimal curl, inline state and bundles and source maps, auth shapes, pagination, API spec.
- [games](references/games.md) - Which engine, then Godot packs and scripts, Unity Mono and IL2CPP, Unreal and others, saves, what to keep from it.
- [mods](references/mods.md) - Modern modding: the ladder from data and config through script and framework mods to hooks, per engine (Minecraft, Unity, Godot, Unreal, Elden Ring), offline and single-player.
- [gamemix](references/gamemix.md) - Two games running at once and talking to each other: each exposes events, a local bus carries them, a rules table turns them into actions in the other game.
- [vibe](references/vibe.md) - How it feels: look, motion, game feel and sound measured into numbers (springs, jump physics, loudness).
- [spec](references/spec.md) - Writing the findings down as a spec (skeletons for FORMAT, PROTOCOL, API), checking it with a reader and writer, then rewriting or wrapping.

Scripts (verified on real input, they read and change nothing): `scripts/fieldscan` (first look at a binary format from samples), `scripts/trace-summary` (what a program touched, from strace), `scripts/har-endpoints` (the API from a HAR), `scripts/rcon` (Minecraft RCON client, password from the environment), `scripts/pulsestat` (frequency, duty or baud from a captured signal), `scripts/DecompFunc.java` (one decompiled function through Ghidra headless).
