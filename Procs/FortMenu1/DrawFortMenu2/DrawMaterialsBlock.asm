.thumb

push  {r4, r14}


@ Draw Block
mov   r0, #0x10                           @ Use BG palette 0x1
lsl   r0, #0x8
ldr   r1, =gpBG1MapBuffer
mov   r2, #0x10
add   r1, r2

@ Top left corner 1
add   r0, #0x1
strh  r0, [r1]
add   r1, #0x2
add   r0, #0x1
strh  r0, [r1]

@ Top horizontal line
add   r0, #0x1
mov   r2, #0x0

TopLineLoop:
  add   r1, #0x2
  strh  r0, [r1]
  add   r2, #0x1
  cmp   r2, #0xA
  ble   TopLineLoop
  
mov   r3, #0x36
lsl   r3, #0x4
sub   r3, #0x4
add   r3, r0

MenuTitleLoop:
  add   r1, #0x2
  add   r3, #0x1
  strh  r3, [r1]
  add   r2, #0x1
  cmp   r2, #0x13
  ble   MenuTitleLoop


@ Top left corner 2
add   r0, #0x4
add   r1, #0x16
strh  r0, [r1]
add   r0, #0x1
add   r1, #0x2
strh  r0, [r1]

@ Main body
add   r0, #0x1
add   r1, #0x2
mov   r2, #0x2
mov   r3, #0x0

MainBodyLoop:
  strh  r0, [r1]
  add   r1, #0x2
  add   r2, #0x1
  cmp   r2, #0x14
  ble   MainBodyLoop
  
  add   r2, r0, #0x1
  strh  r2, [r1]                          @ Right vertical line.
  add   r1, #0x2
  mov   r2, #0x0
  add   r3, #0x1
  cmp   r3, #0x4
  bge   EndLoop
  
  sub   r2, r0, #0x3
  add   r1, #0x14
  strh  r2, [r1]                          @ Left vertical line.
  add   r1, #0x2
  mov   r2, #0x1
  b     MainBodyLoop
  EndLoop:
  
@ Bottom left corner
add   r0, #0x11
add   r1, #0x14
strh  r0, [r1]

@ Bottom horizontal line
add   r0, #0x1
mov   r2, #0x0

BottomLineLoop:
  add   r1, #0x2
  strh  r0, [r1]
  add   r2, #0x1
  cmp   r2, #0x13
  ble   BottomLineLoop
  
@ Bottom right corner
add   r0, #0x6
add   r1, #0x2
strh  r0, [r1]


mov   r0, #0x1
ldr   r4, =EnableBackgroundSyncById 
bl    GOTO_R4


pop   {r4}
pop   {r0}
bx    r0
GOTO_R4:
bx    r4
