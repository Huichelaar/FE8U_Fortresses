@ Executed on B press. Mimics default destructor, 0801BCCC,
@ but doesn't clear BG0, BG1 and doesn't call 0x08005758, DeleteFaceByIndex.
.thumb

push  {r4, r14}

ldr   r4, =EndMenu
bl    GOTO_R4
mov   r0, #0x9

pop   {r4}
pop   {r1}
bx    r1
GOTO_R4:
bx    r4
