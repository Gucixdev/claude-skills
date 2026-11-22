# hardware-anything (pcb)

From a need to Gerbers, with an electrical and a geometric check at each step. KiCad 10 is the tool; its file formats
are text, the CLI does the checks, and Python `pcbnew` builds boards from code.

## Flow

1. **Spec** (`docs/SPEC.md`): supply voltage and current, interfaces, size and mounting, environment, quantity, target
   cost. Power budget as a table: every rail, every consumer, worst case current, regulator headroom.
2. **Block diagram and part choice**: each part with its datasheet pinned in `docs/datasheets/` (link or file name, not
   scraped copies); alternatives in stock matter, but stock changes, so the BOM carries manufacturer part numbers.
3. **Schematic**: one sheet per function, nets named for meaning (`VBUS_5V`, `SDA_SENS`), decoupling 100 nF at every IC
   supply pin plus bulk per rail, pull-ups with values justified, every unused pin handled, test points on rails and
   buses, reverse-polarity and ESD where a connector faces the world. Check each application circuit against the part's
   reference design.
4. **ERC**, then footprints assigned and each checked against the datasheet land-pattern drawing (pitch, pad size, pin 1,
   courtyard). A footprint made by hand gets a 1:1 print on paper laid against the real part.
5. **Layout**: outline on `Edge.Cuts` from the enclosure contract (`cad`), connectors and holes first at fixed
   coordinates, then placement by signal flow, then power and ground (a solid ground plane on layer 2 of a 4-layer, or
   a pour on a 2-layer), then critical nets (clocks, USB differential 90 ohm, switching-regulator loop short), then the
   rest. Rules set to the fab's capability before routing.
6. **DRC with schematic parity** and `scripts/pcb-check` (it refuses to write fab files for a failing board).
7. **3D fit**: STEP/STL against the case (`cad`, board-in-case interference), connector openings aligned in mm.
8. **Bring-up list** (`docs/BRINGUP.md`): continuity of rails to ground before power, first power from a current-limited
   supply, expected voltages per rail, then each interface with its test.

## Building a board from code

`examples/pcb_demo.py` is the pattern: nets, footprints with pads, tracks and the outline, then `SaveBoard`. For a
real design the schematic comes first; KiCad schematics are s-expressions and can be generated, but the dependable way
is to draw the sheets in the editor (or write the netlist in a small Python table and place footprints from it) and
let ERC and the netlist export (`kicad-cli sch export netlist`) be the source of truth. Autorouting: export the board
to Specctra DSN (`pcbnew.ExportSpecctraDSN`), route with Freerouting (Java, **not installed**; UNSURE about its CLI
flags - read its `--help` before use), import the `.ses` (`pcbnew.ImportSpecctraSES`), then DRC. Hand-route
clocks, power and anything analog.

Typical cheap-fab capability to set as rules (UNSURE: read the fab's current page before ordering): 0.15 mm
track/space, 0.3 mm drill, 0.6 mm via pad, 0.2 mm silk line, 1.6 mm FR4, 1 oz copper. Current capacity: about 0.3 mm
per 0.5 A on an outer layer at 10 K rise, use IPC-2221 or a calculator for anything near the limit, and put the number
in `docs`.

## Simulation

| Question | Tool | How |
|---|---|---|
| Filter corner, divider, LED current, op-amp stage, regulator loop | `ngspice -b file.cir` | `.ac`/`.tran` plus `meas` and an `if err > tol` PASS/FAIL, as in `examples/rc_lowpass.cir` |
| Logic and a microcontroller's peripherals | Verilator/Icarus for HDL (`cpu`), or QEMU for firmware | not SPICE |
| Thermal, EMC, signal integrity above ~100 MHz | not covered here | say so; calculators for estimates, a measurement for truth |

Vendor SPICE models (.lib/.subckt) go in the project with their licence; a generic model (ideal op-amp) validates the
topology only, and the report says "ideal". Simulating the real schematic: `kicad-cli sch export netlist --format
spice` (verified present in 10.0.8) then run with sources added in a wrapper `.cir`; the circuit needs SPICE models on its symbols.

## Checks recorded in the report

ERC and DRC counts (0/0), board size and area from `stats`, min track/space/drill versus the fab's list, unconnected
count 0, BOM lines with MPNs, a list of the parts with no 3D model. Everything else is "not checked".
