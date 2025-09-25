local _, PKG = ...
local Debug = PKG.Debug

local player_scales = PKG.QUESTVIEW_PLAYER_SCALES
local emotes = PKG.QUESTVIEW_EMOTES

StoryQuestPlayerModelMixin = {}
local QuestPlayerMixin = StoryQuestPlayerModelMixin

function QuestPlayerMixin:SetupModel()
    self.is_clear = true
    self.is_unit_set = false
    self:SetUnit("none")
    self:ClearModel()
    self:ClearAll()
end

function QuestPlayerMixin:setPMUnit()
    local _, is_in_alt = C_PlayerInfo.GetAlternateFormInfo()
    self.is_in_alt = is_in_alt
    self.is_clear = false
    if not self.is_unit_set then
        local player_loc = PlayerLocation:CreateFromUnit("player")
        local race_id = C_PlayerInfo.GetRace(player_loc)
        local body_type = C_PlayerInfo.GetSex(player_loc) + 2
        self.race_id = race_id
        self.body_type = body_type
        self.is_unit_set = true
        -- Will immediately call OnModelLoaded if there is no load delay BEFORE finishing here
        self:SetUnit("player")
    else
        self:RefreshUnit()
    end
end

function QuestPlayerMixin:ClearAll()
    self.is_loaded = false
    self.defer_read_scroll = false
    self.defer_kneel = false
    self.defer_yes = false
    self.defer_no = false
end

function QuestPlayerMixin:OnHide()
    self:ClearAll()
end

function QuestPlayerMixin:OnModelLoaded()
    if self.is_clear or not self.is_unit_set then
        return
    end

    -- determine effective race ID to use based on alt forms
    local raceID = self.race_id
    if self.race_id == 52 and self.is_in_alt then
        -- alliance dracthyr in blood elf visage
        raceID = 10
    elseif self.race_id == 70 and self.is_in_alt then
        -- horde dracthyr in human visage
        raceID = 1
    elseif self.race_id == 22 and self.is_in_alt then
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
    race_info = race_info[self.body_type]

    local heightScale = race_info['sf']
    local ps = PKG.Settings.Get("ScalePlayer")
    Debug("player - race:[", self.race_id, "] eff_race:[", raceID, "] alt_form:[", self.is_in_alt, "] hScale:[", heightScale, "] pScale:[", ps, "]")
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
    else
        self:SetFacing(0.5)
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

    self:SetAnimation(emotes.Idle)

    self.is_loaded = true
    self.FadeIn:Play()
    if self.defer_read_scroll then
        self:ReadScroll()
    end
    if self.defer_kneel then
        self:Kneel()
    end
    if self.defer_no then
        self:SetNo()
    end
    if self.defer_yes then
        self:SetYes()
    end
end

local NO_KIT_FRAMES = {
    [1] = { [2] = -150, [3] = -180 }, -- human
    [2] = { [2] = 180, [3] = 280 }, -- orc
    [3] = { [2] = 150, [3] = 180 }, -- dwarf
    [4] = { [2] = 150, [3] = -40 }, -- night elf
    [5] = { [2] = 230, [3] = 140 }, -- undead
    [6] = { [2] = 180, [3] = 100 }, -- tauren
    [7] = { [2] = 90, [3] = 0 }, -- gnome
    [8] = { [2] = -120, [3] = 180 }, -- troll
    [9] = { [2] = 180, [3] = 180 }, -- goblin
    [10] = { [2] = 180, [3] = 180 }, -- blood elf
    [11] = { [2] = 180, [3] = 180 }, -- draenei
    [22] = { [2] = 180, [3] = 180 }, -- worgen
    -- don't need any others because by MOP races we have the scroll kit
}
function QuestPlayerMixin:ReadScroll()
    if not self.is_loaded then
        self.defer_read_scroll = true
        return
    end
    self.defer_read_scroll = false

    self:SetSheathed(true, false)
    if PKG.FF.ReadingKit then
        self:SetAnimation(emotes.IdleRead)
        self:ApplySpellVisualKit(29521, false)
    else
        local frame = NO_KIT_FRAMES[self.race_id][self.body_type]
        if frame < 0 then
            self:FreezeAnimation(emotes.Sheath, 0, -frame)
        else
            self:FreezeAnimation(emotes.Train, 0, frame)
        end
        self:ApplySpellVisualKit(230853, false)
    end
end

function QuestPlayerMixin:Kneel()
    if not self.is_loaded then
        self.defer_kneel = true
        return
    end
    self.defer_kneel = false

    self:SetAnimation(emotes.IdleKneel)
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
