local _, PKG = ...

-- player factors
-- sf: percent bigger(+) or smaller(-) from default size
-- x: right(+) or left(-) offset
-- z: up(+) or down(-) offset
-- f: percent change in facing toward cam(+) or away from cam(-)
local p_default = {['sf'] = -10}
local p_human_M = {['sf'] = -3, ['x'] = 15, ['z'] = 13}
local p_human_F = {['sf'] = -7, ['x'] = 15, ['z'] = 5}
local p_dwarf_M = {['sf'] = -15, ['x'] = 5, ['z'] = -10}
local p_dwarf_F = {['sf'] = -13, ['x'] = 5, ['z'] = -8}
local p_gnome_M = {['sf'] = -28, ['x'] = 5, ['z'] = -30}
local p_gnome_F = {['sf'] = -28, ['x'] = 5, ['z'] = -25}
local p_night_elf_M = {['sf'] = 1, ['x'] = 5, ['z'] = 32}
local p_night_elf_F = {['sf'] = -1, ['x'] = 0, ['z'] = 21}
local p_tauren_M = {['sf'] = 6, ['x'] = 10, ['z'] = 25}
local p_tauren_F = {['sf'] = 3, ['x'] = 0, ['z'] = 28}
local p_undead_M = {['sf'] = -10, ['x'] = 0, ['z'] = 2}
local p_undead_F = {['sf'] = -6, ['x'] = 0, ['z'] = 8}
local p_orc_M = {['sf'] = -3, ['x'] = 0, ['z'] = 14}
local p_orc_F = {['sf'] = -1, ['x'] = 0, ['z'] = 21}
local p_troll_M = {['sf'] = -6.5, ['x'] = 0, ['z'] = 28}
local p_troll_F = {['sf'] = 4, ['x'] = -5, ['z'] = 32}
local p_blood_elf_M = {['sf'] = -1, ['x'] = 10, ['z'] = 15}
local p_blood_elf_F = {['sf'] = -8, ['x'] = 0, ['z'] = 15}
local p_draenei_M = {['sf'] = 10, ['x'] = -30, ['z'] = 33, ['f'] = 20}
local p_draenei_F = {['sf'] = 4, ['x'] = -10, ['z'] = 27, ['f'] = 10}
local p_goblin_M = {['sf'] = -24, ['x'] = 5, ['z'] = -6}
local p_goblin_F = {['sf'] = -27, ['x'] = 5, ['z'] = -14}
local p_worgen_M = {['sf'] = 5, ['x'] = 10, ['z'] = -3}
local p_worgen_F = {['sf'] = 25, ['x'] = 5, ['z'] = 41, ['f'] = -60}
local p_pandaren_M = {['sf'] = 17, ['x'] = 5, ['z'] = 45}
local p_pandaren_F = {['sf'] = -9, ['x'] = -10, ['z'] = 30}
local p_vulpera = {['sf'] = -33.3}
local p_dracthyr = {['sf'] = 0, ['x'] = -30, ['z'] = -10}
local P = {
    [1] = { -- human
        ['new'] = {[2] = p_human_M, [3] = p_human_F},
        ['old'] = {[2] = p_human_M, [3] = p_human_F}},
    [2] = { -- orc
        ['new'] = {[2] = p_orc_M, [3] = p_orc_F},
        ['old'] = {[2] = p_orc_M, [3] = p_orc_F}},
    [3] = { -- dwarf
        ['new'] = {[2] = p_dwarf_M, [3] = p_dwarf_F},
        ['old'] = {[2] = p_dwarf_M, [3] = p_dwarf_F}},
    [4] = { -- night elf
        ['new'] = {[2] = p_night_elf_M, [3] = p_night_elf_F},
        ['old'] = {[2] = p_night_elf_M, [3] = p_night_elf_F}},
    [5] = { -- undead
        ['new'] = {[2] = p_undead_M, [3] = p_undead_F},
        ['old'] = {[2] = p_undead_M, [3] = p_undead_F}},
    [6] = { -- tauren
        ['new'] = {[2] = p_tauren_M, [3] = p_tauren_F},
        ['old'] = {[2] = p_tauren_M, [3] = p_tauren_F}},
    [7] = { -- gnome
        ['new'] = {[2] = p_gnome_M, [3] = p_gnome_F},
        ['old'] = {[2] = p_gnome_M, [3] = p_gnome_F}},
    [8] = { -- troll
        ['new'] = {[2] = p_troll_M, [3] = p_troll_F},
        ['old'] = {[2] = p_troll_M, [3] = p_troll_F}},
    [9] = { -- goblin
        ['new'] = {[2] = p_goblin_M, [3] = p_goblin_F},
        ['old'] = {[2] = p_goblin_M, [3] = p_goblin_F}},
    [10] = { -- blood elf
        ['new'] = {[2] = p_blood_elf_M, [3] = p_blood_elf_F},
        ['old'] = {[2] = p_blood_elf_M, [3] = p_blood_elf_F}},
    [11] = { -- draenei
        ['new'] = {[2] = p_draenei_M, [3] = p_draenei_F},
        ['old'] = {[2] = p_draenei_M, [3] = p_draenei_F}},
    [22] = { -- worgen
        ['new'] = {[2] = p_worgen_M, [3] = p_worgen_F},
        ['old'] = {[2] = p_worgen_M, [3] = p_worgen_F}},
    [23] = { -- gilnean
        ['new'] = {[2] = p_human_M, [3] = p_human_F},
        ['old'] = {[2] = p_human_M, [3] = p_human_F}},
    [24] = { -- pandaren, neutral
        ['new'] = {[2] = p_pandaren_M, [3] = p_pandaren_F}},
    [25] = { -- pandaren, alliance
        ['new'] = {[2] = p_pandaren_M, [3] = p_pandaren_F}},
    [26] = { -- pandaren, horde
        ['new'] = {[2] = p_pandaren_M, [3] = p_pandaren_F}},
    [27] = { -- nightborne
        ['new'] = {[2] = p_night_elf_M, [3] = p_night_elf_F}},
    [28] = { -- highmountain
        ['new'] = {[2] = p_tauren_M, [3] = p_tauren_F}},
    [29] = { -- void elf
        ['new'] = {[2] = p_blood_elf_M, [3] = p_blood_elf_F}},
    [30] = { -- lightforged
        ['new'] = {[2] = p_draenei_M, [3] = p_draenei_F}},
    [31] = { -- zandalari
        ['new'] = {[2] = p_troll_M, [3] = p_troll_F}},
    [32] = { -- kul tiran
        ['new'] = {[2] = p_default, [3] = p_default}},
    [34] = { -- dark iron
        ['new'] = {[2] = p_dwarf_M, [3] = p_dwarf_F}},
    [35] = { -- vulpera
        ['new'] = {[2] = p_vulpera, [3] = p_vulpera}},
    [36] = { -- mag'har
        ['new'] = {[2] = p_orc_M, [3] = p_orc_F}},
    [37] = { -- mechagnome
        ['new'] = {[2] = p_gnome_M, [3] = p_gnome_F}},
    [52] = { -- dracthyr, alliance
        ['new'] = {[2] = p_dracthyr, [3] = p_dracthyr}},
    [70] = { -- dracthyr, horde
        ['new'] = {[2] = p_dracthyr, [3] = p_dracthyr}},
    [84] = { -- earthen, horde
        ['new'] = {[2] = p_dwarf_M, [3] = p_dwarf_F}},
    [85] = { -- earthen, alliance
        ['new'] = {[2] = p_dwarf_M, [3] = p_dwarf_F}},
}
PKG.PLAYER_SCALES = P
