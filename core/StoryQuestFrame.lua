local _, PKG = ...
local Debug = PKG.Debug

StoryQuestFrameMixin = {}
local StoryQuest = StoryQuestFrameMixin

function StoryQuest:UiScaleChanged()
    local sf = PKG.Settings.Get("ScaleFrame")
    self:SetScale(UIParent:GetScale() * sf)
    self.container.playerModel:SetupModel()
    self.container.giverModel:SetupModel()
    if self:IsShown() then
        -- reload internal stuff
        self:showQuestFrame()
    end
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

local mapBGs = PKG.QUESTVIEW_MAP_BGS

local function questInfoDisplay(template, parentFrame)
    if template == QUEST_TEMPLATE_MAP_DETAILS or template == QUEST_TEMPLATE_MAP_REWARDS then
        return
    end

    local fInfo = QuestInfoFrame
    local fRwd = fInfo.rewardsFrame

    for i, questItem in ipairs(fRwd.RewardButtons) do
        local point, relativeTo, relativePoint, _, y = questItem:GetPoint()
        if point and relativeTo and relativePoint then
            if i == 1 then
                questItem:SetPoint(point, relativeTo, relativePoint, 0, y)
            elseif relativePoint == "BOTTOMLEFT" then
                questItem:SetPoint(point, relativeTo, relativePoint, 0, -4)
            else
                questItem:SetPoint(point, relativeTo, relativePoint, 4, 0)
            end
        end
    end

    QuestInfoTitleHeader:SetTextColor(1, 0.8, 0.1)
    QuestInfoDescriptionHeader:SetTextColor(1, 0.8, 0.1)
    QuestInfoDescriptionText:SetTextColor(1, 1, 1)
    QuestInfoObjectivesHeader:SetTextColor(1, 0.8, 0.1)
    QuestInfoObjectivesText:SetTextColor(1, 1, 1)
    QuestInfoGroupSize:SetTextColor(1, 1, 1)
    QuestInfoRewardText:SetTextColor(1, 1, 1)
    QuestInfoQuestType:SetTextColor(1, 1, 1)
    fRwd.ItemChooseText:SetTextColor(1, 1, 1)
    fRwd.ItemChooseText:SetShadowColor(0, 0, 0, 1)
    fRwd.ItemChooseText:SetShadowOffset(1, -1)
    fRwd.ItemReceiveText:SetTextColor(1, 1, 1)
    fRwd.ItemReceiveText:SetShadowColor(0, 0, 0, 1)
    fRwd.ItemReceiveText:SetShadowOffset(1, -1)
    QuestInfoXPFrame.ReceiveText:SetShadowColor(0, 0, 0, 1)
    QuestInfoXPFrame.ReceiveText:SetShadowOffset(1, -1)
    QuestInfoAccountCompletedNotice:SetTextColor(0, 0.9, 0.6)

    fRwd.Header:SetTextColor(1, 1, 1)
    fRwd.Header:SetShadowColor(0, 0, 0, 1)

    if fRwd.SpellLearnText then
        fRwd.SpellLearnText:SetTextColor(1, 1, 1)
    end

    if fRwd.PlayerTitleText then
        fRwd.PlayerTitleText:SetTextColor(1, 1, 1)
    end

    if fRwd.XPFrame.ReceiveText then
        fRwd.XPFrame.ReceiveText:SetTextColor(1, 1, 1)
    end

    local objectives = QuestInfoObjectivesFrame.Objectives
    local index = 0

    local questID = C_QuestLog.GetSelectedQuest()
    local waypointText = C_QuestLog.GetNextWaypointText(questID)
    if waypointText then
        index = index + 1
        objectives[index]:SetTextColor(1, 0.93, 0.73)
    end

    for i = 1, GetNumQuestLeaderBoards() do
        local _, objectiveType, isCompleted = GetQuestLogLeaderBoard(i)
        if objectiveType ~= "spell" and objectiveType ~= "log" and index < MAX_OBJECTIVES then
            index = index + 1

            local objective = objectives[index]
            if objective then
                if isCompleted then
                    objective:SetTextColor(0.2, 1, 0.2)
                else
                    objective:SetTextColor(1, 1, 1)
                end
            end
        end
    end
end

local pat_sep = "[\\.|!|?|\n]%s+"
local pat_emo = "^<[^>]*>"
local function splitQuest(inputstr)
    local t = {}
    local i = 1

    -- cleanup and normalize the quest text
    inputstr = inputstr:gsub("\n+", "\n") -- collapse multi-line gaps to a single newline
    inputstr = inputstr:gsub("^%s+", "") -- left trim whitespace
    inputstr = inputstr:gsub("%s+$", "") -- right trim whitespace
    inputstr = inputstr:gsub(" %s+", " ") -- collapse multi-space gaps to a single space
    inputstr = inputstr:gsub("%.%.%.", "…") -- normalize elipsis
    inputstr = inputstr:gsub("%-%-", "—") -- normalize emdash
    inputstr = inputstr:gsub("(%S)—(%S)", "%1 — %2") -- as above
    inputstr = inputstr:gsub(" Co%.", " Co;,;") -- change abbrev period into a pattern we fix back later

    -- split the string by uwus and separators
    while inputstr ~= "" do
        local emo_s, emo_e = inputstr:find(pat_emo)
        if emo_s then
            t[i] = inputstr:sub(emo_s, emo_e):gsub("%s+$", ""):gsub(";,;", ".")
            i = i + 1
            inputstr = inputstr:sub(emo_e + 1):gsub("^%s+", "")
        else
            local sep_s, _ = inputstr:find(pat_sep)
            if sep_s then
                t[i] = inputstr:sub(1, sep_s):gsub("%s+$", ""):gsub(";,;", ".")
                i = i + 1
                inputstr = inputstr:sub(sep_s + 1):gsub("^%s+", "")
            else
                t[i] = inputstr:gsub("%s+$", ""):gsub(";,;", ".")
                inputstr = ""
                i = i + 1
            end
        end
    end
    return t
end

function StoryQuest:HideQuestFrame()
    -- cannot actually hide it as we are stealing its elements/events and need it
    -- to remain technially shown for the duration
    if self.blizzFramePoints then
        wipe(self.blizzFramePoints)
    else
        self.blizzFramePoints = {}
    end
    for i = 1, QuestFrame:GetNumPoints() do
        tinsert(self.blizzFramePoints, {QuestFrame:GetPoint(i)})
    end
    QuestFrame:ClearAllPoints()
    QuestFrame:SetClampedToScreen(false)
    QuestFrame:SetPoint("RIGHT", UIParent, "LEFT", -800, 0)
end

function StoryQuest:UnhideQuestFrame()
    QuestFrame:ClearAllPoints()
    QuestFrame:SetClampedToScreen(true)
    for _, pt in ipairs(self.blizzFramePoints) do
        QuestFrame:SetPoint(pt[1], pt[2], pt[3], pt[4], pt[5])
    end
end

function StoryQuest:showRewards(showObjective)
    local questID = QuestInfoFrame.questLog and C_QuestLog.GetSelectedQuest() or GetQuestID()

    local xp = GetRewardXP()
    local money = GetRewardMoney()
    local title = GetRewardTitle()
    local currency = C_QuestInfoSystem.GetQuestRewardCurrencies(questID) or {};
    local _, _, skillPoints = GetRewardSkillPoints()
    local items = GetNumQuestRewards()
    local spells = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}
    local choices = GetNumQuestChoices()
    local honor = GetRewardHonor()

    local qinfoHeight = 300
    local qinfoTop = -20

    if showObjective then
        self.container.dialog.objectiveText:SetText(GetObjectiveText())
        UIFrameFadeIn(self.container.dialog.objectiveHeader, 0.1, 0, 1)
        UIFrameFadeIn(self.container.dialog.objectiveText, 0.1, 0, 1)
    end

    if (xp > 0 or money > 0 or title or #currency > 0 or skillPoints or items > 0 or #spells > 0 or choices > 0 or honor > 0) then
        local f = QuestInfoRewardsFrame
        UIFrameFadeIn(f, 0.1, 0, 1)
        f:SetParent(self)
        f:SetHeight(qinfoHeight)
        f:ClearAllPoints()
        f:SetFrameLevel(5)
        if showObjective then
            f:SetPoint("TOPLEFT", self.container.dialog.objectiveText, "BOTTOMLEFT", 0, -15)
        else
            f:SetPoint("CENTER", self, "CENTER", -5, qinfoTop)
        end
    end
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
            self.container.acceptButton:SetText(COVENANT_MISSIONS_SKIP_TO_END)
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
        self.container.acceptButton:SetText(COVENANT_MISSIONS_SKIP_TO_END)
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
        mapTex = "default"
    end
    self.container.mapBG:SetTexture("Interface/AddOns/StoryQuest/textures/backgrounds/" .. mapTex)

    self.container.floaty.title:SetText(GetTitleText())
    self:Show()

    self.container.playerModel:setPMUnit()

    local npc_name = GetUnitName("questnpc")
    local npc_type = UnitCreatureType("questnpc")
    local gm = self.container.giverModel
    if UnitIsUnit("questnpc", "player") then
        -- quest giver is the player; typically for auto-accepted quests, story pushes, etc.
        gm:setBoardUnit()
    elseif npc_name and npc_type then
        -- quest giver has a creature type; some kind of entity with a normal model
        gm:setPMUnit("questnpc", UnitIsDead("questnpc") and true or false, npc_name, npc_type)
    elseif npc_name then
        -- quest giver has a name but no type; probably an item or letter; give player a reading anim
        gm:ClearModel()
        gm:RefreshCamera()
        self.container.playerModel:ReadScroll()
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
end

function StoryQuest:OnHide()
    self.container.mapBG:SetAlpha(0)
    self.container.playerModel:SetAlpha(0)
    self.container.giverModel:SetAlpha(0)
    self:EnableKeyboard(false)
    self:SetScript("OnKeyDown", nil)
    self:UnhideQuestFrame()
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
    if (questStartItemID ~= nil and questStartItemID ~= 0) or (QuestGetAutoAccept() and QuestIsFromAreaTrigger()) then
        --AcknowledgeAutoAcceptQuest()
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
    self:showQuestFrame()
    self.questString = splitQuest(GetQuestText())
    if self.questState ~= "COMPLETING" then
        tinsert(self.questString, "")
    end
    self:nextGossip()
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
        C_Timer.After(0, function() self:UiScaleChanged() end) -- pause one frame for cvars
    elseif event == "LOADING_SCREEN_DISABLED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        self:UpdateMapId()
    elseif event == "QUEST_PROGRESS" then
        self:evQuestProgress()
    elseif event == "QUEST_DETAIL" then
        self:evQuestDetail(...)
    elseif event == "QUEST_COMPLETE" then
        self:evQuestComplete()
    elseif event == "QUEST_FINISHED" then
        self:evQuestFinished()
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

function StoryQuest:settingChanged(setting, value)
    local var = setting:GetVariable()
    Debug("setting changed - ", var, " [", value, "]")
    if var == "LockFrame" then
        self:applyLockFrame()
    elseif var == "ScaleFrame" or var == "ScalePlayer" then
        self:UiScaleChanged()
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
end

function StoryQuest:OnLoad()
    self.mapId = 0
    self.updateAttempts = 0

    self.border:SetTextureSliceMargins(32, 32, 32, 32)
    self.border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    self.container.floaty.inset:SetTextureSliceMargins(64, 64, 64, 64)
    self.container.floaty.inset:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)

    self.container.floaty.title:SetTextColor(1.0, 0.77, 0.15)
    self.container.floaty.title:SetFont(STANDARD_TEXT_FONT, 24)
    self.container.floaty.title:SetShadowColor(0, 0, 0, 1)
    self.container.floaty.title:SetShadowOffset(2, -2)

    self.container.dialog.text:SetFont(STANDARD_TEXT_FONT, 15)
    self.container.dialog.text:SetTextColor(1, 1, 1)

    self.container.dialog.objectiveHeader:SetTextColor(1, 1, 1)
    self.container.dialog.objectiveHeader:SetShadowColor(0, 0, 0, 1)
    self.container.dialog.objectiveHeader:SetText(QUEST_OBJECTIVES)

    self.container.dialog.objectiveText:SetTextColor(1, 1, 1)
    self.container.dialog.objectiveText:SetShadowColor(0, 0, 0, 1)
    self.container.dialog.objectiveText:SetShadowOffset(1, -1)

    self:SetScript("OnShow", self.OnShow)
    self:SetScript("OnHide", self.OnHide)
    self:SetScript("OnEvent", self.OnEvent)

    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("UI_SCALE_CHANGED")
    self:RegisterEvent("LOADING_SCREEN_DISABLED")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("QUEST_DETAIL")
    self:RegisterEvent("QUEST_FINISHED")
    self:RegisterEvent("QUEST_COMPLETE")
    self:RegisterEvent("QUEST_PROGRESS")

    self.container.dialog:SetScript("OnMouseUp", dialog_OnMouseUp)
    self.container.declineButton:SetScript("OnClick", decline_OnClick)
    self.container.acceptButton:SetScript("OnClick", accept_OnClick)

    self:clearQuestReq()
    self:SetClampedToScreen(true)
    self:SetMovable(true)

    hooksecurefunc("QuestInfo_Display", questInfoDisplay)
end
