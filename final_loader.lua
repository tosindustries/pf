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

    -- Locals
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Create UI
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local TabHolder = Instance.new("Frame")
    local TabContainer = Instance.new("Frame")

    ScreenGui.Name = "PFGui"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.Size = UDim2.new(0, 600, 0, 400)

    Title.Name = "Title"
    Title.Parent = Main
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "Phantom Forces"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    TabHolder.Name = "TabHolder"
    TabHolder.Parent = Main
    TabHolder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.Size = UDim2.new(0, 150, 1, -30)

    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 150, 0, 30)
    TabContainer.Size = UDim2.new(1, -150, 1, -30)

    -- Make window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Title.InputEnded:Connect(function(input)
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

    -- Create Tabs
    local VisualsTab = Instance.new("ScrollingFrame")
    VisualsTab.Name = "VisualsTab"
    VisualsTab.Parent = TabContainer
    VisualsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    VisualsTab.BorderSizePixel = 0
    VisualsTab.Size = UDim2.new(1, 0, 1, 0)
    VisualsTab.ScrollBarThickness = 4
    VisualsTab.Visible = true

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

    -- Create ESP Toggles
    local function CreateToggle(name, default, yPos, callback)
        local Toggle = Instance.new("Frame")
        local Button = Instance.new("TextButton")
        local Title = Instance.new("TextLabel")

        Toggle.Name = name
        Toggle.Parent = VisualsTab
        Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Toggle.BorderSizePixel = 0
        Toggle.Size = UDim2.new(1, -20, 0, 30)
        Toggle.Position = UDim2.new(0, 10, 0, yPos)

        Button.Name = "Button"
        Button.Parent = Toggle
        Button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(1, -40, 0.5, -10)
        Button.Size = UDim2.new(0, 20, 0, 20)
        Button.Font = Enum.Font.SourceSans
        Button.Text = ""
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14

        Title.Name = "Title"
        Title.Parent = Toggle
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Size = UDim2.new(1, -60, 1, 0)
        Title.Font = Enum.Font.SourceSans
        Title.Text = name
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local enabled = default
        Button.MouseButton1Click:Connect(function()
            enabled = not enabled
            Button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            callback(enabled)
        end)
    end

    -- Add ESP Toggles
    local yOffset = 10
    CreateToggle("Enable ESP", false, yOffset, function(Value)
        ESPSettings.Enabled = Value
    end)
    yOffset = yOffset + 35

    CreateToggle("Team Check", true, yOffset, function(Value)
        ESPSettings.TeamCheck = Value
    end)
    yOffset = yOffset + 35

    CreateToggle("Team Color", true, yOffset, function(Value)
        ESPSettings.TeamColor = Value
    end)
    yOffset = yOffset + 35

    CreateToggle("Show Box", false, yOffset, function(Value)
        ESPSettings.ShowBox = Value
    end)
    yOffset = yOffset + 35

    CreateToggle("Show Name", false, yOffset, function(Value)
        ESPSettings.ShowName = Value
    end)
    yOffset = yOffset + 35

    CreateToggle("Show Health", false, yOffset, function(Value)
        ESPSettings.ShowHealth = Value
    end)
    yOffset = yOffset + 35

    CreateToggle("Show Distance", false, yOffset, function(Value)
        ESPSettings.ShowDistance = Value
    end)
    yOffset = yOffset + 35

    CreateToggle("Show Tracer", false, yOffset, function(Value)
        ESPSettings.ShowTracer = Value
    end)

    -- ESP Objects
    local ESPObjects = {}

    -- Get PF Character
    local function GetPFCharacter(player)
        if not player then return nil end
        local chars = ReplicatedStorage:FindFirstChild("Character")
        if chars and chars:FindFirstChild(player.Name) then
            return chars[player.Name]
        end
        return nil
    end

    -- Get PF Health
    local function GetPFHealth(character)
        if not character then return 0, 100 end
        local health = character:FindFirstChild("Health")
        if health then
            return health.Value, 100
        end
        return 0, 100
    end

    -- Create ESP Object
    local function CreateESPObject(player)
        if not player or player == LocalPlayer then return end
        
        local espObject = {
            Player = player,
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"),
            HealthBarOutline = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            TracerOutline = Drawing.new("Line")
        }
        
        -- Box Settings
        espObject.Box.Thickness = ESPSettings.BoxThickness
        espObject.Box.Filled = false
        espObject.Box.Visible = false
        espObject.BoxOutline.Thickness = ESPSettings.BoxThickness + 1
        espObject.BoxOutline.Filled = false
        espObject.BoxOutline.Color = Color3.new(0, 0, 0)
        espObject.BoxOutline.Visible = false
        
        -- Name Settings
        espObject.Name.Size = ESPSettings.TextSize
        espObject.Name.Center = true
        espObject.Name.Outline = ESPSettings.TextOutline
        espObject.Name.Visible = false
        
        -- Distance Settings
        espObject.Distance.Size = ESPSettings.TextSize
        espObject.Distance.Center = true
        espObject.Distance.Outline = ESPSettings.TextOutline
        espObject.Distance.Visible = false
        
        -- Health Bar Settings
        espObject.HealthBar.Thickness = 1
        espObject.HealthBar.Filled = true
        espObject.HealthBar.Visible = false
        espObject.HealthBarOutline.Thickness = 2
        espObject.HealthBarOutline.Filled = true
        espObject.HealthBarOutline.Color = Color3.new(0, 0, 0)
        espObject.HealthBarOutline.Visible = false
        
        -- Tracer Settings
        espObject.Tracer.Thickness = ESPSettings.TracerThickness
        espObject.Tracer.Visible = false
        espObject.TracerOutline.Thickness = ESPSettings.TracerThickness + 1
        espObject.TracerOutline.Color = Color3.new(0, 0, 0)
        espObject.TracerOutline.Visible = false
        
        ESPObjects[player] = espObject
        return espObject
    end

    -- Remove ESP Object
    local function RemoveESPObject(player)
        local espObject = ESPObjects[player]
        if espObject then
            for _, drawing in pairs(espObject) do
                if type(drawing) == "table" and drawing.Remove then
                    pcall(function() drawing:Remove() end)
                end
            end
            ESPObjects[player] = nil
        end
    end

    -- Update ESP Object
    local function UpdateESPObject(espObject)
        if not espObject or not ESPSettings.Enabled then
            if espObject then
                for _, drawing in pairs(espObject) do
                    if type(drawing) == "table" and drawing.Visible ~= nil then
                        drawing.Visible = false
                    end
                end
            end
            return
        end
        
        local player = espObject.Player
        if not player or not player.Parent then return end
        
        local character = GetPFCharacter(player)
        if not character then return end
        
        -- Get health
        local health, maxHealth = GetPFHealth(character)
        if health <= 0 then return end
        
        -- Team Check
        if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team then
            for _, drawing in pairs(espObject) do
                if type(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
            return
        end
        
        -- Get character position
        local torso = character:FindFirstChild("Torso")
        if not torso then return end
        
        local head = character:FindFirstChild("Head")
        if not head then return end
        
        -- Distance Check
        local distance = (torso.Position - Camera.CFrame.Position).Magnitude
        if distance > ESPSettings.MaxDistance then
            for _, drawing in pairs(espObject) do
                if type(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
            return
        end
        
        -- Get corners for box ESP
        local topPos = head.Position + Vector3.new(0, 1, 0)
        local bottomPos = torso.Position - Vector3.new(0, 2, 0)
        
        local screenTop, onScreenTop = Camera:WorldToViewportPoint(topPos)
        local screenBottom, onScreenBottom = Camera:WorldToViewportPoint(bottomPos)
        
        if not onScreenTop or not onScreenBottom then
            for _, drawing in pairs(espObject) do
                if type(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
            return
        end
        
        local boxSize = Vector2.new(math.abs(screenTop.Y - screenBottom.Y) / 2, math.abs(screenTop.Y - screenBottom.Y))
        local boxPosition = Vector2.new(screenTop.X - boxSize.X / 2, screenTop.Y)
        
        -- Set Color
        local color = ESPSettings.TeamColor and player.TeamColor.Color or Color3.new(1, 1, 1)
        
        -- Update Box
        if ESPSettings.ShowBox then
            espObject.Box.Size = boxSize
            espObject.Box.Position = boxPosition
            espObject.Box.Color = color
            espObject.Box.Visible = true
            
            espObject.BoxOutline.Size = boxSize
            espObject.BoxOutline.Position = boxPosition
            espObject.BoxOutline.Visible = true
        else
            espObject.Box.Visible = false
            espObject.BoxOutline.Visible = false
        end
        
        -- Update Name
        if ESPSettings.ShowName then
            espObject.Name.Text = player.Name
            espObject.Name.Position = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y - 16)
            espObject.Name.Color = color
            espObject.Name.Visible = true
        else
            espObject.Name.Visible = false
        end
        
        -- Update Distance
        if ESPSettings.ShowDistance then
            espObject.Distance.Text = string.format("%.0f studs", distance)
            espObject.Distance.Position = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y + boxSize.Y)
            espObject.Distance.Color = color
            espObject.Distance.Visible = true
        else
            espObject.Distance.Visible = false
        end
        
        -- Update Health Bar
        if ESPSettings.ShowHealth then
            local healthPercent = health / maxHealth
            local barSize = Vector2.new(2, boxSize.Y * healthPercent)
            local barPosition = Vector2.new(boxPosition.X - 5, boxPosition.Y + boxSize.Y * (1 - healthPercent))
            
            espObject.HealthBar.Size = barSize
            espObject.HealthBar.Position = barPosition
            espObject.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
            espObject.HealthBar.Visible = true
            
            espObject.HealthBarOutline.Size = Vector2.new(4, boxSize.Y)
            espObject.HealthBarOutline.Position = Vector2.new(boxPosition.X - 6, boxPosition.Y)
            espObject.HealthBarOutline.Visible = true
        else
            espObject.HealthBar.Visible = false
            espObject.HealthBarOutline.Visible = false
        end
        
        -- Update Tracer
        if ESPSettings.ShowTracer then
            local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            local tracerStart = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y + boxSize.Y)
            
            espObject.Tracer.From = screenCenter
            espObject.Tracer.To = tracerStart
            espObject.Tracer.Color = color
            espObject.Tracer.Visible = true
            
            espObject.TracerOutline.From = screenCenter
            espObject.TracerOutline.To = tracerStart
            espObject.TracerOutline.Visible = true
        else
            espObject.Tracer.Visible = false
            espObject.TracerOutline.Visible = false
        end
    end

    -- Update all ESP Objects
    local function UpdateESP()
        for _, espObject in pairs(ESPObjects) do
            pcall(UpdateESPObject, espObject)
        end
    end

    -- Initialize ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESPObject(player)
        end
    end

    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        CreateESPObject(player)
    end)

    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        RemoveESPObject(player)
    end)

    -- Update ESP
    RunService.RenderStepped:Connect(UpdateESP)

    return true
end

-- Run the script with error handling
local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result