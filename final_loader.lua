local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    if game.PlaceId ~= 292439477 then return false end
    
    -- Core Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    local CurrentCamera = workspace.CurrentCamera
    local worldToViewportPoint = CurrentCamera.worldToViewportPoint

    local LocalPlayer = Players.LocalPlayer
    local HeadOff = Vector3.new(0, 0.5, 0)
    local LegOff = Vector3.new(0, 3, 0)

    -- Create UI System
    local UI = {}

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
        
        -- Create pages
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
            Aimbot = UI.createMenuButton("Aimbot", 1, menuButtons),
            Visuals = UI.createMenuButton("Visuals", 2, menuButtons),
            Settings = UI.createMenuButton("Settings", 3, menuButtons)
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

    function UI.createMenuButton(text, order, parent)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Size = UDim2.new(0, 70, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(200, 200, 200)
        button.TextSize = 14
        button.Font = Enum.Font.GothamSemibold
        button.LayoutOrder = order
        button.Parent = parent
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        return button
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

    -- Create UI first
    local ui = UI.new()

    -- Initialize variables
    local aimbotActive = false
    local lastToggleTime = 0
    local TOGGLE_COOLDOWN = 0.3

    -- ESP Settings
    local ESP = {
        Enabled = false,
        TeamCheck = true,
        ShowBox = true,
        ShowHealth = true,
        ShowName = true,
        ShowDistance = true,
        ShowTracer = true,
        MaxDistance = 1000,
        BoxThickness = 3,
        TracerThickness = 2,
        TracerOrigin = "Bottom", -- "Bottom", "Mouse", "Top"
        TextSize = 13,
        Objects = {},
        Connections = {} -- Store all connections for proper cleanup
    }

    -- Safe function call wrapper
    local function safecall(func, ...)
        local success, result = pcall(func, ...)
        if not success then
            warn("ESP Error:", result)
        end
        return success, result
    end

    function ESP:CreateObject(player)
        if not player or not player.Parent then return end
        if self.Objects[player] then return end
        
        -- Create drawings with error handling
        local drawings = {}
        local function createDrawing(drawingType, properties)
            local success, drawing = pcall(function()
                local d = Drawing.new(drawingType)
                for prop, value in pairs(properties) do
                    d[prop] = value
                end
                return d
            end)
            
            if not success then
                warn("Failed to create drawing:", drawing)
                return nil
            end
            return drawing
        end
        
        -- Box and outline
        local Box = createDrawing("Square", {
            Visible = false,
            Color = player.TeamColor.Color,
            Thickness = self.BoxThickness,
            Transparency = 1,
            Filled = false,
            ZIndex = 1
        })
        
        local BoxOutline = createDrawing("Square", {
            Visible = false,
            Color = Color3.new(0, 0, 0),
            Thickness = self.BoxThickness + 1,
            Transparency = 1,
            Filled = false,
            ZIndex = 0
        })
        
        -- Health bar
        local HealthBar = createDrawing("Line", {
            Visible = false,
            Color = Color3.new(0, 1, 0),
            Thickness = 2,
            Transparency = 1,
            ZIndex = 2
        })
        
        local HealthBarOutline = createDrawing("Line", {
            Visible = false,
            Color = Color3.new(0, 0, 0),
            Thickness = 4,
            Transparency = 1,
            ZIndex = 1
        })
        
        -- Name tag
        local NameTag = createDrawing("Text", {
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Size = self.TextSize,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            ZIndex = 2
        })
        
        -- Distance tag
        local DistanceTag = createDrawing("Text", {
            Visible = false,
            Color = Color3.new(1, 1, 1),
            Size = self.TextSize,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            ZIndex = 2
        })
        
        -- Tracer
        local Tracer = createDrawing("Line", {
            Visible = false,
            Color = player.TeamColor.Color,
            Thickness = self.TracerThickness,
            Transparency = 1,
            ZIndex = 1
        })
        
        local TracerOutline = createDrawing("Line", {
            Visible = false,
            Color = Color3.new(0, 0, 0),
            Thickness = self.TracerThickness + 1,
            Transparency = 1,
            ZIndex = 0
        })
        
        -- Check if any drawings failed to create
        if not (Box and BoxOutline and HealthBar and HealthBarOutline and 
                NameTag and DistanceTag and Tracer and TracerOutline) then
            -- Cleanup any successfully created drawings
            for _, drawing in pairs({Box, BoxOutline, HealthBar, HealthBarOutline, 
                                   NameTag, DistanceTag, Tracer, TracerOutline}) do
                if drawing then
                    drawing:Remove()
                end
            end
            return
        end
        
        -- Create update connection
        local connection = RunService.RenderStepped:Connect(function()
            safecall(function()
                self:UpdateESP(player)
            end)
        end)
        
        self.Objects[player] = {
            Box = Box,
            BoxOutline = BoxOutline,
            HealthBar = HealthBar,
            HealthBarOutline = HealthBarOutline,
            NameTag = NameTag,
            DistanceTag = DistanceTag,
            Tracer = Tracer,
            TracerOutline = TracerOutline,
            Connection = connection
        }
        
        -- Store connection for cleanup
        self.Connections[player] = connection
    end

    function ESP:RemoveObject(player)
        local object = self.Objects[player]
        if not object then return end
        
        -- Remove all drawings
        safecall(function()
            for _, drawing in pairs(object) do
                if typeof(drawing) == "table" and drawing.Remove then
                    drawing:Remove()
                end
            end
        end)
        
        -- Disconnect update connection
        if self.Connections[player] then
            self.Connections[player]:Disconnect()
            self.Connections[player] = nil
        end
        
        self.Objects[player] = nil
    end

    function ESP:UpdateESP(player)
        if not player or not player.Parent then return end
        
        local object = self.Objects[player]
        if not object then return end
        
        -- Early exit conditions
        if not self.Enabled or player == LocalPlayer then
            self:ToggleDrawings(object, false)
            return
        end
        
        -- Character checks
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        
        if not (character and humanoid and rootPart and head) or humanoid.Health <= 0 then
            self:ToggleDrawings(object, false)
            return
        end
        
        -- Team check
        if self.TeamCheck and player.Team == LocalPlayer.Team then
            self:ToggleDrawings(object, false)
            return
        end
        
        -- Distance check
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > self.MaxDistance then
            self:ToggleDrawings(object, false)
            return
        end
        
        -- Screen position checks
        local rootPos, rootVis = worldToViewportPoint(CurrentCamera, rootPart.Position)
        if not rootVis then
            self:ToggleDrawings(object, false)
            return
        end
        
        -- Calculate positions with error handling
        local headPos = worldToViewportPoint(CurrentCamera, head.Position + HeadOff)
        local legPos = worldToViewportPoint(CurrentCamera, rootPart.Position - LegOff)
        
        -- Update Box
        if self.ShowBox then
            local boxSize = Vector2.new(1000 / rootPos.Z, headPos.Y - legPos.Y)
            local boxPosition = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            
            object.BoxOutline.Size = boxSize
            object.BoxOutline.Position = boxPosition
            object.BoxOutline.Visible = true
            
            object.Box.Size = boxSize
            object.Box.Position = boxPosition
            object.Box.Color = player.TeamColor.Color
            object.Box.Visible = true
        end
        
        -- Update Health Bar
        if self.ShowHealth then
            local health = humanoid.Health / humanoid.MaxHealth
            local barHeight = headPos.Y - legPos.Y
            local barPosition = Vector2.new(rootPos.X - object.Box.Size.X/2 - 5, rootPos.Y - object.Box.Size.Y/2)
            
            object.HealthBarOutline.From = Vector2.new(barPosition.X, barPosition.Y)
            object.HealthBarOutline.To = Vector2.new(barPosition.X, barPosition.Y + barHeight)
            object.HealthBarOutline.Visible = true
            
            object.HealthBar.From = Vector2.new(barPosition.X, barPosition.Y + barHeight * (1 - health))
            object.HealthBar.To = Vector2.new(barPosition.X, barPosition.Y + barHeight)
            object.HealthBar.Color = Color3.new(1 - health, health, 0)
            object.HealthBar.Visible = true
        end
        
        -- Update Name Tag
        if self.ShowName then
            object.NameTag.Position = Vector2.new(rootPos.X, rootPos.Y - object.Box.Size.Y/2 - 15)
            object.NameTag.Text = player.Name
            object.NameTag.Color = player.TeamColor.Color
            object.NameTag.Visible = true
        end
        
        -- Update Distance Tag
        if self.ShowDistance then
            object.DistanceTag.Position = Vector2.new(rootPos.X, rootPos.Y + object.Box.Size.Y/2 + 5)
            object.DistanceTag.Text = string.format("[%dm]", math.floor(distance))
            object.DistanceTag.Color = player.TeamColor.Color
            object.DistanceTag.Visible = true
        end
        
        -- Update Tracer
        if self.ShowTracer then
            local tracerStart
            if self.TracerOrigin == "Bottom" then
                tracerStart = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            elseif self.TracerOrigin == "Mouse" then
                tracerStart = UserInputService:GetMouseLocation()
            else -- Top
                tracerStart = Vector2.new(Camera.ViewportSize.X/2, 0)
            end
            
            object.TracerOutline.From = tracerStart
            object.TracerOutline.To = Vector2.new(rootPos.X, rootPos.Y)
            object.TracerOutline.Visible = true
            
            object.Tracer.From = tracerStart
            object.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            object.Tracer.Color = player.TeamColor.Color
            object.Tracer.Visible = true
        end
    end

    function ESP:ToggleDrawings(object, visible)
        if not object then return end
        
        safecall(function()
            for _, drawing in pairs(object) do
                if typeof(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = visible
                end
            end
        end)
    end

    -- Create UI elements
    local espToggle = UI.createToggle("Enable ESP", ui.Pages.Visuals, function(state)
        ESP.Enabled = state
    end)

    local boxToggle = UI.createToggle("Show Boxes", ui.Pages.Visuals, function(state)
        ESP.ShowBox = state
    end)

    local healthToggle = UI.createToggle("Show Health", ui.Pages.Visuals, function(state)
        ESP.ShowHealth = state
    end)

    local nameToggle = UI.createToggle("Show Names", ui.Pages.Visuals, function(state)
        ESP.ShowName = state
    end)

    local distanceToggle = UI.createToggle("Show Distance", ui.Pages.Visuals, function(state)
        ESP.ShowDistance = state
    end)

    local tracerToggle = UI.createToggle("Show Tracers", ui.Pages.Visuals, function(state)
        ESP.ShowTracer = state
    end)

    local teamCheckToggle = UI.createToggle("Team Check", ui.Pages.Visuals, function(state)
        ESP.TeamCheck = state
    end)

    local tracerOriginDropdown = UI.createDropdown("Tracer Origin", ui.Pages.Visuals, {"Bottom", "Mouse", "Top"}, function(value)
        ESP.TracerOrigin = value
    end)

    local distanceSlider = UI.createSlider("ESP Distance", ui.Pages.Visuals, 100, 2000, 1000, function(value)
        ESP.MaxDistance = value
    end)

    -- Set initial states
    espToggle.SetState(false)
    boxToggle.SetState(true)
    healthToggle.SetState(true)
    nameToggle.SetState(true)
    distanceToggle.SetState(true)
    tracerToggle.SetState(true)
    teamCheckToggle.SetState(true)
    tracerOriginDropdown.SetValue("Bottom")
    distanceSlider.SetValue(1000)

    -- Initialize ESP
    for _, player in pairs(Players:GetChildren()) do
        ESP:CreateObject(player)
    end

    -- Player handling
    Players.PlayerAdded:Connect(function(player)
        ESP:CreateObject(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        ESP:RemoveObject(player)
    end)

    -- Cleanup handler
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if ui and child == ui.ScreenGui then
            -- Cleanup all ESP objects
            for player, _ in pairs(ESP.Objects) do
                ESP:RemoveObject(player)
            end
            
            -- Cleanup all connections
            for _, connection in pairs(ESP.Connections) do
                if connection then
                    connection:Disconnect()
                end
            end
            
            -- Clear tables
            ESP.Objects = {}
            ESP.Connections = {}
        end
    end)

    -- Add toggle key for menu
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            local currentTime = tick()
            if currentTime - lastToggleTime >= TOGGLE_COOLDOWN then
                ui.MainFrame.Visible = not ui.MainFrame.Visible
                lastToggleTime = currentTime
            end
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