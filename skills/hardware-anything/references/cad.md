# hardware-anything (cad)

Parametric solids with exact dimensions: products, enclosures, mounts, jigs - and game or render models, which have the
same discipline with different units.

## Product parts in OpenSCAD

1. **Contract table in `docs/SPEC.md`**: name, value in mm, tolerance, why (mating part, standard, printer limit).
2. **Parameters first in the `.scad`**, one per row of the table, same names; derived values computed below them, never
   typed twice. `assert(wall >= 2 * nozzle, "wall thinner than two lines");` stops a bad parameter at render time
   (`assert` works in 2021.01).
3. **One module per part, one `assembly()`** that places them as they sit in the product; each part also renders alone
   (`part = "lid";` selected with `-D 'part="lid"'`) so it can be exported for printing.
4. **Check**:
   ```sh
   scripts/scad-measure -e 60,40,25 box.scad          # size against the table, volume, closed mesh
   scripts/scad-measure -0 interference.scad          # intersection(){ a(); b(); } must be empty
   scripts/scad-measure -D wall=3 -e 60,40,25 box.scad  # a parameter sweep is just a loop around this
   ```
   Interference file: `include <box.scad>` is not needed if the parts are `use <parts.scad>`; the file holds only
   `intersection() { partA(); partB(); }` for each pair that must not collide, and a `difference()` of the cavity for
   what must fit inside (`-0` again: nothing may remain outside).
5. **Mass and cost**: volume (cm3) x density (PLA 1.24, PETG 1.27, ABS 1.04, aluminium 2.70 g/cm3) x infill factor for
   FDM (a wall-only estimate is volume of the shell; slicer numbers beat estimates, say which one it is).
6. **Drawings**: `projection(cut=true)` to a 2D slice, `openscad -o x.svg` / `x.dxf` for laser and CNC; add dimensions
   as text in the table, OpenSCAD does not dimension.
7. **Export**: STL for printing (`-o part.stl`), 3MF where the slicer takes it; STEP for CAD handover through FreeCAD
   (`freecadcmd` script importing the mesh gives a mesh solid, not parametric - hand over the `.scad` as the source).

FDM numbers to start from, replace with a measured calibration print (UNSURE until printed): clearance 0.2 mm per side
for sliding fits, 0.1 for press, holes print ~0.2 mm small (add to diameter), minimum wall = 2 x nozzle width (0.8 mm for
0.4), bridging up to ~40 mm, overhangs steeper than 45 degrees need support, M3 hole 3.2-3.4, heat-set insert hole per
the insert datasheet, layer height divides the Z dimensions you care about.

For sheet metal, CNC and injection moulding the tolerances come from the process; ask who makes it, do not invent.

## FreeCAD

Scriptable with `freecadcmd -c script.py` for STEP import/export and Part-design checks (volume, bounding box,
`Shape.isValid()`). Use it when a STEP must be read or written; model in OpenSCAD otherwise (text, diffable).
Mesh to solid and STEP from STL are lossy - the `.scad` stays the source.

## Blender (game models and renders)

Drive the live Blender through the MCP server (`godot (blender)` has the safety rules and the export pipeline). What
matters for dimensions:

- Scene unit scale 1.0 and metres; a door is 2.0 m tall. Apply scale (Ctrl+A) before export; read the result:
  `[tuple(o.dimensions) for o in bpy.context.selected_objects]` and compare with the contract.
- Origin where the thing is held or stands (feet for a character, hinge for a door), forward axis agreed with the
  engine (Godot is -Z forward, Y up; glTF export handles the Z-up conversion).
- Budget in the contract: triangles per model, texture size, material count; read it back with a script, not by eye.
- A product render: import the STL/STEP-derived mesh, real-world sizes, camera focal length from the product photo
  conventions (50-85 mm for product shots), three lights, a neutral floor.
- Never test on the live editor with destructive scripts; look with `look` often, it is cheap.

## Fit tests that catch the usual failures

| Failure | Test |
|---|---|
| Lid does not close | `-0` on `intersection(){ lid(); box(); }` in the closed position, then size of the gap with a dimension check |
| Board does not fit the case | export the PCB as STL from KiCad (`kicad-cli pcb export stl`), `import()` it into the assembly, interference with the case |
| Screw does not reach | boss height minus head clearance computed from parameters; assert it |
| Cable or connector blocked | a keep-out module (the plug's envelope) is part of the assembly and joins the interference test |
| Part prints wrong way | the contract names the print orientation and the supports; flat face on the bed |
