local _, PKG = ...

-- player factors
local p_default = {['sf'] = 1.1}
local p_human_M = {['sf'] = 1.07, ['x'] = -55, ['z'] = -27}
local p_human_F = {['sf'] = 1.13, ['x'] = -55, ['z'] = -33}
local p_dwarf_M = {['sf'] = 1.2, ['x'] = -65, ['z'] = -33}
local p_dwarf_F = {['sf'] = 1.15, ['x'] = -65, ['z'] = -33}
local p_gnome_M = {['sf'] = 1.51, ['x'] = -65, ['z'] = -30}
local p_gnome_F = {['sf'] = 1.5, ['x'] = -65, ['z'] = -30}
local p_night_elf_M = {['sf'] = 0.99, ['x'] = -65, ['z'] = -9}
local p_night_elf_F = {['sf'] = 1.035, ['x'] = -70, ['z'] = -15}
local p_tauren_M = {['sf'] = 0.94, ['x'] = -60, ['z'] = -21}
local p_tauren_F = {['sf'] = 0.97, ['x'] = -70, ['z'] = -15}
local p_undead_M = {['sf'] = 1.11, ['x'] = -70, ['z'] = -27}
local p_undead_F = {['sf'] = 1.08, ['x'] = -70, ['z'] = -25}
local p_orc_M = {['sf'] = 1.03, ['x'] = -70, ['z'] = -22}
local p_orc_F = {['sf'] = 1.04, ['x'] = -70, ['z'] = -13}
local p_troll_M = {['sf'] = 1.07, ['x'] = -70, ['z'] = -4}
local p_troll_F = {['sf'] = 0.96, ['x'] = -75, ['z'] = -12}
local p_blood_elf_M = {['sf'] = 1.04, ['x'] = -60, ['z'] = -28}
local p_blood_elf_F = {['sf'] = 1.13, ['x'] = -90, ['z'] = -24}
local p_draenei_M = {['sf'] = 0.91, ['x'] = -100, ['z'] = -15, ['f'] = 0.4}
local p_draenei_F = {['sf'] = 0.96, ['x'] = -80, ['z'] = -17, ['f'] = 0.45}
local p_goblin_M = {['sf'] = 1.35, ['x'] = -65, ['z'] = -10}
local p_goblin_F = {['sf'] = 1.38, ['x'] = -65, ['z'] = -15}
local p_worgen_M = {['sf'] = 0.95, ['x'] = -60, ['z'] = -48}
local p_worgen_F = {['sf'] = 0.80, ['x'] = -65, ['z'] = -20, ['f'] = 0.8}
local p_pandaren_M = {['sf'] = 0.9, ['x'] = -65, ['z'] = -9}
local p_pandaren_F = {['sf'] = 1.14, ['x'] = -80, ['z'] = 0}
local p_vulpera = {['sf'] = 1.5}
local p_dracthyr = {['sf'] = 1.0, ['x'] = -100, ['z'] = -10}
local P = {
    [0] = { -- default
        ['new'] = {[1] = p_default, [2] = p_default, [3] = p_default}},
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
