local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    if game.PlaceId ~= 292439477 then return false end
    
    -- Core Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local Camera = workspace.CurrentCamera
    local CurrentCamera = workspace.CurrentCamera
    local worldToViewportPoint = CurrentCamera.worldToViewportPoint

    local LocalPlayer = Players.LocalPlayer
    local HeadOff = Vector3.new(0, 0.5, 0)
    local LegOff = Vector3.new(0, 3, 0)

    -- Safe function call wrapper
    local function safecall(func, ...)
        local success, result = pcall(func, ...)
        if not success then
            warn("Error:", result)
        end
        return success, result
    end

    -- Create UI System
    local UI = {}

    function UI.new()
        -- Remove existing UI if it exists
        for _, child in pairs(CoreGui:GetChildren()) do
            if child.Name == "TOSIndustriesV1" then
                child:Destroy()
            end
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "TOSIndustriesV1"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        -- Handle different exploit environments
        local success, _ = pcall(function()
            if syn then
                syn.protect_gui(screenGui)
                screenGui.Parent = CoreGui
            elseif gethui then
                screenGui.Parent = gethui()
            else
                screenGui.Parent = CoreGui
            end
        end)
        
        if not success then
            screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
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
        Connections = {}, -- Store all connections for proper cleanup
        Active = false -- Track if ESP system is active
    }

    function ESP:CreateObject(player)
        if not player or not player.Parent then return end
        if self.Objects[player] then return end
        
        -- Create drawings with error handling
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
        
        -- Create all drawings
        local drawings = {
            Box = createDrawing("Square", {
                Visible = false,
                Color = player.TeamColor.Color,
                Thickness = self.BoxThickness,
                Transparency = 1,
                Filled = false,
                ZIndex = 1
            }),
            BoxOutline = createDrawing("Square", {
                Visible = false,
                Color = Color3.new(0, 0, 0),
                Thickness = self.BoxThickness + 1,
                Transparency = 1,
                Filled = false,
                ZIndex = 0
            }),
            HealthBar = createDrawing("Line", {
                Visible = false,
                Color = Color3.new(0, 1, 0),
                Thickness = 2,
                Transparency = 1,
                ZIndex = 2
            }),
            HealthBarOutline = createDrawing("Line", {
                Visible = false,
                Color = Color3.new(0, 0, 0),
                Thickness = 4,
                Transparency = 1,
                ZIndex = 1
            }),
            Name = createDrawing("Text", {
                Visible = false,
                Color = Color3.new(1, 1, 1),
                Size = self.TextSize,
                Center = true,
                Outline = true,
                OutlineColor = Color3.new(0, 0, 0),
                ZIndex = 2
            }),
            Distance = createDrawing("Text", {
                Visible = false,
                Color = Color3.new(1, 1, 1),
                Size = self.TextSize,
                Center = true,
                Outline = true,
                OutlineColor = Color3.new(0, 0, 0),
                ZIndex = 2
            }),
            Tracer = createDrawing("Line", {
                Visible = false,
                Color = player.TeamColor.Color,
                Thickness = self.TracerThickness,
                Transparency = 1,
                ZIndex = 1
            }),
            TracerOutline = createDrawing("Line", {
                Visible = false,
                Color = Color3.new(0, 0, 0),
                Thickness = self.TracerThickness + 1,
                Transparency = 1,
                ZIndex = 0
            })
        }
        
        -- Check if any drawings failed to create
        for name, drawing in pairs(drawings) do
            if not drawing then
                -- Cleanup any successfully created drawings
                for _, d in pairs(drawings) do
                    if d then d:Remove() end
                end
                return
            end
        end
        
        -- Create update connection
        local connection = RunService.RenderStepped:Connect(function()
            if not self.Active then return end
            safecall(function()
                self:UpdateESP(player, drawings)
            end)
        end)
        
        self.Objects[player] = drawings
        self.Connections[player] = connection
    end

    function ESP:RemoveObject(player)
        local drawings = self.Objects[player]
        if not drawings then return end
        
        -- Remove all drawings
        safecall(function()
            for _, drawing in pairs(drawings) do
                if drawing and drawing.Remove then
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

    function ESP:UpdateESP(player, drawings)
        if not player or not player.Parent then return end
        if not drawings then return end
        
        -- Early exit conditions
        if not self.Enabled or player == LocalPlayer then
            self:ToggleDrawings(drawings, false)
            return
        end
        
        -- Character checks
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        
        if not (character and humanoid and rootPart and head) or humanoid.Health <= 0 then
            self:ToggleDrawings(drawings, false)
            return
        end
        
        -- Team check
        if self.TeamCheck and player.Team == LocalPlayer.Team then
            self:ToggleDrawings(drawings, false)
            return
        end
        
        -- Distance check
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > self.MaxDistance then
            self:ToggleDrawings(drawings, false)
            return
        end
        
        -- Screen position checks
        local rootPos, rootVis = worldToViewportPoint(CurrentCamera, rootPart.Position)
        if not rootVis then
            self:ToggleDrawings(drawings, false)
            return
        end
        
        -- Calculate positions
        local headPos = worldToViewportPoint(CurrentCamera, head.Position + HeadOff)
        local legPos = worldToViewportPoint(CurrentCamera, rootPart.Position - LegOff)
        
        -- Update Box
        if self.ShowBox then
            local boxSize = Vector2.new(1000 / rootPos.Z, headPos.Y - legPos.Y)
            local boxPosition = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            
            drawings.BoxOutline.Size = boxSize
            drawings.BoxOutline.Position = boxPosition
            drawings.BoxOutline.Visible = true
            
            drawings.Box.Size = boxSize
            drawings.Box.Position = boxPosition
            drawings.Box.Color = player.TeamColor.Color
            drawings.Box.Visible = true
        else
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
        end
        
        -- Update Health Bar
        if self.ShowHealth then
            local health = humanoid.Health / humanoid.MaxHealth
            local barHeight = headPos.Y - legPos.Y
            local barPosition = Vector2.new(rootPos.X - drawings.Box.Size.X/2 - 5, rootPos.Y - drawings.Box.Size.Y/2)
            
            drawings.HealthBarOutline.From = Vector2.new(barPosition.X, barPosition.Y)
            drawings.HealthBarOutline.To = Vector2.new(barPosition.X, barPosition.Y + barHeight)
            drawings.HealthBarOutline.Visible = true
            
            drawings.HealthBar.From = Vector2.new(barPosition.X, barPosition.Y + barHeight * (1 - health))
            drawings.HealthBar.To = Vector2.new(barPosition.X, barPosition.Y + barHeight)
            drawings.HealthBar.Color = Color3.new(1 - health, health, 0)
            drawings.HealthBar.Visible = true
        else
            drawings.HealthBar.Visible = false
            drawings.HealthBarOutline.Visible = false
        end
        
        -- Update Name
        if self.ShowName then
            drawings.Name.Position = Vector2.new(rootPos.X, rootPos.Y - drawings.Box.Size.Y/2 - 15)
            drawings.Name.Text = player.Name
            drawings.Name.Color = player.TeamColor.Color
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end
        
        -- Update Distance
        if self.ShowDistance then
            drawings.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + drawings.Box.Size.Y/2 + 5)
            drawings.Distance.Text = string.format("[%dm]", math.floor(distance))
            drawings.Distance.Color = player.TeamColor.Color
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
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
            
            drawings.TracerOutline.From = tracerStart
            drawings.TracerOutline.To = Vector2.new(rootPos.X, rootPos.Y)
            drawings.TracerOutline.Visible = true
            
            drawings.Tracer.From = tracerStart
            drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            drawings.Tracer.Color = player.TeamColor.Color
            drawings.Tracer.Visible = true
        else
            drawings.Tracer.Visible = false
            drawings.TracerOutline.Visible = false
        end
    end

    function ESP:ToggleDrawings(drawings, visible)
        if not drawings then return end
        
        safecall(function()
            for _, drawing in pairs(drawings) do
                if drawing and drawing.Visible ~= nil then
                    drawing.Visible = visible
                end
            end
        end)
    end

    function ESP:Toggle(state)
        self.Active = state
        self.Enabled = state
        
        -- Update visibility for all objects
        for player, drawings in pairs(self.Objects) do
            self:ToggleDrawings(drawings, state)
        end
    end

    -- Initialize ESP
    ESP:Toggle(false) -- Start disabled
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

    -- Create UI first
    local ui = UI.new()

    -- Create UI elements
    local espToggle = UI.createToggle("Enable ESP", ui.Pages.Visuals, function(state)
        ESP:Toggle(state)
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

    -- Cleanup handler
    CoreGui.ChildRemoved:Connect(function(child)
        if child.Name == "TOSIndustriesV1" then
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
            ESP:Toggle(false)
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