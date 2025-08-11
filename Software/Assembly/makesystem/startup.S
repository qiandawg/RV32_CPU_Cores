.set noreorder 
.section .init_text, "ax"

c0_entryhi = $9
c0_entrylo = $2
c0_context = $4
c0_index = $0
c0_cause = $13
c0_epc = $14
c0_status = $12

reset:
    j initialize_itlb
    nop
excep_handler:
    mfc0  $26,c0_cause
    andi $26,$26,0x1c
    lw  $27,j_table($26)
    nop
    jr  $27
    nop

    .org 0x40
 j_table:
    .word int_entry
    .word sys_entry
    .word uni_entry
    .word ovf_entry
    .word itlb_entry
    .word dtlb_entry
    .word reset
    .word reset

int_entry:
    j reset
    nop

sys_entry:
    j reset
    nop

uni_entry:
    j reset
    nop

ovf_entry:
    j reset
    nop

itlb_entry:
    lui $27,0x8000
    lw $26,itlb_ctr
    addi $26,$26,1
    andi $26,$26,0x7
    sw $26,itlb_ctr
    lui $27,0x0
    or $26,$27,$26
    mtc0 $26,c0_index
    mfc0 $27,c0_context
    lw $26,0($27)
    mtc0 $26,c0_entrylo
    sll $26,$27,0xa
    srl $26,$26,0xc
    mtc0 $26,c0_entryhi
    tlbwi
    eret
    nop

dtlb_entry:
    lui $27,0x8000
    lw $26,dtlb_ctr
    addi $26,$26,1
    andi $26,$26,0x7
    sw $26,dtlb_ctr
    lui $27,0x4000
    or $26,$27,$26
    mtc0 $26,c0_index
    mfc0 $27,c0_context
    lw $26,0($27)
    mtc0 $26,c0_entrylo
    sll $26,$27,0xa
    srl $26,$26,0xc
    mtc0 $26,c0_entryhi
    tlbwi
    eret
    nop

initialize_itlb:
    mtc0 $0,c0_index
    lui $27,0x9000
    lw $26,0($27)
    mtc0 $26,c0_entrylo
    lui $26,0x0
    mtc0 $26,c0_entryhi
    tlbwi
    mtc0 $27,c0_context
    li $26,0x3f
    mtc0 $26,c0_status
.set noat
    lui $1,0x0
    jr $1
.set at
    nop
    nop

itlb_ctr: .word 0
dtlb_ctr: .word 0

.section .tlb_data, "aw"
    .word 0x00820000
    .word 0x00820002
    .word 0x00820001
    .word 0x008200f0
