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
    local Mouse = LocalPlayer:GetMouse()
    
    -- Initialize variables
    local aimbotActive = false
    local lastToggleTime = 0
    local TOGGLE_COOLDOWN = 0.3
    
    -- Create drawings
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
    
    -- ESP System
    local ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = true,
        TeamCheck = true,
        Players = {},
        Connections = {}
    }
    
    -- Aimbot System
    local Aimbot = {
        Enabled = false,
        Active = false,
        Silent = false,
        TargetPart = "Head",
        FOV = 100,
        Smoothness = 2,
        TeamCheck = true,
        VisibilityCheck = false,
        PredictMovement = true,
        PredictionAmount = 0.165,
        HitChance = 100,
        AutoShoot = false
    }
    
    -- UI System
    local UI = {}
    local ui = nil
    
    function UI.new()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "TOSIndustriesV1"
        screenGui.ResetOnSpawn = false
        
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = game:GetService("CoreGui")
        else
            screenGui.Parent = game:GetService("CoreGui")
        end
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 300, 0, 400)
        mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 8)
        mainCorner.Parent = mainFrame
        
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
        
        local topCorner = Instance.new("UICorner")
        topCorner.CornerRadius = UDim.new(0, 8)
        topCorner.Parent = topBar
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -40, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "TOS Industries v1"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = topBar
        
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -35, 0, 2)
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 95, 95)
        closeButton.Text = "×"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 20
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = topBar
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeButton
        
        closeButton.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
        end)
        
        local menuButtons = Instance.new("Frame")
        menuButtons.Name = "MenuButtons"
        menuButtons.Size = UDim2.new(1, -20, 0, 40)
        menuButtons.Position = UDim2.new(0, 10, 0, 45)
        menuButtons.BackgroundTransparency = 1
        menuButtons.Parent = mainFrame
        
        local menuLayout = Instance.new("UIListLayout")
        menuLayout.FillDirection = Enum.FillDirection.Horizontal
        menuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
        menuLayout.Padding = UDim.new(0, 10)
        menuLayout.Parent = menuButtons
        
        local function createMenuButton(name, order)
            local button = Instance.new("TextButton")
            button.Name = name .. "Button"
            button.Size = UDim2.new(0, 70, 1, 0)
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            button.Text = name
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.TextSize = 14
            button.Font = Enum.Font.GothamSemibold
            button.LayoutOrder = order
            button.Parent = menuButtons
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = button
            
            return button
        end
        
        local contentContainer = Instance.new("Frame")
        contentContainer.Name = "ContentContainer"
        contentContainer.Size = UDim2.new(1, -20, 1, -95)
        contentContainer.Position = UDim2.new(0, 10, 0, 90)
        contentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        contentContainer.BorderSizePixel = 0
        contentContainer.Parent = mainFrame
        
        local containerCorner = Instance.new("UICorner")
        containerCorner.CornerRadius = UDim.new(0, 8)
        containerCorner.Parent = contentContainer
        
        local pages = {
            Aimbot = Instance.new("ScrollingFrame"),
            Visuals = Instance.new("ScrollingFrame"),
            Settings = Instance.new("ScrollingFrame")
        }
        
        for name, frame in pairs(pages) do
            frame.Name = name .. "Page"
            frame.Size = UDim2.new(1, -20, 1, -20)
            frame.Position = UDim2.new(0, 10, 0, 10)
            frame.BackgroundTransparency = 1
            frame.BorderSizePixel = 0
            frame.ScrollBarThickness = 2
            frame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
            frame.Visible = false
            frame.Parent = contentContainer
            
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 10)
            layout.Parent = frame
        end
        
        local buttons = {
            Aimbot = createMenuButton("Aimbot", 1),
            Visuals = createMenuButton("Visuals", 2),
            Settings = createMenuButton("Settings", 3)
        }
        
        local currentPage = "Aimbot"
        pages[currentPage].Visible = true
        buttons[currentPage].BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        buttons[currentPage].TextColor3 = Color3.fromRGB(255, 255, 255)
        
        for name, button in pairs(buttons) do
            button.MouseButton1Click:Connect(function()
                if currentPage == name then return end
                
                -- Hide current page
                pages[currentPage].Visible = false
                buttons[currentPage].BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                buttons[currentPage].TextColor3 = Color3.fromRGB(200, 200, 200)
                
                -- Show new page
                currentPage = name
                pages[currentPage].Visible = true
                button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end
        
        -- Make window draggable
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return {
            ScreenGui = screenGui,
            MainFrame = mainFrame,
            Pages = pages
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
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(0, 2, 0.5, -8)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Parent = toggle
        
        local state = false
        
        local function updateToggle()
            state = not state
            local pos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local color = state and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(255, 255, 255)
            
            indicator.Position = pos
            indicator.BackgroundColor3 = color
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 30, 45)
            
            callback(state)
        end
        
        button.MouseButton1Click:Connect(updateToggle)
        
        return {
            Frame = container,
            SetState = function(newState)
                if state ~= newState then
                    updateToggle()
                end
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
        local dragConnection
        local endConnection
        
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
                
                dragConnection = UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                endConnection = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        if dragConnection then dragConnection:Disconnect() end
                        if endConnection then endConnection:Disconnect() end
                    end
                end)
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
    
    function UI.createColorPicker(text, parent, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        button.BorderSizePixel = 0
        button.Text = ""
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
        
        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(0, 30, 0, 20)
        preview.Position = UDim2.new(1, -40, 0.5, -10)
        preview.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
        preview.BorderSizePixel = 0
        preview.Parent = button
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 4)
        uiCorner.Parent = preview
        
        button.MouseButton1Click:Connect(function()
            local picker = Instance.new("Frame")
            picker.Size = UDim2.new(0, 200, 0, 220)
            picker.Position = UDim2.new(1, 10, 0, 0)
            picker.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            picker.BorderSizePixel = 0
            picker.Visible = true
            picker.Parent = container
            
            local pickerCorner = Instance.new("UICorner")
            pickerCorner.CornerRadius = UDim.new(0, 6)
            pickerCorner.Parent = picker
            
            -- Add color picker UI elements here
            -- This is a simplified version, you can expand it with RGB sliders
            local function updateColor(color)
                preview.BackgroundColor3 = color
                callback(color)
            end
            
            -- Close picker when clicking outside
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local position = input.Position
                    local pickerPos = picker.AbsolutePosition
                    local pickerSize = picker.AbsoluteSize
                    
                    if position.X < pickerPos.X or position.X > pickerPos.X + pickerSize.X or
                       position.Y < pickerPos.Y or position.Y > pickerPos.Y + pickerSize.Y then
                        picker:Destroy()
                        connection:Disconnect()
                    end
                end
            end)
        end)
        
        return {
            Frame = container,
            SetColor = function(color)
                preview.BackgroundColor3 = color
                callback(color)
            end
        }
    end
    
    function ESP:CreatePlayer(player)
        if self.Players[player] then return end
        
        local drawings = {
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"),
            HealthBarOutline = Drawing.new("Square"),
            Tracer = Drawing.new("Line")
        }
        
        -- Box settings
        drawings.BoxOutline.Visible = false
        drawings.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        drawings.BoxOutline.Thickness = 3
        drawings.BoxOutline.Filled = false
        drawings.BoxOutline.Transparency = 1
        
        drawings.Box.Visible = false
        drawings.Box.Color = Color3.fromRGB(255, 255, 255)
        drawings.Box.Thickness = 1
        drawings.Box.Filled = false
        drawings.Box.Transparency = 1
        
        -- Name settings
        drawings.Name.Visible = false
        drawings.Name.Center = true
        drawings.Name.Outline = true
        drawings.Name.Font = 2
        drawings.Name.Size = 13
        drawings.Name.Color = Color3.fromRGB(255, 255, 255)
        drawings.Name.Transparency = 1
        
        -- Distance settings
        drawings.Distance.Visible = false
        drawings.Distance.Center = true
        drawings.Distance.Outline = true
        drawings.Distance.Font = 2
        drawings.Distance.Size = 13
        drawings.Distance.Color = Color3.fromRGB(255, 255, 255)
        drawings.Distance.Transparency = 1
        
        -- Health bar settings
        drawings.HealthBarOutline.Visible = false
        drawings.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
        drawings.HealthBarOutline.Filled = true
        drawings.HealthBarOutline.Thickness = 1
        drawings.HealthBarOutline.Transparency = 1
        
        drawings.HealthBar.Visible = false
        drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
        drawings.HealthBar.Filled = true
        drawings.HealthBar.Thickness = 1
        drawings.HealthBar.Transparency = 1
        
        -- Tracer settings
        drawings.Tracer.Visible = false
        drawings.Tracer.Color = Color3.fromRGB(255, 255, 255)
        drawings.Tracer.Thickness = 1
        drawings.Tracer.Transparency = 1
        
        self.Players[player] = drawings
    end
    
    function ESP:RemovePlayer(player)
        local drawings = self.Players[player]
        if not drawings then return end
        
        for _, drawing in pairs(drawings) do
            if drawing then
                drawing.Visible = false
                drawing:Remove()
            end
        end
        
        self.Players[player] = nil
    end
    
    function ESP:UpdatePlayer(player)
        if not self.Enabled then return end
        if player == LocalPlayer then return end
        
        -- Team Check
        if self.TeamCheck and player.Team == LocalPlayer.Team then
            local drawings = self.Players[player]
            if drawings then
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
            end
            return
        end
        
        local drawings = self.Players[player]
        if not drawings then
            self:CreatePlayer(player)
            drawings = self.Players[player]
        end
        
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if not character or not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            return
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if not onScreen then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            return
        end
        
        local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
        local size = math.clamp(1 / (distance * 0.2), 0.1, 1)
        local boxSize = Vector2.new(1000 * size, 1500 * size)
        
        -- Update box
        if self.Boxes then
            drawings.BoxOutline.Visible = true
            drawings.BoxOutline.Size = boxSize
            drawings.BoxOutline.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
            
            drawings.Box.Visible = true
            drawings.Box.Size = boxSize
            drawings.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
        else
            drawings.BoxOutline.Visible = false
            drawings.Box.Visible = false
        end
        
        -- Update name
        if self.Names then
            drawings.Name.Visible = true
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 15)
        else
            drawings.Name.Visible = false
        end
        
        -- Update distance
        if self.Distance then
            drawings.Distance.Visible = true
            drawings.Distance.Text = string.format("[%d]", math.floor(distance))
            drawings.Distance.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 5)
        else
            drawings.Distance.Visible = false
        end
        
        -- Update health bar
        if self.Health then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxSize.Y
            local barPosition = Vector2.new(pos.X - boxSize.X / 2 - 7, pos.Y - boxSize.Y / 2)
            
            drawings.HealthBarOutline.Visible = true
            drawings.HealthBarOutline.Size = Vector2.new(4, barHeight)
            drawings.HealthBarOutline.Position = barPosition
            
            drawings.HealthBar.Visible = true
            drawings.HealthBar.Size = Vector2.new(2, barHeight * healthPercent)
            drawings.HealthBar.Position = Vector2.new(barPosition.X + 1, barPosition.Y + barHeight * (1 - healthPercent))
            drawings.HealthBar.Color = Color3.fromRGB(255 - 255 * healthPercent, 255 * healthPercent, 0)
        else
            drawings.HealthBarOutline.Visible = false
            drawings.HealthBar.Visible = false
        end
        
        -- Update tracer
        if self.Tracers then
            drawings.Tracer.Visible = true
            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
        else
            drawings.Tracer.Visible = false
        end
    end
    
    function ESP:Update()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                self:UpdatePlayer(player)
            end
        end
    end
    
    -- Initialize ESP
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESP:CreatePlayer(player)
    end)
    
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP:RemovePlayer(player)
    end)
    
    -- Initialize existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP:CreatePlayer(player)
        end
    end
    
    -- Update ESP in RenderStepped
    RunService:BindToRenderStep("ESP", Enum.RenderPriority.Camera.Value + 1, function()
        ESP:Update()
    end)
    
    -- Combat Tab
    local aimbotToggle = UI.createToggle("Enable Aimbot", ui.Pages.Aimbot, function(state)
        Aimbot.Enabled = state
        if not state then
            Aimbot.Active = false
            Aimbot.Silent = false
        end
        fovCircle.Visible = state
    end)
    
    local silentAimToggle = UI.createToggle("Silent Aim", ui.Pages.Aimbot, function(state)
        Aimbot.Silent = state
        if state then
            -- Disable regular aimbot when silent aim is enabled
            Aimbot.Active = false
        end
    end)
    
    local autoShootToggle = UI.createToggle("Auto Shoot", ui.Pages.Aimbot, function(state)
        Aimbot.AutoShoot = state
    end)
    
    local hitChanceSlider = UI.createSlider("Hit Chance", ui.Pages.Aimbot, 1, 100, 100, function(value)
        Aimbot.HitChance = value
    end)
    
    local fovSlider = UI.createSlider("FOV Size", ui.Pages.Aimbot, 10, 800, 100, function(value)
        Aimbot.FOV = value
        fovCircle.Radius = value
    end)
    
    local smoothnessSlider = UI.createSlider("Smoothness", ui.Pages.Aimbot, 1, 10, 2, function(value)
        Aimbot.Smoothness = value
    end)
    
    local fovColorPicker = UI.createColorPicker("FOV Circle Color", ui.Pages.Aimbot, Color3.fromRGB(255, 255, 255), function(color)
        fovCircle.Color = color
    end)
    
    local teamCheckToggle = UI.createToggle("Team Check", ui.Pages.Aimbot, function(state)
        ESP.TeamCheck = state
    end)
    
    local visibilityCheckToggle = UI.createToggle("Visibility Check", ui.Pages.Aimbot, function(state)
        Aimbot.VisibilityCheck = state
    end)
    
    local predictionToggle = UI.createToggle("Movement Prediction", ui.Pages.Aimbot, function(state)
        Aimbot.PredictMovement = state
    end)
    
    -- Visuals Tab
    local espToggle = UI.createToggle("Enable ESP", ui.Pages.Visuals, function(state)
        ESP.Enabled = state
    end)
    
    local boxesToggle = UI.createToggle("Show Boxes", ui.Pages.Visuals, function(state)
        ESP.Boxes = state
    end)
    
    local namesToggle = UI.createToggle("Show Names", ui.Pages.Visuals, function(state)
        ESP.Names = state
    end)
    
    local healthToggle = UI.createToggle("Show Health", ui.Pages.Visuals, function(state)
        ESP.Health = state
    end)
    
    local distanceToggle = UI.createToggle("Show Distance", ui.Pages.Visuals, function(state)
        ESP.Distance = state
    end)
    
    local tracersToggle = UI.createToggle("Show Tracers", ui.Pages.Visuals, function(state)
        ESP.Tracers = state
    end)
    
    -- Input Connections
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.E then
            if Aimbot.Enabled then
                if not Aimbot.Silent then
                    Aimbot.Active = not Aimbot.Active
                    -- Visual feedback
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Aimbot",
                        Text = Aimbot.Active and "Activated" or "Deactivated",
                        Duration = 1
                    })
                end
            end
        elseif input.KeyCode == Enum.KeyCode.RightShift then
            ui.MainFrame.Visible = not ui.MainFrame.Visible
        end
    end)
    
    -- Set initial states
    aimbotToggle.SetState(false)
    fovSlider.SetValue(100)
    smoothnessSlider.SetValue(2)
    teamCheckToggle.SetState(false)
    visibilityCheckToggle.SetState(false)
    predictionToggle.SetState(true)
    espToggle.SetState(false)
    boxesToggle.SetState(true)
    namesToggle.SetState(true)
    healthToggle.SetState(true)
    distanceToggle.SetState(true)
    tracersToggle.SetState(true)
    
    -- Make sure UI is visible initially
    ui.MainFrame.Visible = true
    
    -- Main Loop
    RunService:BindToRenderStep("ESP_Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
        ESP:Update()
        Aimbot:Update()
        
        -- Update FOV Circle
        if Aimbot.Enabled then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = Aimbot.FOV
            fovCircle.Visible = true
            
            -- Update snapline if we have a target
            local target = Aimbot:GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(Aimbot.TargetPart)
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        snapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        snapLine.To = Vector2.new(pos.X, pos.Y)
                        snapLine.Visible = true
                    else
                        snapLine.Visible = false
                    end
                end
            else
                snapLine.Visible = false
            end
        else
            fovCircle.Visible = false
            snapLine.Visible = false
        end
    end)
    
    -- Cleanup
    local function cleanup()
        RunService:UnbindFromRenderStep("ESP_Aimbot")
        
        for _, connection in pairs(ESP.Connections) do
            connection:Disconnect()
        end
        
        for player in pairs(ESP.Players) do
            ESP:RemovePlayer(player)
        end
        
        if fovCircle then fovCircle:Remove() end
        if snapLine then snapLine:Remove() end
        if ui and ui.ScreenGui then ui.ScreenGui:Destroy() end
    end
    
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if ui and child == ui.ScreenGui then
            cleanup()
        end
    end)
    
    return true
end

local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result