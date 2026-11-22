# rea (mods)

What: change or extend a game he owns without rewriting it - new content, changed numbers, a hook that reports what
happens inside. This part is the ladder of how, by engine, and where the line is.
Boundary (`rea`): single-player and offline, his own copy. Online and anti-cheat-protected play is not touched: a mod
that gives an edge, bypasses a check or runs while the anti-cheat is active is out. Run modded games only in the
mode where the anti-cheat is not used, and keep a clean install for anything online.

## 1. Take the lowest rung that does the job

Each rung up needs more of the game's internals and breaks more often with a game update.

| Rung | What | Examples | Breaks on update |
|---|---|---|---|
| 1. Config and data | edit the numbers, tables, text, keymaps the game already reads | `.ini`/JSON/CSV, Factorio prototypes, Skyrim `.esp` records, RimWorld XML defs | rarely |
| 2. Content packs | replace or add assets in the format the game loads | Minecraft resource and data packs, Godot `.pck` patches, Unreal `~mods` pak folder | sometimes |
| 3. Script mods in the game's own mod API | the game ships a scripting layer | Lua (Factorio, Garry's Mod, Don't Starve), Papyrus (Skyrim), GDScript in Godot games that load user scripts | when the API changes |
| 4. Framework mods | a loader plus a library that exposes the game's classes | Minecraft: Fabric, NeoForge/Forge (Java), Paper/Spigot servers (plugins); Unity Mono: BepInEx, MelonLoader with Harmony patches; Unreal: UE4SS; Skyrim: SKSE | every game update, often |
| 5. Native hooks | a DLL or shared library injected or proxy-loaded, patching code in memory | ModEngine2 for FromSoftware games (loads mods from a config), `LD_PRELOAD` on Linux, Frida for a quick look | every game update, always |
| 6. External memory reading | a separate process reads values out of the running game | overlays, auto-splitters | every game update |

Order of work: read what the game offers (`games`, the mod folders, the official modding docs and the community wiki)
before building anything; a rung 1 or 2 solution beats a hook.

## 2. By engine

- **Minecraft (Java):** a data or resource pack needs no code (`pack.mcmeta`, JSON). Code: Fabric (small, fast to
  update) or NeoForge; Paper plugins on a server he runs locally. Mappings give readable names for the obfuscated
  game; build with Gradle from the loader's template mod, `./gradlew build`, and the jar goes into `mods/`. Check the
  game version, the loader version and the Java version that pair, since all three move.
- **Unity (Mono):** BepInEx or MelonLoader into the game folder, a plugin (C#, `dotnet build`) that uses Harmony to
  patch a method before or after it runs (`prefix`, `postfix`). Find the method with a decompiler (`software`, ILSpy or
  dnSpy for `Assembly-CSharp.dll`). IL2CPP games need the interop assemblies the loader generates first.
- **Godot:** a `.pck` loaded with `ProjectSettings.load_resource_pack()` replaces resources by path; scripts are GDScript
  text inside the pack (`games`, section 2), so a patch is often a replaced file. Loaders for compiled games exist and
  change quickly: check the loader's page for the game's engine version before choosing.
- **Unreal:** a pak placed in `Content/Paks/~mods` overrides assets of the same path; UE4SS gives Lua and Blueprint hooks on
  many UE4/UE5 games; the engine version from the pak header decides which tools apply.
- **FromSoftware (Elden Ring and relatives):** ModEngine2 loads replaced files, param tables and DLLs from a mod
  folder given in a TOML profile; param edits are done in a param editor (DSMapStudio, Smithbox). The game's anti-cheat
  only starts in the online launch: mods run through the loader's launcher with the anti-cheat off and the game kept
  offline, never through the normal online start. The tooling changes with the game's patches, so check the current
  ModEngine2 and editor pages for the installed game version before every session.
- **Source, GoldSrc, id Tech and similar:** loose files and a console are the mod interface; `cfg` files and Lua or
  engine scripts do most of it.

## 3. A mod project

```
mymod/
  README.md      what it changes, the game and loader versions it was tested on
  src/           code or data
  build          one script, no arguments
  test/          what proves it: a log line in a headless run, a save that loads, a table that parses
  re/            notes on the game parts it touches (rea)
```

1. Write the one change as a sentence and the check that proves it ("the sword deals 12 damage, shown by the log line
   `damage=12`") before the code.
2. Copy the game's folder or use a throwaway profile; mods run against the copy, saves are backed up first.
3. Log, do not guess: a mod that prints what it patched and the values it saw is debuggable; one that does not is not.
4. Pin the versions in the README (game build, loader, dependencies). When the game updates, the failing test says
   which rung broke.
5. Ship only what is his: code, data tables and changed values. Do not redistribute the game's own assets, binaries or
   decompiled sources (`ship-anything`, legal basics); a patch format (a diff, a script that edits the user's copy)
   is the clean way.

## 4. Safety

- Mods are code running with his rights: read third-party mods before running them, take them from the loader's
  official pages, not from re-uploads; no unknown executables.
- Back up saves. Keep one untouched install.
- A game that talks to a server is out of scope for hooks (above); a local server he runs himself is fine.
