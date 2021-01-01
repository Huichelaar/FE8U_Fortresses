@ Returns RAM address of unit struct of unit. Arguments:
@   r0 = unitID
.thumb

ldr   r1, =gUnitArray
mov   r2, #0x48
lsl   r2, #0x6
sub   r2, #0x90
add   r2, r1

Loop:
  ldr   r3, [r1]
  cmp   r3, #0x0
  beq   L1
  ldrb  r3, [r3, #0x4]
  cmp   r0, r3
  beq   Return
  L1:
  mov   r3, #0x0
  add   r1, #0x48
  cmp   r1, r2
  bge   L2
  b     Loop
  
L2:
mov   r1, #0x0
Return:
mov   r0, r1
bx    r14
