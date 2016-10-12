.globl DIVIDE
.globl dloop
.globl d1
.globl d2
.globl d3   
.globl d4
.globl dend
.globl main
.globl done

.data
dividend: 	.asciiz "Enter Dividend:"
divisor: 	.asciiz "Enter Divisor: "
quotient: 	.asciiz "Quotient is    "
remainder:  .asciiz "Remainder is   "

.text
# Subroutine DIVIDE
# Returns the quotient and dividend of two numbers
# param  : divident $a1, divisor $a2
# return : quotient $v0, remainder $v1
DIVIDE:
	#v0-quotient 	v1-remainder
	#a1-dividend 	a2-divisor
	#t0-counter 	t1-remainder bit set
	
	#check sign for a1, t0 holds sign bit
	slt $t0, $a1, $0 	#t0 = 1 if a1 < 0 
	beq $t0, $0, d1		#branch to d1 if a1 is positive
	add $v0, $v0, $0	#clear $v0
	sub $a1, $0, $a1 	#a1 = abs(a1)
d1:
	#check sign for a2, t1 holds sign bit
	slt $t1, $a2, $0 	#t1 = 1 if a2 < -
	beq $t1, $0, d2 	#branch to d2 if a2 is positive
	or $0, $0, $0		#nop
	sub $a2, $0, $a2 	#a2 = abs(a2)
d2:
	#evaluate sign for result
	xor $t7, $t0, $t1 	#SIGN IN $t7, 0 = POS, 1 = NEG
	addi $t0, $0, 17 	#initialize counter to 17
	add $v0, $0, $0 	#initialize quotient to 0
	add $v1, $a1, $0	#remainder reg initialized with dividend
	sll $a2, $a2, 16 	#load divisor in left half of 32bit reg
dloop:
	sub $v1, $v1, $a2	#sub remainder -= divisor
	slt $t1, $v1, $0 	#0 v1 positive,1 v1 negative
	beq $t1, $0, d3 	#if positive skip to rempos
	sll $v0, $v0, 1		#shift quotient left, set lsb to 0
	add $v1, $v1, $a2	#if neg, restore remainder += divisor 
	j 	d4
	or $0, $0, $0, 		#NOP
d3:
	addi $v0, $v0, 1 	#set quotient lsb to 1

d4:
	srl $a2, $a2, 1		#shift divisor reg right 1 bit
	addi $t0, $t0, -1   #repetition counter - 1
	bne $t0, $0, dloop  #branch to dloop if counter = 0
	or $0, $0, $0		#NOP

	beq $t7,  $0, dend	#TODO : set sign to result $v0
	or $0, $0, $0 		#nop
	sub $v0, $0, $v0
dend:
	jr $ra   			#return to main
	add $0, $0, $0		#NOP


main:
	#Display string and read dividend
	addi $v0, $0, 4		#load immediate, sys call 4 for printing strings
	
	lui	$a0, 0x1000		#load address str into a0
	syscall				#OS performs syscall to print divident

	addi $v0, $0, 5		#syscall 5 for read int
	syscall
	add	$a1, $v0, $0 	#store dividend

	#Display string and read divisor
	addi $v0, $0, 4 	#load syscall 4 for print string
	lui	$a0, 0x1000		#lui of divisor string
	ori	$a0, $a0, 16	#add offset to divisor str
	syscall				#print string
	addi $v0, $0, 5 	#read int
	syscall
	add $a2, $v0, $0	#store divisor

	jal DIVIDE  		#call DIVIDE routine
	add $0, $0, $0  	#NOP

	add $t0, $v0, $0 	#save quotient in t0

	#Display Quotient
	addi $v0, $0, 4		#Print quotient str
	lui	$a0, 0x1000
	ori	$a0, 0x0020
	syscall
	addi $v0, $0, 1		#Print quotient int
	add $a0, $t0, $0
	syscall
	addi $v0, $0, 11 	#Print new line
	addi $a0, $0, 10 	
	syscall

	#Display Remainder
	addi $v0, $0, 4		#Print remainder str
	lui	$a0, 0x1000
	ori $a0, 0x0030
	syscall
	addi $v0, $0, 1;	#Print remainder int
	add $a0, $v1, $0
	syscall
	addi $v0, $0, 11 	#Print new line
	addi $a0, $0, 10 	
	syscall

	j main			
	add $0, $0, $0		#NOP

