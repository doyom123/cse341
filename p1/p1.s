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


#   a = 0x10000000
#   b = 0x10000002
#   c = 0x10000004
#   d = 0x10000006
#   e = 0x10000008
.globl main

.globl isoprt
.globl isoprt1
.globl prec
.globl prec1
.globl prec2

.globl oprdpush
.globl oprdpush1
.globl oprdpop
.globl oprdpop1
.globl oprtpush
.globl oprtpush1
.globl oprtpop
.globl oprtpop1

.data
a: .half 32
b: .half 923
c: .half 0x6214
d: .half 4
e: .half 17
empty: .space 6
exp: .asciiz "c:=25+b/a+b*3" # 0x1000 0010
oprd: .space 16              # 0x1000 0020 max_size = 16
oprt: .space 16              # 0x1000 0030 max_size = 16

.text

#____________MATH FUNCTIONS_____________ #



#____________BYTE_OPERATIONS____________ #
isoprt:
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

prec:
    #Find prec($a0)
    addi $t0, $a0, -43      #compare a0 to '+'
    beq $t0, $0, prec1      #branch if equal to '+'
    addi $t0, $0, 0         #set prec(a0) = 0
    addi $t0, $a0, -45      #compare a0 to '-'
    beq $t0, $0, prec1      #branch if equal to '-' 
    addi $t0, $0, 0         #set prec(a0) = 0
    addi $t0, $0, 1         #set prec(a1) = 1
prec1:
    #Find prec(oprt.top)
    lw $t1, -4($s3)         #load oprt.top in $t0
    addi $t2, $t1, -43      #compare oprt.top to '+'
    beq $t2, $0, prec2      #branch if equal to '+'
    addi $t2, $0, 0         #set prec(oprt.top) = 0
    addi $t2, $t1, -45      #compare oprt.top to '-'
    beq $t2, $0, prec2      #branch if equal to '-''
    addi $t2, $0, 0         #set prec(oprt.top) = 0
    addi $t2, $0, 1         #set prec(oprt.top) = 1
prec2:
    slt $v0, $t0, $t2       #evaluate $a0 < oprt.top
    jr $ra
    or $0, $0, $0           #nop

#____________STACK_OPERATIONS_________________#
oprdpush:
    beq $s1, $s2, oprdpush1 #branch if oprd_ptr == oprt_addr
    addi $v0, $0, 0         #set success fail
    sw $a0, 0($s1)          #push to oprd stack
    addi $s1, $s1, 4        #increment oprd_ptr
    addi $v0, $0, 1         #set success return
oprdpush1:
    jr $ra                  #return 
    or $0, $0, $0           #nop

oprdpop:
    beq $s0, $s1, oprdpop   #check if empty
    addi $v1, $0, 0         #set fail return 0
    lw $v0, -4($s1)         #pop from oprd_stack
    addi $s1, $s1, -4       #decrement oprd_ptr
    addi $v1, $0, 1         #set success return 1
oprdpop1:
    jr $ra                  #return
    or $0, $0, $0           #nop

oprtpush:
    beq $s3, $s4, oprtpush1 #branch if oprd_ptr == oprt_end_addr
    addi $v0, $0, 0         #set fail return 0
    sw $a0, 0($s3)          #push to oprt_stack
    addi $s3, $s3, 4        #increment oprt_ptr
    addi $v0, $0, 1         #set success return 1
oprtpush1:
    jr $ra                  #return 
    or $0, $0, $0           #nop

oprtpop:
    beq $s2, $s3, oprtpop1  #check if empty
    addi $v1, $0, 0         #set fail return 0
    lw $v0, -4($s3)         #pop from oprt_stack
    addi $s3, $s3, -4       #decrement oprt_ptr
    addi $v1, $0, 1         #set success return 1
oprtpop1:
    jr $ra                  #return
    or $0, $0, $0           #nop


main:
    ################################
    # $s0 = operand stack addr     #
    # $s1 = operand stack pointer  #
    # $s2 = operator stack addr    #
    # $s3 = operator stack pointer #
    # $s4 = operator end addr      #
    # $s5 = current byte ptr       #    
    # $s6 = num bit                #    
    ################################

    #Preprocessing
    #Setup stack addresses and pointers
    lui $s0, 0x1000         #load oprd_stack_addr
    or  $s0, $s0, 0x0020
    lui $s1, 0x1000         #load oprd_stack_ptr
    or  $s1, $s1, 0x0020
    lui $s2, 0x1000         #load oprt_stack_addr
    or  $s2, $s2, 0x0060
    lui $s3, 0x1000         #load oprt_stack_ptr
    or  $s3, $s3, 0x0060
    lui $s4, 0x1000         #load oprt_stack_end_addr
    or  $s4, $s4, 0x00A0
    lui $s5, 0x1000
    or  $s5, $s5, 0x0010    #load current_byte_ptr
    addi $s6, $0, 0         #initialize num = 0


    addi $a0, $0, '*'
    jal oprtpush
    or $0, $0, $0

    addi $a0, $0, '+'
    jal prec
    or $0, $0, $0

