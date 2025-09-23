local _, PKG = ...
local Debug = PKG.Debug

local player_scales = PKG.QUESTVIEW_PLAYER_SCALES
local emotes = PKG.QUESTVIEW_EMOTES

StoryQuestPlayerModelMixin = {}
local QuestPlayerMixin = StoryQuestPlayerModelMixin

function QuestPlayerMixin:SetupModel()
    self:ClearAll()
    self:SetFacing(0.5)
    self.is_clear = false
end

function QuestPlayerMixin:setPMUnit()
    self.is_clear = false
    if not self.is_unit_set then
        self:SetUnit("player", true, true)
    end
    self.is_unit_set = true
    self:RefreshUnit()
end

function QuestPlayerMixin:ClearAll()
    self.is_clear = true
    self.is_loaded = false
    self.read_scroll = false
end

function QuestPlayerMixin:OnHide()
    self:ClearAll()
end

function QuestPlayerMixin:OnModelLoaded()
    if self.is_clear or not self.is_unit_set then
        return
    end
    Debug("player model loaded")

    local _, _, real_race_id = UnitRace("player")
    local body_type = UnitSex("player")
    -- determine effective race ID to use based on alt forms
    local raceID = real_race_id
    local _, is_in_alt = C_PlayerInfo.GetAlternateFormInfo()
    if real_race_id == 52 and is_in_alt then
        -- alliance dracthyr in blood elf visage
        raceID = 10
    elseif real_race_id == 70 and is_in_alt then
        -- horde dracthyr in human visage
        raceID = 1
    elseif real_race_id == 22 and is_in_alt then
        -- worgen in human form
        raceID = 1
    end

    local race_info = player_scales[raceID]
    if not race_info then
        race_info = player_scales[0]
    end
    if not PKG.FF.NewPlayerModels and race_info['old'] then
        race_info = race_info['old']
    else
        race_info = race_info['new']
    end
    race_info = race_info[body_type]

    local heightScale = race_info['sf']
    local ps = PKG.Settings.Get("ScalePlayer")
    Debug("real race:", real_race_id, "effective race:", raceID, "in alt form:", is_in_alt, "height scale:", heightScale, "personal scale:", ps)
    if ps then
        heightScale = heightScale / ps
    end
    local foot_offset = floor((heightScale - 1.0) * -100)
    if race_info['z'] then
        foot_offset = foot_offset + race_info['z']
    end
    local offsetX = -35
    if race_info['x'] then
        offsetX = race_info['x']
    end

    self:RefreshCamera()
    self:SetCamDistanceScale(heightScale)
    self:SetViewTranslation(offsetX, foot_offset)
    if race_info['f'] then
        self:SetFacing(race_info['f'])
    end

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

    self.is_loaded = true
    self.FadeIn:Play()
    if self.defer_read_scroll then
        self:ReadScroll()
    end
    if self.defer_no then
        self:SetNo()
    end
    if self.defer_yes then
        self:SetYes()
    end
end

function QuestPlayerMixin:ReadScroll()
    if not self.is_loaded then
        self.defer_read_scroll = true
        return
    end
    self.defer_read_scroll = false

    self:SetAnimation(emotes.IdleRead)
    self:ApplySpellVisualKit(29521, false)
end

function QuestPlayerMixin:SetNo()
    if not self.is_loaded then
        self.defer_no = true
        return
    end
    self.defer_no = false

    self:SetAnimation(emotes.No)
end

function QuestPlayerMixin:SetYes()
    if not self.is_loaded then
        self.defer_yes = true
        return
    end
    self.defer_yes = false

    self:SetAnimation(emotes.Yes)
end
