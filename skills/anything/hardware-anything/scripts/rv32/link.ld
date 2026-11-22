/* QEMU virt: RAM starts at 0x80000000. Code first, 64 KiB stack at the top of the first 1 MiB. */
ENTRY(_start)
SECTIONS {
	. = 0x80000000;
	.text : { *(.text.init) *(.text*) }
	.rodata : { *(.rodata*) *(.srodata*) }
	.data : { *(.data*) *(.sdata*) }
	.bss : { *(.bss*) *(.sbss*) *(COMMON) }
	. = 0x80100000;
	_stack_top = .;
}
