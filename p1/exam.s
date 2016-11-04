.globl main
.globl process
.globl midpt
.globl finish

.data

.text
main:
	addi $a0, $0, 0xC7
	addi $t0, $0, 0x94
	addi $v0, $0, 0x05  
process:
	sll $t0, $a0, 28
	srl $t0, $t0, 31
	sll $a0, $a0, 25
	srl $a0, $a0, 31
	xor $v0, $a0, $t0
	beq $v0 $0, finish
	or $0, $0, $0
midpt:
	addi $v0, $a0, 1
finish:
	jr $ra
	or $0, $0, $0