# rea (games)

What: a game he owns - to learn how it is built, read a save, extract its own assets for modding, or measure its feel.
How: find the engine, unpack the container, read the logic that is stored as scripts or data tables, diff saves.
Only games he owns and only for understanding or interoperability; no cracking, no DRM or anti-cheat work (`rea`
boundaries).

## 1. Which engine

```sh
ls GAME_DIR; file GAME_DIR/*; ls GAME_DIR/*_Data 2>/dev/null
```

| You see | Engine | Go to |
|---|---|---|
| `*.pck`, or an exe with a large appended blob; `project.godot` in a pck | Godot | section 2 |
| `UnityPlayer.so`/`.dll`, `GAME_Data/`, `globalgamemanagers`, `*.assets`, `Assembly-CSharp.dll` | Unity (Mono) | section 3 |
| the same, with `GameAssembly.so`/`.dll` and `il2cpp_data/` | Unity (IL2CPP) | section 3 |
| `*.pak` with `Engine/`, `Content/Paks` | Unreal | section 4 |
| `.love`, or a zip with `main.lua` | LÖVE (Lua) | `unzip -l`, the Lua is plain source |
| `data.win`, `game.ios` | GameMaker | section 4 |
| a Java `.jar`, or `.exe` + `.dll` managed (`file` says "Mono/.Net assembly") | Java / .NET | `software` |
| a folder of `.json`/`.png`/`.ogg` and one executable | often a custom or web engine: just read the data | section 5 |

`strings -n 8 EXE | rg -i 'godot|unity|unreal|love2d|gamemaker'` settles doubt.

## 2. Godot

- A `.pck` is a container: header, then a file table (path, offset, size, md5), then the files. Godot 4 stores
  scripts as compiled GDScript bytecode in exports (`.gdc`) and resources as binary (`.scn`, `.res`, converted
  `.ctex`/`.oggstr`). Reading the container is easy; getting source back needs a decompiler.
- Tool: GDRE Tools (gdsdecomp, "Godot RE Tools"): recovers a project from a `.pck`/exe, including decompiled scripts and
  converted resources. It is not in the Arch repos here; fetch the release from its GitHub project and check the
  version against the engine version (`strings EXE | rg 'Godot Engine v'`).
- His own games are not obfuscated: if a Godot project is his, read it in the editor, not through this.
- What to read first: `project.godot` (autoloads, input map, physics ticks), the player script for the constants
  (gravity, speed, jump velocity, coyote time) - those are the real numbers behind the feel, so read them before
  measuring anything (`vibe`).

## 3. Unity

- Mono builds: `GAME_Data/Managed/Assembly-CSharp.dll` is the game's code as .NET IL. Decompile with ILSpy
  (`ilspycmd` is not packaged here; the ILSpy release or `dotnet tool install ilspycmd -g` provides it), then read the
  classes by name: `PlayerController`, `GameManager`, `Inventory`.
- IL2CPP builds: the code is native in `GameAssembly.so` with metadata in `il2cpp_data/Metadata/global-metadata.dat`.
  Il2CppDumper (AUR) turns the pair into stub C# with method names and addresses, then Ghidra gets those names
  (`ghidra`). It tells you what exists and where, not the method bodies.
- Assets (`*.assets`, `*.resS`, bundles): AssetRipper (GUI/CLI from its GitHub release) exports textures, meshes,
  audio and scenes; UnityPy (`pip install UnityPy` into a venv) reads them from Python.
- ScriptableObjects and TextAssets are where designers keep data tables (item stats, enemy waves): export them as
  YAML/JSON and read; this is often the whole "balance" of the game.

## 4. Others, briefly

- Unreal: `.pak` lists with `u4pak` or UnrealPak; assets are `.uasset`/`.uexp`, readable with FModel (GUI) for
  meshes and textures; the game logic is Blueprint, which is data in those assets.
- GameMaker: `UndertaleModTool` opens `data.win` with the scripts and objects.
- RPG Maker: a folder `www/data/*.json` or `Game.rgss3a` archives; the JSON is the game.

## 5. Saves and data files

A save is a format (`formats`): make a save, do one action in the game, save again, `scripts/fieldscan save1 save2`. Many
are plain JSON, XML or a zipped folder; some are a serialized object (Unity `BinaryFormatter`, Godot's `var_to_bytes`
and `store_var` use a documented binary variant format), and some are encrypted with a key that sits in the game's
own code (then it is a code question, `software`).

## 6. Mods and mixes

Changing the game instead of reading it: [mods](mods.md). Two games running together and reacting to each other: [gamemix](gamemix.md).

## 7. Result

Per game, in `re/` then `docs/`: the engine and version, the container layout, the data tables you read (as
tables), the constants that define the feel (`vibe`), and the save layout. What goes into his own code is the
numbers and the rules, written fresh; the game's art, audio and code are not redistributed (`ship-anything`, legal basics).
