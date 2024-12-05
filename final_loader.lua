local function startScript()
    -- Wait for game to load
    if not game:IsLoaded() then 
        game.Loaded:Wait() 
    end

    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    -- Locals
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- UI Colors
    local Colors = {
        Background = Color3.fromRGB(25, 25, 25),
        DarkContrast = Color3.fromRGB(20, 20, 20),
        Container = Color3.fromRGB(30, 30, 30),
        TextColor = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 170, 255)
    }

    -- Create UI
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local TopBar = Instance.new("Frame")
    local UICornerTop = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local Content = Instance.new("Frame")
    local UICornerContent = Instance.new("UICorner")
    local Shadow = Instance.new("ImageLabel")

    ScreenGui.Name = "PFESP"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Shadow.Name = "Shadow"
    Shadow.Parent = Main
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 47, 1, 47)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Colors.DarkContrast
    Shadow.ImageTransparency = 0.5

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Colors.Background
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -175, 0.5, -200)
    Main.Size = UDim2.new(0, 350, 0, 400)
    Main.ClipsDescendants = true

    UICorner.Parent = Main
    UICorner.CornerRadius = UDim.new(0, 6)

    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = Colors.DarkContrast
    TopBar.Size = UDim2.new(1, 0, 0, 30)

    UICornerTop.Parent = TopBar
    UICornerTop.CornerRadius = UDim.new(0, 6)

    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "ESP Settings"
    Title.TextColor3 = Colors.TextColor
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    Content.Name = "Content"
    Content.Parent = Main
    Content.BackgroundColor3 = Colors.Container
    Content.BorderSizePixel = 0
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.Size = UDim2.new(1, 0, 1, -30)

    UICornerContent.Parent = Content
    UICornerContent.CornerRadius = UDim.new(0, 6)

    -- Make window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Create Toggle Function
    local function CreateToggle(name, default, yPos, callback)
        local Toggle = Instance.new("Frame")
        local UICornerToggle = Instance.new("UICorner")
        local Button = Instance.new("TextButton")
        local UICornerButton = Instance.new("UICorner")
        local Label = Instance.new("TextLabel")

        Toggle.Name = name
        Toggle.Parent = Content
        Toggle.BackgroundColor3 = Colors.Background
        Toggle.BorderSizePixel = 0
        Toggle.Position = UDim2.new(0, 10, 0, yPos)
        Toggle.Size = UDim2.new(1, -20, 0, 35)

        UICornerToggle.Parent = Toggle
        UICornerToggle.CornerRadius = UDim.new(0, 4)

        Button.Name = "Button"
        Button.Parent = Toggle
        Button.AnchorPoint = Vector2.new(1, 0.5)
        Button.BackgroundColor3 = default and Colors.Accent or Color3.fromRGB(200, 200, 200)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(1, -10, 0.5, 0)
        Button.Size = UDim2.new(0, 24, 0, 24)
        Button.Font = Enum.Font.SourceSans
        Button.Text = ""
        Button.AutoButtonColor = false

        UICornerButton.Parent = Button
        UICornerButton.CornerRadius = UDim.new(0, 4)

        Label.Name = "Label"
        Label.Parent = Toggle
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Size = UDim2.new(1, -60, 1, 0)
        Label.Font = Enum.Font.Gotham
        Label.Text = name
        Label.TextColor3 = Colors.TextColor
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local enabled = default
        Button.MouseButton1Click:Connect(function()
            enabled = not enabled
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundColor3 = enabled and Colors.Accent or Color3.fromRGB(200, 200, 200)
            }):Play()
            callback(enabled)
        end)

        -- Hover Effect
        Toggle.MouseEnter:Connect(function()
            TweenService:Create(Toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.DarkContrast
            }):Play()
        end)

        Toggle.MouseLeave:Connect(function()
            TweenService:Create(Toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.Background
            }):Play()
        end)
    end

    -- ESP Settings
    local ESPSettings = {
        Enabled = false,
        TeamCheck = true,
        TeamColor = true,
        ShowName = false,
        ShowHealth = false,
        ShowDistance = false,
        ShowBox = false,
        ShowTracer = false,
        MaxDistance = 1000,
        TextSize = 13,
        BoxThickness = 1,
        TracerThickness = 1,
        TextOutline = true
    }

    -- Add Toggles
    local yOffset = 10
    CreateToggle("Enable ESP", false, yOffset, function(Value)
        ESPSettings.Enabled = Value
    end)
    yOffset = yOffset + 45

    CreateToggle("Team Check", true, yOffset, function(Value)
        ESPSettings.TeamCheck = Value
    end)
    yOffset = yOffset + 45

    CreateToggle("Team Color", true, yOffset, function(Value)
        ESPSettings.TeamColor = Value
    end)
    yOffset = yOffset + 45

    CreateToggle("Show Box", false, yOffset, function(Value)
        ESPSettings.ShowBox = Value
    end)
    yOffset = yOffset + 45

    CreateToggle("Show Name", false, yOffset, function(Value)
        ESPSettings.ShowName = Value
    end)
    yOffset = yOffset + 45

    CreateToggle("Show Health", false, yOffset, function(Value)
        ESPSettings.ShowHealth = Value
    end)
    yOffset = yOffset + 45

    CreateToggle("Show Distance", false, yOffset, function(Value)
        ESPSettings.ShowDistance = Value
    end)
    yOffset = yOffset + 45

    CreateToggle("Show Tracer", false, yOffset, function(Value)
        ESPSettings.ShowTracer = Value
    end)

    -- Rest of your ESP code here...
    -- (ESP Objects, GetPFCharacter, GetPFHealth, CreateESPObject, etc.)

    return true
end

-- Run the script with error handling
local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result