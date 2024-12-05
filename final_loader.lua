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

    -- Simple UI Library
    local Library = {}
    
    function Library:CreateWindow(title)
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
        Title.Text = title
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
        local dragging
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
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        RunService.RenderStepped:Connect(function()
            if dragging and dragInput then
                local delta = dragInput.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        local window = {}
        local tabs = {}
        
        function window:AddTab(name)
            local TabButton = Instance.new("TextButton")
            local TabPage = Instance.new("ScrollingFrame")
            
            TabButton.Name = name
            TabButton.Parent = TabHolder
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            TabButton.BorderSizePixel = 0
            TabButton.Size = UDim2.new(1, 0, 0, 30)
            TabButton.Font = Enum.Font.SourceSans
            TabButton.Text = name
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.TextSize = 14
            TabButton.AutoButtonColor = false
            
            TabPage.Name = name
            TabPage.Parent = TabContainer
            TabPage.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            TabPage.BorderSizePixel = 0
            TabPage.Size = UDim2.new(1, 0, 1, 0)
            TabPage.ScrollBarThickness = 4
            TabPage.Visible = false
            
            local tab = {}
            
            function tab:AddToggle(name, default, callback)
                local Toggle = Instance.new("Frame")
                local Button = Instance.new("TextButton")
                local Title = Instance.new("TextLabel")
                
                Toggle.Name = name
                Toggle.Parent = TabPage
                Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Toggle.BorderSizePixel = 0
                Toggle.Size = UDim2.new(1, -20, 0, 30)
                Toggle.Position = UDim2.new(0, 10, 0, #TabPage:GetChildren() * 35)
                
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
            
            function tab:AddSlider(name, min, max, default, callback)
                local Slider = Instance.new("Frame")
                local Title = Instance.new("TextLabel")
                local SliderBar = Instance.new("Frame")
                local Fill = Instance.new("Frame")
                local Value = Instance.new("TextLabel")
                
                Slider.Name = name
                Slider.Parent = TabPage
                Slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Slider.BorderSizePixel = 0
                Slider.Size = UDim2.new(1, -20, 0, 45)
                Slider.Position = UDim2.new(0, 10, 0, #TabPage:GetChildren() * 50)
                
                Title.Name = "Title"
                Title.Parent = Slider
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(1, -20, 0, 20)
                Title.Font = Enum.Font.SourceSans
                Title.Text = name
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = Slider
                SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0, 10, 0, 25)
                SliderBar.Size = UDim2.new(1, -60, 0, 10)
                
                Fill.Name = "Fill"
                Fill.Parent = SliderBar
                Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                Fill.BorderSizePixel = 0
                Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                
                Value.Name = "Value"
                Value.Parent = Slider
                Value.BackgroundTransparency = 1
                Value.Position = UDim2.new(1, -45, 0, 20)
                Value.Size = UDim2.new(0, 35, 0, 20)
                Value.Font = Enum.Font.SourceSans
                Value.Text = tostring(default)
                Value.TextColor3 = Color3.fromRGB(255, 255, 255)
                Value.TextSize = 14
                
                local dragging = false
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
                        Fill.Size = pos
                        local value = math.floor(min + ((max - min) * pos.X.Scale))
                        Value.Text = tostring(value)
                        callback(value)
                    end
                end)
            end
            
            table.insert(tabs, {button = TabButton, page = TabPage})
            
            TabButton.MouseButton1Click:Connect(function()
                for _, t in pairs(tabs) do
                    t.page.Visible = (t.button == TabButton)
                    t.button.BackgroundColor3 = (t.button == TabButton) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(35, 35, 35)
                end
            end)
            
            if #tabs == 1 then
                TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                TabPage.Visible = true
            end
            
            return tab
        end
        
        return window
    end
    
    -- Create UI
    local Window = Library:CreateWindow("Phantom Forces")
    local VisualsTab = Window:AddTab("Visuals")
    local SettingsTab = Window:AddTab("Settings")

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

    -- Add ESP Toggles
    VisualsTab:AddToggle("Enable ESP", false, function(Value)
        ESPSettings.Enabled = Value
    end)

    VisualsTab:AddToggle("Team Check", true, function(Value)
        ESPSettings.TeamCheck = Value
    end)

    VisualsTab:AddToggle("Team Color", true, function(Value)
        ESPSettings.TeamColor = Value
    end)

    VisualsTab:AddToggle("Show Box", false, function(Value)
        ESPSettings.ShowBox = Value
    end)

    VisualsTab:AddToggle("Show Name", false, function(Value)
        ESPSettings.ShowName = Value
    end)

    VisualsTab:AddToggle("Show Health", false, function(Value)
        ESPSettings.ShowHealth = Value
    end)

    VisualsTab:AddToggle("Show Distance", false, function(Value)
        ESPSettings.ShowDistance = Value
    end)

    VisualsTab:AddToggle("Show Tracer", false, function(Value)
        ESPSettings.ShowTracer = Value
    end)

    -- Add ESP Sliders
    VisualsTab:AddSlider("Max Distance", 100, 5000, 1000, function(Value)
        ESPSettings.MaxDistance = Value
    end)

    VisualsTab:AddSlider("Text Size", 8, 24, 13, function(Value)
        ESPSettings.TextSize = Value
        for _, espObject in pairs(ESPObjects) do
            if espObject.Name and espObject.Distance then
                espObject.Name.Size = Value
                espObject.Distance.Size = Value
            end
        end
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

    -- Notify on load
    Rayfield:Notify({
        Title = "Script Loaded",
        Content = "ESP is ready to use",
        Duration = 5,
        Image = 4483362458
    })

    return true
end

-- Run the script with error handling
local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result