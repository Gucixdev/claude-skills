# rea (embedded)

What: map exactly what happens inside an embedded product - an electric toothbrush, a remote, a kettle, a sensor, a
router - from the button you press down to the pins, the registers and the firmware that move them.
The deliverable is a verified model of the device: block diagram, netlist with a confidence per net, signal catalogue,
firmware or behaviour spec. It is not a board. A new PCB is a separate job that starts only when this model has
passed its own tests (section 9); a design copied from an unverified model is the board that may not work.

Every statement in the model is a claim with a status (`checked`, `inferred`, `unknown`) and how to re-test it. The
device keeps working until the last rung: non-destructive steps first, anything destructive on a second unit.

## 0. Before touching it

- Which product, how many units (buy a second one if the first is the only copy of anything), and what the map is for:
  behaviour only, a pin-accurate map, the firmware, or a compatible controller. It decides how deep to go.
- Hazards, written into `re/NOTES.md` before the case is opened: mains-connected parts (the live side stays closed, use an
  isolation transformer or do not power it from the wall), lithium cells (never short, never puncture, bench supply
  with a current limit instead of the cell where the board allows), charged capacitors, ESD.
- Boundary (`rea`): his own devices, repair and interoperability. A device that locks its firmware (read-out protection,
  encrypted updates) says no to reading it: map it from outside (section 8) instead of defeating the lock with
  glitching or decapping; no cracking of someone else's security.

## 1. The product, without opening it (zero risk)

- Model number, FCC ID, CE/UL marks: the FCC ID on the label opens the regulator's filing, which usually has internal
  photos, a block diagram, the radio frequency and the test setup. Patents and service manuals show the intended design.
- Observed behaviour, as a table in `re/NOTES.md`: input (button press, tilt, charge, time) and the visible/audible
  result (LED pattern, motor pattern, beeps) with durations measured on a video (frame count) or a stopwatch.
  A toothbrush example: modes selected by a press, a 2-minute timer with a pulse every 30 seconds, an LED pattern for
  charging and low battery. This table is the first test set for the model.

## 2. Open it and document it

- Case: warm and pry, or cut along the weld on a second unit; photograph every step with a ruler in frame.
- The board: both sides at full resolution in raking and diffuse light; then a parts table
  `designator | marking | package | what | datasheet | confidence`. Remove conformal coating only where a pin must be
  probed.
- Everything that is not the board: battery (chemistry and voltage from the label), motor or transducer, coils,
  switches, LEDs, sensors. Each is a part with its own datasheet or its own measurement (a coil: inductance and resistance).

## 3. Identify the chips

- Read markings under good light and a loupe; a datasheet's "marking" section decodes them. Look up the logo, the part
  number, the date code. Common silicon in cheap consumer devices: 8-bit controllers from Holtek, Sinowealth, Padauk
  (OTP, no debug port), Nuvoton, Puya; Cortex-M from STM32, GigaDevice, WCH; radios from Nordic, Espressif, Realtek.
- A black epoxy blob over the die (chip on board) has no marking. Identify it by its neighbours (what it drives and
  senses), the pad count around the blob, the supply voltage, and its behaviour; the family is often visible in
  the bonding-wire layout only. Mark it `unknown MCU` until something decides it.
- Do not trust a marking alone: a remarked chip exists. Confirm by supply range, pin count and behaviour.

## 4. Board to netlist

1. Power off, cell out. Continuity (beep) from every IC pin to its neighbours and to the test pads; note the result.
2. Work in this order: power (cell, charger, regulator, power switch), then ground, clocks and crystals, resets, then
   the signals; two-layer boards give most of it from the photos, multilayer boards need the vias and a meter.
3. Write the netlist as a TSV first (`net | pins | how established`), then draw it in KiCad as documentation:
   `kicad-cli sch erc FILE.kicad_sch` finds pins left floating or shorted in the drawing, and
   `kicad-cli sch export netlist -o out.net FILE.kicad_sch` gives the netlist back for a diff against the TSV.
4. Name the function blocks: power path, charger, motor or load driver, sensing (shunts, NTC, Hall, accelerometer,
   pressure), user interface (button, LEDs, buzzer), the controller, the radio if any. A block diagram with each
   arrow labelled by signal type (digital, PWM, analog, bus).
5. Read the sensing: a low-value resistor in the motor's return leg is a current shunt, a pad next to the cell with
   a divider is the battery monitor, a resistor and a capacitor on a pin is a button debounce or a reset.

## 5. Powered measurements

- A bench supply with a current limit instead of the cell, the board in each mode, and a table
  `point | condition | volts | amps | frequency | duty` filled from the meter or a scope.
- Rails first, then the current draw per mode: microamps asleep, tens of milliamps awake, hundreds with the motor
  running. The current profile over time is a fingerprint of what the firmware does: a sleep that wakes every
  second to check the button, a motor ramp, the charge taper.
- Motor and coil drives are PWM or a square wave: measure frequency and duty on the driver's gate or output with a
  scope or logic analyser. For an electric brush this number is the product's character; do not assume it, measure it.
- Equipment: a multimeter, a bench supply with a current limit, a logic analyser supported by sigrok (cheap USB
  clones work, or a spare Raspberry Pi Pico with the sigrok firmware), a scope when the signal is analog or fast.
  Look at what is already on hand before buying anything (`rules (zero-cost)`).

## 6. Signals and buses

Capture one mode per file, with the action's time noted, and decode.

```sh
sigrok-cli --scan                                              # the analyser it finds
sigrok-cli -d fx2lafw --config samplerate=1m --time 2s -C D0,D1,D2 -o re/cap-mode2.sr
sigrok-cli -i re/cap-mode2.sr -P uart:baudrate=9600:rx=D0 -A uart=rx-data      # decode a UART
sigrok-cli -i re/cap-mode2.sr -P i2c:scl=D1:sda=D2                              # decode I2C; the addresses show the chip
sigrok-cli -i re/cap-mode2.sr -C D0 -O csv > re/d0.csv && scripts/pulsestat re/d0.csv    # frequency and duty, or the baud
```

(Check the driver and options with `sigrok-cli --help` and `sigrok-cli -d DRIVER --show` on the actual analyser;
`sigrok-cli` and PulseView are in the Arch repos, not installed here.)

`scripts/pulsestat` reads the CSV or a list of edges and says whether the signal is periodic (frequency, duty) or a bit
stream (nearest standard baud). Recognising a signal by eye:

| Signal | Looks like |
|---|---|
| PWM | steady period, the duty changes with a setting (speed, brightness) |
| UART | idle high; frames start with a low bit; all pulses a multiple of one bit time (the shortest pulse is 1/baud) |
| I2C | two wires, both idle high through pull-ups, clock bursts of 9 pulses per byte; 7-bit addresses 0x08-0x77 |
| SPI | clock, data out, data in and a chip select that frames each transaction; flash chips and displays |
| SWD / JTAG | two wires (SWDIO, SWCLK) or four to five (TCK, TMS, TDI, TDO) on pads or a header near the controller |
| One-wire | one data line, pulse-width coded bits |
| Analog sensor | a voltage that follows the physical quantity (Hall, NTC, pressure bridge): record against the stimulus |

## 7. The firmware, by the rung that is open

1. **The vendor's update file** (a dfu image, a firmware download, an OTA payload): `binwalk FILE`, `strings`, then
   `formats` (header, checksum, payload). Often unencrypted. This is the least invasive source.
2. **A boot console**: a UART header or pads. Measure idle level with a meter (3.3 V or 5 V) before wiring, connect
   ground, then listen: `picocom -b 115200 /dev/ttyUSB0` (picocom is installed here; the baud comes from `pulsestat`).
   A boot log names the chip, the version, the memory map and sometimes drops to a shell.
3. **A debug port** (SWD or JTAG): `openocd` with the interface and target configs for the chip (repo package) can
   halt the core and read flash and RAM: `openocd -f interface/ADAPTER.cfg -f target/CHIP.cfg -c "init; halt; flash probe 0"`.
   If the maker locked the chip (read-out protection), the dump is blocked on purpose: stop and use section 8.
4. **External SPI flash**: `flashrom -p PROGRAMMER -r dump1.bin` twice, compare the two dumps (`cmp`), work on a copy
   (`rea (hardware)`).
5. **No access at all** (mask ROM or OTP controller): there is no firmware to read; use section 8.

With a dump: Ghidra with the right architecture and base address. A Cortex-M image starts with a vector table (word 0 =
initial stack pointer in RAM, word 1 = reset handler, an odd address because of Thumb), so the base is the flash
address (`0x08000000` on STM32) and the reset handler is where to start. Load the vendor's SVD file for the peripheral
names (GPIO, TIM, ADC, I2C). Then connect the firmware to the board: every access to a peripheral register is a pin
in the netlist (this timer's channel drives the gate you measured at 260 Hz). Result: a table
`pin | net | peripheral | what the firmware does with it`. Read one function at a time with
`scripts/DecompFunc.java` (`ghidra`).

## 8. Silicon you cannot read: map it from outside

A black box is mapped by stimulus and response, and by timing:

1. Make a table of every input you can drive (button, tilt, pressure, temperature, supply voltage, charge state) and every
   output you can record (each pin, the current draw, LEDs).
2. Drive one input at a time, hold it, record all outputs for a fixed time. Build the state table
   `state | input | output | next state`; then write the state machine and make it predict a sequence you have not
   tried. A wrong prediction finds the missing state.
3. Time constants carry the oscillator: a 120.0 s timer that measures 118.7 s at 3.0 V and 121.9 s at 4.2 V says the clock is
   an RC oscillator, not a crystal. Measure at two supply voltages.
4. The current trace as a side channel: each mode has its own shape (periodic spikes = a scan loop, a flat step
   = the motor); compare traces, do not read instructions from them.
5. Die-level work (decapsulation with acid or a hot plate, microscopy of the die) reads the family and the memory
   layout. It is a lab procedure with real hazards and destroys the unit: only on a second unit, only when
   identification cannot be done otherwise, and only with the right equipment and protection.

## 9. Check the model before anything is built from it

- Replay: feed the model (a Python state machine or a small C program) the same input log as a real capture; its outputs
  must match the capture in timing within the measured tolerance. Keep the capture and the replay result as a test
  under `tests/` (`code (done)`, `code (test)`).
- Analog parts: simulate the driver or charger in `ngspice` (installed) with the measured values and compare current
  and voltage with the scope numbers.
- Firmware: run the vector table's code in QEMU (`qemu-system-arm` is installed; its boards are limited), or in an
  emulator such as simavr or Renode (not installed here), to confirm what a function does before relying on it.
- A claim table `id | claim | evidence | status | how to re-test`; open items go to `unknown`.
- Only when the replay and the simulation agree on all captures, build: a breadboard or a development board with the
  same controller first, then the PCB (`kicad-cli pcb export ...`, `rea (hardware)`), with an acceptance test written from the
  behaviour table of section 1. Building from a model that has not passed this is how a board ends up not working.

## 10. Writing it down

`docs/DEVICE.md`: block diagram, parts table, netlist (the TSV plus the KiCad files), power tree and the per-mode current,
signal catalogue (each pin: net, direction, voltage, frequency or protocol), firmware map if there is one, the behaviour
table, and the open questions. Photos and captures stay in `re/`. Unit serial numbers, MAC addresses, keys and
credentials are not committed (`publish-anything`).
