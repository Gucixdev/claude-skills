# hardware-anything (cpu)

A RISC-V-style core: from the instruction table to RTL that agrees with a reference model on every instruction.
Start in C, because the reference model decides what "correct" means; the hardware is the second implementation.

## Order

1. **DESIGN.md** (`whiteboard-programming`): need / maybe / no. Word size (RV32), extensions (I; M and C are later),
   privilege (machine mode only or none), memory map, interrupts (none first), pipeline (single-cycle or 5-stage),
   target (simulation only, an FPGA board he owns, or an ASIC shuttle - the target sets the clock and the memory style).
2. **ISA table, one source**: opcode, format, fields, semantics, as data (TSV). Decoder, assembler macros and the docs
   are generated from it. A custom instruction goes into the same table; LLVM assembles unknown opcodes with
   `.insn` (tested here: `.insn r 0x0b, 0, 0, a0, a1, a2` assembles to `00c5850b`).
3. **Reference model**: `scripts/rv32/iss.c`, RV32I in about 150 lines of C89, builds with `-std=c89 -pedantic -Werror`
   and ASan/UBSan. `iss -t prog.bin` prints one line per retired instruction (`pc insn xRD=value`): the golden trace.
   Extend it with M (mul/div corner cases: divide by zero gives -1 and the dividend as remainder; MIN/-1 overflow),
   then CSRs and traps if wanted.
4. **Programs**: `scripts/rv32-run [-m rv32im] [-i] prog.c` compiles with clang, links at 0x80000000, runs on QEMU's
   `virt` board; `-i` makes the C model run the same ELF and compares output and exit status. QEMU is a second
   independent model, so a bug in `iss.c` shows as a disagreement before any hardware exists. Write the tests that
   target the hardware's weak spots: back-to-back dependent instructions (forwarding), load then use (stall), taken
   branches (flush), sign extension of every load width, shifts by 0 and 31, `x0` as destination, misaligned and
   out-of-range addresses (a trap in the model - decide and document what the core does).
   The official `riscv-tests` / `riscv-arch-test` suites are the reference for compliance; fetch them when the core
   passes the home-made ones (UNSURE of current repo layout, read their READMEs).
5. **RTL**: Verilog or SystemVerilog (Amaranth or Chisel if he wants Python or Scala; `pip`/`sbt` not installed).
   Start with the register file + ALU + decoder as separate modules each with its own test, then the datapath.
   Rules that save weeks: one clock, synchronous reset, no latches (`always_ff` / `always_comb`), memory as a
   module with a parameterised depth and a `$readmemh` image.
6. **Simulate** with Verilator (C++ test bench, fast) or Icarus (quick). Needs
   `sudo pacman -S verilator iverilog gtkwave` (he runs it). The test bench loads the same flat binary
   (`llvm-objcopy -O binary`) as the C model.
7. **Lockstep check**: the test bench prints `pc insn rd=value` at each retire, in the same format as `iss -t`;
   `diff <(iss -t prog.bin) <(vsim_trace)` shows the first instruction where the hardware differs. A pipelined core
   retires in order, so the traces match exactly; stalls only change the cycle count, which is a separate number.
8. **Formal**: riscv-formal (SymbiYosys; `sby` is not in the Arch repos, AUR or source) proves each instruction's
   semantics against a model for all inputs, not only the test programs. The alternative that needs nothing: Lean 4
   (`code (lean4)`) or Z3 (`pacman -S z3`) models of the ALU and decoder, proving for example that the adder
   implementation equals the spec on all 32-bit inputs for the shape you generate. State what was proved.
9. **Synthesis and numbers**: `yosys -p "synth -top core; stat"` for cell counts; `nextpnr` + a vendor-neutral flow
   (iCE40, ECP5 with open tools) gives the maximum clock for an FPGA he owns; CPI and Coremark/Dhrystone-style
   numbers come from the testbench cycle counter, written into `docs/` with the command.

## What counts as done

A table in `docs/`: instructions implemented (from the ISA table), tests passing on QEMU, C model and RTL, lockstep
diff empty on every program, formal result if any, resource and clock numbers, and the list of what is not
implemented (traps, CSRs, interrupts, M, C). "Boots Linux" is a separate, large goal (MMU, S-mode, CLINT/PLIC, SBI):
do not claim it from a toy core.
