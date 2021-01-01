@ Initialize the Fort and Material settings
.thumb

push  {r4, r14}


@ Overwritten by hook
ldr   r4, =ClearUnits
bl    GOTO_R4
ldr   r4, =ClearConvoyItems
bl    GOTO_R4
ldr   r4, =ClearGlobalTriggerState
bl    GOTO_R4


@ Initialize Fort and Material settings
ldr   r0, =InitFortMatSettings
ldr   r1, =FortsMatsData
ldr   r2, =FortMatChunkSize
ldr   r2, [r2]
lsr   r2, #0x1                            @ Need to half it
ldr   r4, = CpuSet
bl    GOTO_R4


pop   {r4}
pop   {r0}
bx    r0
GOTO_R4:
bx    r4
