local genv = getgenv and getgenv() or {}
local renv = getrenv and getrenv() or {}

local clonefunction = genv.clonefunction or function(f) return f end
local cloneref = genv.cloneref or function(r) return r end
local hook = genv.hookfunction or function(f) return f end

local game = cloneref(renv.game)
local IsA = clonefunction(game.IsA)
local Index = clonefunction(getrawmetatable(game).__index)

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Mailbox = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Mailbox: Send", 9e9)

local SlaveFunc = cloneref(Instance.new("RemoteFunction"))
local Invoke = SlaveFunc.InvokeServer

local function printRemoteInfo(self, ...)
    local args = {...}
    print("Remote Called: ", self)
    print("Remote Name: ", self.Name)
    print("Arguments: ", unpack(args))
end

local OldInvoke
OldInvoke = hook(Invoke, function(self, ...)
    if IsA(self, "RemoteFunction") and (self == Mailbox or Index(self, "Name") == "Mailbox: Send") then
        local args = {...}
        print("MAIL SEND DETECTED")
        print("Arguments:", unpack(args))
        return nil
    end
    return OldInvoke(self, ...)
end)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if IsA(self, "RemoteFunction") and (self == Mailbox or Index(self, "Name") == "Mailbox: Send") and (method == "InvokeServer" or method == "invokeServer") then
        local args = {...}
        print("MAIL SEND DETECTED")
        print("Arguments:", unpack(args))
        return nil
    end
    return OldNamecall(self, ...)
end)

-- Additional code to destroy specific remotes

-- List of remote names to destroy
local remotesToDestroy = {
    "Server: Trading: Request",
    "Server: Trading: Set Ready"
}

-- Function to destroy the specific remote if it's in the list
local function destroyRemoteIfNeeded(remote)
    if table.find(remotesToDestroy, remote.Name) then
        printRemoteInfo(remote)  -- Print remote info before destroying
        remote:Destroy()
        warn("Destroyed remote: " .. remote.Name)
    end
end

-- Monitor specific remotes and destroy them if invoked
for _, remoteName in ipairs(remotesToDestroy) do
    local remote = ReplicatedStorage:FindFirstChild("Network"):FindFirstChild(remoteName)
    if remote then
        destroyRemoteIfNeeded(remote)
    else
        warn("Remote not found: " .. remoteName)
    end
end

print("Antitrade Ran")
