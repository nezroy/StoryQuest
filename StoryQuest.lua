local _, PKG = ...
local Debug = PKG.Debug

-- global API for this addon
STORYQUEST_ADDON = {}
STORYQUEST_ADDON.VERSION_STRING = "StoryQuest @project-version@"
STORYQUEST_ADDON.VERSION = "@project-version@"

-- setup slash commands
_G["SLASH_STORYQUEST1"] = "/squest"
_G["SLASH_STORYQUEST2"] = "/storyquest"
SlashCmdList["STORYQUEST"] = function(msg)
    local cmd, args = msg:match("^(%S*)%s*(.-)$")
    Debug("slash command:", cmd, "args:", args)
    if cmd == "cid" then
        --PKG.QUESTVIEW_DEBUG_CREATURE_ID = tonumber(args)
    else
        DEFAULT_CHAT_FRAME:AddMessage("StoryQuest: invalid command")
    end
end
