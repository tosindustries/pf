local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    if game.PlaceId ~= 292439477 then return false end
    
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.NumSides = 100
    fovCircle.Radius = 100
    fovCircle.Filled = false
    fovCircle.Visible = false
    fovCircle.ZIndex = 999
    fovCircle.Transparency = 1
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    
    local snapLine = Drawing.new("Line")
    snapLine.Thickness = 1
    snapLine.Visible = false
    snapLine.ZIndex = 999
    snapLine.Transparency = 1
    snapLine.Color = Color3.fromRGB(255, 0, 0)
    
    local UI = {}
    
    function UI.new()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "TOSIndustriesV1"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 300, 0, 350)
        mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = screenGui
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        title.BorderSizePixel = 0
        title.Text = "TOS Industries v1"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.SourceSansBold
        title.Parent = mainFrame
        
        local container = Instance.new("ScrollingFrame")
        container.Name = "Container"
        container.Size = UDim2.new(1, -20, 1, -40)
        container.Position = UDim2.new(0, 10, 0, 35)
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.ScrollBarThickness = 4
        container.ScrollingDirection = Enum.ScrollingDirection.Y
        container.Parent = mainFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.Parent = container
        
        local sections = {
            Main = UI.createSection("Main", container),
            Visuals = UI.createSection("Visuals", container),
            Aimbot = UI.createSection("Aimbot", container)
        }
        
        return {
            ScreenGui = screenGui,
            MainFrame = mainFrame,
            Sections = sections,
            Visible = true
        }
    end
    
    function UI.createSection(name, parent)
        local section = Instance.new("Frame")
        section.Name = name .. "Section"
        section.Size = UDim2.new(1, 0, 0, 120)
        section.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        section.BorderSizePixel = 0
        section.Parent = parent
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        title.BorderSizePixel = 0
        title.Text = name
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 14
        title.Font = Enum.Font.SourceSansBold
        title.Parent = section
        
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(1, -20, 1, -35)
        container.Position = UDim2.new(0, 10, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = section
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.Parent = container
        
        return {
            Frame = section,
            Container = container
        }
    end
    
    function UI.createToggle(text, parent, callback)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(1, 0, 0, 25)
        toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggle.BorderSizePixel = 0
        toggle.Text = text
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 14
        toggle.Font = Enum.Font.SourceSans
        toggle.Parent = parent
        
        local state = false
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(1, -21, 0, 4)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        indicator.BorderSizePixel = 0
        indicator.Parent = toggle
        
        toggle.MouseButton1Click:Connect(function()
            state = not state
            indicator.BackgroundColor3 = state and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
            callback(state)
        end)
        
        return toggle
    end
    
    function UI.createSlider(text, parent, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 40)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.SourceSans
        label.Parent = sliderFrame
        
        local sliderBG = Instance.new("Frame")
        sliderBG.Name = "SliderBG"
        sliderBG.Size = UDim2.new(1, -20, 0, 4)
        sliderBG.Position = UDim2.new(0, 10, 0, 25)
        sliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        sliderBG.BorderSizePixel = 0
        sliderBG.Parent = sliderFrame
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBG
        
        local value = default or min
        local dragging = false
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pos)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. ": " .. value
            callback(value)
        end
        
        sliderBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return sliderFrame
    end
    
    local gui = UI.new()
    
    local ESP = {
        Enabled = false,
        BoxEnabled = false,
        SkeletonEnabled = false,
        NameEnabled = false,
        HealthEnabled = false,
        TeamCheck = true,
        BoxColor = Color3.fromRGB(255, 255, 255),
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        MaxDistance = 1000,
        Players = {},
        Connections = {}
    }
    
    local Aimbot = {
        Enabled = false,
        TeamCheck = true,
        VisibilityCheck = true,
        TargetPart = "Head",
        Smoothness = 1,
        FOV = 100,
        MaxDistance = 1000,
        CurrentTarget = nil,
        SilentAim = false,
        AutoShoot = false,
        AutoWall = false,
        PredictMovement = false,
        RandomizationStrength = 0,
        HitChance = 100,
        UnlockOnDeath = true,
        IgnoreTransparency = false,
        TargetPriority = "Distance",
        AimKey = Enum.KeyCode.E,
        TriggerKey = Enum.KeyCode.X,
        FOVVisible = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        SnapLines = false,
        SnapLineColor = Color3.fromRGB(255, 0, 0)
    }
    
    UI.createToggle("Enable All", gui.Sections.Main.Container, function(state)
        ESP.Enabled = state
        Aimbot.Enabled = state
    end)
    
    UI.createToggle("Team Check", gui.Sections.Main.Container, function(state)
        ESP.TeamCheck = state
        Aimbot.TeamCheck = state
    end)
    
    UI.createToggle("Box ESP", gui.Sections.Visuals.Container, function(state)
        ESP.BoxEnabled = state
    end)
    
    UI.createToggle("Skeleton ESP", gui.Sections.Visuals.Container, function(state)
        ESP.SkeletonEnabled = state
    end)
    
    UI.createToggle("Name ESP", gui.Sections.Visuals.Container, function(state)
        ESP.NameEnabled = state
    end)
    
    UI.createToggle("Health ESP", gui.Sections.Visuals.Container, function(state)
        ESP.HealthEnabled = state
    end)
    
    UI.createSlider("ESP Distance", gui.Sections.Visuals.Container, 100, 2000, 1000, function(value)
        ESP.MaxDistance = value
    end)
    
    UI.createToggle("Enable Aimbot", gui.Sections.Aimbot.Container, function(state)
        Aimbot.Enabled = state
    end)
    
    UI.createToggle("Visibility Check", gui.Sections.Aimbot.Container, function(state)
        Aimbot.VisibilityCheck = state
    end)
    
    UI.createSlider("Smoothness", gui.Sections.Aimbot.Container, 1, 10, 1, function(value)
        Aimbot.Smoothness = value
    end)
    
    UI.createSlider("FOV", gui.Sections.Aimbot.Container, 30, 500, 100, function(value)
        Aimbot.FOV = value
    end)
    
    UI.createToggle("Silent Aim", gui.Sections.Aimbot.Container, function(state)
        Aimbot.SilentAim = state
    end)
    
    UI.createToggle("Auto Shoot", gui.Sections.Aimbot.Container, function(state)
        Aimbot.AutoShoot = state
    end)
    
    UI.createToggle("Auto Wall", gui.Sections.Aimbot.Container, function(state)
        Aimbot.AutoWall = state
    end)
    
    UI.createToggle("Predict Movement", gui.Sections.Aimbot.Container, function(state)
        Aimbot.PredictMovement = state
    end)
    
    UI.createSlider("Hit Chance", gui.Sections.Aimbot.Container, 1, 100, 100, function(value)
        Aimbot.HitChance = value
    end)
    
    UI.createSlider("Randomization", gui.Sections.Aimbot.Container, 0, 100, 0, function(value)
        Aimbot.RandomizationStrength = value
    end)
    
    UI.createToggle("Show FOV", gui.Sections.Aimbot.Container, function(state)
        Aimbot.FOVVisible = state
    end)
    
    UI.createToggle("Show Snaplines", gui.Sections.Aimbot.Container, function(state)
        Aimbot.SnapLines = state
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightAlt then
            gui.MainFrame.Visible = not gui.MainFrame.Visible
        end
    end)
    
    return true
end

local success, result = pcall(startScript)
if not success then return false end
return result