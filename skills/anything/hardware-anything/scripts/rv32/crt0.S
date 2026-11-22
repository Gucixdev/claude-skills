# Startup for bare RV32I programs run by rv32-run: stack, call main, report its return value, stop.
# The "virt" board of QEMU has the 16550 UART at 0x10000000 and the test finisher at 0x100000
# (write 0x5555 = pass, (code << 16) | 0x3333 = fail with that code).
	.section .text.init
	.globl _start
_start:
	la	sp, _stack_top
	call	main
	beqz	a0, 1f
	slli	a0, a0, 16
	li	t0, 0x3333
	or	a0, a0, t0
	j	2f
1:	li	a0, 0x5555
2:	li	t0, 0x100000
	sw	a0, 0(t0)
3:	j	3b
