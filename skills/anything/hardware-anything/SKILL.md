---
name: hardware-anything
description: Design physical or silicon things and prove them in a simulator or measurement first - parts in OpenSCAD, FreeCAD, Blender; PCBs in KiCad (ERC, DRC, Gerbers, SPICE); RISC-V style CPUs (C model, RTL, lockstep, formal). Use for CAD, SCAD, STL, STEP, enclosure, wymiary, PCB, KiCad, schemat, SPICE, RISC-V, procesor, Verilog, FPGA.
metadata:
  priority: "2"
  tags: "#hardware #cad #pcb #cpu #riscv #kicad #openscad #blender #spice #verilog #simulation #measurement #dev"
  requires: "skill:rules skill:code ?skill:whiteboard-programming ?skill:rea ?skill:godot ?cmd:openscad ?cmd:kicad-cli ?cmd:ngspice ?cmd:clang ?cmd:ld.lld ?cmd:qemu-system-riscv32 ?cmd:freecadcmd ?cmd:verilator ?cmd:iverilog ?cmd:yosys"
---

# hardware-anything

A drawing is a claim; a tool run is the evidence. Every part, board and core here ends with a checker that returns a
number or a pass/fail, and "done" means that checker was run (`code (done)`). Nothing is made, ordered or paid for
by Claude: files and reports are the output, he decides about a printer, a fab or an FPGA.

<!-- digest -->

## What and how

| He wants | First move | Part | Ends with |
|---|---|---|---|
| A product part, enclosure, bracket, jig, anything with real dimensions | `docs/SPEC.md` with the dimension table, then a parametric `.scad` | `cad` | STL/STEP, `scripts/scad-measure -e X,Y,Z` green, fit and interference tests |
| A model for a game or a render | Blender through MCP (`godot (blender)`), real scale in metres, polycount budget | `cad` | glTF/FBX, dimensions printed from the object |
| A copy of an existing part | measure it first: `rea (hardware)` | `cad` | parametric model with the measured table |
| A circuit board, from idea to fab files | block diagram, power budget, parts with real footprints | `pcb` | KiCad project, `scripts/pcb-check` clean, Gerbers, STEP, BOM |
| An analog or power subcircuit | SPICE netlist with a `.measure` pass/fail | `pcb` | the numbers next to the datasheet limits |
| A processor, RISC-V or his own ISA | `docs/DESIGN.md` need/maybe/no, then the ISA table | `cpu` | reference model, programs that pass on it, RTL that agrees instruction by instruction |

## The loop (all three)

1. **Contract first.** One table: every dimension / net / instruction with value, tolerance and why. It is the test
   input later. Lean 4 or a layout proof only where a guarantee pays (`whiteboard-programming`); a measurement is the
   proof for geometry.
2. **Parametric source, text only.** `.scad`, a pcbnew Python script or `.kicad_*` s-expressions, Verilog, C. A
   diff shows what changed; a GUI-only file is a black box and gets regenerated from text or avoided.
3. **Checker before beauty.** Run it after every change, show the output, fix the first failure only.
4. **A failing case on purpose.** Each checker is shown to fail once (a box 1 mm too wide, a clearance of 0.1, a
   wrong ALU result) - a checker never seen failing proves nothing. The `examples/` do exactly this.
5. **Numbers into the docs.** Volume, mass at the material density, board area, clock, resource count land in
   `docs/` as measured, with the command that produced them.

## Say what the simulator cannot tell

CAD checks fit, not strength or print quality. SPICE checks the model, not the part's real tolerance, temperature or
EMC. A passing DRC is the fab's minimum, not a good layout. RTL simulation is not silicon timing. Name the gap in the
report ("UNSURE: not printed", "not on a bench"); first print, first power-up and first bitstream are his, with the
bring-up list from the part.

## Tools on this machine (checked 2026-11-15)

Present: `openscad` 2021.01, `freecad`/`freecadcmd` 1.1, `kicad`/`kicad-cli` 10.0.8 with Python `pcbnew`, `ngspice` 47,
`clang` with the riscv32 target + `ld.lld` + `llvm-objdump`/`llvm-objcopy`, `qemu-system-riscv32/64`. Blender is driven
live through MCP.
Missing, he installs (needs root, so I never do): `sudo pacman -S kicad-library kicad-library-3d` (standard symbols,
footprints and 3D models - without them a part is a hand-made footprint), `sudo pacman -S verilator iverilog yosys
gtkwave z3` for RTL; `sby`/`nextpnr` are not in the repos (AUR or source). OpenSCAD 2021.01 has no manifold backend:
big boolean models render slowly, keep `$fn` low until the last export.

## Scripts (`scripts/`, all with `--help` and a header)

| Script | Does | Exit |
|---|---|---|
| `scad-measure` | OpenSCAD to STL, prints size, volume, triangles; `-e X,Y,Z` checks dimensions, `-0` asserts an empty intersection, open meshes are flagged | 0 / 1 off / 2 failed |
| `pcb-check` | ERC + DRC (with schematic parity), then stats, Gerbers, drill, STEP, render, BOM into `fab/`; nothing is written for a failing board | 0 / 1 / 2 |
| `rv32-run` | C or asm to RV32 (`-m rv32im`), runs on QEMU `virt`, `-i` also on the C reference model and compares | program's / 1 mismatch |

`examples/`: `box.scad`, `pcb_demo.py` (a board made from code, `bad` makes a clearance error), `rc_lowpass.cir`
(SPICE with pass/fail), `hello.c`, `alu.c`, and `scripts/rv32/iss.c` (the reference simulator).

## Rules

- Units are millimetres in CAD and PCB, metres in Blender/glTF; the conversion is written once, in the contract table.
- Tolerances for printing come from the printer: first print a calibration piece, put the measured clearance into the
  parameter (`cad`), do not assume 0.2.
- Standard parts and libraries are used as they are; a footprint is checked against the datasheet drawing, pin by pin,
  before the board is routed (the commonest dead board is a correct schematic with a mirrored footprint).
- Anything that leaves the machine - an order at a fab, a purchase, a post - waits for his yes for that exact thing.
