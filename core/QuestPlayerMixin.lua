local _, PKG = ...
local Debug = PKG.Debug

local emotes = PKG.EMOTES

StoryQuestPlayerModelMixin = {}
local QuestPlayerMixin = StoryQuestPlayerModelMixin

function QuestPlayerMixin:SetupModel()
    self.skip_model_load = true -- ClearModel will cause a model load event we ignore
    self.is_unit_set = false
    self:SetUnit("none")
    self:ClearModel()
    self:ClearAll()
end

function QuestPlayerMixin:ClearAll()
    self.is_loaded = false
    self.defer_read_scroll = false
    self.defer_kneel = false
    self.defer_yes = false
    self.defer_no = false
end

function QuestPlayerMixin:OnShow()
    local _, is_in_alt = C_PlayerInfo.GetAlternateFormInfo()
    self.is_in_alt = is_in_alt
    self.skip_model_load = false
    if not self.is_unit_set then
        local player_loc = PlayerLocation:CreateFromUnit("player")
        local race_id = C_PlayerInfo.GetRace(player_loc)
        local body_type = C_PlayerInfo.GetSex(player_loc) + 2
        self.race_id = race_id
        self.body_type = body_type
        self.is_unit_set = true
        self:SetUnit("player")
    else
        self:RefreshUnit()
    end
    -- NOTE: the above Set/RefreshUnit calls will immediately call OnModelLoaded
    -- if there is no load delay BEFORE continuing on in here; don't add anything
    -- after those calls without considering the timing issue
end

function QuestPlayerMixin:OnHide()
    -- model will load when frame first gets re-shown, but we don't want to
    -- actually handle that until after the OnShow handler runs
    self.skip_model_load = true
    self:ClearAll()
end

function QuestPlayerMixin:OnModelLoaded()
    if self.skip_model_load or not self.is_unit_set then
        return
    end

    -- determine effective race based on alt forms
    local race_id = self.race_id
    if self.race_id == 52 and self.is_in_alt then
        race_id = 10 -- alliance dracthyr in blood elf visage
    elseif self.race_id == 70 and self.is_in_alt then
        race_id = 1 -- horde dracthyr in human visage
    elseif self.race_id == 22 and self.is_in_alt then
        race_id = 1 -- worgen in human form
    end

    local p_info = PKG.PLAYER_SCALES[race_id]
    if p_info then
        if not PKG.FF.NewPlayerModels and p_info.old then
            p_info = p_info.old
        else
            p_info = p_info.new
        end
    end
    if p_info then
        p_info = p_info[self.body_type]
    end

    local x = -70
    local z = -40
    local sf = 1.0
    local f = 0.5

    local ps = PKG.Settings.Get("ScalePlayer")
    if p_info then
        if p_info.x then
            x = x + p_info.x
        end
        if p_info.z then
            z = z + p_info.z
        end
        if p_info.sf then
            sf = sf * (1/((100 + p_info.sf)/100))
            --if ps then
            --    heightScale = heightScale / ps
            --end
        end
        if p_info.f then
            f = f * ((100 - p_info.f)/100)
        end
    end

--    Debug("INFO - final_z:", foot_offset, "(", heightScale, ")")
    Debug("player - race:", self.race_id, "| eff_race:", race_id, "| alt_form:", self.is_in_alt, "| sf:", sf, "| ps:", ps, "| x:", x, "| z:", z, "| f:", f)

    self:RefreshCamera()
    self:SetCamDistanceScale(sf)
    self:SetViewTranslation(x, z)
    self:SetFacing(f)

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
