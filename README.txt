INSTALL
  Install by using Event Assembler to apply "Fortresses.event" to an FE8U ROM. There's a few quirks to 
  keep in mind:
  
    - If you're already using a text buildfile, remove the #include "Text/Install Text Data.event" from 
    "Fortresses.event" and instead #include "Text/FortMaterial/FortMaterial.event" in your text 
    buildfile.
    
    - Some parts in the text buildfiles need to remain contiguous. I'll go into more detail in the IMPLEMENTATION - TEXT section.
    
    - This hack uses Extended Modular Save. If you're already using EMS, remove the #include 
    "ExpandedModularSave/ExModularSave.event" from "Fortresses.event", instead copy:
      - The #includes under "//CUSTOM", lines 85-94,
      - DeclSaveChunk($1128, FortMatSaveChunkSize, SaveFortsMats+1, LoadFortsMats+1), line 159,
      - DeclSaveChunk($2DC1, FortMatSaveChunkSize, SaveFortsMats+1, LoadFortsMats+1), line 218,
    in "ExpandedModularSave/ExModularSave.event" to your ExModularSave.event file.
    Also copy the "ExpandedModularSave/Custom" directory and place it in your ExpandedModularSave 
    directory.
    
    - If you've repointed unit_address, 0x08803D64, or OAMREGS_Count_1, 0x08590F7C, you'll 
    have to alter these definitions in "Defs/Definitions.asm and put the affected .asm files through 
    Lyn again. The affected files can be found by (recursively) searching the "Fortresses" directory 
    for the keywords.
    
    - If you're already customising the exp calculation routine, this hack may interfere. You can 
    disable this hack's exp mod by removing the hook (and other inserted code) in 
    "Abilities/Abilities.event". Note that doing this means the exp bonus ability will not function, so 
    don't assign this ability to any unit.
    
    - If you want to debug stuff, comment out the { and } in "Fortresses.event" to disable the scope. 
    This will allow new labels to appear in the sym file. There's also the "Debug" definition. Defining 
    this will turn the "Guide" command that appears in the menu during chapters into a 
    win-chapter-button.


WHATITDO?
  Heya, this here is a thing I made which installs fortresses, forts, for short. These forts can do two 
  things for the player. First, they produce materials which can be used to upgrade these forts (I'm 
  also planning on building a crafting system which can use these materials to craft items). Second, 
  the forts can provide bonuses based on the (player) unit in charge of the fort. The only bonus I've 
  implemented so far is an exp boost, but I'm planning on making more. More details regarding how stuff 
  is implemented below.
  
  There's a lot here, so I probably forgot to detail something. Ask me if anything's unclear. Also try 
  pressing R in the fort menu, accesible via the world map, for some more info.


IMPLEMENTATION
  The default settings are pretty useless, so I'll go into how everything works here, so you can set 
  t(h)ings. By default there are 21 forts and 26 materials. These both have a ROM struct and a RAM 
  struct.

  RAM STRUCTS
    The RAM structs are saved during regular save and suspend save. Each fort takes up 5 bytes in RAM 
    and each material takes up 2 bytes in RAM.
    
      - The RAM Material struct only consists of one short holding how 
      much of that material a player has. This value should not exceed 999 or it won't be displayed 
      correctly.
      
      - The RAM Fort struct consists of:
      
        - +0x0, byte holding the unitID of the fortmaster, the unit in charge of this fort. 0 Indicates 
        the fort is empty, and the player can assign a fortmaster to it.
        
        - +0x1, lvl and exp byte. Top two MSBs hold the level of the fort, the 6 LSBs hold the exp. A 
        level up happens when exp reaches 50, unless fort level is already 4. Exp increases whenever a 
        chapter ends, if the fort is controlled by a player unit and the fort is not at the max level 
        (which is 4). A random number between FortExpGainLower and FortExpGainUpper is generated to be 
        added to the current exp. These two variables can be found "Fortresses.event." I recommend 
        ensuring FortExpGainUpper >= FortExpGainLower. A fort can not level up more than once per 
        chapter end. However, if the player has enough of the required materials they can level up the 
        fort manually, as many times as they want (until max level) in between chapters.
        
        - +0x2, three bytes which hold how much of each material a fort has produced/gathered. Each of 
        the fort's four materials gets 6 bits. After a chapter ends, forts controlled by player units 
        will produce materials. A fort can't hold more than 50 of the same material, excess materials 
        are discarded.
      
    There's room for more materials and forts in RAM, but I've set the total size limit to 0xB6 bytes. 
    The RAM fort structs and material structs grow toward each other, so make sure not to go over 0xB6 
    or there'll be overlap. If you want to increase this limit make sure there's room in the save 
    formats. Change "FortMatSaveChunkSize" and "FortMatChunkSize" in "Fortresses.event" accordingly. 
    You may also want to find a different spot in RAM to keep the structs (repoint FortsMatsData in 
    "Defs/Definitions.asm"), as they're kept in 0x03003B48 which only has 0xBC free bytes. On that note, 
    apparently its untested whether this space is not actually used by vanilla, so err, yeah. I didn't 
    run into any issues w.r.t. this yet.
      
  ROM STRUCTS & TABLES
    There's three ROM structs:
    
      - MaterialStruct, in "Structs/Material/Material.event", consists of:
        - +0x0, word, this holds a pointer to the Gfx data of the material's icon. The Material(MatID, 
        Name) macro will calculate this value based on MatID.
        - +0x4, short, "Name", the textID of the material's name.
        - +0x6, short, 0. Padding to make iterating over the struct easier.
        
      - FortStruct, in "Structs/Fort/Fort.event", consists of:
        - +0x0, four bytes, each byte representing a material, MatID, which this fort produces.
        - +0x4, short, Name, textID used when displaying the fort's name.
        - +0x6, short, textID referring to the help text displayed when this fort is hovered over. 
        TextID+1 and textID+2 can also be used depending on fort level, so make sure these three 
        textIDs remain contiguous.
        - +0x8, three words, each of these words correspond to a level interval (1 to 2, 2 to 3 and 3 
        to 4). Each of these words consist of:
          - +0x0 MatID, W
          - +0x1 X
          - +0x2 MatID, Y
          - +0x3 Z
        When a fort is at level A it needs X' amount of material W and Z' amount of material Y to get to 
        level A+1. Where X' = current fort exp / (50 / X), anologous for Z'. set X and Z to at least 1, 
        at most 99, although I'd recommend to set it no higher than 50, otherwise X' or Z' could come 
        out weird. Also, make sure W =/= Y, or the calculation will be off, and things will break.
        - +0x14, word, this is a pointer to a ProduceStruct.
        - +0x18, two words, 0. Padding.
        
      - ProduceStruct, in "Structs/Fort/Fort.event", these are used by FortStructs. These consist of 16 
      words each consisting of four bytes. These bytes correspond to the four materials a fort can 
      produce. At chapter end a number is generated from [0-15], this value will determine which of the 
      16 words in this struct will determine how much of each material a fort is going to produce. The 
      higher the level of the fort, the more numbers will be generated from [0-15]. The highest 
      resulting number will be picked, so you will probably want to make sure the order of the words 
      reflects greater spoils as the index increases.
        Also note that at level 1 a fort can only produce more of the first and second materials. LV2 
        unlocks material 3 and LV3 unlocks material 4.
      
      There's also a few standalone tables:
      
        - "Structs/Save/InitFortMatSettings.dmp", this one holds the initial settings for the RAM fort 
        & material structs.
        
        - "Structs/Extra/ClassTierTable.dmp", this one is indexed by classID and only goes up to 0xFF. 
        The value in each entry indicates which tier the class is. This affects how much the
        fortmaster's ability is boosted. I'm using this table instead of the promoted class bit in 
        class struct, because I want to use three tiers of classes. Make sure no entry has a value 
        greater than 0x2, otherwise the ability boost will break.
        
        - "Structs/Extra/UnitAbility.dmp", indexed by unitID (charID). Indicates which ability a unit 
        has. 
        0x1 is reserved for unit 0 and is used to display a fort can be assigned a unit. 0x0 is also 
        reserved and indicates, if the unit is player unit, that the unit can not be assigned to a fort 
        or, if the unit is an enemy unit, that the unit is an enemy. Right now, the only other value is 
        0x2 which indicates the exp bonus ability.
        
        - "Structs/Extra/AbilityBoosts.dmp", indexed by UnitAbility. Entries in this table are 8 
        bytes long. The first 6 bytes indicate the boost multiplier, which of these is used is 
        calculated by this formula: valuebyte = class tier + fort level - 2, where class tier is a 
        value between [1-3] and fort level is a value between [1-4]. Byte 8 is used to determine which 
        symbol should be displayed next to the multiplier (%, +, etc.). Byte 7 indicates if this symbol 
        should be drawn left (if 0) or right (if 1) of the multiplier.

  TEXT
    There's a few things to keep in mind when changing text.
      - "Text/FortMaterial/Forts.event" consists of two parts:
        - The first part contains these:
          Fortname,
          3 helptexts. Which is used depends on fort lvl, so keep these three contiguous.
        - The second part contains helptext indexed by materialID, so keep these entries contiguous.
      
      - "Text/FortMaterial/Abilities.event" consists of entries made up of:
        - Ability text upper line
        - Ability text lower line
        - Ability helptext
        - padding
      The order of the entries is not relevant but keep the components contiguous.
      
  FORTMASTERS
    Units put in charge of a fort have their dead bit (RAM Unit struct +0xC bit +0x2) set. I did this, 
    to prevent people from using fortmasters during a chapter. An alternative could've been the skip 
    unit bit (RAM Unit struct +0xE bit +0x0), but this didn't seem to affect story events, so I decided 
    to use the dead bit instead. When you remove a fortmaster from a fort, the dead bit is unset, 
    bringing the unit back to your party.


MENU
  There is a menu for managing forts. Open the worldmap menu when hovering over the player avatar and 
  there should be a "Manage Forts" button. Press this to open the fortmenu.
  
  The fortmenu consists of three blocks (and a little fancy-schmancy animation to stare at). Top left 
  contains the initial menu. Bottom right contains the forts. Top right is a preview window displaying 
  how much of relevant materials you'll have after undertaking an action.
  
  There's three options in the top left menu here:
    - Gather. Pick a fort and press A to gather the materials that the fort has produced so far. You 
    won't be able to gather more than 999 of a material.
    - Upgrade. Pick a fort and press A to spend materials to increase that fort's level.
    - Assign. Select a fort by pressing A on it. Then scroll through different units and press A to 
    confirm that unit will be this fort's fortmaster. Pressing B instead will put the previous 
    fortmaster in charge again. You will also be able to leave the fort without a fortmaster.

  Pressing R will also display some helptext.


CONCLUDING
 So it's all still very WIP. I just wanted to have something out by the new year (2021). 't Would also 
 help if people wanted to play around with it and maybe find bugs or other weirdness. I learnt some 
 real fun things, like how to work with menus, how to use EMS, how to set up compound objects.


CREDITS
  - The tree being chopped down in the fort menu was made by Obsidian Daddy.
  - The other assets displayed in that animation (pirate, plateau) are in vanilla FE8, so credit goes 
  to IS for that. I Frankenstein'd the "MATERIALS" and "FORTS" displayed in the fortmenu from vanilla 
  FE8 menu UI, so credit goes to IS for that too.
  - The material icons in order of appearance in "Graphics/Materials.png":
    - Coal          from Bomberman Jetters Densetsu no Bomberman, ripped by Garamonde.
    - Copper        from Bomberman Jetters Densetsu no Bomberman, ripped by Garamonde.
    - Lime          from Bomberman Jetters Densetsu no Bomberman, ripped by Garamonde.
    - Iron          from Bomberman Jetters Densetsu no Bomberman, ripped by Garamonde.
    - Wood          made by kb.
    - Magic wood    simple recolour I made of an icon by kb.
    - Spice         from Minecraft, ripped by WizToad.
    - Gunpowder     from Minecraft, ripped by WizToad.
    - Hemp          made by Zarg.
    - Belladonna    made by Beansy.
    - Laurel        from Minecraft, ripped by WizToad.
    - Topaz         made by GabrielKnight.
    - Ruby          made by GabrielKnight.
    - Emerald       made by GabrielKnight.
    - Diamond       made by GabrielKnight.
    - Milk          from Fire Emblem Fates, ripped by Henrai.
    - Cabbage       from Fire Emblem Fates, ripped by Henrai.
    - Grape         from Fire Emblem Fates, ripped by Henrai.
    - Fish          from Fire Emblem Fates, ripped by Henrai.
    - Wheat         from Fire Emblem Fates, ripped by Henrai.
    - Meat          from Boktai 3 / Shin Bokura no Taiyou, ripped by Greiga Master.
    - Down          from Radiant Historia, ripped by redblueyellow.
    - Hide          from Radiant Historia, ripped by redblueyellow.
    - Wool          from Radiant Historia, ripped by redblueyellow.
    - Oil           made by GabrielKnight.
    - Rune          from Radiant Historia, ripped by redblueyellow.
  - ExModularSave made by StanH_, Colorz.
  - Assuming I didn't miss anything, the rest should go to me, Huichelaar.
  Tell me if I've missed anyone, I'll make sure to add them to the credits.