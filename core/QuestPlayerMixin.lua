local _, PKG = ...
local Debug = PKG.Debug

local player_scales = PKG.QUESTVIEW_PLAYER_SCALES
local emotes = PKG.QUESTVIEW_EMOTES

StoryQuestPlayerModelMixin = {}
local QuestPlayerMixin = StoryQuestPlayerModelMixin

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
    self:SetFacing(0.5)
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
