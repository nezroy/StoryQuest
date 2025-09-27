local _, PKG = ...
local Debug = PKG.Debug

local model_tweaks = PKG.MODEL_TWEAKS
local npc_tweaks = PKG.NPC_TWEAKS
local emotes = PKG.EMOTES
local board_types = PKG.BOARD_TYPES

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

function QuestGiverMixin:SetQuestUnit(creature_id, display_id)
    self.is_clear = false

    -- SetCreature/SetUnit will immediately call OnModelLoaded if there
    -- is no load delay, BEFORE completing execution here
    if creature_id ~= nil then
        self.creature_id = creature_id
        self:SetCreature(creature_id, display_id or 0)
        return true
    else
        -- we do it this way to get equipped weapon; otherwise we could just set by creature ID
        self.creature_id = getCreatureIDFromGUID(UnitGUID("questnpc"))
        local did_set_unit = self:SetUnit("questnpc")
        if not did_set_unit then
            self.creature_id = 0
        end
        return did_set_unit
    end
end

function QuestGiverMixin:OnModelLoaded()
    if self.is_clear then
        return
    end
    local fileID = self.file_id ~= nil and self.file_id or self:GetModelFileID()
    local tweaks = nil
    local tweak_opts = nil
    local creatureID = self.creature_id

    local sf = 1.0
    local z = 60
    local x = -100
    local p = 0.0
    local f = -0.5

    if creatureID and npc_tweaks[creatureID] then
        tweaks = npc_tweaks[creatureID]
    elseif fileID and model_tweaks[fileID] then
        tweaks = model_tweaks[fileID]
    end
    if tweaks ~= nil and type(tweaks) == 'table' then
        tweak_opts = tweaks
    end
    local mod_sf = -20 -- default if not changed results in sf of 1.25
    if tweak_opts ~= nil then
        if tweak_opts['sf'] ~= nil then
            mod_sf = tweak_opts['sf']
        end
    elseif tweaks ~= nil then
        mod_sf = tweaks
    end
    sf = sf * (1/((100 + mod_sf)/100))

    Debug("giver model - fileID:", fileID, "| creatureID:", creatureID, "| sf:", sf, "| dID:", self:GetDisplayInfo())
    self:InitializeCamera(sf)

    self.idle_anim = emotes.Idle

    if tweak_opts ~= nil then
        if tweak_opts.x then
            x = x + tweak_opts.x
        end
        if tweak_opts.z then
            z = z + tweak_opts.z
        end
        if tweak_opts.p ~= nil then
            p = tweak_opts.p
        end
        if tweak_opts.f ~= nil then
            f = tweak_opts.f
        end
        if tweak_opts.ia ~= nil then
            self.idle_anim = tweak_opts.ia
        end
        if tweak_opts.hk ~= nil then
            self.half_kits = tweak_opts.hk
        end
    end

    self.doAnims = self.idle_anim ~= -1 and true or false
    self:SetPitch(p)
    self:SetFacing(f)
    if self.idle_anim ~= -1 then
        self:SetAnimation(self.idle_anim)
    end
    self:SetViewTranslation(x, z)

    self.is_loaded = true
    self.FadeIn:Play()
end

function QuestGiverMixin:SetBoardUnit(board_type)
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
    self.creature_id = 0
    self.file_id = nil
    self.do_anims = false
    self.idle_anim = emotes.Idle
    self.half_kits = false
    self.anim_next = -1
    self.anim_playing = false
    self.is_clear = true
    self.is_loaded = false

    self:SetUnit("none")
    self:SetCreature(0)
    self:SetAlpha(0)
    self:ClearModel()

    self:SetPosition(0, 0, 0)
    self:SetRoll(0)
    self:SetFacing(0)
    self:SetPitch(0)
    self:ClearTransform()

    self:SetCameraTarget(0, 0, 0)
    self:SetCameraPosition(0, 0, 0)
end
