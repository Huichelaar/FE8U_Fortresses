@ Executed when any FortMenu2 command is selected
@ after FortMenu1's "Gather" command was selected. Arguments:
@   r0 = FortMenu2 proc pointer
@   r1 = DrawFortMenu2 proc pointer
.thumb

push  {r4-r7, r14}
sub   sp, #0x4


mov   r2, #0x61
ldrb  r2, [r0, r2]                  @ Current command index
mov   r3, #0x2A
ldrb  r3, [r1, r3]                  @ Top fort
lsr   r2, #0x1
add   r5, r2, r3                    @ Selected fort


@ Re-draw entries & preview
mov   r0, #0x55
mov   r2, #0xFF
strb  r2, [r1, r0]                  @ Preview is re-drawn if prev command =/= current command
mov   r0, r1
mov   r1, #0x0
ldr   r4, =Goto6CLabel
bl    GOTO_R4                       @ Re-draw FortMenu2 entries



@ Check if fort is controlled by enemy
mov   r0, #0x5
mov   r1, r5
mul   r1, r0
ldr   r0, =FortsMatsData
ldrb  r2, [r0, r1]                  @ Fort's Fortmaster
ldr   r1, =UnitAbility
ldrb  r0, [r1, r2]
cmp   r0, #0x0
beq   L4                            @ Unit isn't controllable


@ Grab materials from Fort
mov   r0, r5
bl    GetFortMatCount
mov   r1, sp
str   r0, [r1]

ldr   r0, =FortStruct
lsl   r1, r5, #0x5
add   r4, r0, r1                    @ ROM Fort Struct

ldr   r0, =FortsMatsData
ldr   r1, =FortMatChunkSize
ldr   r1, [r1]
add   r0, r1
ldr   r1, =MaterialCount
ldr   r1, [r1]
lsl   r1, #0x1
sub   r6, r0, r1                    @ RAM Material Data

mov   r7, #0x0
mov   r12, r7                       @ Flag indicating Materials were gathered
Loop:
  mov   r3, sp
  ldrb  r1, [r3, r7]                @ Fort Material RAM
  cmp   r1, #0x0
  beq   L2                          @ No materials to grab
    ldrb  r0, [r4, r7]
    lsl   r0, #0x1
    ldrh  r2, [r0, r6]              @ Material RAM
    mov   r3, #0x3E
    lsl   r3, #0x4
    add   r3, #0x7
    cmp   r2, r3
    bge   L2                        @ No more room for materials
      
      @ Transfer Material from Fort RAM to Material RAM
      add   r2, r1
      mov   r1, #0x0
      cmp   r2, r3
      ble   L3
        sub   r1, r2, r3
        mov   r2, r3
      L3:
      mov   r3, sp
      strb  r1, [r3, r7]
      strh  r2, [r0, r6]
      mov   r0, #0x1
      mov   r12, r0
  L2:
  add   r7, #0x1
  cmp   r7, #0x3
  ble   Loop

mov   r0, #0x1
cmp   r12, r0
bne   L4
  
  @ Update Fort Material counts
  mov   r0, r5
  mov   r1, sp
  ldr   r1, [r1]
  bl    SetFortMatCount
  mov   r0, #0x4
  b     Return
L4:

@ Fortmaster isn't controllable or nothing was gathered
mov   r0, #0x6C
ldr   r4, =m4aSongNumStart
bl    GOTO_R4
mov   r0, #0x0


Return:
add   sp, #0x4
pop   {r4-r7}
pop   {r1}
bx    r1
GOTO_R4:
bx    r4
