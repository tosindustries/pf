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

    return true
end

local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result