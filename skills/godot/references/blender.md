# Godot + Blender integration

## Connections (both auto-start with the app; nothing to click)
- **Godot**: toolbox tool `godot_mcp_server` listens on 9090 (next free up to 9094) in any project with `addons/toolbox` enabled
  (core, scrollsouls, web; `new_project.sh` sets it up). The bridge is `~/dev/godot/core/godot-mcp-bridge.mjs`; it reconnects
  lazily per call. Several editors open -> `godot_instances`, then `godot_use {project}`. `godot_status` for health.
- **Blender**: add-on server on 9876, started by `~/.config/blender/mcp/blendermcp_autostart.py` on every GUI launch. After
  installing a NEW Blender version run `~/.config/blender/mcp/run` once. `blender -b` never serves.

## Godot tools (106+, generated - `python3 ~/dev/godot/core/mcp_tools/gen_tools.py` after changing the plugin)
Load schemas with ToolSearch `select:mcp__godot__godot_<name>`. Groups: scene (read_scene, get_scene_hierarchy, add/remove/move/
rename_node, modify_node_property, set_node_properties, attach_script, set_material/mesh, connect_signal, groups...), file/script
(read_file, list_dir, search_project, create_script, edit_script, validate_script), project (get_errors, get_console_log,
run_scene/stop_scene/is_playing, get_project_settings, update_project_settings, setup_autoload, input map, classdb_query,
rescan_filesystem), ui_*, theme_*, animation_*, animtree_*, particles_*, nav_*, recording_*, export_*, test_assert, map_project.
`godot_cmd {method, params}` is the raw escape hatch. Scene paths are `res://...`, node paths relative to the scene root.

## Blender -> Godot (the pipeline)
1. In Blender (`mcp__blender__execute_blender_code`):
   `exec(open("~/.config/blender/mcp/to_godot.py").read())`
   `print(export_to_godot("~/dev/godot/core", "crate"))`  # selected; or collection="Props" / selected_only=False
   -> writes `<project>/assets/models/<name>.glb` (Y-up, modifiers applied, materials embedded); returns res_path, triangles, warnings.
2. In Godot: `godot_rescan_filesystem {paths: [res_path]}` (waits for the import and reports which files imported).
3. `godot_instance_scene {scene_path, instance_path: res_path}` (or add_node) and `godot_save_scene`.
4. Verify: `godot_get_errors`, `mcp__blender__look` for the Blender side.

## Rules (each one was paid for)
- **Never test new/changed plugin code against the user's live editor.** A bad call aborted it (SIGABRT, unsaved work at risk).
  Test in a disposable instance: `bash core/new_project.sh iso` in a temp layout (it symlinks the same toolbox), run
  `godot --headless --editor --path <iso>`, drive it with the bridge from a node script, then delete it.
- Never call `EditorFileSystem.update_file()/reimport_files()` right after `scan()` or while scanning/importing. Use scan + wait.
- Never block the editor main thread on a child process (`OS.execute`); use `OS.create_process` + a log file + a status poll.
- Godot's JSON leaves raw control characters unescaped; a dropped message looks like a hang. Strip them or parse tolerantly.
- Writes edit the OPEN scene of the user: say what changes. Prefer read-only calls for inspection.
- After changing the bridge file the running MCP client keeps the old code until reconnected (`/mcp`) or the session restarts.
- Pixel/shader regression stays in `tests/render_*.gd` (windowed Vulkan harness), not in MCP.
