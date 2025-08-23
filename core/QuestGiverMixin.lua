local _, PKG = ...
local Debug = PKG.Debug

local model_tweaks = PKG.QUESTVIEW_MODEL_TWEAKS
local npc_tweaks = PKG.QUESTVIEW_NPC_TWEAKS
local emotes = PKG.QUESTVIEW_EMOTES

StoryQuestGiverModelMixin = {}
local QuestGiverMixin = StoryQuestGiverModelMixin

-- emotes used (at random) for talk sequences and end sign-off
local mid_set = {"Talk", "Talk2", "Yes", "No", "Point"}
local end_set = {"Bow", "Salute"}

function QuestGiverMixin:OnAnimFinished()
    if self.anim_next ~= -1 then
        self.anim_playing = true
        if self.half_kits then
            self:PlayAnimKit(self.anim_next)
        else
            self:SetAnimation(self.anim_next)
        end
        self.anim_next = -1
    elseif self.anim_playing then
        self.anim_playing = false
        if not self.half_kits then
            self:SetAnimation(self.idle_anim)
        end
    end
end

function QuestGiverMixin:setQuestGiverAnimation(count, qString, qStringInt)
    if qString == nil or qString[qStringInt] == nil then
        return
    end

    if not self.doAnims then
        return
    end

    -- determine main emote to play for this line
    local prefix = self.half_kits and "Half" or ""
    local a = "Talk"
    local s = string.sub(qString[qStringInt], -1)
    local overwrite_next = false
    if qStringInt >= count then
        a = end_set[math.random(1, #end_set)]
        overwrite_next = true
    elseif s == "!" then
        a = "TalkExclamation"
    elseif s == "?" then
        a = "TalkQuestion"
    end

    -- if playing something, don't interrupt to avoid spastic motions on click-thru
    if self.anim_playing then
        if self.anim_next == -1 or overwrite_next then
            if a == "Talk" then
                a = mid_set[math.random(1, #mid_set)]
            end
            Debug("anim is playing; next anim:", prefix, a)
            if self:HasAnimation(emotes[a]) then
                self.anim_next = emotes[prefix .. a]
            elseif not overwrite_next then
                self.anim_next = emotes[prefix .. "Talk"]
            else
                self.anim_next = -1
            end
        end
    else
        self.anim_playing = true
        self.anim_next = -1
        if qStringInt < count then
            if a == "Talk" then
                a = mid_set[math.random(1, #mid_set)]
            end
        end
        Debug("no anim playing; next anim:", prefix, a)
        local play_anim = nil
        if self:HasAnimation(emotes[a]) then
            play_anim = emotes[prefix .. a]
        elseif not overwrite_next then
            play_anim = emotes[prefix .. "Talk"]
        end
        if play_anim ~= nil then
            if self.half_kits then
                self:PlayAnimKit(play_anim)
            else
                self:SetAnimation(play_anim)
            end
        end
    end
end

function QuestGiverMixin:setPMUnit(unit, is_dead, npc_name, npc_type)
    -- reset previous model/unit
    self:ClearModel()
    self:RefreshCamera()

    -- set new model/unit
    local scaleFactor = 1.25 -- can we figure this out programmatically without lookups?
    self:SetUnit(unit)
    local creatureID = TutorialHelper:GetCreatureIDFromGUID(UnitGUID(unit))
    local dbg_cid = PKG.QUESTVIEW_DEBUG_CREATURE_ID
    if dbg_cid ~= nil then
        creatureID = dbg_cid
        self:SetCreature(creatureID)
    end
    local fileID = self:GetModelFileID()
    local tweaks = nil
    local tweak_opts = nil
    if creatureID and npc_tweaks[creatureID] then
        tweaks = npc_tweaks[creatureID]
    elseif fileID and model_tweaks[fileID] then
        tweaks = model_tweaks[fileID]
    end
    if tweaks ~= nil and type(tweaks) == 'table' then
        tweak_opts = tweaks
    end
    if tweak_opts ~= nil and tweak_opts['sf'] ~= nil then
        scaleFactor = tweak_opts['sf']
    elseif tweaks ~= nil then
        scaleFactor = tweaks
    end
    local wideModel = false
    if scaleFactor < 0 then
        wideModel = true
        scaleFactor = -scaleFactor
    end

    Debug("NPC:", npc_name, "type:", npc_type, "fileID:", fileID, "creatureID:", creatureID, "is_dead:", is_dead, "sf:", scaleFactor)
    self:InitializeCamera(scaleFactor)

    local offsetX = -110
    local offsetZ = 50
    local pitch = 0.0
    local half_kits = false
    local idle_anim = emotes.Idle
    if wideModel then
        -- static tweak for some big wide models like dragons
        offsetX = 30
    elseif scaleFactor > 2.5 then
        -- static tweak for most smaller models
        offsetZ = 100
    end

    if tweak_opts ~= nil then
        if tweak_opts['offsetX'] ~= nil then
            offsetX = tweak_opts['offsetX']
        end
        if tweak_opts['offsetZ'] ~= nil then
            offsetZ = tweak_opts['offsetZ']
        end
        if tweak_opts['pitch'] ~= nil then
            pitch = tweak_opts['pitch']
        end
        if tweak_opts['half_kits'] ~= nil then
            half_kits = tweak_opts['half_kits']
        end
        if tweak_opts['idle_anim'] ~= nil then
            idle_anim = tweak_opts['idle_anim']
        end
    end

    if is_dead then
        self.idle_anim = emotes.IdleDead
        self.doAnims = false
    elseif idle_anim == -1 then
        self.idle_anim = 0
        self.doAnims = false
    else
        self.idle_anim = idle_anim
        self.doAnims = true
    end
    self.half_kits = half_kits
    self.anim_next = -1
    self.anim_playing = false
    if not self.anim_hooked then
        self:HookScript("OnAnimFinished", self.OnAnimFinished)
        self.anim_hooked = true
    end
    self:SetPitch(pitch)
    self:SetAnimation(self.idle_anim)
    self:SetViewTranslation(offsetX, offsetZ)
end

function QuestGiverMixin:setBoardUnit()
    self:ClearModel()
    self:RefreshCamera()
    self:SetModel(1822634)
    self:InitializeCamera(2.0)
    self:SetPitch(0.0)
    self:SetViewTranslation(-400, 10)
    self.doAnims = false
end

function QuestGiverMixin:SetupModel()
    self:ClearModel()
    self:RefreshCamera()
    self:SetFacing(-0.5)
    self:SetFacingLeft(true)
end
