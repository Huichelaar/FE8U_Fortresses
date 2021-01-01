@ Load in font & menu in BG tiles, item icons & system icons & grey menu decorations in OBJ tiles.
.thumb

push  {r4, r14}

@ Load font & palette.
ldr   r4, = Font_InitForUIDefault
bl    GOTO_R4

@ Load menu & palette
ldr   r4, =LoadNewUIGraphics
bl    GOTO_R4

@ Load item icons & palette
ldr   r4, =ResetIconGraphics_
bl    GOTO_R4
mov   r0, #0x2                              @ OBJ Palette 4
ldr   r4, =LoadIconPalettes
bl    GOTO_R4

@ Load system icons & palette
ldr   r4, =LoadObjUIGfx
bl    GOTO_R4

pop   {r4}
pop   {r0}
bx    r0
GOTO_R4:
bx    r4
