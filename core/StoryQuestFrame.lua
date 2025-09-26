local _, PKG = ...
local Debug = PKG.Debug

local mapBGs = PKG.QUESTVIEW_MAP_BGS

StoryQuestFrameMixin = {}
local StoryQuest = StoryQuestFrameMixin

local SKIP_TO_END = "Skip to End"
if PKG.FF.SkipToEnd then
    SKIP_TO_END = COVENANT_MISSIONS_SKIP_TO_END
end

function StoryQuest:UiScaleChanged()
    local sf = PKG.Settings.Get("ScaleFrame")
    self:SetScale(UIParent:GetScale() * sf)
    self.container.playerModel:SetupModel()
    self.container.giverModel:SetupModel()
    if self:IsShown() then
        -- reload internal stuff
        self:showQuestFrame()
    end
    self.defer_ui_change = false
end

function StoryQuest:UpdateMapId()
    self.mapId = C_Map.GetBestMapForUnit("player")
    if not self.mapId and self.updateAttempts < 10 then
        self.updateAttempts = self.updateAttempts + 1
        C_Timer.After(0.5, function() self:UpdateMapId() end)
    else
        self.updateAttempts = 0
    end
end

local pat_sep = "[\\.|!|?|\n]%s+"
local pat_uwu = "^<[^>]*>"
local function splitQuest(inputstr)
    local t = {}
    local i = 1

    -- cleanup and normalize the quest text
    inputstr = inputstr:gsub("[\r\n]+", "\n") -- normalize to LF and collapse multi-line gaps
    inputstr = inputstr:gsub("^%s+", "") -- left trim whitespace
    inputstr = inputstr:gsub("%s+$", "") -- right trim whitespace
    inputstr = inputstr:gsub(" %s+", " ") -- collapse multi-space gaps to a single space
    inputstr = inputstr:gsub("%.%.%.", "…") -- normalize elipsis
    inputstr = inputstr:gsub("%-%-", "—") -- normalize emdash
    inputstr = inputstr:gsub("(%S)—(%S)", "%1 — %2") -- as above
    inputstr = inputstr:gsub(" Co%.", " Co;,;") -- change abbrev period into a pattern we fix back later

    -- split a string by separators, clean up, and add uwu caps if needed
    local sepString = function(text, uwuflag)
        local sep_s, _ = text:find(pat_sep)
        local uwucap = uwuflag and "<" or ""
        local uwuend = uwuflag and ">" or ""
        if sep_s then
            t[i] = uwucap .. text:sub(1, sep_s):gsub("%s+$", ""):gsub(";,;", ".") .. uwuend
            i = i + 1
            text = text:sub(sep_s + 1):gsub("^%s+", "")
        else
            t[i] = uwucap .. text:gsub("%s+$", ""):gsub(";,;", ".") .. uwuend
            i = i + 1
            text = ""
        end
        return text
    end

    -- check for uwus and recursively split those
    while inputstr ~= "" do
        local uwu_s, uwu_e = inputstr:find(pat_uwu)
        if uwu_s then
            local uwustr = inputstr:sub(uwu_s + 1, uwu_e - 1)
            while uwustr ~= "" do
                uwustr = sepString(uwustr, true)
            end
            inputstr = inputstr:sub(uwu_e + 1):gsub("^%s+", "")
        else
            inputstr = sepString(inputstr)
        end
    end

    return t
end

local function styleBlizzRewards()
    local f_rewards = QuestInfoRewardsFrame
    if not f_rewards then
        return
    end

    if f_rewards.RewardButtons then
        for i, quest_item in ipairs(f_rewards.RewardButtons) do
            local point, relativeTo, relativePoint, _, y = quest_item:GetPoint()
            if point and relativeTo and relativePoint then
                if i == 1 then
                    quest_item:SetPoint(point, relativeTo, relativePoint, 0, y)
                elseif relativePoint == "BOTTOMLEFT" then
                    quest_item:SetPoint(point, relativeTo, relativePoint, 0, -4)
                else
                    quest_item:SetPoint(point, relativeTo, relativePoint, 4, 0)
                end
            end
        end
    end

    local styleText = function(text)
        if not text then
            return
        end
        text:SetTextColor(1, 1, 1)
        text:SetShadowColor(0, 0, 0, 1)
        text:SetShadowOffset(1, -1)
    end

    styleText(QuestInfoRewardText)
    styleText(f_rewards.ItemChooseText)
    styleText(f_rewards.ItemReceiveText)
    styleText(QuestInfoXPFrame and QuestInfoXPFrame.ReceiveText)
    styleText(f_rewards.Header)
    styleText(f_rewards.SpellLearnText)
    styleText(f_rewards.PlayerTitleText)
    styleText(f_rewards.XPFrame and f_rewards.XPFrame.ReceiveText)
end

local function unstyleBlizzRewards()
    local f_rewards = QuestInfoRewardsFrame
    if not f_rewards then
        return
    end

    local unstyleText = function(text)
        if not text then
            return
        end
        text:SetTextColor(0, 0, 0)
        text:SetShadowColor(0, 0, 0, 0)
        text:SetShadowOffset(0, 0)
    end

    unstyleText(QuestInfoRewardText)
    unstyleText(f_rewards.ItemChooseText)
    unstyleText(f_rewards.ItemReceiveText)
    unstyleText(QuestInfoXPFrame and QuestInfoXPFrame.ReceiveText)
    unstyleText(f_rewards.Header)
    unstyleText(f_rewards.SpellLearnText)
    unstyleText(f_rewards.PlayerTitleText)
    unstyleText(f_rewards.XPFrame and f_rewards.XPFrame.ReceiveText)
end

function StoryQuest:showRewards(showObjective)
    if showObjective then
        self.container.dialog.objectiveText:SetText(GetObjectiveText())
        UIFrameFadeIn(self.container.dialog.objectiveHeader, 0.1, 0, 1)
        UIFrameFadeIn(self.container.dialog.objectiveText, 0.1, 0, 1)
    end

    local f_rwd = QuestInfoRewardsFrame
    if (not f_rwd or not f_rwd:IsShown()) then
        return
    end

    -- restyle and then steal Blizz's quest reward frame
    -- TODO: not a fan of just stealing the blizz reward panel despite the simplicity
    -- see Blizzard_UIPanels_Game/Mainline/QuestInfo.xml to clone/mimic this eventually
    local qinfoHeight = 300
    local qinfoTop = -20
    styleBlizzRewards()
    f_rwd:SetParent(self)
    f_rwd:SetHeight(qinfoHeight)
    f_rwd:ClearAllPoints()
    f_rwd:SetFrameLevel(5)
    if showObjective then
        f_rwd:SetPoint("TOPLEFT", self.container.dialog.objectiveText, "BOTTOMLEFT", 0, -15)
    else
        f_rwd:SetPoint("CENTER", self, "CENTER", -5, qinfoTop)
    end
    UIFrameFadeIn(f_rwd, 0.1, 0, 1)
end

function StoryQuest:questTextCompleted()
    if self.questStateSet then
        return
    end
    if self.questState == "COMPLETE" then
        self:showRewards(false)
        self.container.acceptButton:SetText(COMPLETE_QUEST)
        self.container.acceptButton:Show()
    elseif self.questState == "PROGRESS" then
        if IsQuestCompletable() then
            self.container.acceptButton:SetText(CONTINUE)
            self.questState = "NEEDCOMPLETE"
        else
            local s = string.sub(self.questString[self.questStringInt], -1)
            if s == "?" then
                self.container.playerModel:SetNo()
            end
            self.container.acceptButton:Hide()
            self.container.declineButton:SetText(CANCEL)
            self.container.declineButton:Show()
        end
    else
        self:showRewards(true)
        self.container.acceptButton:SetText(ACCEPT)
        self.container.acceptButton:Show()
    end
    self.questStateSet = true
end

local MAX_TEXT_WIDTH = 750
function StoryQuest:setBalancedText(text)
    local t = self.container.dialog.text
    t:SetWidth(MAX_TEXT_WIDTH)
    t:SetText(text)
    local needed = t:GetStringWidth()
    if needed > (2 * MAX_TEXT_WIDTH) then
        local balanced = math.floor(needed / 3) + 50
        if balanced < MAX_TEXT_WIDTH then
            t:SetWidth(balanced)
        end
    elseif needed > MAX_TEXT_WIDTH then
        local balanced = math.floor(needed / 2) + 50
        if balanced < MAX_TEXT_WIDTH then
            t:SetWidth(balanced)
        end
    end
end

function StoryQuest:nextGossip()
    if self.questState and self.questState == "NEEDCOMPLETE" then
        self.questState = "COMPLETING"
        -- there will be a QUEST_COMPLETE event shortly
        self:clearDialog()
        self.container.dialog.reqItems:ClearInfo()
        self.container.dialog.reqItems:Hide()
        self.container.dialog.objectiveHeader:Hide()
        self.container.dialog.objectiveText:Hide()
        self.container.acceptButton:Hide()
        self.container.declineButton:Hide()
        self.container.playerModel:SetYes()
        CompleteQuest()
        return
    end
    if self.questStateSet then
        return
    end
    self.questStringInt = self.questStringInt + 1
    local qStringInt = self.questStringInt
    local count = #self.questString

    if (self.container.dialog.reqItems:HasRequiredItems()) then
        self.container.dialog.reqItems:Show()
    else
        self.container.dialog.reqItems:Hide()
    end
    if qStringInt <= count then
        self:setBalancedText(self.questString[qStringInt])
        self.container.giverModel:setQuestGiverAnimation(count, self.questString, qStringInt)
        if qStringInt ~= 1 then
            PlaySound(906)
        end
        if qStringInt == count then
            self:questTextCompleted()
        else
            self.container.acceptButton:SetText(SKIP_TO_END)
            self.container.acceptButton:Show()
        end
    else
        self.questStringInt = count
        self:questTextCompleted()
    end
end

function StoryQuest:lastGossip()
    if self.questStringInt == 1 then
        return
    end
    self.questStringInt = max(self.questStringInt - 1, 1)
    local qStringInt = self.questStringInt
    local count = #self.questString

    if qStringInt <= count then
        self:setBalancedText(self.questString[qStringInt])
        self.container.giverModel:setQuestGiverAnimation(count, self.questString, qStringInt)
        if qStringInt ~= 1 then
            PlaySound(906)
        end
        self.container.acceptButton:SetText(SKIP_TO_END)
        self.container.acceptButton:Show()
        QuestInfoRewardsFrame:Hide()
        self.questStateSet = false
        if self.questState ~= "PROGRESS" then
            self.container.dialog.reqItems:Hide()
        end
        self.container.dialog.objectiveHeader:Hide()
        self.container.dialog.objectiveText:Hide()
    else
        self:questTextCompleted()
    end
end

function StoryQuest:HideQuestFrame()
    -- cannot actually hide it as we are stealing its elements/events and need it
    -- to remain technically shown for the duration
    QuestFrame:SetAlpha(0.0)
end

function StoryQuest:UnhideQuestFrame()
    unstyleBlizzRewards()
    QuestFrame:SetAlpha(1.0)
end

function StoryQuest:showQuestFrame()
    local mapId = self.mapId or C_Map.GetBestMapForUnit("player") or 0
    local mapTex
    repeat
        local mapInfo = C_Map.GetMapInfo(mapId)
        if mapInfo then
            Debug("current map", mapInfo.mapID, mapInfo.name, mapInfo.mapType, mapInfo.parentMapID)
            mapTex = mapBGs[mapInfo.mapID] or mapBGs[mapInfo.parentMapID]
            mapId = mapInfo.parentMapID
        end
    until not mapInfo or mapTex or mapInfo.parentMapID == 0
    if not mapTex then
        mapTex = "Misc/default"
    end
    self.container.mapBG:SetTexture("Interface/AddOns/StoryQuest/textures/backgrounds/" .. mapTex)

    self.container.floaty.title:SetText(GetTitleText())

    local npc_name = GetUnitName("questnpc")
    local is_self = UnitIsUnit("questnpc", "player")
    local is_dead = UnitIsDead("questnpc")

    local PC_kit = self.recent_player_choice and PlayerChoiceFrame and PlayerChoiceFrame.uiTextureKit
    Debug("quest giver - name:[", npc_name, "] self:[", is_self, "] dead:[", is_dead, "] PC_kit:[", PC_kit, "]")

    self:Show()

    local pm = self.container.playerModel
    local gm = self.container.giverModel
    pm:setPMUnit()
    if PKG.FF.PlayerChoice and is_self and PC_kit then
        -- a recent player choice popup was made, use the relevant kit/board
        gm:SetBoardUnit(PC_kit)
    elseif is_self then
        -- typical for auto-accepted quests, story pushes, etc.; have the player read a scroll
        pm:ReadScroll()
    elseif is_dead then
        -- quest giver is a dead NPC; have the player kneel
        pm:Kneel()
    else
        -- attempt to set the questnpc unit, check for success
        local did_set_unit = gm:SetQuestUnit()
        Debug("attempted set unit:", did_set_unit)
        if not did_set_unit then
            -- could not set the model automatically, try to figure out some common cases
            -- (TODO: some of these use English localized names, which only works for English clients)
            if npc_name == "Warchief's Command Board" then
                gm:SetBoardUnit("horde")
            elseif npc_name == "Hero's Call Board" then
                gm:SetBoardUnit("alliance")
            else
                -- if we can't figure out a better option, have the player read a scroll
                pm:ReadScroll()
            end
        end
    end
    --PlaySoundFile("Interface/AddOns/StoryQuest/sounds/dialog_open.ogg", "SFX")
end

function StoryQuest:clearDialog()
    if (self.questString) then
        wipe(self.questString)
        wipe(self.questReqText)
    else
        self.questString = {}
        self.questReqText = {}
    end
    self.questStringInt = 0
end

function StoryQuest:clearQuestReq()
    self.questState = "NONE"
    self.questStateSet = false
    self:clearDialog()
    self.container.dialog.objectiveHeader:Hide()
    self.container.dialog.objectiveText:Hide()
end

function StoryQuest:acceptQuest()
    if self.questState == "TAKE" then
        if (QuestFlagsPVP()) then
            QuestFrame.dialog = StaticPopup_Show("CONFIRM_ACCEPT_PVP_QUEST")
        else
            if (QuestFrame.autoQuest) then
                AcknowledgeAutoAcceptQuest()
            else
                AcceptQuest()
                CloseQuest()
            end
        end
        if self:IsShown() then self:Hide() end
    elseif self.questState == "PROGRESS" then
        CloseQuest()
    else
        if (GetNumQuestChoices() == 0) then
            GetQuestReward(0)
            CloseQuest()
        elseif (GetNumQuestChoices() == 1) then
            GetQuestReward(1)
            CloseQuest()
        else
            if (QuestInfoFrame.itemChoice == 0) then
                QuestChooseRewardError()
            else
                GetQuestReward(QuestInfoFrame.itemChoice)
                CloseQuest()
            end
        end
    end
end

function StoryQuest:OnKeyDown(key)
    local inCombat = InCombatLockdown()
    local interact1,interact2 = GetBindingKey("INTERACTTARGET")
    if key == "SPACE" or ((key == interact1 and interact1 ~= nil) or (key == interact2 and interact2 ~= nil)) then
        if not inCombat then
            self:SetPropagateKeyboardInput(false)
        end
        local Stringcount = #self.questString

        if self.questStringInt < Stringcount then
            self:nextGossip()
        else
            if self.questState == "NEEDCOMPLETE" then
                self:nextGossip()
            else
                self:acceptQuest()
            end
        end
    elseif key == "BACKSPACE" then
        if not inCombat then
            self:SetPropagateKeyboardInput(false)
        end
        self:lastGossip()
    else
        if not inCombat then
            self:SetPropagateKeyboardInput(true)
        end
    end
end

function StoryQuest:OnShow()
    self.container.FadeIn:Play()
    self.container.declineButton:SetText(DECLINE)
    self.container.declineButton:SetShown(not QuestFrame.autoQuest)
    self:EnableKeyboard(true)
    self:SetScript("OnKeyDown", self.OnKeyDown)
    if _G.StoryQuestDebugFrame then
        _G.StoryQuestDebugFrame:Show()
    end
end

function StoryQuest:OnHide()
    self.container.mapBG:SetAlpha(0)
    self:EnableKeyboard(false)
    self:SetScript("OnKeyDown", nil)
    self:UnhideQuestFrame()
    if _G.StoryQuestDebugFrame then
        _G.StoryQuestDebugFrame:Hide()
    end
end

function StoryQuest:evQuestProgress()
    self:HideQuestFrame()
    self:clearQuestReq()

    self.container.dialog.reqItems:UpdateInfo()
    if (self.container.dialog.reqItems:HasRequiredItems()) then
        self.questReqText = splitQuest(GetProgressText())
        self.container.dialog.reqItems:UpdateFrame()
    end
    self:showQuestFrame()
    self.questString = splitQuest(GetProgressText())
    self.questState = "PROGRESS"
    self:nextGossip()
end

function StoryQuest:evQuestDetail(questStartItemID)
    local is_qframe_shown = QuestFrame:IsShown()
    Debug("Blizz QuestFrame:IsShown() -", is_qframe_shown)
    if not is_qframe_shown then
        return
    end
    if (self.questState ~= "COMPLETING") then
        self:HideQuestFrame()
        self:clearQuestReq()
        self.container.dialog.reqItems:ClearInfo()
        self.container.dialog.reqItems:Hide()
        self.questState = "TAKE"
    else
        self.questStringInt = 0
        self.questStateSet = false
    end
    self.questString = splitQuest(GetQuestText())
    if self.questState ~= "COMPLETING" then
        tinsert(self.questString, "")
    end
    if self.in_cine or self.in_load then
        -- defer actually opening this frame until after load/cinematic finishes
        self.needs_showing = true
    else
        self.needs_showing = false
        self:showQuestFrame()
        self:nextGossip()
    end
end

function StoryQuest:evQuestComplete()
    if (self.questState ~= "COMPLETING") then
        self:HideQuestFrame()
        self:clearQuestReq()
        self.container.dialog.reqItems:ClearInfo()
        self.container.dialog.reqItems:Hide()
    else
        self.container.declineButton:SetText(CANCEL)
        self.container.declineButton:SetShown(not QuestFrame.autoQuest)
        self.questStringInt = 0
        self.questStateSet = false
    end
    if not self:IsShown() then
        self:showQuestFrame()
    end
    self.questString = splitQuest(GetRewardText())
    local qText = self.questReqText
    if (#qText > 0) then
        for i = #qText, 1, -1 do
            tinsert(self.questString, 1, qText[i])
        end
    end
    self.questState = "COMPLETE"
    self:nextGossip()
end

function StoryQuest:evQuestFinished()
    QuestInfoRewardsFrame:Hide()
    self:clearQuestReq()
    self.container.dialog.reqItems:ClearInfo()
    self.container.dialog.reqItems:Hide()
    self:Hide()
    if (self.questState ~= "PROGRESS") then
        --PlaySoundFile("Interface/AddOns/StoryQuest/sounds/dialog_close.ogg", "SFX")
    end
end

local function dialog_OnMouseUp(self, button, isInside)
    if not isInside or not (button == "LeftButton" or button == "RightButton") then
        return
    end
    local qview = self:GetParent():GetParent()
    if button == "RightButton" then
        qview:lastGossip()
    else
        qview:nextGossip()
    end
end

local function decline_OnClick()
    CloseQuest()
end

local function accept_OnClick(self)
    local qview = self:GetParent():GetParent()
    local Stringcount = #qview.questString

    if qview.questStringInt < Stringcount then
        qview.questStringInt = Stringcount - 1
        qview:nextGossip()
    else
        if qview.questState == "NEEDCOMPLETE" then
            qview:nextGossip()
        else
            qview:acceptQuest()
        end
    end
end

function StoryQuest:OnEvent(event, ...)
    Debug("event handling", event, ...)
    if event == "ADDON_LOADED" then
        self:evAddonLoaded(...)
    elseif event == "UI_SCALE_CHANGED" then
        if not self.defer_ui_change then
            -- pause one frame for cvars but don't queue multiple of these
            self.defer_ui_change = true
            C_Timer.After(0, function() self:UiScaleChanged() end)
        end
    elseif event == "LOADING_SCREEN_ENABLED" then
        self.in_load = true
        if self:IsShown() then
            self.was_showing = true
            self:Hide()
        else
            self.was_showing = false
        end
    elseif event == "LOADING_SCREEN_DISABLED" then
        self.in_load = false
        if not self.in_cine then
            if self.was_showing then
                self.was_showing = false
                self:Show()
            elseif self.needs_showing then
                self.needs_showing = false
                self:showQuestFrame()
                self:nextGossip()
            end
        end
        self:UpdateMapId()
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        self:UpdateMapId()
    elseif event == "QUEST_PROGRESS" then
        self:evQuestProgress()
    elseif event == "QUEST_DETAIL" then
        self:evQuestDetail(...)
    elseif event == "QUEST_COMPLETE" then
        self:evQuestComplete()
    elseif event == "QUEST_FINISHED" then
        self:evQuestFinished()
    elseif event == "CINEMATIC_START" then
        local is_real = select(1, ...)
        if is_real then
            self.in_cine = true
            if self:IsShown() then
                self.was_showing = true
                self:Hide()
            else
                self.was_showing = false
            end
        end
    elseif event == "CINEMATIC_STOP" then
        self.in_cine = false
        if not self.in_load then
            if self.was_showing then
                self.was_showing = false
                self:Show()
            elseif self.needs_showing then
                self.needs_showing = false
                self:showQuestFrame()
                self:nextGossip()
            end
        end
    elseif event == "BARBER_SHOP_RESULT" then
        local pm = self.container.playerModel
        pm:SetupModel()
    elseif event == "PLAYER_CHOICE_CLOSE" then
        self.recent_player_choice = true
        C_Timer.After(2, function () self.recent_player_choice = false end)
    end
end

function StoryQuest:applyLockFrame()
    local lf = PKG.Settings.Get("LockFrame")
    if not lf then
        self:RegisterForDrag("LeftButton")
        self:SetScript("OnDragStart", self.StartMoving)
        self:SetScript("OnDragStop", self.StopMovingOrSizing)
    else
        self:SetScript("OnDragStart", nil)
        self:SetScript("OnDragStop", nil)
        self:RegisterForDrag()
    end
end

function StoryQuest:applyTitleStyle()
    local style = PKG.Settings.Get("TitleStyle")
    if style == 2 then
        self.container.blackout_head:SetHeight(48)
        self.container.blackout_head:SetAlpha(1.0)
        self.container.blackout_fade:Show()
        self.container.floaty.title:SetHeight(48)
    elseif style == 3 then
        self.container.blackout_head:SetHeight(80)
        self.container.blackout_head:SetAlpha(0.0)
        self.container.blackout_fade:Hide()
        self.container.floaty.title:SetHeight(80)
    else
        self.container.blackout_head:SetHeight(96)
        self.container.blackout_head:SetAlpha(1.0)
        self.container.blackout_fade:Show()
        self.container.floaty.title:SetHeight(96)
    end
end

function StoryQuest:settingChanged(setting, value)
    local var = setting:GetVariable()
    Debug("setting changed - ", var, " [", value, "]")
    if var == "LockFrame" then
        self:applyLockFrame()
    elseif var == "ScaleFrame" or var == "ScalePlayer" then
        self:UiScaleChanged()
    elseif var == "TitleStyle" then
        self:applyTitleStyle()
    end
end

function StoryQuest:evAddonLoaded(addon_name)
    if addon_name ~= "StoryQuest" then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")

    -- setup our settings
    if not STORYQUEST_DB then
        STORYQUEST_DB = {["SettingVer"] = 1}
    end
    if not STORYQUEST_CHAR_DB then
        STORYQUEST_CHAR_DB = {["SettingVer"] = 1}
    end
    PKG.Settings.Setup(function (setting, value) self:settingChanged(setting, value) end)

    self:UiScaleChanged()
    self:applyLockFrame()
    self:applyTitleStyle()
end

function StoryQuest:OnLoad()
    self.mapId = 0
    self.updateAttempts = 0

    self.border:SetTextureSliceMargins(32, 32, 32, 32)
    self.border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    self.container.floaty.inset:SetTextureSliceMargins(64, 64, 64, 64)
    self.container.floaty.inset:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)

    self:SetScript("OnShow", self.OnShow)
    self:SetScript("OnHide", self.OnHide)
    self:SetScript("OnEvent", self.OnEvent)

    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("UI_SCALE_CHANGED")
    self:RegisterEvent("LOADING_SCREEN_DISABLED")
    self:RegisterEvent("LOADING_SCREEN_ENABLED")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("QUEST_DETAIL")
    self:RegisterEvent("QUEST_FINISHED")
    self:RegisterEvent("QUEST_COMPLETE")
    self:RegisterEvent("QUEST_PROGRESS")
    self:RegisterEvent("CINEMATIC_START")
    self:RegisterEvent("CINEMATIC_STOP")
    self:RegisterEvent("BARBER_SHOP_RESULT")
    if PKG.FF.PlayerChoice then
        self:RegisterEvent("PLAYER_CHOICE_CLOSE")
        self:RegisterEvent("PLAYER_CHOICE_UPDATE")
    end

    self.container.dialog:SetScript("OnMouseUp", dialog_OnMouseUp)
    self.container.declineButton:SetScript("OnClick", decline_OnClick)
    self.container.acceptButton:SetScript("OnClick", accept_OnClick)

    self:clearQuestReq()
    self:SetClampedToScreen(true)
    self:SetMovable(true)
end
