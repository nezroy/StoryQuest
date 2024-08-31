local _, PKG = ...
local Debug = PKG.Debug

local DEFAULT_DB = {
    ["LockFrame"] = false,
    ["ScaleFrame"] = 1.0,
    ["HelmetMode"] = 1,
    ["ScalePlayer"] = 1.0,
    ["WeaponMode"] = 1,
}

local callback = nil
local function OnSettingChanged(setting, value)
    if callback and type(callback) == "function" then
        callback(setting, value)
    end
end

local function ScaleFormatter(value)
    return string.format("%.2f", value)
end

local function Setup(use_callback)
    callback = use_callback
    local category = Settings.RegisterVerticalLayoutCategory("StoryQuest")

    do
        local var = "LockFrame"
        local name = "Lock Position"
        local tooltip = "Prevents the StoryQuest window from being moved from its current position."
        local defVal = DEFAULT_DB[var]

        local setting = Settings.RegisterAddOnSetting(category, var, var, STORYQUEST_DB, type(defVal), name, defVal)
        setting:SetValueChangedCallback(OnSettingChanged)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    do
        local var = "ScaleFrame"
        local name = "Scale Window"
        local tooltip = "Adjusts the size of the StoryQuest window."
        local defVal = DEFAULT_DB[var]

        local setting = Settings.RegisterAddOnSetting(category, var, var, STORYQUEST_DB, type(defVal), name, defVal)
        setting:SetValueChangedCallback(OnSettingChanged)
        local opts = Settings.CreateSliderOptions(0.5, 2.0, 0.05)
        opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, ScaleFormatter)
        Settings.CreateSlider(category, setting, opts, tooltip)
    end

    do
        local var = "HelmetMode"
        local name = "Head Slot Behavior (global)"
        local tooltip = "Determines the default head slot visibility behavior for all characters."
        local defVal = DEFAULT_DB[var]

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, "Show Head Slot")
            container:Add(2, "Hide Head Slot")
            return container:GetData()
        end

        local setting = Settings.RegisterAddOnSetting(category, var, var, STORYQUEST_DB, type(defVal), name, defVal)
        setting:SetValueChangedCallback(OnSettingChanged)
        Settings.CreateDropdown(category, setting, GetOptions, tooltip)
    end

    do
        local var = "HelmetMode"
        local name = "Head Slot Behavior (character)"
        local tooltip = "Determines the head slot visibility behavior for the current character."
        local defVal = DEFAULT_DB[var]

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, "Use Global Setting")
            container:Add(2, "Show Head Slot")
            container:Add(3, "Hide Head Slot")
            return container:GetData()
        end

        local setting = Settings.RegisterAddOnSetting(category, "Char" .. var, var, STORYQUEST_CHAR_DB, type(defVal), name, defVal)
        setting:SetValueChangedCallback(OnSettingChanged)
        Settings.CreateDropdown(category, setting, GetOptions, tooltip)
    end

    do
        local var = "WeaponMode"
        local name = "Weapon Behavior (global)"
        local tooltip = "Determines the default weapon behavior for all characters."
        local defVal = DEFAULT_DB[var]

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, "Stow Weapons")
            container:Add(2, "Draw Weapons")
            container:Add(3, "Hide Weapons")
            return container:GetData()
        end

        local setting = Settings.RegisterAddOnSetting(category, var, var, STORYQUEST_DB, type(defVal), name, defVal)
        setting:SetValueChangedCallback(OnSettingChanged)
        Settings.CreateDropdown(category, setting, GetOptions, tooltip)
    end

    do
        local var = "WeaponMode"
        local name = "Weapopn Behavior (character)"
        local tooltip = "Determines the weapon behavior for the current character."
        local defVal = DEFAULT_DB[var]

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, "Use Global Setting")
            container:Add(2, "Stow Weapons")
            container:Add(3, "Draw Weapons")
            container:Add(4, "Hide Weapons")
            return container:GetData()
        end

        local setting = Settings.RegisterAddOnSetting(category, "Char" .. var, var, STORYQUEST_CHAR_DB, type(defVal), name, defVal)
        setting:SetValueChangedCallback(OnSettingChanged)
        Settings.CreateDropdown(category, setting, GetOptions, tooltip)
    end

    do
        local var = "ScalePlayer"
        local name = "Scale Player Model"
        local tooltip = "Adjusts the size of the player model for the current character."
        local defVal = DEFAULT_DB[var]

        local setting = Settings.RegisterAddOnSetting(category, var, var, STORYQUEST_CHAR_DB, type(defVal), name, defVal)
        setting:SetValueChangedCallback(OnSettingChanged)
        local opts = Settings.CreateSliderOptions(0.5, 2.0, 0.05)
        opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, ScaleFormatter)
        Settings.CreateSlider(category, setting, opts, tooltip)
    end

    Settings.RegisterAddOnCategory(category)
end

local function Get(name, only_global)
    if not only_global and STORYQUEST_CHAR_DB[name] ~= nil then
        return STORYQUEST_CHAR_DB[name]
    elseif STORYQUEST_DB[name] ~= nil then
        return STORYQUEST_DB[name]
    else
        return DEFAULT_DB[name]
    end
end

PKG.Settings = {
    ["Setup"] = Setup,
    ["Get"] = Get
}
