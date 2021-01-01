@ Calculates & returns Unit Ability bonus. Arguments:
@   r0 = FortID
@ Returns bonus level based on unit's class Tier and Fort lv.
.thumb

push  {r4-r5, r14}

ldr   r1, =FortsMatsData
mov   r2, #0x5
mul   r0, r2
add   r1, r0
ldrb  r0, [r1]              @ Unit ID
ldrb  r5, [r1, #0x1]
lsr   r5, #0x6              @ Fort Level

ldr   r4, =GetUnitByCharId
bl    GOTO_R4
cmp   r0, #0x0
beq   L1
ldr   r0, [r0, #0x4]
cmp   r0, #0x0
beq   L1
ldrb  r0, [r0, #0x4]        @ Unit's Class' ID

L1:
ldr   r1, =ClassTierTable   @ I use a separate table here because char/class ability 2's
ldrb  r0, [r1, r0]          @ Promoted Unit bit only distinguishes between two tiers (not enough for me).
add   r0, r5

pop   {r4-r5}
pop   {r1}
bx    r1
GOTO_R4:
bx    r4
