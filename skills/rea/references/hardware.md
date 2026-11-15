# rea (hardware)

Physical parts, boards, devices and firmware - the user's own, or interoperability (`rea` boundaries). A repairer's habit
applies throughout: observe first, change one thing at a time, write down what each probe showed.

Three kinds of target, one method: measure it, write the numbers into a model, check the model against the real thing.

## A. A physical part, for CAD

The aim is a parametric model someone can reprint, modify or mount against - not a mesh that merely looks right.

1. **Look and decide**: photos from the front, top and side with a ruler or a coin in frame; which faces matter (mating
   faces, holes, slots, clearances) and which are cosmetic. A part's function sets the tolerance: a mount hole needs
   0.1 mm, a casing curve does not.
2. **Measure, cheapest tool first**
   - Digital calipers: outer and inner dimensions, hole diameters and depths (depth rod), steps. Each dimension three
     times, record the spread; a spread above 0.1 mm means the part is not stiff or the point is ambiguous.
   - Hole centres and patterns: measure edge to edge on both sides of the hole and compute the centre, or use pins in
     the holes and measure over them. Pitch and angle patterns (bolt circles) from three holes.
   - Threads: a thread gauge or a known screw to match pitch; diameter with calipers. Write down the standard (M3,
     M4, 1/4"-20), not the measured 2.96 mm.
   - Curves and organic shapes: a flat-bed scan or a top-down photo at 100% scale with a reference object, then trace
     it (Inkscape or the sketch tool); or contour templates; or photogrammetry (COLMAP, Meshroom) / a phone 3D scan for
     a mesh used as reference only.
   - A mesh from scanning is a reference to model over, never the deliverable: fit planes, cylinders and fillets to it.
3. **Model parametrically**: every measurement a named variable at the top (`examples/bracket.scad` in this skill is
   the shape: variables, one printer-tolerance variable, geometry below). OpenSCAD for script-first models
   (`openscad -o out.stl [-D 'w=42'] model.scad`, installed here); FreeCAD (installed) for sketches and constraints and
   assemblies; CadQuery or build123d when it must be Python. Dimensions are claims: keep a table (feature, nominal,
   measured, spread, how) in `re/NOTES.md`.
4. **Check against reality**: print or cut a test piece, hold it to the real part, and compare - or overlay a 1:1
   printout of the drawing on the part. Fix the model, not the print. Typical errors: a measured-in-the-middle hole that
   is conical, a face that is not square, the part itself warped.
5. **Fit**: the model carries a clearance variable per mating pair. Printed FDM parts usually need 0.1-0.3 mm over the
   nominal on holes and under it on pegs, depending on the printer; find the value once with a tolerance test piece
   (a row of holes 0.0, 0.1, 0.2, 0.3 mm oversize) and keep it in the project.
6. **Write down**: the model file, the dimension table, the photos and the drawing (FreeCAD TechDraw or an exported
   SVG/PDF with dimensions) next to the code; the STEP/STL are build outputs. Revisions and variants of the part
   differ: say which unit was measured.

## B. A circuit board

A board is understood before it is redrawn, and redrawn as documentation before it is ever rebuilt. A PCB made from an
unverified model is the board that may not work; build one only after the model passes its replay and simulation
tests. The whole procedure (chips, netlist, powered measurements, buses, firmware, black-box mapping, verification)
is in [embedded](embedded.md); in short:

1. Identify the markings and datasheets first (`rules (rtfm)`); photograph both sides.
2. Parts table, then netlist by continuity with the power off (never probe a mains-side circuit live).
3. Document it in KiCad (`kicad-cli sch erc|export`), measure it powered, decode its buses.
4. Only with a verified model: outline and mounting holes (part A), footprints, routing; `kicad-cli pcb export
   svg|gerbers|drill|pos|step` (checked: KiCad 10.0.8). A STEP export goes back into the mechanical CAD model.
5. Claims in `re/NOTES.md`: net, from, to, how it was established (visual, continuity, measured).

## C. Firmware, update files and devices

- `binwalk FILE` shows what is embedded, `binwalk -e FILE` extracts; `unsquashfs` for SquashFS roots; `strings` for
  versions, URLs and names of keys (never publish key material). The vendor's update file is a format like any other
  (`formats`): header, checksum, payload.
- A flash dump is read from the chip with its tool (`flashrom`, installed) and kept read-only; read it twice and compare
  the two dumps before trusting either, then work on a copy. The extracted filesystem is software (`software`,
  `ghidra`).
- What the kernel knows about a device on the machine: `lsusb -v`, `lspci -vv`, `dmesg`, `/sys/class/*`,
  `udevadm info -a -n /dev/DEV`.
- USB traffic: `usbmon` through Wireshark/`tshark` (`modprobe usbmon`), then it is a `network`-style capture question.
  Serial, I2C and SPI with a logic analyser: capture, decode with `sigrok-cli` or PulseView, decoded frames to a file,
  only the distinct ones are read.

## Writing it down

Pinouts, voltages, register maps, timings and dimensions as tables, each with how it was measured and on which unit
or revision. A spec nobody can reproduce is an opinion (`spec`, `rules (knows-unknowns)`).
