local _, PKG = ...
local Debug = PKG.Debug

local model_tweaks = PKG.QUESTVIEW_MODEL_TWEAKS
local npc_tweaks = PKG.QUESTVIEW_NPC_TWEAKS

StoryQuestGiverModelMixin = {}
local QuestGiverMixin = StoryQuestGiverModelMixin

StoryQuestPlayerModelMixin = {}
local QuestPlayerMixin = StoryQuestPlayerModelMixin

-- emote IDs used for SetAnimation
local emotes = {
    ["Idle"] = 0,
    ["IdleHover"] = 193,
    ["IdleDead"] = 6,
    ["IdleDrowned"] = 132,
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
local mid_set = {"Talk", "Talk2", "Yes", "No", "Point"}
local end_set = {"Bow", "Salute"}
function QuestGiverMixin:OnAnimFinished()
    if self.anim_next ~= -1 then
        self.anim_playing = true
        if self.half_kits then
            self:PlayAnimKit(self.anim_next)
        else
            self:SetAnimation(self.anim_next)
        end
        self.anim_next = -1
    elseif self.anim_playing then
        self.anim_playing = false
        if not self.half_kits then
            self:SetAnimation(self.idle_anim)
        end
    end
end

function QuestGiverMixin:setQuestGiverAnimation(count, qString, qStringInt)
    if qString == nil or qString[qStringInt] == nil then
        return
    end

    if not self.doAnims then
        return
    end

    -- determine main emote to play for this line
    local prefix = self.half_kits and "Half" or ""
    local a = "Talk"
    local s = string.sub(qString[qStringInt], -1)
    local overwrite_next = false
    if qStringInt >= count then
        a = end_set[math.random(1, #end_set)]
        overwrite_next = true
    elseif s == "!" then
        a = "TalkExclamation"
    elseif s == "?" then
        a = "TalkQuestion"
    end

    -- if playing something, don't interrupt to avoid spastic motions on click-thru
    if self.anim_playing then
        if self.anim_next == -1 or overwrite_next then
            if a == "Talk" then
                a = mid_set[math.random(1, #mid_set)]
            end
            Debug("anim is playing; next anim:", prefix, a)
            if self:HasAnimation(emotes[a]) then
                self.anim_next = emotes[prefix .. a]
            elseif not overwrite_next then
                self.anim_next = emotes[prefix .. "Talk"]
            else
                self.anim_next = -1
            end
        end
    else
        self.anim_playing = true
        self.anim_next = -1
        if qStringInt < count then
            if a == "Talk" then
                a = mid_set[math.random(1, #mid_set)]
            end
        end
        Debug("no anim playing; next anim:", prefix, a)
        local play_anim = nil
        if self:HasAnimation(emotes[a]) then
            play_anim = emotes[prefix .. a]
        elseif not overwrite_next then
            play_anim = emotes[prefix .. "Talk"]
        end
        if play_anim ~= nil then
            if self.half_kits then
                self:PlayAnimKit(play_anim)
            else
                self:SetAnimation(play_anim)
            end
        end
    end
end

local MODEL_FACING = 0.5
function QuestGiverMixin:setPMUnit(unit, is_dead, npc_name, npc_type)
    -- reset previous model/unit
    self:ClearModel()
    self:RefreshCamera()

    -- set new model/unit
    local scaleFactor = 1.25 -- can we figure this out programmatically without lookups?
    self:SetUnit(unit)
    --self:SetCreature(191485)
    local creatureID = TutorialHelper:GetCreatureIDFromGUID(UnitGUID(unit))
    local fileID = self:GetModelFileID()
    if creatureID and npc_tweaks[creatureID] then
        scaleFactor = npc_tweaks[creatureID]
    elseif fileID and model_tweaks[fileID] then
        scaleFactor = model_tweaks[fileID]
    end
    local wideModel = false
    if scaleFactor < 0 then
        wideModel = true
        scaleFactor = -scaleFactor
    end

    Debug("NPC:", npc_name, "type:", npc_type, "fileID:", fileID, "creatureID:", creatureID, "is_dead:", is_dead, "sf:", scaleFactor)
    self:InitializeCamera(scaleFactor)

    local offsetX = -110
    local offsetZ = 50
    if wideModel then
        -- static tweak for some big wide models like dragons
        offsetX = 30
        --offsetZ = 0
    elseif scaleFactor > 2.5 then
        -- static tweak for most smaller models
        offsetZ = 100
    end

    if is_dead then
        self.idle_anim = emotes.IdleDead
        self.doAnims = false
    else
        self.doAnims = true
        self.idle_anim = emotes.Idle
    end

    self.half_kits = false
    if fileID == 1267024 then
        -- floating scroll
        offsetX = -350
        offsetZ = 250
        self.doAnims = false
    elseif fileID == 5159886 then
        self.idle_anim = emotes.IdleHover
        self.half_kits = true
    end
    self.anim_next = -1
    self.anim_playing = false
    if not self.anim_hooked then
        self:HookScript("OnAnimFinished", self.OnAnimFinished)
        self.anim_hooked = true
    end
    self:SetAnimation(self.idle_anim)
    self:SetViewTranslation(offsetX, offsetZ)
end

function QuestGiverMixin:setBoardUnit()
    self:ClearModel()
    self:RefreshCamera()
    self:SetModel(1822634)
    self:InitializeCamera(2.0)
    self:SetViewTranslation(-400, 10)
    self.doAnims = false
end

function QuestGiverMixin:SetupModel()
    self:ClearModel()
    self:RefreshCamera()
    self:SetFacing(-MODEL_FACING)
    self:SetFacingLeft(true)
end

local player_scales = PKG.QUESTVIEW_PLAYER_SCALES
function QuestPlayerMixin:SetupModel()
    local _, _, raceID = UnitRace("player")
    local heightScale = player_scales[raceID]
    if not heightScale then
        heightScale = player_scales[0] -- default
    end
    local ps = PKG.Settings.Get("ScalePlayer")
    Debug("player frame scale:", heightScale, "personal scale:", ps)
    if ps then
        heightScale = heightScale / ps
    end
    local foot_offset = floor((heightScale - 1.0) * -100)
    Debug("foot_offset:", foot_offset)
    local offsetX = -35

    if raceID == 52 or raceID == 70 then
        -- adjust for dracthyr weirdness; proper fix would check visage form
        -- and reset these params based on current form
        foot_offset = foot_offset - 10
        offsetX = -90
    elseif raceID == 10 then
        -- tweak for blood elf
        foot_offset = foot_offset - 15
    elseif raceID == 22 then
        -- tweak for worgen
        -- TODO: would be really nice if we could figure out if we're in worgen
        -- or human form on model refresh and adjust from that
        foot_offset = foot_offset - 15
        offsetX = -55
    elseif raceID == 1 then
        -- tweaks for humans        
        foot_offset = foot_offset - 15
        offsetX = -55
    end

    self:ClearModel()
    self:RefreshCamera()
    self:SetFacing(MODEL_FACING)
    self:SetUnit("player", true, true)
    self:SetCamDistanceScale(heightScale)
    self:SetViewTranslation(offsetX, foot_offset)
end

function QuestPlayerMixin:afterRefreshUnit()
    local wm = PKG.Settings.Get("WeaponMode")
    local hm = PKG.Settings.Get("HelmetMode")
    if hm == 1 then
        hm = PKG.Settings.Get("HelmetMode", true) + 1
    end
    if wm == 1 then
        wm = PKG.Settings.Get("WeaponMode", true) + 1
    end
    if hm == 3 then
        self:UndressSlot(INVSLOT_HEAD)
    end
    if wm == 2 and not self:GetSheathed() then
        self:SetSheathed(true, false)
    elseif wm == 3 and self:GetSheathed() then
        self:SetSheathed(false, false)
    elseif wm == 4 then
        self:SetSheathed(true, true)
    end
end

function QuestPlayerMixin:setPMUnit()
    self:RefreshUnit()
    C_Timer.After(0, function() self:afterRefreshUnit() end)
end

function QuestPlayerMixin:ReadScroll()
    self:SetAnimation(emotes.IdleRead)
    self:ApplySpellVisualKit(29521, false)
end

function QuestPlayerMixin:SetNo()
    self:SetAnimation(emotes.No)
end

function QuestPlayerMixin:SetYes()
    self:SetAnimation(emotes.Yes)
end
