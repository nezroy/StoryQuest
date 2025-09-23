local _, PKG = ...
local Debug = PKG.Debug

local model_tweaks = PKG.QUESTVIEW_MODEL_TWEAKS
local npc_tweaks = PKG.QUESTVIEW_NPC_TWEAKS
local emotes = PKG.QUESTVIEW_EMOTES
local board_types = PKG.QUESTVIEW_BOARD_TYPES

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
        if not self.half_kits and self.idle_anim ~= -1 then
            self:SetAnimation(self.idle_anim)
        end
    end
end

function QuestGiverMixin:setQuestGiverAnimation(count, qString, qStringInt)
    if qString == nil or qString[qStringInt] == nil then
        return
    end

    if not self.is_loaded or not self.doAnims then
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

local function getCreatureIDFromGUID(guid)
	return tonumber(string.match(guid, "Creature%-.-%-.-%-.-%-.-%-(.-)%-"));
end

function QuestGiverMixin:setQuestUnit(npc_name, npc_type)
    self.is_clear = false

    local unit = "questnpc"
    self.is_dead = UnitIsDead(unit) and true or false
    self.npc_name = npc_name
    self.npc_type = npc_type

    -- set new model/unit
    self.creature_id = getCreatureIDFromGUID(UnitGUID(unit))
    --local cid = self.creature_id
    local dbg_cid = PKG.QUESTVIEW_DEBUG_CREATURE_ID
    if dbg_cid ~= nil then
        self.creature_id = dbg_cid
        self:SetCreature(dbg_cid)
    else
        -- we do this solely to get equipped weapon; otherwise we could just set by creature ID
        self:SetUnit("questnpc")
    end
end

function QuestGiverMixin:OnModelLoaded()
    if self.is_clear then
        return
    end
    local scaleFactor = 1.25 -- can we figure this out programmatically without lookups?
    local fileID = self.file_id ~= nil and self.file_id or self:GetModelFileID()
    local tweaks = nil
    local tweak_opts = nil
    local creatureID = self.creature_id
    local npc_name = self.npc_name
    local npc_type = self.npc_type
    local is_dead = self.is_dead

    if creatureID and npc_tweaks[creatureID] then
        tweaks = npc_tweaks[creatureID]
    elseif fileID and model_tweaks[fileID] then
        tweaks = model_tweaks[fileID]
    end
    if tweaks ~= nil and type(tweaks) == 'table' then
        tweak_opts = tweaks
    end
    if tweak_opts ~= nil then
        if tweak_opts['sf'] ~= nil then
            scaleFactor = tweak_opts['sf']
        end
    elseif tweaks ~= nil then
        scaleFactor = tweaks
    end

    Debug("NPC:", npc_name, "type:", npc_type, "fileID:", fileID, "creatureID:", creatureID, "is_dead:", is_dead, "sf:", scaleFactor)
    self:InitializeCamera(scaleFactor)

    local offsetX = -110
    local offsetZ = 50
    local pitch = 0.0
    local facing = -0.5
    self.idle_anim = emotes.Idle

    if tweak_opts ~= nil then
        if tweak_opts.x ~= nil then
            offsetX = tweak_opts.x
        end
        if tweak_opts.z ~= nil then
            offsetZ = tweak_opts.z
        end
        if tweak_opts.p ~= nil then
            pitch = tweak_opts.p
        end
        if tweak_opts.f ~= nil then
            facing = tweak_opts.f
        end
        if tweak_opts.ia ~= nil then
            self.idle_anim = tweak_opts.ia
        end
        if tweak_opts.hk ~= nil then
            self.half_kits = tweak_opts.hk
        end
    end

    if is_dead then
        self.idle_anim = emotes.IdleDead
        self.doAnims = false
    else
        self.doAnims = self.idle_anim ~= -1 and true or false
    end
    self:SetPitch(pitch)
    self:SetFacing(facing)
    if self.idle_anim ~= -1 then
        self:SetAnimation(self.idle_anim)
    end
    self:SetViewTranslation(offsetX, offsetZ)

    self.is_loaded = true
    self.FadeIn:Play()
end

function QuestGiverMixin:setBoardUnit(board_type)
    Debug("set board type:", board_type)
    self.is_clear = false
    if board_types[board_type] ~= nil then
        self.file_id = board_types[board_type]
    else
        self.file_id = board_types["genericplayerchoice"]
    end
    self:SetModel(self.file_id)
end

function QuestGiverMixin:SetupModel()
    self:ClearAll()
    self:SetFacingLeft(true)
end

function QuestGiverMixin:OnHide()
    self:ClearAll()
end

function QuestGiverMixin:ClearAll()
    Debug("doing ClearAll")
    self:SetUnit("none")
    self:SetCreature(0)
    self:SetAlpha(0)
    self:ClearModel()

    self.npc_name = nil
    self.npc_type = nil
    self.is_dead = nil
    self.creature_id = 0
    self.file_id = nil
    self.do_anims = false
    self.idle_anim = emotes.Idle
    self.half_kits = false
    self.anim_next = -1
    self.anim_playing = false
    self.is_clear = true
    self.is_loaded = false

    self:SetPosition(0, 0, 0)
    self:SetRoll(0)
    self:SetFacing(0)
    self:SetPitch(0)
    self:ClearTransform()

    self:SetCameraTarget(0, 0, 0)
    self:SetCameraPosition(0, 0, 0)
end
