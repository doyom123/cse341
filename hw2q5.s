# convert ble $s2, $vo, convert
# to native MIPS instructions 
# ble $t0, $t1, target
# branch to target if $t0 <= $t1

.globl main
.globl convert

.data

.text
main:
  slt $t0, %vo, $s2
  beq $t0, $0, convert
  

    