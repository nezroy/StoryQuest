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
    self.defer_action = false
end

function QuestPlayerMixin:OnShow()
    self.skip_model_load = false
    if not self.is_unit_set then
        if not PKG.FF.ReadingKit then
            local player_loc = PlayerLocation:CreateFromUnit("player")
            local race_id = C_PlayerInfo.GetRace(player_loc)
            local body_type = C_PlayerInfo.GetSex(player_loc) + 2
            self.race_id = race_id
            self.body_type = body_type
        end
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

    local file_id = self:GetModelFileID()
    local p_info = PKG.PLAYER_SCALES[file_id]

    local x = -70
    local z = -40
    local sf = 1.0
    local f = 0.5
    local ps = PKG.Settings.Get("ScalePlayer")
    if ps ~= 1.0 then
        sf = sf/ps
    end

    if p_info then
        if p_info.x then
            x = x + p_info.x
        end
        if p_info.z then
            z = z + p_info.z
        end
        if p_info.sf then
            sf = sf * (1/((100 + p_info.sf)/100))
            -- TODO: apply personal scale setting here
        end
        if p_info.f then
            f = f * ((100 - p_info.f)/100)
        end
    end

    Debug("player - fileID:", file_id, "| sf:", sf, "| ps:", ps, "| x:", x, "| z:", z, "| f:", f)

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
    if self.defer_action then
        self:SetAction(self.defer_action)
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
function QuestPlayerMixin:SetAction(action)
    if not self.is_loaded then
        self.defer_action = action
        return
    end
    self.defer_action = false

    if action == "read" then
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
    elseif action == "kneel" then
        self:SetAnimation(emotes.IdleKneel)
    elseif action == "no" then
        self:SetAnimation(emotes.No)
    elseif action == "yes" then
        self:SetAnimation(emotes.Yes)
    end
end

function QuestPlayerMixin:OnEvent(event, ...)
    Debug("QuestPlayerMixin event handling", event, ...)
    if event == "BARBER_SHOP_RESULT" then
        self:SetupModel()
    end
end

function QuestPlayerMixin:OnLoad()
    self:SetScript("OnEvent", self.OnEvent)
    if not PKG.FF.ReadingKit then
        -- we only need race/body type info if we have to custom animate "reading"
        self:RegisterEvent("BARBER_SHOP_RESULT")
    end
end
