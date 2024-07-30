local cubeNames = {
    "Luck Cube",
    "Speed Cube",
    "Inferno Cube",
    "Glitch Cube",
    "Haste Cube",
    "Fortune Cube",
    "Pastel Cube",
    "Golden Cube",
    "Wealth Cube",
    "Spore Blossom",
    "Technosphere",
    "Event Horizon",
    "Stellar Nebula"
}

local cubeColors = {
    ["Luck Cube"] = "#05ff3b",
    ["Speed Cube"] = "#6397ff",
    ["Inferno Cube"] = "#fc6330",
    ["Glitch Cube"] = "#440345",
    ["Haste Cube"] = "#0558ff",
    ["Fortune Cube"] = "#288000",
    ["Pastel Cube"] = "#cc96ff",
    ["Golden Cube"] = "#fab546",
    ["Wealth Cube"] = "#ffec59",
    ["Spore Blossom"] = "#ed4aff",
    ["Technosphere"] = "#5c4aff",
    ["Event Horizon"] = "#6854ff",
    ["Stellar Nebula"] = "#ffffff"
}

local notifiedCubes = {}
local webhookUrl = 'https://discord.com/api/webhooks/1267509979179384904/Rjbr-dhjFDs6t-e6RaEyBqeBrsCPWs7vMNXwf-qyD6kMCrdyv03s1Mzxxhc_oA6zK2xd'
local userId = '370943880767471617'
local notificationCooldown = 0.86 -- seconds

local function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

local function RGBToDecimal(r, g, b)
    return (r * 256 * 256) + (g * 256) + b
end

local function sendDiscordNotification(cubeName)
    local currentTime = tick()

    if notifiedCubes[cubeName] and currentTime - notifiedCubes[cubeName] < notificationCooldown then
        return
    end

    notifiedCubes[cubeName] = currentTime

    local OSTime = os.time()
    local Time = os.date('!*t', OSTime)
    local Avatar = 'https://cdn.discordapp.com/embed/avatars/4.png'
    local colorHex = cubeColors[cubeName] or "#1F40FF" -- default color if not found
    local r, g, b = hexToRGB(colorHex)
    local Embed = {
        title = 'Tycoon RNG',
        color = RGBToDecimal(r, g, b),
        footer = { text = game.JobId },
        fields = {
            {
                name = cubeName, -- Collected cube Name
                value = 'collected'
            }
        },
        timestamp = string.format('%d-%d-%dT%02d:%02d:%02dZ', Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
    }

    if cubeName == "Stellar Nebula" or cubeName == "Event Horizon" or cubeName == "Technosphere" or cubeName == "Spore Blossom" then
        table.insert(Embed.fields, {
            name = "User",
            value = "<@"..userId..">"
        })
    end

    (syn and syn.request or http_request) {
        Url = webhookUrl, -- Use the updated webhook URL
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = game:GetService('HttpService'):JSONEncode({ embeds = { Embed } })
    }
end

local function sendMeteorNotification(rarity)
    local OSTime = os.time()
    local Time = os.date('!*t', OSTime)
    local Avatar = 'https://cdn.discordapp.com/embed/avatars/4.png'
    local Embed = {
        title = 'Tycoon RNG',
        color = '99999',
        footer = { text = game.JobId },
        fields = {
            {
                name = 'Meteor',
                value = rarity .. ' dropped.'
            }
        },
        timestamp = string.format('%d-%d-%dT%02d:%02d:%02dZ', Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
    }
    (syn and syn.request or http_request) {
        Url = 'https://discord.com/api/webhooks/1267509979179384904/Rjbr-dhjFDs6t-e6RaEyBqeBrsCPWs7vMNXwf-qyD6kMCrdyv03s1Mzxxhc_oA6zK2xd',
        Method = 'POST',
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = game:GetService('HttpService'):JSONEncode({ embeds = { Embed } })
    }
end

local function teleportPlayer()
    local player = game.Players.LocalPlayer

    if player and player.Character then
        local character = player.Character

        for _, cubeName in ipairs(cubeNames) do
            local cubeModel = game.Workspace:FindFirstChild(cubeName)

            if cubeModel and cubeModel:IsA("Model") then
                local modelCenter = cubeModel:GetModelCFrame().p
                character:SetPrimaryPartCFrame(CFrame.new(modelCenter))
                sendDiscordNotification(cubeName) -- Send notification when teleporting to the cube
                break
            end
        end
    else
        print("Player or their character not found.")
    end
end
teleportPlayer()
local function fireTouchDetectors()
    for _, cubeName in ipairs(cubeNames) do
        local cubeModel = game.Workspace:FindFirstChild(cubeName)

        if cubeModel and cubeModel:IsA("Model") then
            for _, child in ipairs(cubeModel:GetDescendants()) do
                if child:IsA("TouchTransmitter") then
                    firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, child.Parent, 0)
                    firetouchinterest(game.Players.LocalPlayer.Character.PrimaryPart, child.Parent, 1)
                    sendDiscordNotification(cubeName) -- Send notification for each collected cube
                end
            end
        end
    end
end

local function createGui()
    if game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("TeleportGui") then
        return -- GUI already exists, so we return to avoid creating it again
    end

    local ScreenGui = Instance.new("ScreenGui")
    local MenuFrame = Instance.new("Frame")
    local ToggleButtonFrame = Instance.new("Frame")
    local ToggleButton = Instance.new("TextButton")
    local FireTouchDetectorsFrame = Instance.new("Frame")
    local FireTouchDetectorsButton = Instance.new("TextButton")
    local CollapseButton = Instance.new("TextButton")
    local AntiAfkButton = Instance.new("TextButton")
    local LoadingFrame = Instance.new("Frame")
    local LoadingBar = Instance.new("Frame")
    local TpCubesLabel = Instance.new("TextLabel")
    local BringCubesLabel = Instance.new("TextLabel")
    local WebhookTextBox = Instance.new("TextBox")
    local UserIdTextBox = Instance.new("TextBox") -- New User ID TextBox
    local CubeCountLabel = Instance.new("TextLabel") -- Added for cube count display

    ScreenGui.Name = "TeleportGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    ScreenGui.DisplayOrder = 1000

    LoadingFrame.Size = UDim2.new(0, 150, 0, 50)
    LoadingFrame.Position = UDim2.new(0.5, -75, 0.5, 20)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    LoadingFrame.BackgroundTransparency = 0.3
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.Parent = ScreenGui

    local LoadingUICorner = Instance.new("UICorner")
    LoadingUICorner.CornerRadius = UDim.new(0.1, 0)
    LoadingUICorner.Parent = LoadingFrame

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Text = "Loading"
    LoadingText.Size = UDim2.new(1, 0, 1, -10)
    LoadingText.Position = UDim2.new(0, 0, 0, 0)
    LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Parent = LoadingFrame

    LoadingBar.Size = UDim2.new(0, 0, 0, 5)
    LoadingBar.Position = UDim2.new(0, 0, 1, -5)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
    LoadingBar.Parent = LoadingFrame

    local LoadingBarUICorner = Instance.new("UICorner")
    LoadingBarUICorner.CornerRadius = UDim.new(0.5, 0)  -- Fully rounded
    LoadingBarUICorner.Parent = LoadingBar

    local progressTween = game:GetService("TweenService"):Create(LoadingBar, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, 5)})
    progressTween:Play()

    wait(2.5)
    LoadingFrame:Destroy()

    MenuFrame.Size = UDim2.new(0, 320, 0, 270) -- Increased height by 50 to accommodate new text box
    MenuFrame.Position = UDim2.new(0.5, -100, 0.5, -135)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MenuFrame.BackgroundTransparency = 0.8
    MenuFrame.BorderSizePixel = 0
    MenuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MenuFrame.Draggable = true
    MenuFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.1, 0)
    UICorner.Parent = MenuFrame

    TpCubesLabel.Size = UDim2.new(0, 51, 0, 7)
    TpCubesLabel.Position = UDim2.new(0.5, -130, 0.5, -82)
    TpCubesLabel.BackgroundTransparency = 1
    TpCubesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TpCubesLabel.Text = "TP to Cubes"
    TpCubesLabel.TextScaled = true
    TpCubesLabel.Parent = MenuFrame

    ToggleButtonFrame.Size = UDim2.new(0, 100, 0, 40)
    ToggleButtonFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
    ToggleButtonFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    ToggleButtonFrame.Parent = MenuFrame

    local ButtonFrameUICorner = Instance.new("UICorner")
    ButtonFrameUICorner.CornerRadius = UDim.new(0.2, 0)
    ButtonFrameUICorner.Parent = ToggleButtonFrame

    ToggleButton.Size = UDim2.new(0.5, -5, 1, -10)
    ToggleButton.Position = UDim2.new(0, 5, 0, 5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    ToggleButton.Text = "Off"
    ToggleButton.Parent = ToggleButtonFrame

    local ButtonUICorner = Instance.new("UICorner")
    ButtonUICorner.CornerRadius = UDim.new(0.1, 0)
    ButtonUICorner.Parent = ToggleButton

    BringCubesLabel.Size = UDim2.new(0, 52, 0, 10)
    BringCubesLabel.Position = UDim2.new(0.5, -130, 0.5, -25)
    BringCubesLabel.BackgroundTransparency = 1
    BringCubesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    BringCubesLabel.Text = "Bring Cubes"
    BringCubesLabel.TextScaled = true
    BringCubesLabel.Parent = MenuFrame

    WebhookTextBox.Size = UDim2.new(0.5, 0, 0.10, 0)
    WebhookTextBox.Position = UDim2.new(0.45, 0, 0.925, -180)
    WebhookTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    WebhookTextBox.Text = "Enter webhook URL"
    WebhookTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    WebhookTextBox.ClearTextOnFocus = true
    WebhookTextBox.TextWrapped = true
    WebhookTextBox.Parent = MenuFrame

    local WebhookTextBoxUICorner = Instance.new("UICorner")
    WebhookTextBoxUICorner.CornerRadius = UDim.new(0.1, 0)
    WebhookTextBoxUICorner.Parent = WebhookTextBox

    WebhookTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            webhookUrl = WebhookTextBox.Text
            WebhookTextBox.Text = "Webhook URL Set"
        end
    end)

    UserIdTextBox.Size = UDim2.new(0.5, 0, 0.10, 0)
    UserIdTextBox.Position = UDim2.new(0.45, 0, 1.14, -180) -- Position below the WebhookTextBox
    UserIdTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    UserIdTextBox.Text = "Enter User ID"
    UserIdTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    UserIdTextBox.ClearTextOnFocus = true
    UserIdTextBox.TextWrapped = true
    UserIdTextBox.Parent = MenuFrame

    local UserIdTextBoxUICorner = Instance.new("UICorner")
    UserIdTextBoxUICorner.CornerRadius = UDim.new(0.1, 0)
    UserIdTextBoxUICorner.Parent = UserIdTextBox

    UserIdTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            userId = UserIdTextBox.Text
            UserIdTextBox.Text = "User ID Set"
        end
    end)

    FireTouchDetectorsFrame.Size = UDim2.new(0, 100, 0, 40)
    FireTouchDetectorsFrame.Position = UDim2.new(0.5, -130, 0.5, -13)
    FireTouchDetectorsFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    FireTouchDetectorsFrame.Parent = MenuFrame

    local FireTouchDetectorsFrameUICorner = Instance.new("UICorner")
    FireTouchDetectorsFrameUICorner.CornerRadius = UDim.new(0.2, 0)
    FireTouchDetectorsFrameUICorner.Parent = FireTouchDetectorsFrame

    FireTouchDetectorsButton.Size = UDim2.new(0.5, -5, 1, -10)
    FireTouchDetectorsButton.Position = UDim2.new(0, 5, 0, 5)
    FireTouchDetectorsButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    FireTouchDetectorsButton.Text = "Off"
    FireTouchDetectorsButton.Parent = FireTouchDetectorsFrame

    local FireTouchDetectorsButtonUICorner = Instance.new("UICorner")
    FireTouchDetectorsButtonUICorner.CornerRadius = UDim.new(0.1, 0)
    FireTouchDetectorsButtonUICorner.Parent = FireTouchDetectorsButton

    AntiAfkButton.Size = UDim2.new(0, 100, 0, 20)
    AntiAfkButton.Position = UDim2.new(0.5, -130, 1, -30)
    AntiAfkButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    AntiAfkButton.Text = "Anti AFK: Off"
    AntiAfkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AntiAfkButton.Parent = MenuFrame

    local AntiAfkUICorner = Instance.new("UICorner")
    AntiAfkUICorner.CornerRadius = UDim.new(0.1, 0)
    AntiAfkUICorner.Parent = AntiAfkButton

    CollapseButton.Size = UDim2.new(0, 50, 0, 30)
    CollapseButton.Position = UDim2.new(0.5, -25, 0, 10)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CollapseButton.BackgroundTransparency = 0
    CollapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CollapseButton.Text = "X"
    CollapseButton.AnchorPoint = Vector2.new(0.5, 0)
    CollapseButton.Parent = ScreenGui

    local CollapseButtonUICorner = Instance.new("UICorner")
    CollapseButtonUICorner.CornerRadius = UDim.new(0.1, 0)
    CollapseButtonUICorner.Parent = CollapseButton

    local UIS = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos
    local guiCollapsed = false

    local initialMenuFrameSize = MenuFrame.Size
    local initialMenuFramePosition = MenuFrame.Position

    local function update(input)
        local delta = input.Position - dragStart
        MenuFrame:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), "Out", "Quad", 0.2, true)
    end

    MenuFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MenuFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MenuFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local initialPosition
	

    local function toggleTeleport()
        teleporting = not teleporting

        if teleporting then
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character.PrimaryPart then
                initialPosition = player.Character.PrimaryPart.Position
            end

            ToggleButton:TweenSizeAndPosition(UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), "Out", "Quad", 0.2, true)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            ToggleButton.Text = "On"
            teleportConnection = game:GetService("RunService").Stepped:Connect(function()
                teleportPlayer()
                wait(0.2)
            end)
        else
            ToggleButton:TweenSizeAndPosition(UDim2.new(0.5, -5, 1, -10), UDim2.new(0, 5, 0, 5), "Out", "Quad", 0.2, true)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
            ToggleButton.Text = "Off"
            if teleportConnection then
                teleportConnection:Disconnect()
            end

            if initialPosition then
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    local character = player.Character
                    character:SetPrimaryPartCFrame(CFrame.new(initialPosition))
                end
            end
        end
    end

    local function toggleFireTouchDetectors()
        fireTouchEnabled = not fireTouchEnabled

        if fireTouchEnabled then
            FireTouchDetectorsButton:TweenSizeAndPosition(UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), "Out", "Quad", 0.2, true)
            FireTouchDetectorsButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            FireTouchDetectorsButton.Text = "On"
            fireTouchConnection = game:GetService("RunService").Stepped:Connect(function()
                fireTouchDetectors()
                wait(1.5)
            end)
        else
            FireTouchDetectorsButton:TweenSizeAndPosition(UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), "Out", "Quad", 0.2, true)
            FireTouchDetectorsButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            FireTouchDetectorsButton.Text = "On"
            fireTouchConnection = game:GetService("RunService").Stepped:Connect(function()
                fireTouchDetectors()
                wait(1.5)
            end)
        end
    end

    local function toggleAntiAfk()
        antiAfkEnabled = not antiAfkEnabled

        if antiAfkEnabled then
            AntiAfkButton.Text = "Anti AFK: On"
            antiAfkConnection = game:GetService("RunService").Stepped:Connect(function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()

                local function simulateMovement()
                    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                    if humanoidRootPart then
                        local initialPosition = humanoidRootPart.Position
                        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0.091, -0.082) -- Move back
                        wait(0.05)
                        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 0.082) -- Move forward
                    end
                end

                simulateMovement()
                wait(60)
            end)
        else
            AntiAfkButton.Text = "Anti AFK: Off"
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
            end
        end
    end

    ToggleButton.MouseButton1Click:Connect(toggleTeleport)
    FireTouchDetectorsButton.MouseButton1Click:Connect(toggleFireTouchDetectors)
    AntiAfkButton.MouseButton1Click:Connect(toggleAntiAfk)

    CollapseButton.MouseButton1Click:Connect(function()
        guiCollapsed = not guiCollapsed
        if guiCollapsed then
            MenuFrame:TweenSizeAndPosition(UDim2.new(0, 200, 0, 0), UDim2.new(0.5, -100, 0.5, -130), "Out", "Quad", 0.2, true)
            ToggleButtonFrame:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.2, true)
            ToggleButton:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, true, function()
                ToggleButton.Visible = false
            end)
            FireTouchDetectorsFrame:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.2, true, function()
                FireTouchDetectorsButton.Visible = false
            end)
            AntiAfkButton:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, true, function()
                AntiAfkButton.Visible = false
            end)
            TpCubesLabel.Visible = false
            BringCubesLabel.Visible = false
            WebhookTextBox.Visible = false
            UserIdTextBox.Visible = false -- Hide UserIdTextBox
            CubeCountLabel.Visible = false -- Hide CubeCountLabel
            CollapseButton.Text = ">"
        else
            ToggleButton.Visible = true
            FireTouchDetectorsButton.Visible = true
            AntiAfkButton.Visible = true
            TpCubesLabel.Visible = true
            BringCubesLabel.Visible = true
            WebhookTextBox.Visible = true
            UserIdTextBox.Visible = true -- Show UserIdTextBox
            CubeCountLabel.Visible = true -- Show CubeCountLabel
            MenuFrame:TweenSizeAndPosition(initialMenuFrameSize, initialMenuFramePosition, "Out", "Quad", 0.2, true)
            ToggleButtonFrame:TweenSizeAndPosition(UDim2.new(0, 100, 0, 40), UDim2.new(0.5, -130, 0.5, -70), "Out", "Quad", 0.2, true)
            ToggleButton:TweenSize(UDim2.new(0.5, -5, 1, -10), "Out", "Quad", 0.2, true)
            FireTouchDetectorsFrame:TweenSizeAndPosition(UDim2.new(0, 100, 0, 40), UDim2.new(0.5, -130, 0.5, -13), "Out", "Quad", 0.2, true)
            FireTouchDetectorsButton:TweenSize(UDim2.new(0.5, -5, 1, -10), "Out", "Quad", 0.2, true)
            AntiAfkButton:TweenSize(UDim2.new(0, 100, 0, 20), "Out", "Quad", 0.2, true)
            CollapseButton.Text = "X"
        end
    end)

    local function showClosingMessage()
        local message = Instance.new("TextLabel")
        message.Text = "Closing... Bye!"
        message.Size = UDim2.new(0, 200, 0, 50)
        message.Position = UDim2.new(1, -210, 1, -60)
        message.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        message.TextColor3 = Color3.fromRGB(255, 255, 255)
        message.TextScaled = true
        message.BackgroundTransparency = 0.5
        message.Parent = ScreenGui

        local messageUICorner = Instance.new("UICorner")
        messageUICorner.CornerRadius = UDim.new(0.1, 0)
        messageUICorner.Parent = message

        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 0, 5)
        progressBar.Position = UDim2.new(0, 0, 1, -5)
        progressBar.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        progressBar.Parent = message

        local progressBarUICorner = Instance.new("UICorner")
        progressBarUICorner.CornerRadius = UDim.new(0.5, 0)  -- Fully rounded
        progressBarUICorner.Parent = progressBar

        local progressTween = game:GetService("TweenService"):Create(progressBar, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 5)})
        progressTween:Play()

        message:TweenPosition(UDim2.new(1, -210, 1, -110), "Out", "Quad", 0.5, true)
        game:GetService("TweenService"):Create(message, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, TextTransparency = 0.5}):Play()

        wait(1.02)

        game:GetService("TweenService"):Create(message, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        wait(1.02)
        message:Destroy()
    end

    local function removeGui()
        if teleporting then
            teleporting = false
            if teleportConnection then
                teleportConnection:Disconnect()
            end
            if initialPosition then
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    local character = player.Character
                    character:SetPrimaryPartCFrame(CFrame.new(initialPosition))
                end
            end
        end

        if antiAfkEnabled then
            antiAfkEnabled = false
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
            end
        end

        if fireTouchEnabled then
            fireTouchEnabled = false
            if fireTouchConnection then
                fireTouchConnection:Disconnect()
            end
        end

        showClosingMessage()
        wait(0.2)

        MenuFrame:TweenSizeAndPosition(UDim2.new(0, 200, 0, 0), UDim2.new(0.5, -100, 0.5, -130), "Out", "Quad", 0.5, true)
        game:GetService("TweenService"):Create(MenuFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        ToggleButtonFrame:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.5, true)
        game:GetService("TweenService"):Create(ToggleButtonFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        game:GetService("TweenService"):Create(CollapseButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        wait(0.5)
        ScreenGui:Destroy()
    end

    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.L then
            removeGui()
        end
    end)

    MenuFrame.BackgroundTransparency = 1
    local fadeInTween = game:GetService("TweenService"):Create(MenuFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3})
    fadeInTween:Play()

    -- Adding Cube Count Label
    CubeCountLabel.Size = UDim2.new(0, 120, 0, 15)
    CubeCountLabel.Position = UDim2.new(1, -160, 0, 5)
    CubeCountLabel.BackgroundTransparency = 1
    CubeCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CubeCountLabel.Text = "Amount RN: 0"
    CubeCountLabel.TextScaled = true
    CubeCountLabel.Parent = MenuFrame

    -- Function to count the cubes
    local function updateCubeCount()
        local count = 0
        for _, cubeName in ipairs(cubeNames) do
            if game.Workspace:FindFirstChild(cubeName) then
                count = count + 1
            end
        end
        CubeCountLabel.Text = "Amount RN: " .. count
    end

    -- Update the cube count periodically
    spawn(function()
        while true do
            updateCubeCount()
            wait(1)
        end
    end)
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(1)
        createGui()
    end)
end)

if game.Players.LocalPlayer and game.Players.LocalPlayer.Character then
    createGui()
else
    game.Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        createGui()
    end)
end

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local function simulateMovement()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        local initialPosition = humanoidRootPart.Position
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -0.3)  -- Move back
        wait(3)
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 0.3)   -- Move forward
    end
end

while true do
    simulateMovement()
    wait(60)
end
