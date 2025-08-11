MEMORY
{
	/* ram0 - Startup/Exception Text */
	ram0  : ORIGIN = 0x00000000, LENGTH = 1K

	/* ram1 - Page Table Data */
	ram1  : ORIGIN = 0x10000000, LENGTH = 1K

	/* ram2 - User Text */
	ram2  : ORIGIN = 0x20000000, LENGTH = 16K

	/* ram3 - User Data */
	ram3  : ORIGIN = 0x20002000, LENGTH = 16K
}

SECTIONS
{
	.init_text 0x80000000 : { *(.init_text) } AT> ram0
	.tlb_data 0x90000000 : { *(.tlb_data) } AT> ram1

	. = 0x00000000; /* Begin laying out memory from 0x00000000 virtual */
	.text . : {     *(.text) } AT> ram2 /* Emplace application code at "ram2" physical */

	. = 0x00001000; /* Now at virtual address 0x1000 */
	_DRAM_BASE = .;

	/* Setup the early stack (if any) right here. Usually a part of crt.c to bootstrap things.*/
	.early_stack . : { *(.early_stack) } AT> ram3

	.data . : { _DATA_BEGIN = .; *(.data) } AT>ram3 /* put in "ram3" */

	/* rodata and bss are used for C constants and zero-initialized "stack" variables */
	.rodata . : { *(.rodata) } AT>ram3 /* put in "ram3" */
	.bss . : { _BSS_BEGIN = .; *(.bss); _BSS_END = .; } AT>ram3

	/* The user-code stack top starts at the next available 4-byte aligned address */
	_STACK_TOP = _DRAM_BASE + LENGTH(ram3) - 4; /* Any space in our data ram is used for stack */

	/DISCARD/ : { *(.reginfo) *(.MIPS.abiflags) *(.gnu.attributes) }
}
