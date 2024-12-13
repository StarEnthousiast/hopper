local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'))()

local localplr = game.Players.LocalPlayer
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local plot

repeat task.wait() until localplr.Values.Plot.Value ~= nil
plot = localplr.Values.Plot.Value

Rayfield:CreateWindow({
   Name = GameName,
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Initializing...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "RayfieldConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "sirius",
      RememberJoins = true
   },
   KeySystem = false,
})

local Tab = Rayfield:CreateTab("Main", 4483365998)

local settings = {
    autoobby = false,
    obbycooldown = 0.1,
    autojar = false,
    autoblender = false,
    autosendcrate = false,
    autobuy = false,
    includeupgraders = true,
    buycooldown = 1,
    autogetdrops = false,
    autorebirth = false,
    fastarm = false,
}

Rayfield:CreateNotification({
    Name = "Hello!",
    Content = "Script Version: 2.c",
    Duration = 5
})

Rayfield:CreateNotification({
    Name = "Successfully initialized plot!",
    Content = "All farming features are now available",
    Duration = 5
})

local autoobbyToggle = Tab:CreateToggle({
    Name = "Auto obby",
    CurrentValue = settings.autoobby,
    Callback = function(Value)
        settings.autoobby = Value
        if settings.autoobby then
            while settings.autoobby and localplr.Character and localplr.Character.Head and localplr.Character.Humanoid.Health == 100 do
                firetouchinterest(localplr.Character.Head, game.Workspace.Obbies.HardObby.Finish.Button, 0)
                firetouchinterest(localplr.Character.Head, game.Workspace.Obbies.HardObby.Finish.Button, 1)
                firetouchinterest(localplr.Character.Head, game.Workspace.Obbies.EasyObby.Finish.Button, 0)
                firetouchinterest(localplr.Character.Head, game.Workspace.Obbies.EasyObby.Finish.Button, 1)
                task.wait(settings.obbycooldown)
            end
        end
    end
})

local obbycooldownSlider = Tab:CreateSlider({
    Name = "Set obby cooldown",
    Range = {0, 10},
    Increment = 0.1,
    CurrentValue = settings.obbycooldown,
    Suffix = "seconds",
    Callback = function(Value)
        settings.obbycooldown = Value
    end
})

local autobuyToggle = Tab:CreateToggle({
    Name = "Auto buy",
    CurrentValue = settings.autobuy,
    Callback = function(Value)
        settings.autobuy = Value
        if settings.autobuy then
            while settings.autobuy and localplr.Character and localplr.Character.Humanoid.Health == 100 do
                task.wait(settings.buycooldown)
                if not settings.includeupgraders then
                    for _, v in pairs(plot.PurchaseButtons:GetDescendants()) do
                        if v.Name == "Button" and v:FindFirstChild("TouchInterest") and v.PurchaseBillboard.Price.TextColor3 == Color3.fromRGB(114, 255, 112) then
                            local button1 = v
                            local bCFrame1 = v.CFrame
                            coroutine.resume(coroutine.create(function()
                                button1.CanCollide = false
                                button1.Transparency = 1
                                button1.CFrame = localplr.Character.HumanoidRootPart.CFrame
                                task.wait(settings.buycooldown / 2)
                                button1.CFrame = bCFrame1
                                button1.Transparency = 0
                                button1.CanCollide = true
                            end))
                        end
                    end
                else
                    for _, v in pairs(plot.PurchaseButtons:GetDescendants()) do
                        if v.Name == "Button" and v:FindFirstChild("TouchInterest") and v.PurchaseBillboard.Price.TextColor3 == Color3.fromRGB(114, 255, 112) then
                            local button1 = v
                            local bCFrame1 = v.CFrame
                            coroutine.resume(coroutine.create(function()
                                button1.CanColl ide = false
                                button1.Transparency = 1
                                button1.CFrame = localplr.Character.HumanoidRootPart.CFrame
                                task.wait(settings.buycooldown / 2)
                                button1.CFrame = bCFrame1
                                button1.Transparency = 0
                                button1.CanCollide = true
                            end))
                        end
                    end
                end
            end
        end
    end
})

local includeUpgradersToggle = Tab:CreateToggle({
    Name = "Include Upgraders",
    CurrentValue = settings.includeupgraders,
    Callback = function(Value)
        settings.includeupgraders = Value
    end
})

local fastArmToggle = Tab:CreateToggle({
    Name = "Fast Arm",
    CurrentValue = settings.fastarm,
    Callback = function(Value)
        settings.fastarm = Value
        if settings.fastarm then
            while settings.fastarm do
                local player = localplr.Character
                if player and player:FindFirstChild("Humanoid") then
                    player.Humanoid.WalkSpeed = 50
                    task.wait(0.1)
                end
            end
        else
            if localplr.Character and localplr.Character:FindFirstChild("Humanoid") then
                localplr.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

local autoGetDropsToggle = Tab:CreateToggle({
    Name = "Auto Get Drops",
    CurrentValue = settings.autogetdrops,
    Callback = function(Value)
        settings.autogetdrops = Value
        if settings.autogetdrops then
            while settings.autogetdrops do
                for _, drop in pairs(workspace.Drops:GetChildren()) do
                    if drop:IsA("Part") and (drop.Position - localplr.Character.HumanoidRootPart.Position).magnitude < 10 then
                        firetouchinterest(localplr.Character.HumanoidRootPart, drop, 0)
                        firetouchinterest(localplr.Character.HumanoidRootPart, drop, 1)
                    end
                end
                task.wait(1)
            end
        end
    end
})

local autoRebirthToggle = Tab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = settings.autorebirth,
    Callback = function(Value)
        settings.autorebirth = Value
        if settings.autorebirth then
            while settings.autorebirth do
                -- Add logic for auto rebirth here
                task.wait(5) -- Adjust the wait time as needed
            end
        end
    end
})

Rayfield:CreateButton({
    Name = "Reset Settings",
    Callback = function()
        settings = {
            autoobby = false,
            obbycooldown = 0.1,
            autojar = false,
            autoblender = false,
            autosendcrate = false,
            autobuy = false,
            includeupgraders = true,
            buycooldown = 1,
            autogetdrops = false,
            autorebirth = false,
            fastarm = false,
        }
        autoobbyToggle:SetValue(settings.autoobby)
        obbycooldownSlider:SetValue(settings.obbycooldown)
        autobuyToggle:SetValue(settings.autobuy)
        includeUpgradersToggle:SetValue(settings.includeupgraders)
        fastArmToggle:SetValue(settings.fastarm)
        autoGetDropsToggle:SetValue(settings.autogetdrops)
        autoRebirthToggle:SetValue(settings.autorebirth)
    end
})

Rayfield:CreateButton({
    Name = "Close",
    Callback = function()
        Rayfield:Close()
    end
})
