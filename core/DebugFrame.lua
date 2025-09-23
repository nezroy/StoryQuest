local _, PKG = ...
local Debug = PKG.Debug

StoryQuestDebugFrameMixin = {}
local DebugFrame = StoryQuestDebugFrameMixin

function DebugFrame:UiScaleChanged()
    local sf = PKG.Settings.Get("ScaleFrame")
    self:SetScale(UIParent:GetScale() * sf)
    self.defer_ui_change = false
end

function DebugFrame:evAddonLoaded(addon_name)
    if addon_name ~= "StoryQuest" then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")
    if not self.defer_ui_change then
        -- pause one frame for cvars but don't queue multiple of these
        self.defer_ui_change = true
        C_Timer.After(0, function() self:UiScaleChanged() end)
    end
end

function DebugFrame:OnEvent(event, ...)
    Debug("event handling", event, ...)
    if event == "ADDON_LOADED" then
        self:evAddonLoaded(...)
    elseif event == "UI_SCALE_CHANGED" then
        if not self.defer_ui_change then
            -- pause one frame for cvars but don't queue multiple of these
            self.defer_ui_change = true
            C_Timer.After(0, function() self:UiScaleChanged() end)
        end
    end
end

local function grid_OnClick(self)
    local df = self:GetParent():GetParent()
    local bg = StoryQuestFrame.container.mapBG
    if df.bgTex ~= 0 then
        bg:SetTexture(df.bgTex)
        df.bgTex = 0
    else
        df.bgTex = bg:GetTexture()
        bg:SetTexture("Interface/AddOns/StoryQuest/textures/backgrounds/misc/grid")
    end
end

local function feet_OnClick(self)
    local b = StoryQuestFrame.container.dialog.blackout_feet
    local cb = StoryQuestFrame.container.blackout_head
    if b:IsShown() then
        b:Hide()
        cb:Hide()
    else
        b:Show()
        cb:Show()
    end
end

local function face_OnClick(self)
    local pm = StoryQuestFrame.container.playerModel
    if pm:GetFacing() == -0.5 then
        pm:SetFacing(0.55)
    else
        pm:SetFacing(-0.5)
    end
end

local function set_unit()
    local gm = StoryQuestFrame.container.giverModel
    gm:setQuestUnit("testing", "testing")
    gm:Show()
end

local function reset_OnClick(self)
    local df = self:GetParent():GetParent()
    local bg = StoryQuestFrame.container.mapBG
    local b = StoryQuestFrame.container.dialog.blackout_feet
    local cb = StoryQuestFrame.container.blackout_head
    local pm = StoryQuestFrame.container.playerModel
    local gm = StoryQuestFrame.container.giverModel
    if df.bgTex ~= 0 then
        bg:SetTexture(df.bgTex)
        df.bgTex = 0
    end
    if not b:IsShown() then
        b:Show()
        cb:Show()
    end
    pm:SetFacing(0.55)
    gm:Hide()
    PKG.QUESTVIEW_DEBUG_CREATURE_ID = nil
    C_Timer.After(0, set_unit)
end

local function show_creature(cid)
    local gm = StoryQuestFrame.container.giverModel
    gm:Hide()
    PKG.QUESTVIEW_DEBUG_CREATURE_ID = cid
    C_Timer.After(0, set_unit)
end

local model_buttons = {
    {"gnm M", 8416}, {"gnm F", 6376}, {"dwf M", 658}, {"dwf F", 2878},
    {"hmn M", 197}, {"hmn F", 9296}, {"nelf M", 2079}, {"nelf F", 8583},
    {"tau M", 2980}, {"tau F", 2991},
}
function DebugFrame:OnLoad()
    self.bgTex = 0
    self.border:SetTextureSliceMargins(32, 32, 32, 32)
    self.border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)

    self.container.gridButton:SetScript("OnClick", grid_OnClick)
    self.container.feetButton:SetScript("OnClick", feet_OnClick)
    self.container.faceButton:SetScript("OnClick", face_OnClick)
    self.container.resetButton:SetScript("OnClick", reset_OnClick)

    local y_off = -64
    for i = 1, #model_buttons do
        local btn_def = model_buttons[i]
        local mod_idx = (i - 1) % 4
        local btn = CreateFrame("Button", nil, self.container, "StoryQuestDebugButtonTemplate")
        btn:SetText(btn_def[1])
        btn:SetScript("OnClick", function () show_creature(btn_def[2]) end)
        if mod_idx == 0 then
            btn:SetPoint("TOPLEFT", self.container, "TOPLEFT", 0, y_off)
        elseif mod_idx == 1 then
            btn:SetPoint("TOP", self.container, "TOP", -37, y_off)
        elseif mod_idx == 2 then
            btn:SetPoint("TOP", self.container, "TOP", 37, y_off)
        else
            btn:SetPoint("TOPRIGHT", self.container, "TOPRIGHT", 0, y_off)
            y_off = y_off - 32
        end
    end

    self:SetScript("OnEvent", self.OnEvent)

    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("UI_SCALE_CHANGED")
end
