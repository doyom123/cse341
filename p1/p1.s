# ###############  DATA ADDRESSES  ###############
#               a = 0x1000 0000  
#               b = 0x1000 0002  
#               c = 0x1000 0004  
#               d = 0x1000 0006  
#               e = 0x1000 0008  
#   operand stack = 0x1000 0010
#  operator stack = 0x1000 0050
#      expression = 0x1000 0090

# ###############  SAVED REGISTERS  ###############
# $s0 = operand stack addr     
# $s1 = operand stack pointer  
# $s2 = operator stack addr    
# $s3 = operator stack pointer 
# $s4 = expression addr        
# $s5 = current byte ptr       
# $s6 = current byte               
# $s7 = assop/num bit              
# $t5 = assignment addr 

# ###############  SUBROUTINE LIST  ###############
#  ____________________________________________
# /_______________math_functions______________/|
# |___________________________________________|/

# 1. ADD
# # $a1 + $a2 = $v0
# # PARAM  : $a1, $a2
# # RETURN : $v0

# 2. SUB
# # $a1 - $a2 = $v0
# # PARAM  : $a1, $a2
# # RETURN : $v0

# 3. MULT
# # Returns the product of two numbers
# # $a1 * $a2 = $v0
# # PARAM  : $a1, $a2
# # RETURN : $v0

# 4. DIVIDE
# # Returns the quotient and remainder of two numbers
# # $a1 / $a2 = $v0, remainder = $v1
# # PARAM  : $a1, $a2
# # RETURN : $v0,$v1

# 5. CALC
# # PARAM  : $a0, $a1, $a2
# # RETURN : $v0, $v1(DIVIDE and MOD), $a3(mod) // 0=notmod, 1=mod
#  _____________________________________________
# /_______________byte_operations______________/|
# |____________________________________________|/

# 1. ISVALID
# # Determines whether current bytes
# # is a valid input
# # [0-9,+,-,*,/,%,a-e]
# # PARAM  : $a0
# # RETURN : $v0 // 0=invalid, 1=valid

# 2. ISOPRT
# # Determines whether the given
# # byte is an operator or operand
# # PARAM  : $a0
# # RETURN : $v0 // 0=operand, 1=operator

# 3. ISVAR
# # Determines whether the given
# # byte is a variable [a-e]
# # If so, sets $v1 to value in memory of var
# # PARAM  : $a0
# # RETURN : $v0 // 0=false, 1=true
#            $v1

# 4. ISVARADDR        
# # Determines whether the given
# # byte is a variable [a-e]
# # If so, sets $v1 to addr of var
# # PARAM  : $a0
# # RETURN : $v0 // 0=false, 1=true
#            $v1 = addr

# 5. PREC
# # Compares precedence and
# # returns the value of the expression
# # prec($a0) <= prec(oprt.top)
# # PARAM  : $a0
# # RETURN : $v0 // 0=false, 1=true
#  ______________________________________________
# /_______________stack_operations______________/|
# |_____________________________________________|/

# 1. OPRDPUSH
# # Pushes a half word to 
# # operand array stack
# # PARAM  : $a0
# # RETURN : $v0 // 0=fail, 1=success

# 2. OPRDPOP
# # Returns the top of 
# # operand array stack
# # PARAM  : null
# # RETURN : $v0 = top of stack
# #          $v1 // 0=fail 1=success

# 3. OPRTPUSH
# # Pushes a half word to 
# # operator array stack
# # PARAM  : $a0
# # RETURN : $v0 // 0=fail, 1=success

# 4. OPRTPOP
# # Returns the top of 
# # operator array stack
# # PARAM  : null
# # RETURN : $v0 = top of stack
# #          $v1 // 0=fail 1=success


.globl main
.globl mainass
.globl mainassop
.globl mainassop1
.globl mainassop
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
#####VARIABLES#####
a:          .half 0 
b:          .half 0xFFFF 
c:          .half 0xCE20 
d:          .half 1 
e:          .half 102 
###################
empty1: .space 6
err_msg : .asciiz "SYNTAX ERROR"
empty: .space 2

oprd: .space 128       # 0x1000 0020 oprd stack max_size = 32
oprt: .space 128       # 0x1000 0060 oprt stack max_size = 32
empty2: .space 1

#####EXPRESSION#####
exp: .asciiz "e:=e   - 43 *     e+   e%17+462    - c   /   4" # 0x1000 0120
####################




.text
###################################################
#________________<>MATH FUNCTIONS<>________________
################################################### 
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

    beq $t7,  $0, dend  
    or $0, $0, $0       #nop
    sub $v0, $0, $v0
dend:
    jr $ra              #return
    add $0, $0, $0      #nop

CALC: 
    addi $a3, $0, 0     #reset a3 mod check to 0
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

    addi $t0, $0, 37 # /
    beq $a0, $t0, DIVIDE 
    addi $a3, $0, 1

###################################################
#________________<>BYTE_OPERATIONS<>_______________
###################################################
ISVALID:
    addi $t0, $0, 97        #redundant
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
    beq $t0, $0, isvalid1   #still redundant
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
    beq $t0, $0, isvalid1   #yeah
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
    lw $t1, -4($s3)         #load oprt.top in $t1
    or $0, $0, $0
    addi $t2, $t1, -43      #compare oprt.top to '+'
    beq $t2, $0, prec2      #branch if equal to '+'
    addi $t2, $0, 0         #set PREC(oprt.top) = 0
    addi $t2, $t1, -45      #compare oprt.top to '-'
    beq $t2, $0, prec2      #branch if equal to '-''
    addi $t2, $0, 0         #set PREC(oprt.top) = 0
    addi $t2, $0, 1         #set PREC(oprt.top) = 1
prec2:
    slt $v0, $t2, $t0       #evaluate $a0 <= oprt.top
    beq $v0, $0, prec3 
    or $0, $0, $0
    addi $v0, $0, 0
    jr $ra                  #return in v0 ~(a0 > oprt.top)
    or $0, $0, $0
prec3:
    add $v0, $0, 1
    jr $ra
    or $0, $0, $0  
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
    addi $t0, $0, 0
    sw $t0, 0($s1)
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
    addi $t0, $0, 0
    sw $t0, 0($s3)
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
    or  $s0, $s0, 0x0020
    lui $s1, 0x1000         #load oprd_stack_ptr
    or  $s1, $s1, 0x0020
    lui $s2, 0x1000         #load oprt_stack_addr
    or  $s2, $s2, 0x00A0
    lui $s3, 0x1000         #load oprt_stack_ptr
    or  $s3, $s3, 0x00A0
    lui $s4, 0x1000         #load expr_addr
    or  $s4, $s4, 0x0120
    addi $s7, $0, 0         #initialize num = 0
    lui $s5, 0x1000         #load current_byte_addr
    or  $s5, $s5, 0x0120 
mainass:
    lb $s6, 0($s5)         #load current byte
    or $0, $0, $0
    addi $t0, $0, 32       #check if cb == space
    beq $s6, $t0, mainass
    addi $s5, $s5 1
    add $a0, $0, $s6       #check if cb is var
    jal ISVAR
    or $0, $0, $0
    add $t5, $0, $t1
    beq $v0, $0, error     #if not var, error
    or $0, $0, $0
mainassop:
    lb $s6, 0($s5)         #load current byte
    or $0, $0, $0
    addi $t0, $0, 32       #check if cb == space
    beq $s6, $t0, mainassop
    addi $s5, $s5, 1
    addi $t0, $0, 58       #check fi cb = ':''
    beq $t0, $s6, mainassop1
    or $0, $0, $0
    j error 
    or $0, $0, $0
mainassop1:
    lb $s6, 0($s5)
    addi $s5, $s5, 1
    addi $t0, $0, 61        #check if cb = '='
    beq $t0, $s6, mainassop2
    or $0, $0, $0    
    j error
    or $0, $0, $0
mainassop2:
    addi $s7, $0, 0         #reset num bit to 0
mainloop:    
    #Get current byte right after '='
    lb  $s6, 0($s5)         #load current_byte
    or $0, $0, $0
    # cb = $s6
    addi $t0, $0, 32        #check if cb == space
    beq $s6, $t0, mainloop  
    addi $s5, $s5, 1
    addi $s5, $s5, -1
    #Evaluate current byte
    add $a0, $0, $s6        #check if cb is valid
    jal ISVALID
    or $0, $0, $0
    beq $v0, $0, error
    or $0, $0, $0
    beq $s6, $0, end        #check if cb == NULL
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
    addi $s5, $s5, 1        #increment cb_ptr
    j mainloop
    or $0, $0, $0
main2: #cb is OPERATOR
    addi $s7, $0, 0         #set num = 0
    beq $s2, $s3, main21    #check if oprt_stack is empty
    or $0, $0, $0
    #if oprt not empty
    add $a0, $0, $s6        #evaluate precedence
    jal PREC
    or $0, $0, $0
    beq $v0, $0, main21
    or $0, $0, $0
    #calc subroutine : Pops oprd and oprt, determines math func
    #                  Pushes return value of math function
    jal OPRDPOP
    or $0, $0, $0
    add $a2, $0, $v0
    jal OPRDPOP
    or $0, $0, $0
    add $a1, $0, $v0
    jal OPRTPOP
    or $0, $0, $0
    add $a0, $0, $v0
    jal CALC
    or $0, $0, $0
    beq $a3, $0, main22     #if notmod branch to end1
    add $a0, $0, $v1
    jal OPRDPUSH
    or $0, $0, $0
    j main2
    or $0, $0, $0
main22: 
    add $a0, $0, $v0
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
    addi $v0, $0, 4         #print SYNTAX ERROR
    lui $a0, 0x1000
    or $a0, $a0, 0x0010
    syscall
    j done
end:
    beq $s2, $s3, done      #branch if operator stack is empty
    or $0, $0, $0
    jal OPRDPOP
    or $0, $0, $0
    add $a2, $0, $v0
    jal OPRDPOP
    or $0, $0, $0
    add $a1, $0, $v0
    jal OPRTPOP
    or $0, $0, $0
    add $a0, $0, $v0
    addi $a3, $0, 0         #reset a3 mod check to 0
    jal CALC
    or $0, $0, $0
    beq $a3, $0, end1       #if notmod branch to end1
    or $0, $0, $0
    add $a0, $0, $v1
    jal OPRDPUSH
    or $0, $0, $0
    j end
    or $0, $0, $0
end1:  #not mod, OPRDPUSH push v0
    add $a0, $0, $v0
    jal OPRDPUSH
    or $0, $0, $0,
    j end
    or $0, $0, $0

done:
#                        (  )/  
#                         )(/
#      ________________  ( /)
#     ()__)____________)))))
                        
    lw $t0, 0($s0)        #store final value
    or $0, $0, $0   
    sh $t0, 0($t5)        #t5 holds mem addr to store
    or $0, $0, $0
    
