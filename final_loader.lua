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
        
        -- Rest of your UI code...
        -- (Keep all the existing UI creation code here)
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