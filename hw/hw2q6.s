# ASKS FOR USER TO ENTER INTEGER
# CALL ROUTINE COUNT THAT COUNTS THE 
# NUM OF OCCURENCES OF THE USER ENTERED
# INTEGER IN AN ARRAY OF INTEGERS

.globl main
.globl count
.globl countloop
.globl notequal
.globl done

.data
array:  .byte   4, 8, 4, 3, 2, 5, 9, 5, 7, 1
blank: 	.space	6 
string1: .asciiz "Enter integer: "

.text
count:
	# t0 = max index
	# t1 = array addrr
	# t2 = current byte
	# v0 = return count
	# a0 = user input 
	addi $t0, $0, 10	#max index t0 to 10
	lui $t1, 0x1001		#set t1 to array addr
	add $v0, $0, $0  	#initialize return count 
countloop:
	lbu $t2, ($t1)		#load byte into t2 from current address
	bne $a0, $t2, notequal #compare $a0 with t1
	add $0, $0, $0 	#nop
	addi $v0, $v0, 1	#if equal, increment return count
notequal:
	addi $t1, $t1, 1	#increment array addr
	addi $t0, $t0, -1	#decrement t1 max index
	bne $t0, $0, countloop	#loop back to count if t0 != 0
	add $0, $0, $0		#nop
	jr	$ra
	add $0, $0, $0		#nop	

main:
	# GET INPUT
	lui $a0, 0x1001   	#load string into a0
	ori $a0, 0x0010
	addi $v0, $0, 4   	#string instr 4 into v0
	syscall           	#call print string

	addi $v0, $0, 5   	#string instr 5 int v0, read int
	syscall            	#result in v0
	add $a0, $0, $v0	#place input into a0

	jal count			#call count routine, 1 arg in a0
	add $0, $0, $0 	#nop

done:
	add $0, $0, $0		#nop