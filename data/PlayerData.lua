local _, PKG = ...

-- player factors
-- sf: percent bigger(+) or smaller(-) from default size
-- x: right(+) or left(-) offset
-- z: up(+) or down(-) offset
-- f: percent change in facing toward cam(+) or away from cam(-)
local p_human_M = {['sf'] = -3, ['x'] = 15, ['z'] = 13}
local p_human_F = {['sf'] = -7, ['x'] = 15, ['z'] = 5}
local p_dwarf_M = {['sf'] = -15, ['x'] = 5, ['z'] = -10}
local p_dwarf_F = {['sf'] = -13, ['x'] = 5, ['z'] = -8}
local p_gnome_M = {['sf'] = -28, ['x'] = 5, ['z'] = -30}
local p_gnome_F = {['sf'] = -28, ['x'] = 5, ['z'] = -25}
local p_night_elf_M = {['sf'] = 1, ['x'] = 5, ['z'] = 32}
local p_night_elf_F = {['sf'] = -1, ['x'] = 0, ['z'] = 21}
local p_tauren_M = {['sf'] = 8, ['x'] = 10, ['z'] = 65}
local p_tauren_F = {['sf'] = 3, ['x'] = 0, ['z'] = 28}
local p_orc_F = {['sf'] = -1, ['x'] = 0, ['z'] = 21}
local p_troll_M = {['sf'] = -6.5, ['x'] = 0, ['z'] = 28}
local p_blood_elf_M = {['sf'] = -1, ['x'] = 10, ['z'] = 15}
local p_blood_elf_F = {['sf'] = -8, ['x'] = 0, ['z'] = 15}
local P = {
    -- old player models (pre revamp)
    [119940] = p_human_M, -- human male (old)
    [119563] = p_human_F, -- human female (old)
    [119159] = p_gnome_M, -- gnome male (old)
    [119063] = p_gnome_F, -- gnome female (old)
    [118355] = p_dwarf_M, -- dwarf male (old)
    [118135] = p_dwarf_F, -- dwarf female (old)
    [120791] = p_night_elf_M, -- night elf male (old)
    [120590] = p_night_elf_F, -- night elf female (old)
    [121768] = {['sf'] = -10, ['x'] = 0, ['z'] = 2}, -- undead male (old)
    [121608] = {['sf'] = -6, ['x'] = 0, ['z'] = 8}, -- undead female (old)
    [121287] = {['sf'] = -3, ['x'] = 0, ['z'] = 14}, -- orc male (old)
    [121087] = p_orc_F, -- orc female (old)
    [122560] = p_troll_M, -- troll male (old)
    [122414] ={['sf'] = 4, ['x'] = -5, ['z'] = 32}, -- troll female (old)
    [122055] = {['sf'] = 6, ['x'] = 10, ['z'] = 25}, -- taruen male (old)
    [121961] = p_tauren_F, -- tauren female (old)
    [117721] = {['sf'] = 10, ['x'] = -30, ['z'] = 33, ['f'] = 20}, -- draenei male (old)
    [117437] = {['sf'] = 4, ['x'] = -10, ['z'] = 27, ['f'] = 10}, -- draenei female (old)
    [117170] = p_blood_elf_M, -- blood elf male (old)
    [116921] = p_blood_elf_F, -- blood elf female (old)

    -- player models
    [1011653] = p_human_M, -- human male
    [1000764] = p_human_F, -- human female
    [900914] = p_gnome_M, -- gnome male
    [940356] = {['sf'] = -30, ['x'] = -5, ['z'] = -25}, -- gnome female
    [878772] = {['sf'] = -18, ['x'] = -5, ['z'] = 6}, -- dwarf male
    [950080] = {['sf'] = -14, ['x'] = 5, ['z'] = -8}, -- dwarf female
    [974343] = p_night_elf_M, -- night elf male
    [921844] = p_night_elf_F, -- night elf female
    [959310] = {['sf'] = -5, ['x'] = 0, ['z'] = 7}, -- undead male
    [997378] = {['sf'] = -4, ['x'] = 0, ['z'] = 16}, -- undead female
    [917116] = {['sf'] = -6, ['x'] = 10, ['z'] = 10}, -- hunched orc & mag'har orc male
    [1968587] = {['sf'] = 14, ['x'] = 30, ['z'] = 15, ['f'] = 10}, -- upright orc & mag'har orc male
    [949470] = p_orc_F, -- orc & mag'har orc female
    [1022938] = p_troll_M, -- troll male
    [1018060] = {['sf'] = -5, ['x'] = -5, ['z'] = 45}, -- troll female
    [968705] = p_tauren_M, -- tauren male
    [986648] = p_tauren_F, -- tauren female
    [1005887] = {['sf'] = 16, ['x'] = -30, ['z'] = 40, ['f'] = 20}, -- draenei male
    [1022598] = {['sf'] = 9, ['x'] = -10, ['z'] = 32, ['f'] = 10}, -- draenei female
    [1100087] = p_blood_elf_M, -- blood elf male
    [1100258] = p_blood_elf_F, -- blood elf female
    [307454] = PKG.FF.NewWorgenModel and
        {['sf'] = -6, ['x'] = 0, ['z'] = 50} or -- worgen male
        {['sf'] = 5, ['x'] = -10, ['z'] = -3},  -- worgen male (old)
    [307453] = PKG.FF.NewWorgenModel and
        {['sf'] = -8.5, ['x'] = 5, ['z'] = 45, ['f'] = -45} or -- worgen female
        {['sf'] = 25, ['x'] = 5, ['z'] = 41, ['f'] = -60},     -- worgen female (old)
    [119376] = {['sf'] = -24, ['x'] = 5, ['z'] = -6}, -- goblin male
    [119369] = {['sf'] = -26, ['x'] = 5, ['z'] = -14}, -- goblin female
    [535052] = {['sf'] = 17, ['x'] = 5, ['z'] = 45}, -- pandaren male
    [589715] = {['sf'] = -9, ['x'] = -10, ['z'] = 30}, -- pandaren female
    [1734034] = p_blood_elf_M, -- void elf male
    [1733758] = p_blood_elf_F, -- void elf female
    [1620605] = {['sf'] = -1, ['x'] = -30, ['z'] = 45, ['f'] = 20}, -- lightforged male
    [1593999] = {['sf'] = 3, ['x'] = -10, ['z'] = 35, ['f'] = 10}, -- lightforged female
    [1630218] = p_tauren_M, -- highmountain male
    [1630402] = p_tauren_F, -- highmountain female
    [1814471] = p_night_elf_M, -- nightborne male
    [1810676] = {['sf'] = -1, ['x'] = 0, ['z'] = 24}, -- nightborne female
    [2622502] = p_gnome_M, -- mechagnome male
    [2564806] = p_gnome_F, -- mechagnome female
    [1721003] = {['sf'] = 7, ['x'] = 0, ['z'] = 32}, -- kul tiran male
    [1886724] = {['sf'] = -5, ['x'] = -10, ['z'] = 35}, -- kul tiran female
    [1890765] = {['sf'] = -17.5, ['x'] = 5, ['z'] = 7}, -- dark iron male
    [1890763] = p_dwarf_F, -- dark iron female
    [1630447] = {['sf'] = 4, ['x'] = 10, ['z'] = 35, ['f'] = -30}, -- zandalari male
    [1662187] = {['sf'] = 0, ['x'] = -5, ['z'] = 5, ['f'] = -45}, -- zandalari female
    [1890761] = {['sf'] = -20, ['z'] = -5}, -- vulpera male
    [1890759] = {['sf'] = -26, ['z'] = -7}, -- vulpera female
    [4207724] = {['sf'] = -12, ['x'] = -50, ['z'] = 50}, -- dracthyr male & female
    [4395382] = p_blood_elf_M, -- dracthyr male visage
    [4220448] = p_human_F, -- dracthyr female visage
    [5548261] = {['sf'] = -12, ['x'] = -5, ['z'] = 20}, -- earthen male
    [5548259] = {['sf'] = -10, ['x'] = 5, ['z'] = 0}, -- earthen female
}
PKG.PLAYER_SCALES = P
