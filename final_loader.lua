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
        Players = {},
        Connections = {}
    }
    
    -- Aimbot System
    local Aimbot = {
        Enabled = false,
        Active = false,
        TargetPart = "Head",
        FOV = 100,
        Smoothness = 2
    }
    
    -- UI System
    local UI = {}
    local ui = nil  -- Will be initialized later
    
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
                currentTab.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                currentTab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                currentTab.Container.Visible = false
            end
            
            tab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
            tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab.Container.Visible = true
            currentTab = tab
        end
        
        for _, tab in pairs(tabs) do
            tab.Button.MouseButton1Click:Connect(function()
                selectTab(tab)
            end)
        end
        
        selectTab(tabs.Combat)
        
        -- Make the window draggable
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
        drawings.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        drawings.BoxOutline.Thickness = 3
        drawings.BoxOutline.Filled = false
        drawings.Box.Color = Color3.fromRGB(255, 255, 255)
        drawings.Box.Thickness = 1
        drawings.Box.Filled = false
        
        -- Name settings
        drawings.Name.Center = true
        drawings.Name.Outline = true
        drawings.Name.Font = 2
        drawings.Name.Size = 13
        
        -- Distance settings
        drawings.Distance.Center = true
        drawings.Distance.Outline = true
        drawings.Distance.Font = 2
        drawings.Distance.Size = 13
        
        -- Health bar settings
        drawings.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
        drawings.HealthBarOutline.Filled = true
        drawings.HealthBarOutline.Thickness = 1
        drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
        drawings.HealthBar.Filled = true
        drawings.HealthBar.Thickness = 1
        
        -- Tracer settings
        drawings.Tracer.Color = Color3.fromRGB(255, 255, 255)
        drawings.Tracer.Thickness = 1
        
        self.Players[player] = drawings
    end
    
    function ESP:RemovePlayer(player)
        local drawings = self.Players[player]
        if not drawings then return end
        
        for _, drawing in pairs(drawings) do
            if drawing then
                drawing:Remove()
            end
        end
        
        self.Players[player] = nil
    end
    
    function ESP:UpdatePlayer(player)
        if not self.Enabled then return end
        if player == LocalPlayer then return end
        
        local drawings = self.Players[player]
        if not drawings then
            self:CreatePlayer(player)
            drawings = self.Players[player]
        end
        
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if not character or not rootPart or not humanoid then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            return
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
            return
        end
        
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        local size = math.clamp(1 / (distance * 0.2), 0.1, 1)
        local boxSize = Vector2.new(1500 * size, 1900 * size)
        
        if self.Boxes then
            drawings.BoxOutline.Visible = true
            drawings.Box.Visible = true
            drawings.BoxOutline.Size = boxSize
            drawings.BoxOutline.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
            drawings.Box.Size = boxSize
            drawings.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
        else
            drawings.BoxOutline.Visible = false
            drawings.Box.Visible = false
        end
        
        if self.Names then
            drawings.Name.Visible = true
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 15)
        else
            drawings.Name.Visible = false
        end
        
        if self.Distance then
            drawings.Distance.Visible = true
            drawings.Distance.Text = math.floor(distance) .. " studs"
            drawings.Distance.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 5)
        else
            drawings.Distance.Visible = false
        end
        
        if self.Health then
            drawings.HealthBarOutline.Visible = true
            drawings.HealthBar.Visible = true
            
            local healthBarSize = Vector2.new(3, boxSize.Y)
            local healthBarPos = Vector2.new(pos.X - boxSize.X / 2 - 6, pos.Y - boxSize.Y / 2)
            local healthPercentage = humanoid.Health / humanoid.MaxHealth
            
            drawings.HealthBarOutline.Size = healthBarSize
            drawings.HealthBarOutline.Position = healthBarPos
            drawings.HealthBar.Size = Vector2.new(3, healthBarSize.Y * healthPercentage)
            drawings.HealthBar.Position = Vector2.new(healthBarPos.X, healthBarPos.Y + healthBarSize.Y * (1 - healthPercentage))
            drawings.HealthBar.Color = Color3.fromRGB(255 - 255 * healthPercentage, 255 * healthPercentage, 0)
        else
            drawings.HealthBarOutline.Visible = false
            drawings.HealthBar.Visible = false
        end
        
        if self.Tracers then
            drawings.Tracer.Visible = true
            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
        else
            drawings.Tracer.Visible = false
        end
    end
    
    function ESP:Update()
        for player in pairs(self.Players) do
            if not Players:FindFirstChild(player.Name) then
                self:RemovePlayer(player)
            end
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            self:UpdatePlayer(player)
        end
    end
    
    function Aimbot:GetClosestPlayer()
        local maxDistance = self.FOV
        local target = nil
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local part = character:FindFirstChild(self.TargetPart)
            if not part then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            
            local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
            if distance < maxDistance then
                maxDistance = distance
                target = player
            end
        end
        
        return target
    end
    
    function Aimbot:Update()
        if not self.Enabled or not self.Active then return end
        
        local target = self:GetClosestPlayer()
        if not target then return end
        
        local character = target.Character
        if not character then return end
        
        local part = character:FindFirstChild(self.TargetPart)
        if not part then return end
        
        local pos = part.Position
        local targetCF = CFrame.new(Camera.CFrame.Position, pos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / self.Smoothness)
    end
    
    -- Initialize UI
    ui = UI.new()
    
    -- Create toggles
    local aimbotToggle = UI.createToggle("Enable Aimbot", ui.Tabs.Combat.Container, function(state)
        Aimbot.Enabled = state
        fovCircle.Visible = state
    end)
    
    local espToggle = UI.createToggle("Enable ESP", ui.Tabs.Visuals.Container, function(state)
        ESP.Enabled = state
    end)
    
    local boxesToggle = UI.createToggle("Show Boxes", ui.Tabs.Visuals.Container, function(state)
        ESP.Boxes = state
    end)
    
    local namesToggle = UI.createToggle("Show Names", ui.Tabs.Visuals.Container, function(state)
        ESP.Names = state
    end)
    
    local healthToggle = UI.createToggle("Show Health", ui.Tabs.Visuals.Container, function(state)
        ESP.Health = state
    end)
    
    local distanceToggle = UI.createToggle("Show Distance", ui.Tabs.Visuals.Container, function(state)
        ESP.Distance = state
    end)
    
    local tracersToggle = UI.createToggle("Show Tracers", ui.Tabs.Visuals.Container, function(state)
        ESP.Tracers = state
    end)
    
    -- Initialize existing players
    for _, player in pairs(Players:GetPlayers()) do
        ESP:CreatePlayer(player)
    end
    
    -- Player Connections
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESP:CreatePlayer(player)
    end)
    
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP:RemovePlayer(player)
    end)
    
    -- Input Connections
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.E then
            Aimbot.Active = not Aimbot.Active
        elseif input.KeyCode == Enum.KeyCode.RightShift then
            ui.MainFrame.Visible = not ui.MainFrame.Visible
        end
    end)
    
    -- Main Loop
    RunService:BindToRenderStep("ESP", Enum.RenderPriority.Camera.Value + 1, function()
        ESP:Update()
        Aimbot:Update()
        
        if Aimbot.Enabled then
            fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
            fovCircle.Radius = Aimbot.FOV
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end)
    
    -- Cleanup
    local function cleanup()
        RunService:UnbindFromRenderStep("ESP")
        
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