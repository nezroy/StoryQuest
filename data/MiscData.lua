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
    ["Eat"] = 61,
    ["Sheath"] = 89,
    ["Train"] = 195,
}
PKG.EMOTES = emotes

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
    --]]
    ["thewarwithin"] = -223875,
    --[[
    ["Oribos"] = 1822634,
    ["jailerstower"] = 1822634,
    ["cypherchoice"] = 1822634,
    --]]
}
PKG.BOARD_TYPES = B

-- object name to fileid lookups
local O = {
    ["Danger Sign"] = 319484,
    ["Fel Portal"] = 1268729,
    ["Lever"] = 897186,
}
PKG.OBJECT_TYPES = O
