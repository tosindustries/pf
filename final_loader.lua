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
    
    -- Aimbot System
    local Aimbot = {
        Enabled = false,
        Active = false,
        TargetPart = "Head",
        FOV = 100,
        Smoothness = 2
    }
    
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
    
    -- UI System
    // ... rest of UI code ...
    
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
    
    -- Player Connections
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESP:CreatePlayer(player)
    end)
    
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP:RemovePlayer(player)
    end)
    
    -- Initialize existing players
    for _, player in pairs(Players:GetPlayers()) do
        ESP:CreatePlayer(player)
    end
    
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
    end
    
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child == ui.ScreenGui then
            cleanup()
        end
    end)
    
    return true
end

startScript()