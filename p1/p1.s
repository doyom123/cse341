# DATA SECTION EXAMPLE
# .data
# a: .half 32
# b: .half 923
# c: .half 0x6214
# d: .half 4
# e: .half 17
# exp: .asciiz "c:=25+b/a+b*3"

# STACK EXAMPLE
# c:=a/3-e*2
# stack should look like
#  ____
# | + | - TOP
# | / |
# | a |
# | 3 |
# | * |
# | e |
# | 2 | - BOTTOM
# -----
# pop *e2 first
# then pop /a3 next
# then +

#     NULL = 0x00 
#   + = 43 = 0x2b
#   - = 45 = 0x2d
#   * = 42 = 0x2a
#   / = 47 = 0x2f
#   % = 37 = 0x25
#   :=  58 = 0x3a 61 0x3d
#    space = 32 0x20
#        0 = 48
#        1 = 49
#        2 = 50
#        3 = 51   
#        4 = 52
#        5 = 53
#        6 = 54
#        7 = 55   
#        8 = 56
#        9 = 57

.globl main
.globl mainloop
.globl main1
.globl main11
.globl main2
.globl main21
.globl main22
.globl error
.globl end
.globl end1
.globl done

.globl ADD
.globl SUB
.globl MULT
.globl mloop
.globl m1
.globl m2
.globl m3
.globl mend
.globl DIVIDE
.globl dloop
.globl d1
.globl d2
.globl d3   
.globl d4
.globl dend
.globl CALC

.globl ISVALID
.globl isvalid1
.globl ISOPRT
.globl isoprt1
.globl ISVAR
.globl isvar1
.globl PREC
.globl prec1
.globl prec2

.globl OPRDPUSH
.globl oprdpush1
.globl OPRDPOP
.globl oprdpop1
.globl OPRTPUSH
.globl oprtpush1
.globl OPRTPOP
.globl oprtpop1

.data
a: .half 32
b: .half 923
c: .half 0x6214
d: .half 4
e: .half 17
empty: .space 6
oprd: .space 64              # 0x1000 0010 max_size = 16
oprt: .space 64              # 0x1000 0050 max_size = 16
exp: .asciiz "c:=258+b/a+b*3" # 0x1000 0090

.text
#________________<>MATH FUNCTIONS<>________________ 
ADD:
    add $v0, $a1, $a2
    jr $ra
    or $0, $0, $0    

SUB:
    sub $v0, $a1, $a2
    jr $ra
    or $0, $0, $0

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
    add $v0, $0, $a1    #set v0 to a1
    beq $a2, $t1, mend  #check if $a2 == 1
    addi $a2, $a2, -1   #decrement counter
mloop:
    add $v0, $v0, $a1   #
    addi $a2, $a2, -1   #decrement counter
    bne $a2, $0, mloop  #check if counter $a2 is 0
    or $0, $0, $0       #nop
m3:
    beq $t7, $0, mend   #branch if positive, else set neg
    or $0, $0, $0       #nop
    sub $v0, $0, $v0
mend:
    jr $ra              #complete MULT subroutine
    or $0, $0, $0       #nop  

DIVIDE:
    #t0-counter     t1-remainder bit set
    #check sign for a1, t0 holds sign bit
    slt $t0, $a1, $0    #t0 = 1 if a1 < 0 
    beq $t0, $0, d1     #branch to d1 if a1 is positive
    add $v0, $v0, $0    #clear $v0
    sub $a1, $0, $a1    #a1 = abs(a1)
d1:
    #check sign for a2, t1 holds sign bit
    slt $t1, $a2, $0    #t1 = 1 if a2 < -
    beq $t1, $0, d2     #branch to d2 if a2 is positive
    or $0, $0, $0       #nop
    sub $a2, $0, $a2    #a2 = abs(a2)
d2:
    #evaluate sign for result
    xor $t7, $t0, $t1   #SIGN IN $t7, 0 = POS, 1 = NEG
    addi $t0, $0, 17    #initialize counter to 17
    add $v0, $0, $0     #initialize quotient to 0
    add $v1, $a1, $0    #remainder reg initialized with dividend
    sll $a2, $a2, 16    #load divisor in left half of 32bit reg
dloop:
    sub $v1, $v1, $a2   #sub remainder -= divisor
    slt $t1, $v1, $0    #0 v1 positive,1 v1 negative
    beq $t1, $0, d3     #if positive skip to d3
    sll $v0, $v0, 1     #shift quotient left, set lsb to 0
    add $v1, $v1, $a2   #if neg, restore remainder += divisor 
    j   d4
    or $0, $0, $0,      #nop
d3:
    addi $v0, $v0, 1    #set quotient lsb to 1
d4:
    srl $a2, $a2, 1     #shift divisor reg right 1 bit
    addi $t0, $t0, -1   #repetition counter - 1
    bne $t0, $0, dloop  #branch to dloop if counter = 0
    or $0, $0, $0       #nop

    beq $t7,  $0, dend  #TODO : set sign to result $v0
    or $0, $0, $0       #nop
    sub $v0, $0, $v0
dend:
    jr $ra              #return to main
    add $0, $0, $0      #nop

CALC: #TODO : TEST
    addi $t0, $0, 43 # +
    beq $a0, $t0, ADD 
    or $0, $0, $0

    addi $t0, $0, 45 # -
    beq $a0, $t0, SUB 
    or $0, $0, $0

    addi $t0, $0, 42 # *
    beq $a0, $t0, MULT
    or $0, $0, $0

    addi $t0, $0, 47 # /
    beq $a0, $t0, DIVIDE 
    or $0, $0, $0

    addi $t0, $0, 37 # %
    beq $a0, $t0, DIVIDE 
    addi $v2, $0, 1         #set v2 0=notmod, 1=mod

###################################################
#________________<>BYTE_OPERATIONS<>_______________
###################################################
ISVALID:
    addi $t0, $0, 97
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 98
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 99
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 100
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 101
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 48
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 49
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 50
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 51
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 52
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 53
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 54
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 55
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 56
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 57
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 43
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 45
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 42
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 47
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 37
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 58
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 61
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $t0, $0, 0
    sub $t0, $a0, $t0
    beq $t0, $0, isvalid1
    addi $v0, $0, 1
    addi $v0, $0, 0
isvalid1:
    jr $ra
    or $0, $0, $0

ISVAR:
    addi $t0, $a0, -97      #compare to 'a'
    lui $t1, 0x1000         #load half word at a
    or $t1, $t1, 0x0000
    lh $v1, 0($t1)
    or $0, $0, $0      
    beq $t0, $0, isvar1
    addi $v0, $0, 1

    addi $t0, $a0, -98      #compare to 'b'
    lui $t1, 0x1000         #load half word at b
    or $t1, $t1, 0x0002
    lh $v1, 0($t1) 
    or $0, $0, $0     
    beq $t0, $0, isvar1
    addi $v0, $0, 1

    addi $t0, $a0, -99      #compare to 'c'
    lui $t1, 0x1000         #load half word at c
    or $t1, $t1, 0x0004
    lh $v1, 0($t1)
    or $0, $0, $0      
    beq $t0, $0, isvar1
    addi $v0, $0, 1

    addi $t0, $a0, -100      #compare to 'd'
    lui $t1, 0x1000         #load half word at d
    or $t1, $t1, 0x0006
    lh $v1, 0($t1)
    or $0, $0, $0      
    beq $t0, $0, isvar1
    addi $v0, $0, 1

    addi $t0, $a0, -101     #compare to 'e'
    lui $t1, 0x1000         #load half word at e
    or $t1, $t1, 0x0008
    lh $v1, 0($t1)
    or $0, $0, $0      
    beq $t0, $0, isvar1
    addi $v0, $0, 1
    addi $v0, $0, 0         #set return value v0 = 0
    addi $v1, $0, 0         #set return value v1 = 0
isvar1:
    jr $ra
    or $0, $0, $0 

ISOPRT:
    addi $t0, $a0, -43      #compare to '+'
    beq $t0, $0, isoprt1
    addi $v0, $0, 1
    addi $t0, $a0, -45      #compare to '-'
    beq $t0, $0, isoprt1
    addi $v0, $0, 1
    addi $t0, $a0, -42      #compare to '*'
    beq $t0, $0, isoprt1
    addi $v0, $0, 1
    addi $t0, $a0, -47      #compare to '/'
    beq $t0, $0, isoprt1
    addi $v0, $0, 1
    addi $t0, $a0, -37      #compare to '%'
    beq $t0, $0, isoprt1
    addi $v0, $0, 1         #set return v0 = true 
    addi $v0, $0, 0         #set return v1 = false
isoprt1:
    jr $ra
    or $0, $0, $0           #nop

PREC:
    #Find PREC($a0)
    addi $t0, $a0, -43      #compare a0 to '+'
    beq $t0, $0, prec1      #branch if equal to '+'
    addi $t0, $0, 0         #set PREC(a0) = 0
    addi $t0, $a0, -45      #compare a0 to '-'
    beq $t0, $0, prec1      #branch if equal to '-' 
    addi $t0, $0, 0         #set PREC(a0) = 0
    addi $t0, $0, 1         #set PREC(a1) = 1
prec1:
    #Find PREC(oprt.top)
    lw $t1, -4($s3)         #load oprt.top in $t0
    addi $t2, $t1, -43      #compare oprt.top to '+'
    beq $t2, $0, prec2      #branch if equal to '+'
    addi $t2, $0, 0         #set PREC(oprt.top) = 0
    addi $t2, $t1, -45      #compare oprt.top to '-'
    beq $t2, $0, prec2      #branch if equal to '-''
    addi $t2, $0, 0         #set PREC(oprt.top) = 0
    addi $t2, $0, 1         #set PREC(oprt.top) = 1
prec2:
    slt $v0, $t0, $t2       #evaluate $a0 < oprt.top
    jr $ra
    or $0, $0, $0           #nop
###################################################
#_______________<>STACK_OPERATIONS<>_______________
###################################################
OPRDPUSH:
    beq $s1, $s2, oprdpush1 #branch if oprd_ptr == oprt_addr
    addi $v0, $0, 0         #set success fail
    sw $a0, 0($s1)          #push to oprd stack
    addi $s1, $s1, 4        #increment oprd_ptr
    addi $v0, $0, 1         #set success return
oprdpush1:
    jr $ra                  #return 
    or $0, $0, $0           #nop

OPRDPOP:
    beq $s0, $s1, OPRDPOP   #check if empty
    addi $v1, $0, 0         #set fail return 0
    lw $v0, -4($s1)         #pop from oprd_stack
    addi $s1, $s1, -4       #decrement oprd_ptr
    addi $v1, $0, 1         #set success return 1
oprdpop1:
    jr $ra                  #return
    or $0, $0, $0           #nop

OPRTPUSH:
    beq $s3, $s4, oprtpush1 #branch if oprd_ptr == exp_addr
    addi $v0, $0, 0         #set fail return 0
    sw $a0, 0($s3)          #push to oprt_stack
    addi $s3, $s3, 4        #increment oprt_ptr
    addi $v0, $0, 1         #set success return 1
oprtpush1:
    jr $ra                  #return 
    or $0, $0, $0           #nop

OPRTPOP:
    beq $s2, $s3, oprtpop1  #check if empty
    addi $v1, $0, 0         #set fail return 0
    lw $v0, -4($s3)         #pop from oprt_stack
    addi $s3, $s3, -4       #decrement oprt_ptr
    addi $v1, $0, 1         #set success return 1
oprtpop1:
    jr $ra                  #return
    or $0, $0, $0           #nop
###################################################
#_____________________<>MAIN<>_____________________
###################################################
main:
    #Preprocessing
    #Setup stack addresses and pointers
    lui $s0, 0x1000         #load oprd_stack_addr
    or  $s0, $s0, 0x0010
    lui $s1, 0x1000         #load oprd_stack_ptr
    or  $s1, $s1, 0x0010
    lui $s2, 0x1000         #load oprt_stack_addr
    or  $s2, $s2, 0x0050
    lui $s3, 0x1000         #load oprt_stack_ptr
    or  $s3, $s3, 0x0050
    lui $s4, 0x1000         #load expr_addr
    or  $s4, $s4, 0x0090
    addi $s7, $0, 0         #initialize num = 0
    
    # TODO HANDLE ASSIGNMENT

    lui $s5, 0x1000         #load current_byte_ptr
    or  $s5, $s5, 0x0093  

mainloop:    
    #Get current byte right after '='
  
    lb  $s6, 0($s5)         #load current_byte
    or $0, $0, $0
    #Evaluate current byte
    add $a0, $0, $s6        #check if cb is valid
    jal ISVALID
    or $0, $0, $0
    beq $v0, $0, error
    or $0, $0, $0

    beq $s6, $0, end        #check if cb == NULL
    or $0, $0, $0

    # cb = $s6
    addi $t0, $0, 32        #check if cb == space
    beq $s6, $t0, mainloop  
    or $0, $0, $0

    add $a0, $0, $s6        #check if cb is a var
    jal ISVAR
    or $0, $0, $0
    beq $v0, $0, main1
    or $0, $0, $0
    add $s6, $0, $v1        #if ISVAR == 1 set value to s6
    j main11                #jump to OPRDPUSH int value
    or $0, $0, $0
main1:
    add $a0, $0, $s6        #check if cb is oprt
    jal ISOPRT
    or $0, $0, $0
    addi $t0, $0, 1
    beq $v0, $t0, main2     #if cb is oprt, branch
    or $0, $0, $0
    
    #cb is OPERAND
    addi $s7, $s7, 1        #increment num bit
    addi $s6, $s6, -48      #turn ascii char to int

    beq $s0, $s1, main11    #check if oprd is empty
    or $0, $0, $0

    #if oprd not empty
    addi $t0, $0, 1         #check if num > 1
    slt $t0, $t0, $s7
    beq $t0, $0, main11     #if not, branch to OPRDPUSH
    or $0, $0, $0
    
    #multidigit handler
    jal OPRDPOP             #temp = oprd.top
    or $0, $0, $0           
    add $a1, $0, $v0        
    addi $a2, $0, 10
    jal MULT                #temp *= 10
    or $0, $0, $0
    add $v0, $v0, $s6       #temp += cb
    add $a0, $0, $v0
    jal OPRDPUSH            #push temp onto oprd_stack
    addi $s5, $s5, 1        #increment cb_ptr
    j mainloop
    or $0, $0, $0

main11:
    add $a0, $0, $s6        #push cb to oprd
    jal OPRDPUSH
    addi $s5, $s5, 1         #increment cb_ptr
    j mainloop
    or $0, $0, $0

main2: #cb is OPERATOR
    addi $s7, $0, 0         #set num = 0
    beq $s2, $s3, main21     #check if oprt_stack is empty
    or $0, $0, $0

    #if oprt not empty
    add $a0, $0, $s6        #evaluate precedence
    jal PREC
    or $0, $0, $0

    beq $v0, $0, main21
    or $0, $0, $0

    #calc subroutine
    jal OPRDPOP
    or $0, $0, $0
    add $a1, $0, $v0
    jal OPRDPOP
    or $0, $0, $0
    add $a2, $0, $v0
    jal OPRTPOP
    or $0, $0, $0
    add $a0, $0, $v0
    jal CALC
    or $0, $0, $0
    beq $v2, $0, main22 #if notmod branch to end1
    add $a0, $0, $v0
    jal OPRDPUSH
    or $0, $0, $0
    j end
    or $0, $0, $0
main22:  #TEST
    add $a0, $0, $v1
    jal OPRDPUSH
    or $0, $0, $0,
    j main2
    or $0, $0, $0
    
main21:
    add $a0, $0, $s6        #push cb to oprt
    jal OPRTPUSH
    addi $s5, $s5, 1        #increment cb_ptr
    j mainloop
    or $0, $0, $0

error: 
    #TODO : PRINT OUT ERROR MESSAGE
    #addi $v0, $0, 4
    #lui $a0, 0x1000
    #or $a0, $a0, 0x????
    #syscall
    #j done

end:
    #TODO : WHILE LOOP POPPING OPRT_STACK
    #STATUS : TEST
    beq $s2, $s3, done #branch if operator stack is empty
    or $0, $0, $0
    jal OPRDPOP
    or $0, $0, $0
    add $a1, $0, $v0
    jal OPRDPOP
    or $0, $0, $0
    add $a2, $0, $v0
    jal OPRTPOP
    or $0, $0, $0
    add $a0, $0, $v0
    jal CALC
    or $0, $0, $0
    beq $v2, $0, end1 #if notmod branch to end1
    add $a0, $0, $v0
    jal OPRDPUSH
    or $0, $0, $0
    j end
    or $0, $0, $0
end1:  #is mod, OPRDPUSH v1 instead of v0
    add $a0, $0, $v1
    jal OPRDPUSH
    or $0, $0, $0,
    j end
    or $0, $0, $0

done:
#                        (  )/  
#                         )(/
#      ________________  ( /)
#     ()__)____________)))))  

    or $0, $0, $0
    
