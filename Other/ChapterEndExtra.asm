.thumb

bl    IncreaseFortProduce
bl    IncreaseFortExp

ldr   r0, =ChapterData
ldrb  r0, [r0, #0xE]
lsl   r0, #0x18
asr   r0, #0x18
ldr   r4, =0x080346B1
bl    GOTO_R4

ldr   r1, =0x0808328F
bx    r1
GOTO_R4:
bx    r4
