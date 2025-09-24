local _, PKG = ...

-- emote IDs used for SetAnimation
local emotes = {
    ["Idle"] = 0,
    ["IdleHover"] = 193,
    ["IdleDead"] = 6,
    ["IdleKneel"] = 114,
    ["IdleDrowned"] = 132,
    ["IdleQuadSit"] = 219,
    ["IdleHang"] = 229,
    ["IdleRead"] = 520,
    ["Talk"] = 60,
    ["FullTalk"] = 1203,
    ["HalfTalk"] = 1521,
    ["Talk2"] = 1492,
    ["FullTalk2"] = 1203,
    ["HalfTalk2"] = 1521,
    ["TalkExclamation"] = 64,
    ["FullTalkExclamation"] = 1201,
    ["HalfTalkExclamation"] = 14256,
    ["TalkQuestion"] = 65,
    ["FullTalkQuestion"] = 29460,
    ["HalfTalkQuestion"] = 3216,
    ["Bow"] = 66,
    ["FullBow"] = 3261,
    ["HalfBow"] = 2413,
    ["Point"] = 84,
    ["FullPoint"] = 4010,
    ["HalfPoint"] = 4010,
    ["Salute"] = 113,
    ["FullSalute"] = 18795,
    ["HalfSalute"] = 13678,
    ["Yes"] = 185,
    ["FullYes"] = 9183,
    ["HalfYes"] = 30606,
    ["No"] = 186,
    ["FullNo"] = 20341,
    ["HalfNo"] = 4772,
}
PKG.QUESTVIEW_EMOTES = emotes

PKG.QUESTVIEW_DEBUG_CREATURE_ID = nil

-- model (fileID) tweaks
local T = {
    -- NPCs using generic player models
    [119940] = {['sf'] = 1.45, ['x'] = -75}, -- human male (old)
    [1011653] = {['sf'] = 1.45, ['x'] = -75}, -- human male (new)
    [119563] = {['sf'] = 1.55, ['x'] = -50}, -- human female (old)
    [1000764] = {['sf'] = 1.55, ['x'] = -50}, -- human female (new)
    [119159] = {['sf'] = 2.05, ['x'] = -130}, -- gnome male (old)
    [900914] = {['sf'] = 2.05, ['x'] = -130}, -- gnome male (new)
    [119063] = {['sf'] = 2.05, ['x'] = -120}, -- gnome female (old)
    [940356] = {['sf'] = 2.05, ['x'] = -120}, -- gnome female (new)
    [118355] = {['sf'] = 1.57, ['x'] = -75}, -- dwarf male (old)
    [878772] = {['sf'] = 1.57, ['x'] = -75}, -- dwarf male (new)
    [118135] = {['sf'] = 1.57, ['x'] = -65}, -- dwarf female (old)
    [950080] = {['sf'] = 1.57, ['x'] = -65}, -- dwarf female (new)
    [120791] = {['sf'] = 1.3, ['x'] = -95}, -- night elf male (old)
    [974343] = {['sf'] = 1.3, ['x'] = -95}, -- night elf male (new)
    [120590] = {['sf'] = 1.37, ['x'] = -120}, -- night elf female (old)
    [921844] = {['sf'] = 1.37, ['x'] = -120}, -- night elf female (new)
    [121768] = {['sf'] = 1.5, ['x'] = -60}, -- undead male (old)
    [121608] = {['sf'] = 1.43, ['x'] = -70}, -- undead female (old)
    [121287] = {['sf'] = 1.37, ['x'] = -80}, -- orc male (old)
    [121087] = {['sf'] = 1.39, ['x'] = -70}, -- orc female (old)
    [122560] = {['sf'] = 1.4, ['x'] = -120}, -- troll male (old)
    [122414] = {['sf'] = 1.28, ['x'] = -60}, -- troll female (old)
    [122055] = {['sf'] = 1.2}, -- taruen male (old)
    [968705] = {['sf'] = 1.2}, -- tauren male (new)
    [121961] = {['sf'] = 1.26, ['x'] = -65}, -- tauren female (old)
    [986648] = {['sf'] = 1.26, ['x'] = -65}, -- tauren female (new)
    [117721] = {['sf'] = 1.22, ['x'] = -55, ['f'] = -0.7}, -- draenei male (old)
    [117437] = {['sf'] = 1.27, ['x'] = -70, ['f'] = -0.55}, -- draenei female (old)
    [116921] = {['sf'] = 1.53, ['x'] = -70}, -- blood elf female (old)
    [1100258] = {['sf'] = 1.35}, -- blood elf female (new)
    [117170] = {['sf'] = 1.42, ['x'] = -90}, -- blood elf male (old)
    [307454] = {['sf'] = 1.27}, -- worgen male (old)
    [307453] = {['sf'] = 1.1, ['x'] = -90}, -- worgen female (old)

    [5548259] = 1.45, -- earthen female

    -- non-creature items/objects
    [1822634] = {['sf'] = 2.0, ['x'] = -350, ['z'] = 10, ['ia'] = -1, ['f'] = -0.7}, -- generic quest board
    [429102] = {['sf'] = 3.5, ['x'] = -350, ['z'] = 40, ['ia'] = -1, ['f'] = -0.7}, -- hero board
    [429104] = {['sf'] = 3.5, ['x'] = -350, ['z'] = 40, ['ia'] = -1, ['f'] = -0.7}, -- command board
    [2020272] = {['sf'] = 2.0, ['x'] = -350, ['z'] = 40, ['ia'] = -1, ['f'] = -0.7}, -- marine table
    [1267024] = {['sf'] = 2.0, ['x'] = -350, ['z'] = 250, ['ia'] = -1}, -- floating scroll/khadgar's summons
    [5755585] = {['sf'] = 3.0, ['z'] = 100, ['ia'] = -1}, -- chett
    [6658771] = {['sf'] = 2.5, ['x'] = -300, ['ia'] = -1}, -- titan console

    -- big dragons
    [3084654] = {['sf'] = 0.79, ['x'] = 30}, -- big wrathion
    [4227968] = {['sf'] = 0.79, ['x'] = 30}, -- big selistra
    [4496906] = {['sf'] = 0.7, ['x'] = 30}, -- big kalec
    [4498270] = {['sf'] = 0.7, ['x'] = 30}, -- big dormu
    [4495214] = {['sf'] = 0.7, ['x'] = 30}, -- big alexstrasza
    [1259122] = {['sf'] = 0.7, ['x'] = 30}, -- big senegos
    [4416923] = {['sf'] = 0.79, ['x'] = 30}, -- big ebyssian, big surigosa
    [5151105] = {['sf'] = 0.75, ['x'] = 30}, -- big merithra
    [4492766] = {['sf'] = 0.55, ['x'] = 30}, -- big vyranoth

    -- other stuff
    [1980608] = 1.3, -- Ulfar
    [3762412] = 1.1, -- primus
    [1249799] = 0.9, -- malfurion
    [4218359] = 2.0, -- chromie
    [1890759] = 1.8, -- selistra
    [4216711] = 1.0, -- therazal
    [1890765] = 1.8, -- thaelin
    [4036647] = 1.6, --- huseng
    [4081379] = 1.6, -- tomul
    [4207724] = 1.4, -- vaskarn
    [4498203] = 1.65, -- emberthal
    [1022938] = 1.3, -- senegos
    [119376] = 1.7, -- blixrez
    [123698] = {['sf'] = 2.1, ['x'] = -300}, -- tarindrella, female dryads
    [917116] = 1.3, -- warchief's herald
    [4186587] = 1.6, -- rowie
    [3947971] = 2.0, -- nostwin
    [3950118] = 1.6, -- honeypelt
    [4575036] = {['sf'] = 2.6, ['z'] = 100}, -- newsy
    [1890761] = 1.7, -- veeno
    [1135341] = 0.85, -- brogg
    [4183015] = 1.0, -- ignax
    [1261840] = 1.0, -- cenarius
    [3024835] = 2.0, -- moonberry
    [5011146] = 1.6, -- amrymn
    [4278602] = {['sf'] = 0.3, ['x'] = 30}, -- buri
    [5154480] = 0.95, -- dreamkin
    [4883916] = 2.49, -- Q'onzu
    [1120702] = 1.0, -- aviana
    [1572377] = 0.8, -- locus walker
    [1817113] = 1.35, -- wolf genn
    [5353632] = 1.3, -- magni
    [5492980] = 1.5, -- moira
    [2168127] = 1.1, -- memory of a duke
    [3952870] = 1.1, -- thrall
    [119369] = 1.8, -- izzy
    [1022598]= 1.15, -- zenata
    [959310] = 1.35, -- dalyngrigge
    [3730980] = {['sf'] = 2.6, ['z'] = 100}, -- reese
    [5165026] = {['sf'] = 2.6, ['z'] = 100}, -- squally
    [4066013] = 0.9, -- garz
    [5548261] = 1.4, -- baelgrim
    [5484812] = 1.35, -- brinthe
    [5339030] = 1.4, -- skitter
    [5767091] = 1.5, -- dagan
    [5482015] = 1.0, -- sum'latha
    [5221517] = 0.95, -- kish'nal
    [1886724] = 1.4, -- Dolena
    [5333438] = {['sf'] = 2.6, ['z'] = 100}, -- spindle
    [5348707] = 0.81, -- vix'aron
    [5241992] = 1.05, -- ren'khat
    [589715] = 1.3, -- noli marlen
    [5550057] = 2.0, -- cogwalker
    [1890763] = 1.6, -- jarden
    [5517447] = 0.9, -- miral murder-mittens
    [5763560] = 1.5, -- alyza bowblaze
    [2618947] = 0.6, -- goehi
    [5764885] = 1.6, -- monte gazlowe
    [5899823] = 1.0, -- sitchoaf
    [1905018] = 0.8, -- xithixxin
    [123799] = 1.15, -- ameer
    [123791] = 0.85, -- dabiri
    [3058051] = 1.6, -- tarela
    [1608483] = 2.0, -- maggie wiltshire
    [3657310] = 1.05, -- om'en
    [5159886] = {['sf'] = 1.2, ['ia'] = emotes.IdleHover, ['hk'] = true}, -- xal'atath
    [1738454] = 1.15, -- saurfang
    [126286] = {['sf'] = 1.8, ['x'] = -350}, -- waltor of pal'ea
    [4419101] = 1.18, -- watcher koranos
    [117412] = 1.35, -- lost/broken male, firmanvaar
    [669393] = {['sf'] = 1.3, ['x'] = -180}, -- vol'jin

}
PKG.QUESTVIEW_MODEL_TWEAKS = T

-- NPC (creatureID) tweaks; takes priority over model tweaks
local n_widow_araknai = {
    ['sf'] = 1.1, ['ia'] = emotes.IdleHang, ['hk'] = true,
    ['x'] = -150, ['z'] = 375, ['p'] = -0.33,
}
local n_berrund  = 1.1
local N = {
    [197478] = 2.8, -- herald flaps
    [201648] = {['sf'] = 0.79, ['x'] = 30}, -- big somnikus
    [215788] = n_berrund, [215822] = n_berrund, [215836] = n_berrund,
    [144154] = 1.6, -- thurgaden
    [228860] = 2.2, -- gabby gabi
    [207471] = n_widow_araknai, [227428] = n_widow_araknai,
    [205067] = 1.25, -- shandris feathermoon
    [202656] = 1.18, -- mayla highmountain
    [37195] = 1.18, -- lord darius crowley
    [49425] = {['sf'] = 1.25, ['x'] = -60}, -- darnell
}
PKG.QUESTVIEW_NPC_TWEAKS = N

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
local p_tauren_M = {['sf'] = 0.91, ['x'] = -60, ['z'] = -15}
local p_tauren_F = {['sf'] = 0.95, ['x'] = -70, ['z'] = -15}
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
local p_goblin = {['sf'] = 1.5}
local p_worgen_M = {['sf'] = 0.95, ['x'] = -60, ['z'] = -48}
local p_worgen_F = {['sf'] = 0.80, ['x'] = -65, ['z'] = -20, ['f'] = 0.8}
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
        ['new'] = {[2] = p_goblin, [3] = p_goblin},
        ['old'] = {[2] = p_goblin, [3] = p_goblin}},
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
        ['new'] = {[2] = p_default, [3] = p_default}},
    [25] = { -- pandaren, alliance
        ['new'] = {[2] = p_default, [3] = p_default}},
    [26] = { -- pandaren, horde
        ['new'] = {[2] = p_default, [3] = p_default}},
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
PKG.QUESTVIEW_PLAYER_SCALES = P

-- background textures by mapID
local M = {
    [18]   = "EK/tirisfal_glades_cata",
    [1420] = "EK/tirisfal_glades", -- pre-cata
    [21]   = "EK/silverpine_forest",
    [27]   = "EK/dun_morogh",
    [1426] = "EK/dun_morogh", -- pre-cata
    [37]   = "EK/elwynn_forest",
    [1429] = "EK/elwynn_forest", -- pre-cata
    [84]   = "EK/stormwind",
    [179]  = "EK/gilneas",
    [202]  = "EK/gilneas_city",
    [217]  = "EK/ruins_of_gilneas",
    [425]  = "EK/northshire_abbey",
    [427]  = "EK/coldridge_valley",
    [465]  = "EK/deathknell",
    [467]  = "EK/sunstrider_isle",
    [469]  = "EK/new_tinkertown",
    [998]  = "EK/undercity",
    [1186] = "EK/blackrock_depths",
    [2372] = "EK/arathi_highlands",
    [1]    = "Kalimdor/durotar",
    [1411] = "Kalimdor/durotar", -- pre-cata
    [57]   = "Kalimdor/teldrassil",
    [1438] = "Kalimdor/teldrassil", -- pre-cata
    [62]   = "Kalimdor/darkshore_cata",
    [85]   = "Kalimdor/orgrimmar",
    [89]   = "Kalimdor/darnassus",
    [81]   = "Kalimdor/silithus",
    [463]  = "Kalimdor/darkspear_isle",
    [1412] = "Kalimdor/mulgore", -- pre-cata
    [468]  = "Kalimdor/ammen_vale",
    [407]  = "Misc/darkmoon_faire",
    [1409] = "Misc/starter_isle",
    [971]  = "Misc/telogus_rift",
    [114]  = "Wrath/borean",
    [115]  = "Wrath/dragonblight",
    [117]  = "Wrath/howling_fjord",
    [120]  = "Wrath/stormpeaks",
    [125]  = "Wrath/dalaran",
    [627]  = "Legion/dalaran",
    [629]  = "Legion/dalaran_basement",
    [882]  = "Legion/eredath",
    [896]  = "BFA/drustvar",
    [2321] = "BFA/heart_chamber",
    [1525] = "SL/revendreth",
    [1533] = "SL/bastion",
    [1543] = "SL/maw",
    [1565] = "SL/ardenweald",
    [1670] = "SL/oribos", [1671] = "SL/oribos", [1672] = "SL/oribos",
    [1961] = "SL/korthia",
    [1970] = "SL/zerethmortis",
    [2016] = "SL/tazavesh",
    [1978] = "DF/default",
    [2022] = "DF/waking_shore",
    [2133] = "DF/zaralek",
    [2025] = "DF/thaldraszus",
    [2112] = "DF/valdrakken",
    [2305] = "TWW/dalaran_fall",
    [2248] = "TWW/isle_of_dorn",
    [2339] = "TWW/dornogal",
    [2214] = "TWW/ringing_deeps",
    [2215] = "TWW/hallowfall",
    [2255] = "TWW/azj_kahet", [2256] = "TWW/azj_kahet",
    [2369] = "TWW/siren_isle",
    [2346] = "TWW/undermine",
    [2371] = "TWW/karesh",
    [2472] = "TWW/tazavesh",
}
PKG.QUESTVIEW_MAP_BGS = M

-- board type model IDs related to player choice kits
local B = {
    ["genericplayerchoice"] = 1822634,
    ["alliance"] = 429102,
    ["horde"] = 429104,
    ["marine"] = 2020272,
    --[[
    ["mechagon"] = 1822634,
    ["NightFae"] = 1822634,
    ["Venthyr"] = 1822634,
    ["Kyrian"] = 1822634,
    ["Dragonflight"] = 1822634,
    ["thewarwithin"] = 1822634,
    ["Oribos"] = 1822634,
    ["jailerstower"] = 1822634,
    ["cypherchoice"] = 1822634,
    --]]
}
PKG.QUESTVIEW_BOARD_TYPES = B
