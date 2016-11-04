.globl main
.globl next
.globl wrapup

.data
mem: .halfword 0x0605 0xfe0c 0xfa00 0x1e12 0xae00

.text
main:	lui $t0, 0x1000
		lbu $t1, ($t0)
		addi $t0, $t0, 1
		lbu $t2, ($t0)
		and $v0, $0, $0

next: 	lb $t2, ($t0)
		addi $t0, $t0, 1
		add $v0, $t2, $v0
		slt $t3, $t2, $0
		beq $t3, $0, wrapup
		nor $0, $0, $0
		sub $t2, $0, $t2
		sb $t2, -1($t0)

wrapup:	addi $t1, $t1, -1
		bgtz $t1, next
		nor $0, $0,  $0