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
    ["Dead"] = 6,
    ["Talk"] = 60,
    ["TalkExclamation"] = 64,
    ["TalkQuestion"] = 65,
    ["Bow"] = 66,
    ["Point"] = 84,
    ["Salute"] = 113,
    ["Drowned"] = 132,
    ["Yes"] = 185,
    ["No"] = 186,
    ["Read"] = 520
}
local mid_set = {"Idle", "Talk", "Yes", "No", "Point"}
local end_set = {"Bow", "Salute"}
function QuestGiverMixin:OnAnimFinished()
    if self.anim_next ~= 0 then
        self:SetAnimation(self.anim_next)
        self.anim_next = 0
    else
        self:SetScript("OnAnimFinished", nil)
        self.anim_playing = false
        self:SetAnimation(0)
    end
end

function QuestGiverMixin:setQuestGiverAnimation(count, qString, qStringInt)
    if qString == nil or qString[qStringInt] == nil then
        return
    end

    if not self.doAnims then
        return
    end

    if qStringInt == 1 or qStringInt >= count then
        self:SetScript("OnAnimFinished", nil)
        self.anim_next = 0
        self.anim_playing = false
    end

    -- determine main emote to play for this line
    local a = emotes["Talk"]
    local s = string.sub(qString[qStringInt], -1)
    if qStringInt >= count then
        a = emotes[end_set[math.random(1, #end_set)]]
    elseif s == "!" then
        a = emotes["TalkExclamation"]
    elseif s == "?" then
        a = emotes["TalkQuestion"]
    end

    -- if playing something, don't interrupt to avoid spastic motions on click-thru
    if self.anim_playing then
        if a == emotes["Talk"] then
            self.anim_next = emotes[mid_set[math.random(1, #mid_set)]]
        else
            self.anim_next = a
        end
    else
        self.anim_playing = true
        if qStringInt < count then
            self.anim_next = emotes[mid_set[math.random(1, #mid_set)]]
        end
        self:SetScript("OnAnimFinished", self.OnAnimFinished)
        self:SetAnimation(a)
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

    Debug("NPC:", npc_name, "type:", npc_type, "fileID:", fileID, "creatureID:", creatureID, "is_dead:", is_dead, "sf:", scaleFactor)
    self:InitializeCamera(scaleFactor)

    local offsetX = -110
    local offsetZ = 50
    if scaleFactor < 0.8 then
        -- static tweak for some big models like dragons
        offsetX = 30
        --offsetZ = 0
    elseif scaleFactor > 2.5 then
        -- static tweak for most smaller models
        offsetZ = 100
    end
    if fileID == 1267024 then
        -- floating scroll
        offsetX = -350
        offsetZ = 250
    end
    self:SetViewTranslation(offsetX, offsetZ)

    if is_dead then
        self:SetAnimation(emotes.Dead)
        self.doAnims = false
    else
        self.doAnims = true
    end
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
    self:SetAnimation(emotes.Read)
    self:ApplySpellVisualKit(29521, false)
end

function QuestPlayerMixin:SetNo()
    self:SetAnimation(emotes.No)
end

function QuestPlayerMixin:SetYes()
    self:SetAnimation(emotes.Yes)
end
