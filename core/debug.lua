local _, PKG = ...

local D = DLAPI

local function Debug(...)
    local msg = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        msg = msg .. tostring(arg) .. " "
    end
    D.DebugLog("StoryQuest", "%s", msg)
end

local function Trace()
    D.DebugLog("SQTrace", "%s", "------------------------- Trace -------------------------")
    for i,v in ipairs({("\n"):split(debugstack(2))}) do
        if v ~= "" then
            D.DebugLog("SQTrace", "%d: %s", i, v)
        end
    end
    D.DebugLog("SQTrace", "%s", "---------------------------------------------------------")
end

local function EmptyFunc()
end

if D then
    PKG.Debug = Debug
    PKG.Trace = Trace
    PKG.inDebug = true
    C_CVar.SetCVar("fstack_preferParentKeys", "0")
    Debug("debug log initialized")
else
    PKG.Debug = EmptyFunc
    PKG.Trace = EmptyFunc
    PKG.inDebug = false
end
