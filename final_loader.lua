local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    if game.PlaceId ~= 292439477 then return false end
    
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    -- Initialize variables
    local aimbotActive = false
    local lastToggleTime = 0
    local TOGGLE_COOLDOWN = 0.3 -- Prevent double-toggle
    
    local function createDrawings()
        local fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 100
        fovCircle.Radius = 100
        fovCircle.Filled = false
        fovCircle.Visible = false
        fovCircle.ZIndex = 999
        fovCircle.Transparency = 1
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        
        local snapLine = Drawing.new("Line")
        snapLine.Thickness = 1.5
        snapLine.Visible = false
        snapLine.ZIndex = 999
        snapLine.Transparency = 1
        snapLine.Color = Color3.fromRGB(255, 0, 0)
        
        return fovCircle, snapLine
    end
    
    local fovCircle, snapLine = createDrawings()
    
    -- Add error handling for drawings
    if not fovCircle or not snapLine then
        warn("Failed to create drawings")
        return false
    end
    
    local UI = {}
    
    function UI.new()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "TOSIndustriesV1"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 500, 0, 350)
        mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        mainFrame.BorderSizePixel = 0
        mainFrame.ClipsDescendants = true
        mainFrame.Parent = screenGui
        
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.BackgroundTransparency = 1
        shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        shadow.Size = UDim2.new(1, 47, 1, 47)
        shadow.ZIndex = 0
        shadow.Image = "rbxassetid://6015897843"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.Parent = mainFrame
        
        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 35)
        topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        topBar.BorderSizePixel = 0
        topBar.Parent = mainFrame
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -10, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "TOS Industries v1"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = topBar
        
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 35, 0, 35)
        closeButton.Position = UDim2.new(1, -35, 0, 0)
        closeButton.BackgroundTransparency = 1
        closeButton.Text = "×"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 24
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = topBar
        
        closeButton.MouseEnter:Connect(function()
            TweenService:Create(closeButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play()
        end)
        
        closeButton.MouseLeave:Connect(function()
            TweenService:Create(closeButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)
        
        closeButton.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
        end)
        
        local tabButtons = Instance.new("Frame")
        tabButtons.Name = "TabButtons"
        tabButtons.Size = UDim2.new(0, 120, 1, -35)
        tabButtons.Position = UDim2.new(0, 0, 0, 35)
        tabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        tabButtons.BorderSizePixel = 0
        tabButtons.Parent = mainFrame
        
        local tabContainer = Instance.new("Frame")
        tabContainer.Name = "TabContainer"
        tabContainer.Size = UDim2.new(1, -120, 1, -35)
        tabContainer.Position = UDim2.new(0, 120, 0, 35)
        tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        tabContainer.BorderSizePixel = 0
        tabContainer.Parent = mainFrame
        
        local buttonLayout = Instance.new("UIListLayout")
        buttonLayout.Padding = UDim.new(0, 1)
        buttonLayout.Parent = tabButtons
        
        local function createTab(name)
            local button = Instance.new("TextButton")
            button.Name = name .. "Button"
            button.Size = UDim2.new(1, 0, 0, 35)
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            button.BorderSizePixel = 0
            button.Text = name
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.TextSize = 14
            button.Font = Enum.Font.GothamSemibold
            button.Parent = tabButtons
            
            local container = Instance.new("ScrollingFrame")
            container.Name = name .. "Container"
            container.Size = UDim2.new(1, -20, 1, -20)
            container.Position = UDim2.new(0, 10, 0, 10)
            container.BackgroundTransparency = 1
            container.BorderSizePixel = 0
            container.ScrollBarThickness = 2
            container.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
            container.Visible = false
            container.Parent = tabContainer
            
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 8)
            layout.Parent = container
            
            return {
                Button = button,
                Container = container
            }
        end
        
        local tabs = {
            Combat = createTab("Combat"),
            Visuals = createTab("Visuals"),
            Settings = createTab("Settings")
        }
        
        local currentTab = nil
        
        local function selectTab(tab)
            if currentTab then
                TweenService:Create(currentTab.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 50),
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                }):Play()
                currentTab.Container.Visible = false
            end
            
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 65),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            tab.Container.Visible = true
            currentTab = tab
        end
        
        for _, tab in pairs(tabs) do
            tab.Button.MouseButton1Click:Connect(function()
                selectTab(tab)
            end)
        end
        
        selectTab(tabs.Combat)
        
        local function makeDraggable(gui)
            local dragging
            local dragInput
            local dragStart
            local startPos
            
            local function update(input)
                local delta = input.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
            
            gui.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    dragStart = input.Position
                    startPos = gui.Position
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            
            gui.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    dragInput = input
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    update(input)
                end
            end)
        end
        
        makeDraggable(mainFrame)
        
        return {
            ScreenGui = screenGui,
            MainFrame = mainFrame,
            Tabs = tabs
        }
    end
    
    function UI.createToggle(text, parent, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        button.BorderSizePixel = 0
        button.Text = ""
        button.AutoButtonColor = false
        button.Parent = container
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = button
        
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -45, 0.5, -10)
        toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        toggle.BorderSizePixel = 0
        toggle.Parent = button
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = toggle
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(0, 2, 0.5, -8)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Parent = toggle
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator
        
        local state = false
        
        local function updateToggle()
            TweenService:Create(indicator, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = state and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(255, 255, 255)
            }):Play()
            
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 30, 45)
            }):Play()
            
            callback(state)
        end
        
        button.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
        end)
        
        return {
            Frame = container,
            SetState = function(newState)
                state = newState
                updateToggle()
            end
        }
    end
    
    function UI.createSlider(text, parent, min, max, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 45)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. (default or min)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local sliderBG = Instance.new("Frame")
        sliderBG.Name = "SliderBG"
        sliderBG.Size = UDim2.new(1, -20, 0, 6)
        sliderBG.Position = UDim2.new(0, 10, 0, 30)
        sliderBG.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        sliderBG.BorderSizePixel = 0
        sliderBG.Parent = container
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = sliderBG
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBG
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = sliderFill
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0.5, -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        knob.Parent = sliderFill
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        
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
        
        return {
            Frame = container,
            SetValue = function(newValue)
                value = math.clamp(newValue, min, max)
                local pos = (value - min) / (max - min)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                label.Text = text .. ": " .. value
                callback(value)
            end
        }
    end
    
    function UI.createKeybind(text, parent, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Parent = container
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -100, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = button
        
        local keyLabel = Instance.new("TextLabel")
        keyLabel.Size = UDim2.new(0, 80, 0, 20)
        keyLabel.Position = UDim2.new(1, -90, 0.5, -10)
        keyLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        keyLabel.BorderSizePixel = 0
        keyLabel.Text = default.Name
        keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        keyLabel.TextSize = 12
        keyLabel.Font = Enum.Font.GothamSemibold
        keyLabel.Parent = button
        
        local keyCorner = Instance.new("UICorner")
        keyCorner.CornerRadius = UDim.new(0, 4)
        keyCorner.Parent = keyLabel
        
        local listening = false
        local currentKey = default
        
        button.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            keyLabel.Text = "..."
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keyLabel.Text = currentKey.Name
                    callback(currentKey)
                    listening = false
                    connection:Disconnect()
                end
            end)
        end)
        
        return {
            Frame = container,
            GetKey = function() return currentKey end,
            SetKey = function(newKey)
                currentKey = newKey
                keyLabel.Text = newKey.Name
                callback(newKey)
            end
        }
    end
    
    local function initializeUI()
        local ui = UI.new()
        local config = {
            aimbot = {
                enabled = false,
                active = false,  -- New toggle state
                fov = 100,
                smoothness = 2,
                prediction = true,
                targetPart = "Head",
                key = Enum.KeyCode.E,
                snapline = false
            },
            esp = {
                enabled = false,
                boxes = true,
                tracers = true,
                names = true,
                health = true,
                team = false
            },
            settings = {
                toggleKey = Enum.KeyCode.RightShift
            }
        }
        
        -- Combat Tab
        local aimbotToggle = UI.createToggle("Enable Aimbot", ui.Tabs.Combat.Container, function(state)
            config.aimbot.enabled = state
            fovCircle.Visible = state
            if not state then
                config.aimbot.active = false
                aimbotActive = false
            end
        end)
        
        local fovSlider = UI.createSlider("FOV", ui.Tabs.Combat.Container, 10, 800, config.aimbot.fov, function(value)
            config.aimbot.fov = value
            fovCircle.Radius = value
        end)
        
        local smoothnessSlider = UI.createSlider("Smoothness", ui.Tabs.Combat.Container, 1, 10, config.aimbot.smoothness, function(value)
            config.aimbot.smoothness = value
        end)
        
        local aimbotKey = UI.createKeybind("Aimbot Key", ui.Tabs.Combat.Container, config.aimbot.key, function(key)
            config.aimbot.key = key
        end)
        
        -- Visuals Tab
        local espToggle = UI.createToggle("Enable ESP", ui.Tabs.Visuals.Container, function(state)
            config.esp.enabled = state
        end)
        
        local boxesToggle = UI.createToggle("Show Boxes", ui.Tabs.Visuals.Container, function(state)
            config.esp.boxes = state
        end)
        
        local tracersToggle = UI.createToggle("Show Tracers", ui.Tabs.Visuals.Container, function(state)
            config.esp.tracers = state
        end)
        
        local namesToggle = UI.createToggle("Show Names", ui.Tabs.Visuals.Container, function(state)
            config.esp.names = state
        end)
        
        local healthToggle = UI.createToggle("Show Health", ui.Tabs.Visuals.Container, function(state)
            config.esp.health = state
        end)
        
        -- Settings Tab
        local toggleKeyBind = UI.createKeybind("Toggle Menu", ui.Tabs.Settings.Container, config.settings.toggleKey, function(key)
            config.settings.toggleKey = key
        end)
        
        -- Initialize values
        aimbotToggle.SetState(config.aimbot.enabled)
        fovSlider.SetValue(config.aimbot.fov)
        smoothnessSlider.SetValue(config.aimbot.smoothness)
        espToggle.SetState(config.esp.enabled)
        boxesToggle.SetState(config.esp.boxes)
        tracersToggle.SetState(config.esp.tracers)
        namesToggle.SetState(config.esp.names)
        healthToggle.SetState(config.esp.health)
        
        -- Toggle menu visibility with keybind
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == config.settings.toggleKey then
                ui.MainFrame.Visible = not ui.MainFrame.Visible
            end
        end)
        
        return ui, config
    end
    
    local ui, config = initializeUI()
    
    -- Update FOV Circle
    RunService.RenderStepped:Connect(function()
        if config.aimbot.enabled then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    end)
    
    -- ESP Functions
    local ESP = {
        Drawings = {},
        Connections = {}
    }
    
    function ESP.createDrawings(player)
        if not player then return end
        
        local drawings = {
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"),
            HealthBarOutline = Drawing.new("Square"),
            Tracer = Drawing.new("Line")
        }
        
        -- Verify all drawings were created successfully
        for name, drawing in pairs(drawings) do
            if not drawing then
                warn("Failed to create drawing:", name)
                -- Clean up any successfully created drawings
                for _, d in pairs(drawings) do
                    if d then d:Remove() end
                end
                return
            end
        end
        
        -- Box settings
        drawings.BoxOutline.Thickness = 3
        drawings.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        drawings.BoxOutline.Filled = false
        drawings.BoxOutline.Transparency = 1
        
        drawings.Box.Thickness = 1
        drawings.Box.Color = Color3.fromRGB(255, 255, 255)
        drawings.Box.Filled = false
        drawings.Box.Transparency = 1
        
        -- Name settings
        drawings.Name.Size = 13
        drawings.Name.Center = true
        drawings.Name.Outline = true
        drawings.Name.Color = Color3.fromRGB(255, 255, 255)
        drawings.Name.Font = 2
        
        -- Health bar settings
        drawings.HealthBarOutline.Thickness = 3
        drawings.HealthBarOutline.Filled = false
        drawings.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
        drawings.HealthBarOutline.Transparency = 1
        
        drawings.HealthBar.Thickness = 1
        drawings.HealthBar.Filled = true
        drawings.HealthBar.Transparency = 1
        
        -- Tracer settings
        drawings.Tracer.Thickness = 1
        drawings.Tracer.Color = Color3.fromRGB(255, 255, 255)
        drawings.Tracer.Transparency = 1
        
        ESP.Drawings[player] = drawings
    end
    
    function ESP.removeDrawings(player)
        local drawings = ESP.Drawings[player]
        if drawings then
            for _, drawing in pairs(drawings) do
                drawing:Remove()
            end
            ESP.Drawings[player] = nil
        end
    end
    
    function ESP.updateESP()
        if not config.esp.enabled then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            pcall(function()
                if not ESP.Drawings[player] then
                    ESP.createDrawings(player)
                end
                
                local drawings = ESP.Drawings[player]
                if not drawings then return end
                
                local character = player.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChild("Humanoid")
                
                if not character or not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                    return
                end
                
                local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if not onScreen then
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                    return
                end
                
                -- Get character bounds
                local topPosition = Camera:WorldToViewportPoint((humanoidRootPart.CFrame * CFrame.new(0, 3, 0)).Position)
                local bottomPosition = Camera:WorldToViewportPoint((humanoidRootPart.CFrame * CFrame.new(0, -3, 0)).Position)
                local height = math.abs(topPosition.Y - bottomPosition.Y)
                local width = height * 0.6
                
                if config.esp.enabled then
                    -- Update box
                    if config.esp.boxes then
                        drawings.BoxOutline.Visible = true
                        drawings.Box.Visible = true
                        
                        drawings.BoxOutline.Size = Vector2.new(width, height)
                        drawings.BoxOutline.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                        
                        drawings.Box.Size = Vector2.new(width, height)
                        drawings.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                    else
                        drawings.BoxOutline.Visible = false
                        drawings.Box.Visible = false
                    end
                    
                    -- Update name
                    if config.esp.names then
                        drawings.Name.Visible = true
                        drawings.Name.Text = player.Name
                        drawings.Name.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
                    else
                        drawings.Name.Visible = false
                    end
                    
                    -- Update health bar
                    if config.esp.health and humanoid then
                        drawings.HealthBarOutline.Visible = true
                        drawings.HealthBar.Visible = true
                        
                        local healthBarHeight = height
                        local healthBarWidth = 4
                        local healthPercentage = humanoid.Health / humanoid.MaxHealth
                        
                        drawings.HealthBarOutline.Size = Vector2.new(healthBarWidth, healthBarHeight)
                        drawings.HealthBarOutline.Position = Vector2.new(vector.X - width / 2 - 7, vector.Y - height / 2)
                        
                        drawings.HealthBar.Size = Vector2.new(healthBarWidth, healthBarHeight * healthPercentage)
                        drawings.HealthBar.Position = Vector2.new(vector.X - width / 2 - 7, vector.Y - height / 2 + healthBarHeight * (1 - healthPercentage))
                        drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercentage), 255 * healthPercentage, 0)
                    else
                        drawings.HealthBarOutline.Visible = false
                        drawings.HealthBar.Visible = false
                    end
                    
                    -- Update tracer
                    if config.esp.tracers then
                        drawings.Tracer.Visible = true
                        drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        drawings.Tracer.To = Vector2.new(vector.X, vector.Y)
                    else
                        drawings.Tracer.Visible = false
                    end
                else
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                end
            end)
        end
    end
    
    -- Aimbot Functions
    local function getClosestPlayerToCursor()
        if not config.aimbot.enabled or not config.aimbot.active then return nil end
        
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mousePosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local success, result = pcall(function()
                local character = player.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChild("Humanoid")
                local head = character and character:FindFirstChild(config.aimbot.targetPart)
                
                if character and humanoidRootPart and humanoid and humanoid.Health > 0 and head then
                    local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distance = (Vector2.new(vector.X, vector.Y) - mousePosition).Magnitude
                        if distance <= config.aimbot.fov then
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end)
            
            if not success then
                warn("Error in getClosestPlayerToCursor:", result)
            end
        end
        
        return closestPlayer
    end
    
    local function aimAt(player)
        if not player then return end
        
        local success, error = pcall(function()
            local character = player.Character
            local head = character and character:FindFirstChild(config.aimbot.targetPart)
            if not head then return end
            
            local targetPos = head.Position
            if config.aimbot.prediction then
                local velocity = head.Velocity
                local distance = (head.Position - Camera.CFrame.Position).Magnitude
                local bulletTime = distance / 1000
                targetPos = targetPos + (velocity * bulletTime)
            end
            
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / config.aimbot.smoothness)
        end)
        
        if not success then
            warn("Error in aimAt:", error)
        end
    end
    
    -- Handle aimbot toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == config.aimbot.key then
            local currentTime = tick()
            if currentTime - lastToggleTime >= TOGGLE_COOLDOWN then
                config.aimbot.active = not config.aimbot.active
                aimbotActive = config.aimbot.active
                lastToggleTime = currentTime
            end
        end
    end)
    
    -- Main loop with error handling
    RunService.RenderStepped:Connect(function()
        pcall(function()
            -- Update FOV Circle
            if config.aimbot.enabled then
                fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            end
            
            -- Update ESP
            ESP.updateESP()
            
            -- Handle Aimbot
            if config.aimbot.enabled and config.aimbot.active then
                local target = getClosestPlayerToCursor()
                if target then
                    aimAt(target)
                    if config.aimbot.snapline then
                        local vector = Camera:WorldToViewportPoint(target.Character[config.aimbot.targetPart].Position)
                        snapLine.Visible = true
                        snapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        snapLine.To = Vector2.new(vector.X, vector.Y)
                    end
                else
                    snapLine.Visible = false
                end
            else
                snapLine.Visible = false
            end
        end)
    end)
    
    -- Player Connections
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESP.createDrawings(player)
    end)
    
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP.removeDrawings(player)
    end)
    
    -- Improved cleanup
    local function cleanup()
        pcall(function()
            for _, connection in pairs(ESP.Connections) do
                if connection then connection:Disconnect() end
            end
            
            for _, playerDrawings in pairs(ESP.Drawings) do
                for _, drawing in pairs(playerDrawings) do
                    if drawing then drawing:Remove() end
                end
            end
            
            if fovCircle then fovCircle:Remove() end
            if snapLine then snapLine:Remove() end
            if ui.ScreenGui then ui.ScreenGui:Destroy() end
        end)
    end
    
    -- Handle script cleanup
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child == ui.ScreenGui then
            cleanup()
        end
    end)
    
    return true
end

startScript()