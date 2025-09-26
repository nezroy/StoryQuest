local _, PKG = ...
local emotes = PKG.EMOTES

-- model (fileID) tweaks
-- if only a single value defined (no table), that value is the sf
-- sf: percent bigger(+) or smaller(-) from default size
-- x: right(+) or left(-) offset
-- z: up(+) or down(-) offset
-- f: percent change in facing toward cam(+) or away from cam(-)
-- p: pitch
-- ia: idle animation; -1 to disable anims
-- hk: flag to use upper body/half-kit animations
local T = {
    -- NPCs using generic player models - old models (pre revamp)
    [119940] = {['sf'] = 1.38, ['x'] = 25}, -- human male (old)
    [119563] = {['sf'] = 1.45, ['x'] = 50}, -- human female (old)
    [119159] = {['sf'] = 1.87, ['x'] = -30}, -- gnome male (old)
    [119063] = {['sf'] = 1.9, ['x'] = -20}, -- gnome female (old)
    [118355] = {['sf'] = 1.57, ['x'] = 25}, -- dwarf male (old)
    [118135] = {['sf'] = 1.57, ['x'] = 35}, -- dwarf female (old)
    [120791] = {['sf'] = 1.3, ['x'] = 5}, -- night elf male (old)
    [120590] = {['sf'] = 1.36, ['x'] = -20}, -- night elf female (old)
    [121768] = {['sf'] = 1.47, ['x'] = 40}, -- undead male (old)
    [121608] = {['sf'] = 1.41, ['x'] = 30}, -- undead female (old)
    [121287] = {['sf'] = 1.37, ['x'] = 20}, -- orc male (old)
    [121087] = {['sf'] = 1.36, ['x'] = 30}, -- orc female (old)
    [122560] = {['sf'] = 1.4, ['x'] = -20}, -- troll male (old)
    [122414] = {['sf'] = 1.28, ['x'] = 40}, -- troll female (old)
    [122055] = {['sf'] = 1.25}, -- taruen male (old)
    [121961] = {['sf'] = 1.28, ['x'] = 35}, -- tauren female (old)
    [117721] = {['sf'] = 1.21, ['x'] = 45, ['f'] = -0.7}, -- draenei male (old)
    [117437] = {['sf'] = 1.28, ['x'] = 30, ['f'] = -0.55}, -- draenei female (old)
    [117170] = {['sf'] = 1.35, ['x'] = 10}, -- blood elf male (old)
    [116921] = {['sf'] = 1.44, ['x'] = 30}, -- blood elf female (old)
    [307454] = {['sf'] = 1.28}, -- worgen male (old)
    [307453] = {['sf'] = 1.09, ['x'] = 10}, -- worgen female (old)
    [119376] = {['sf'] = 1.74, ['x'] = -50}, -- goblin male (old)
    [119369] = {['sf'] = 1.82, ['x'] = -50}, -- goblin female (old)

    -- NPCs using generic player models
    [1011653] = {['sf'] = 1.45, ['x'] = 25}, -- human male
    [1000764] = {['sf'] = 1.55, ['x'] = 50}, -- human female
    [900914] = {['sf'] = 2.05, ['x'] = -30}, -- gnome male
    [940356] = {['sf'] = 2.05, ['x'] = -20}, -- gnome female
    [878772] = {['sf'] = 1.57, ['x'] = 25}, -- dwarf male
    [950080] = {['sf'] = 1.57, ['x'] = 35}, -- dwarf female
    [974343] = {['sf'] = 1.3, ['x'] = 5}, -- night elf male
    [921844] = {['sf'] = 1.37, ['x'] = -20}, -- night elf female
    [968705] = {['sf'] = 1.25}, -- tauren male
    [986648] = {['sf'] = 1.28, ['x'] = 35}, -- tauren female
    [1100258] = {['sf'] = 1.35}, -- blood elf female
    [535052] = {['sf'] = 1.17, ['x'] = 40}, -- pandaren male
    [589715] = {['sf'] = 1.44, ['x'] = 55}, -- pandaren female
    [5548259] = 1.45, -- earthen female

    -- non-creature items/objects
    [1822634] = {['sf'] = 2.0, ['x'] = -250, ['z'] = -40, ['ia'] = -1, ['f'] = -0.7}, -- generic quest board
    [429102] = {['sf'] = 3.5, ['x'] = -250, ['z'] = -10, ['ia'] = -1, ['f'] = -0.7}, -- hero board
    [429104] = {['sf'] = 3.5, ['x'] = -250, ['z'] = -10, ['ia'] = -1, ['f'] = -0.7}, -- command board
    [2020272] = {['sf'] = 2.0, ['x'] = -250, ['z'] = -10, ['ia'] = -1, ['f'] = -0.7}, -- marine table
    [1267024] = {['sf'] = 2.0, ['x'] = -250, ['z'] = 200, ['ia'] = -1}, -- floating scroll/khadgar's summons
    [5755585] = {['sf'] = 3.0, ['z'] = 50, ['ia'] = -1}, -- chett
    [6658771] = {['sf'] = 2.5, ['x'] = -200, ['ia'] = -1}, -- titan console

    -- big dragons
    [3084654] = {['sf'] = 0.79, ['x'] = 130}, -- big wrathion
    [4227968] = {['sf'] = 0.79, ['x'] = 130}, -- big selistra
    [4496906] = {['sf'] = 0.7, ['x'] = 130}, -- big kalec
    [4498270] = {['sf'] = 0.7, ['x'] = 130}, -- big dormu
    [4495214] = {['sf'] = 0.7, ['x'] = 130}, -- big alexstrasza
    [1259122] = {['sf'] = 0.7, ['x'] = 130}, -- big senegos
    [4416923] = {['sf'] = 0.79, ['x'] = 130}, -- big ebyssian, big surigosa
    [5151105] = {['sf'] = 0.75, ['x'] = 130}, -- big merithra
    [4492766] = {['sf'] = 0.55, ['x'] = 130}, -- big vyranoth

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
    [123698] = {['sf'] = 2.1, ['x'] = -200}, -- tarindrella, female dryads
    [917116] = 1.3, -- warchief's herald
    [4186587] = 1.6, -- rowie
    [3947971] = 2.0, -- nostwin
    [3950118] = 1.6, -- honeypelt
    [4575036] = {['sf'] = 2.6, ['z'] = 50}, -- newsy
    [1890761] = 1.7, -- veeno
    [1135341] = 0.85, -- brogg
    [4183015] = 1.0, -- ignax
    [1261840] = 1.0, -- cenarius
    [3024835] = 2.0, -- moonberry
    [5011146] = 1.6, -- amrymn
    [4278602] = {['sf'] = 0.3, ['x'] = 130}, -- buri
    [5154480] = 0.95, -- dreamkin
    [4883916] = 2.49, -- Q'onzu
    [1120702] = 1.0, -- aviana
    [1572377] = 0.8, -- locus walker
    [1817113] = 1.35, -- wolf genn
    [5353632] = 1.3, -- magni
    [5492980] = 1.5, -- moira
    [2168127] = 1.1, -- memory of a duke
    [3952870] = 1.1, -- thrall
    [1022598]= 1.15, -- zenata
    [959310] = 1.35, -- dalyngrigge
    [3730980] = {['sf'] = 2.6, ['z'] = 50}, -- reese
    [5165026] = {['sf'] = 2.6, ['z'] = 50}, -- squally
    [4066013] = 0.9, -- garz
    [5548261] = 1.4, -- baelgrim
    [5484812] = 1.35, -- brinthe
    [5339030] = 1.4, -- skitter
    [5767091] = 1.5, -- dagan
    [5482015] = 1.0, -- sum'latha
    [5221517] = 0.95, -- kish'nal
    [1886724] = 1.4, -- Dolena
    [5333438] = {['sf'] = 2.6, ['z'] = 50}, -- spindle
    [5348707] = 0.81, -- vix'aron
    [5241992] = 1.05, -- ren'khat
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
    [126286] = {['sf'] = 1.8, ['x'] = -250}, -- waltor of pal'ea
    [4419101] = 1.18, -- watcher koranos
    [117412] = 1.35, -- lost/broken male, firmanvaar
    [669393] = {['sf'] = 1.3, ['x'] = -80}, -- vol'jin
    [1697869] = 1.5, -- katherine proudmoore TODO: not accurate

}
PKG.MODEL_TWEAKS = T

-- NPC (creatureID) tweaks; takes priority over model tweaks
local n_widow_araknai = {
    ['sf'] = 1.1, ['ia'] = emotes.IdleHang, ['hk'] = true,
    ['x'] = -50, ['z'] = 325, ['p'] = -0.33,
}
local n_berrund  = 1.1
local N = {
    [197478] = 2.8, -- herald flaps
    [201648] = {['sf'] = 0.79, ['x'] = 130}, -- big somnikus
    [215788] = n_berrund, [215822] = n_berrund, [215836] = n_berrund,
    [144154] = 1.6, -- thurgaden
    [228860] = 2.2, -- gabby gabi
    [207471] = n_widow_araknai, [227428] = n_widow_araknai,
    [205067] = 1.25, -- shandris feathermoon
    [202656] = 1.18, -- mayla highmountain
    [37195] = 1.18, -- lord darius crowley
    [49425] = {['sf'] = 1.25, ['x'] = 40}, -- darnell
    [36648] = 1.18, -- baine bloodhoof
    [4949] = 1.22, -- classic thrall
}
PKG.NPC_TWEAKS = N
