.globl main
.globl done
.globl divide
.globl loop
.globl step2a   
.globl step3

.data
dividend: 	.asciiz "Enter Dividend:"
divisor: 	.asciiz "Enter Divisor: "
quotient: 	.asciiz "Quotient is    "
remainder:      .asciiz "Remainder is   "

.text
divide:
	#v0-quotient 	v1-remainder
	#a0-dividend 	a1-divisor
	#t0-counter 	t1-remainder bit set
	addi 		$t0, $0, 17 	#initialize counter to 17
	add 		$v0, $0, $0 	#initialize quotient to 0
	add 		$v1, $a0, $0	#remainder reg initialized with dividend
	sll 		$a1, $a1, 16 	#load divisor in left half of 32bit reg
loop:
	sub 		$v1, $v1, $a1	#sub remainder -= divisor
	slt 		$t1, $v1, $0 	#0 v1 positive,1 v1 negative

	beq 		$t1, $0, step2a #if positive skip to rempos
	sll 		$v0, $v0, 1		#shift quotient left, set lsb to 0
	add 		$v1, $v1, $a1	#if neg, restore remainder += divisor 
	j  		step3
	add 		$0, $0, $0, 	#NOP

step2a:
	addi 		$v0, $v0, 1 	#set quotient lsb to 1

step3:
	srl 		$a1, $a1, 1	#shift divisor reg right 1 bit
	addi 		$t0, $t0, -1    #repetition counter - 1
	bne 		$t0, $0, loop   #branch to loop if counter = 0
	add  		$0, $0, $0	#NOP

	jr		$ra	        #return to main
	add $0, $0, $0			#NOP


main:
	#Display string and read dividend
	addi	 	$v0, $0, 4	#load immediate, sys call 4 for printing strings
	
	lui		$a0, 0x1000	#load address str into a0
	syscall				#OS performs syscall to print divident
	
	addi		$v0, $0, 5	#syscall 5 for read int
	syscall
	add		$t0, $v0, $0 	#store dividend

	#Display string and read divisor
	addi		$v0, $0, 4 	#load syscall 4 for print string
	lui		$a0, 0x1000	#lui of divisor string
	addi		$a0, $a0, 16	#add offset to divisor str
	syscall				#print string
	addi		$v0, $0, 5 	#read int
	syscall
	
	add  		$a1, $v0, $0	#store divisor into a1
	add  		$a0, $t0, $0    #store dividend into a0
	jal divide  			#call divide routine
	add 		$0, $0, $0  	#NOP

	add 		$t0, $v0, $0 	#save quotient in t0

	#Display Quotient
	addi		$v0, $0, 4	#Print quotient str
	lui		$a0, 0x1000
	addi		$a0, 0x0020
	syscall
	addi		$v0, $0, 1	#Print quotient int
	add  		$a0, $t0, $0
	syscall
	addi 		$v0, $0, 11 	#Print new line
	addi 		$a0, $0, 10 	
	syscall

	#Display Remainder
	addi		$v0, $0, 4	#Print remainder str
	lui		$a0, 0x1000
	addi 		$a0, 0x0030
	syscall
	addi 		$v0, $0, 1;	#Print remainder int
	add 		$a0, $v1, $0
	syscall
	addi 		$v0, $0, 11 	#Print new line
	addi 		$a0, $0, 10 	
	syscall
	syscall
	j 		main			
	add $0, $0, $0			#NOP

