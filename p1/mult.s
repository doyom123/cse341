.globl MULT
.globl mloop
.globl m1
.globl m2
.globl m3	#sets sign of result
.globl mend
.globl main

.data

.text
# Subroutine MULT
# Returns the product of two numbers
# param   : $a1, $a2
# return  : $vo
MULT:
  #check sign for a1, t0 holds sign bit
  slt $t0, $a1, $0    #t0 = 1 if a1 < 0
  beq $t0, $0, m1     #b to m1 if a1 is positive
  add $v0, $v0, $0    #clear $v0
  sub $a1, $0, $a1    #a1 = abs(a1)
m1:
  #check sign for a2, t1 holds sign bit
  slt $t1, $a2, $0    #t1 = 1 if a2 < 0
  beq $t1, $0, m2     #branch to m2 if a2 is positive
  or $0, $0, $0       #nop
  sub $a2, $0, $a2    #a2 = abs(a2)
m2:
  #evaluate sign for result
  xor $t7, $t0, $t1   #SIGN IN $T7, 0 = POS, 1 = NEG
  beq $a2, $0, mend   #check if $a2 == 0     
  addi $t1, $0, 1
  add $v0, $0, $a1 	  #set v0 to a1
  beq $a2, $t1, mend  #check if $a2 == 1
  addi $a2, $a2, -1   #decrement counter
mloop:
  add $v0, $v0, $a1   #
  addi $a2, $a2, -1   #decrement counter
  bne $a2, $0, mloop  #check if counter $a2 is 0
  or $0, $0, $0       #nop
m3:
  beq $t7, $0, mend	  #branch if positive, else set neg
  or $0, $0, $0		  #nop
  sub $v0, $0, $v0
mend:
  jr $ra              #complete MULT subroutine
  or $0, $0, $0       #nop  
  
main:
  addi $a1, $0, 4
  addi $a2, $0, -8
  jal MULT
  or $0, $0, $0      #nop

