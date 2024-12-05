local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    if game.PlaceId ~= 292439477 then return false end
    
    -- Core Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local Camera = workspace.CurrentCamera
    
    local LocalPlayer = Players.LocalPlayer
    
    -- Variables
    local aimbotActive = false
    local aimbotTeamCheck = true
    local aimbotVisibilityCheck = true
    local aimbotSmoothing = true
    local aimbotSmoothingAmount = 2
    local showFOV = true
    local fovSize = 120
    local aimbotTargetPart = "Head"
    local aimbotPrediction = true
    local aimbotPredictionAmount = 0.165
    local aimbotTargetMode = "Distance" -- Distance, Health, Random
    local aimbotTriggerBot = false
    local aimbotTriggerBotDelay = 0
    local aimbotSilent = false
    local aimbotWallbang = false
    local aimbotAutoShoot = false
    local aimbotAutoReload = false
    local aimbotJumpCheck = false
    local aimbotDisableOnJump = false
    local lastToggleTime = 0
    local TOGGLE_COOLDOWN = 0.3
    local lastShotTime = 0
    local SHOT_COOLDOWN = 0.1
    
    -- FOV Circle
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Radius = fovSize
    fovCircle.Color = Color3.new(1, 1, 1)
    fovCircle.Thickness = 1
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.NumSides = 60
    
    -- Aimbot Functions
    local function isVisible(part)
        local origin = Camera.CFrame.Position
        local _, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then return false end
        
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local direction = (part.Position - origin).Unit
        local distance = (part.Position - origin).Magnitude
        
        local result = workspace:Raycast(origin, direction * distance, rayParams)
        return not result or result.Instance == part
    end
    
    local function predictPosition(part, velocity)
        if not aimbotPrediction then return part.Position end
        local distance = (part.Position - Camera.CFrame.Position).Magnitude
        local timeToHit = distance / velocity
        return part.Position + (part.Velocity * timeToHit * aimbotPredictionAmount)
    end
    
    local function canWallbang(origin, part)
        if not aimbotWallbang then return false end
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
        
        local direction = (part.Position - origin).Unit
        local distance = (part.Position - origin).Magnitude
        local result = workspace:Raycast(origin, direction * distance, rayParams)
        
        return result and result.Material and (
            result.Material == Enum.Material.Glass or
            result.Material == Enum.Material.Wood or
            result.Material == Enum.Material.WoodPlanks or
            result.Material == Enum.Material.Plastic
        )
    end
    
    local function getTargetPlayer()
        local players = {}
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if aimbotTeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local part = character:FindFirstChild(aimbotTargetPart)
            if not part then continue end
            
            if aimbotVisibilityCheck and not (isVisible(part) or canWallbang(Camera.CFrame.Position, part)) then continue end
            
            if aimbotJumpCheck then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root and math.abs(root.Velocity.Y) > 0.1 then continue end
            end
            
            local pos = Camera:WorldToViewportPoint(part.Position)
            if not pos then continue end
            
            local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
            if distance > fovSize then continue end
            
            table.insert(players, {
                Player = player,
                Character = character,
                Humanoid = humanoid,
                Part = part,
                Distance = distance,
                Health = humanoid.Health,
                Position = pos
            })
        end
        
        if #players == 0 then return nil end
        
        -- Sort based on targeting mode
        if aimbotTargetMode == "Distance" then
            table.sort(players, function(a, b) return a.Distance < b.Distance end)
        elseif aimbotTargetMode == "Health" then
            table.sort(players, function(a, b) return a.Health < b.Health end)
        elseif aimbotTargetMode == "Random" then
            return players[math.random(1, #players)]
        end
        
        return players[1]
    end
    
    -- ESP System
    local ESP = {
        Enabled = false,
        TeamCheck = true,
        ShowBox = true,
        ShowHealth = true,
        ShowName = true,
        ShowDistance = true,
        ShowTracer = true,
        MaxDistance = 1000,
        BoxThickness = 2,
        TracerThickness = 1,
        TracerOrigin = "Bottom",
        TextSize = 13,
        Objects = {},
        Connections = {}
    }
    
    function ESP:CreateObject(player)
        if not player or not player.Parent then return end
        if self.Objects[player] then return end
        
        -- Box
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = self.BoxThickness
        box.Filled = false
        box.Transparency = 1
        
        -- Box outline
        local boxOutline = Drawing.new("Square")
        boxOutline.Visible = false
        boxOutline.Color = Color3.new(0, 0, 0)
        boxOutline.Thickness = self.BoxThickness + 2
        boxOutline.Filled = false
        boxOutline.Transparency = 1
        
        -- Health bar background
        local healthBG = Drawing.new("Square")
        healthBG.Visible = false
        healthBG.Color = Color3.new(1, 0, 0)
        healthBG.Filled = true
        healthBG.Thickness = 1
        healthBG.Transparency = 1
        
        -- Health bar
        local healthBar = Drawing.new("Square")
        healthBar.Visible = false
        healthBar.Color = Color3.new(0, 1, 0)
        healthBar.Filled = true
        healthBar.Thickness = 1
        healthBar.Transparency = 1
        
        -- Name
        local name = Drawing.new("Text")
        name.Visible = false
        name.Center = true
        name.Outline = true
        name.Size = self.TextSize
        name.Font = 2
        name.Color = Color3.new(1, 1, 1)
        
        -- Distance
        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Center = true
        distance.Outline = true
        distance.Size = self.TextSize
        distance.Font = 2
        distance.Color = Color3.new(1, 1, 1)
        
        -- Tracer
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = self.TracerThickness
        tracer.Transparency = 1
        
        -- Tracer outline
        local tracerOutline = Drawing.new("Line")
        tracerOutline.Visible = false
        tracerOutline.Color = Color3.new(0, 0, 0)
        tracerOutline.Thickness = self.TracerThickness + 2
        tracerOutline.Transparency = 1
        
        self.Objects[player] = {
            Box = box,
            BoxOutline = boxOutline,
            HealthBG = healthBG,
            HealthBar = healthBar,
            Name = name,
            Distance = distance,
            Tracer = tracer,
            TracerOutline = tracerOutline
        }
        
        self.Connections[player] = RunService.RenderStepped:Connect(function()
            if not self.Enabled then
                for _, drawing in pairs(self.Objects[player]) do
                    drawing.Visible = false
                end
                return
            end
            
            local character = player.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not rootPart or humanoid.Health <= 0 then return end
            
            if self.TeamCheck and player.Team == LocalPlayer.Team then return end
            
            local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
            if distance > self.MaxDistance then return end
            
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if not onScreen then return end
            
            -- Calculate box size
            local size = (Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2.5, 0)).Y) / 2
            local boxSize = Vector2.new(size * 1.5, size * 3)
            local boxPosition = Vector2.new(pos.X - size * 1.5 / 2, pos.Y - size * 1.5)
            
            -- Update box
            if self.ShowBox then
                boxOutline.Size = boxSize
                boxOutline.Position = boxPosition
                boxOutline.Visible = true
                
                box.Size = boxSize
                box.Position = boxPosition
                box.Color = player.TeamColor.Color
                box.Visible = true
            else
                box.Visible = false
                boxOutline.Visible = false
            end
            
            -- Update health bar
            if self.ShowHealth then
                local health = humanoid.Health / humanoid.MaxHealth
                local barHeight = boxSize.Y
                local barWidth = 4
                
                healthBG.Size = Vector2.new(barWidth, barHeight)
                healthBG.Position = Vector2.new(boxPosition.X - barWidth * 2, boxPosition.Y)
                healthBG.Visible = true
                
                healthBar.Size = Vector2.new(barWidth, barHeight * health)
                healthBar.Position = Vector2.new(boxPosition.X - barWidth * 2, boxPosition.Y + barHeight * (1 - health))
                healthBar.Color = Color3.new(1 - health, health, 0)
                healthBar.Visible = true
            else
                healthBG.Visible = false
                healthBar.Visible = false
            end
            
            -- Update name
            if self.ShowName then
                name.Position = Vector2.new(pos.X, boxPosition.Y - 15)
                name.Text = player.Name
                name.Color = player.TeamColor.Color
                name.Visible = true
            else
                name.Visible = false
            end
            
            -- Update distance
            if self.ShowDistance then
                distance.Position = Vector2.new(pos.X, boxPosition.Y + boxSize.Y + 5)
                distance.Text = string.format("[%dm]", math.floor(distance))
                distance.Color = player.TeamColor.Color
                distance.Visible = true
            else
                distance.Visible = false
            end
            
            -- Update tracer
            if self.ShowTracer then
                local tracerStart
                if self.TracerOrigin == "Bottom" then
                    tracerStart = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                elseif self.TracerOrigin == "Mouse" then
                    tracerStart = UserInputService:GetMouseLocation()
                else -- Top
                    tracerStart = Vector2.new(Camera.ViewportSize.X/2, 0)
                end
                
                tracerOutline.From = tracerStart
                tracerOutline.To = Vector2.new(pos.X, pos.Y)
                tracerOutline.Visible = true
                
                tracer.From = tracerStart
                tracer.To = Vector2.new(pos.X, pos.Y)
                tracer.Color = player.TeamColor.Color
                tracer.Visible = true
            else
                tracer.Visible = false
                tracerOutline.Visible = false
            end
        end)
    end
    
    function ESP:RemoveObject(player)
        local objects = self.Objects[player]
        if not objects then return end
        
        for _, drawing in pairs(objects) do
            drawing:Remove()
        end
        
        if self.Connections[player] then
            self.Connections[player]:Disconnect()
            self.Connections[player] = nil
        end
        
        self.Objects[player] = nil
    end
    
    function ESP:Toggle(state)
        self.Enabled = state
    end
    
    -- Initialize ESP
    for _, player in pairs(Players:GetChildren()) do
        if player ~= LocalPlayer then
            ESP:CreateObject(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        ESP:CreateObject(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        ESP:RemoveObject(player)
    end)
    
    -- Create UI System
    local UI = {
        new = function()
            local ui = {}
            ui.Pages = {
                Aimbot = Instance.new("Frame"),
                Visuals = Instance.new("Frame")
            }
            ui.MainFrame = Instance.new("Frame")
            return ui
        end,
        
        createToggle = function(text, parent, callback)
            local toggle = {}
            toggle.SetState = function(state)
                callback(state)
            end
            return toggle
        end,
        
        createSlider = function(text, parent, min, max, default, callback)
            local slider = {}
            slider.SetValue = function(value)
                callback(value)
            end
            return slider
        end,
        
        createDropdown = function(text, parent, options, callback)
            local dropdown = {}
            dropdown.SetValue = function(value)
                callback(value)
            end
            return dropdown
        end,
        
        createLabel = function(text, parent)
            -- Create label
        end
    }
    
    -- Create UI elements
    local ui = UI.new()
    
    -- Aimbot Page
    local aimbotPage = ui.Pages.Aimbot
    
    -- Main Aimbot Settings
    local aimbotToggle = UI.createToggle("Enable Aimbot", aimbotPage, function(state)
        aimbotActive = state
    end)
    
    local aimbotTeamCheckToggle = UI.createToggle("Team Check", aimbotPage, function(state)
        aimbotTeamCheck = state
    end)
    
    local aimbotVisibilityCheckToggle = UI.createToggle("Visibility Check", aimbotPage, function(state)
        aimbotVisibilityCheck = state
    end)
    
    -- Aimbot Targeting Section
    UI.createLabel("Targeting", aimbotPage)
    
    local aimbotTargetModeDropdown = UI.createDropdown("Target Mode", aimbotPage, {"Distance", "Health", "Random"}, function(value)
        aimbotTargetMode = value
    end)
    
    local aimbotTargetPartDropdown = UI.createDropdown("Target Part", aimbotPage, {"Head", "HumanoidRootPart", "Torso"}, function(value)
        aimbotTargetPart = value
    end)
    
    -- Aimbot Behavior Section
    UI.createLabel("Behavior", aimbotPage)
    
    local aimbotSilentToggle = UI.createToggle("Silent Aim", aimbotPage, function(state)
        aimbotSilent = state
    end)
    
    local aimbotAutoShootToggle = UI.createToggle("Auto Shoot", aimbotPage, function(state)
        aimbotAutoShoot = state
    end)
    
    local aimbotTriggerBotToggle = UI.createToggle("Trigger Bot", aimbotPage, function(state)
        aimbotTriggerBot = state
    end)
    
    local aimbotTriggerBotDelaySlider = UI.createSlider("Trigger Delay (ms)", aimbotPage, 0, 500, 0, function(value)
        aimbotTriggerBotDelay = value / 1000
    end)
    
    local aimbotAutoReloadToggle = UI.createToggle("Auto Reload", aimbotPage, function(state)
        aimbotAutoReload = state
    end)
    
    -- Aimbot Smoothing Section
    UI.createLabel("Smoothing", aimbotPage)
    
    local aimbotSmoothingToggle = UI.createToggle("Use Smoothing", aimbotPage, function(state)
        aimbotSmoothing = state
    end)
    
    local aimbotSmoothingSlider = UI.createSlider("Smoothing Amount", aimbotPage, 1, 10, 2, function(value)
        aimbotSmoothingAmount = value
    end)
    
    -- Aimbot Prediction Section
    UI.createLabel("Prediction", aimbotPage)
    
    local aimbotPredictionToggle = UI.createToggle("Enable Prediction", aimbotPage, function(state)
        aimbotPrediction = state
    end)
    
    local aimbotPredictionSlider = UI.createSlider("Prediction Amount", aimbotPage, 0, 1, 0.165, function(value)
        aimbotPredictionAmount = value
    end)
    
    -- Aimbot FOV Section
    UI.createLabel("FOV", aimbotPage)
    
    local aimbotFOVToggle = UI.createToggle("Show FOV", aimbotPage, function(state)
        showFOV = state
        fovCircle.Visible = state
    end)
    
    local aimbotFOVSlider = UI.createSlider("FOV Size", aimbotPage, 30, 800, 120, function(value)
        fovSize = value
        fovCircle.Radius = value
    end)
    
    -- Aimbot Advanced Section
    UI.createLabel("Advanced", aimbotPage)
    
    local aimbotWallbangToggle = UI.createToggle("Wallbang", aimbotPage, function(state)
        aimbotWallbang = state
    end)
    
    local aimbotJumpCheckToggle = UI.createToggle("Jump Check", aimbotPage, function(state)
        aimbotJumpCheck = state
    end)
    
    local aimbotDisableOnJumpToggle = UI.createToggle("Disable While Jumping", aimbotPage, function(state)
        aimbotDisableOnJump = state
    end)
    
    -- Visuals Page
    local visualsPage = ui.Pages.Visuals
    
    -- ESP Settings
    local espToggle = UI.createToggle("Enable ESP", visualsPage, function(state)
        ESP:Toggle(state)
    end)
    
    local boxToggle = UI.createToggle("Show Boxes", visualsPage, function(state)
        ESP.ShowBox = state
    end)
    
    local healthToggle = UI.createToggle("Show Health", visualsPage, function(state)
        ESP.ShowHealth = state
    end)
    
    local nameToggle = UI.createToggle("Show Names", visualsPage, function(state)
        ESP.ShowName = state
    end)
    
    local distanceToggle = UI.createToggle("Show Distance", visualsPage, function(state)
        ESP.ShowDistance = state
    end)
    
    local tracerToggle = UI.createToggle("Show Tracers", visualsPage, function(state)
        ESP.ShowTracer = state
    end)
    
    local teamCheckToggle = UI.createToggle("Team Check", visualsPage, function(state)
        ESP.TeamCheck = state
    end)
    
    local tracerOriginDropdown = UI.createDropdown("Tracer Origin", visualsPage, {"Bottom", "Mouse", "Top"}, function(value)
        ESP.TracerOrigin = value
    end)
    
    local distanceSlider = UI.createSlider("ESP Distance", visualsPage, 100, 2000, 1000, function(value)
        ESP.MaxDistance = value
    end)
    
    -- Set initial states
    aimbotToggle.SetState(false)
    aimbotTeamCheckToggle.SetState(true)
    aimbotVisibilityCheckToggle.SetState(true)
    aimbotSmoothingToggle.SetState(true)
    aimbotSmoothingSlider.SetValue(2)
    aimbotFOVToggle.SetState(true)
    aimbotFOVSlider.SetValue(120)
    aimbotTargetPartDropdown.SetValue("Head")
    aimbotTargetModeDropdown.SetValue("Distance")
    aimbotPredictionToggle.SetState(true)
    aimbotPredictionSlider.SetValue(0.165)
    aimbotSilentToggle.SetState(false)
    aimbotAutoShootToggle.SetState(false)
    aimbotTriggerBotToggle.SetState(false)
    aimbotTriggerBotDelaySlider.SetValue(0)
    aimbotWallbangToggle.SetState(false)
    aimbotJumpCheckToggle.SetState(false)
    aimbotDisableOnJumpToggle.SetState(false)
    aimbotAutoReloadToggle.SetState(false)
    
    espToggle.SetState(false)
    boxToggle.SetState(true)
    healthToggle.SetState(true)
    nameToggle.SetState(true)
    distanceToggle.SetState(true)
    tracerToggle.SetState(true)
    teamCheckToggle.SetState(true)
    tracerOriginDropdown.SetValue("Bottom")
    distanceSlider.SetValue(1000)
    
    -- Update FOV Circle and Aimbot
    RunService.RenderStepped:Connect(function()
        if showFOV then
            fovCircle.Position = UserInputService:GetMouseLocation()
        end
        
        if not aimbotActive then return end
        if aimbotDisableOnJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and 
           math.abs(LocalPlayer.Character.Humanoid.FloorMaterial.Name) == "Air" then return end
        
        local target = getTargetPlayer()
        if not target then return end
        
        local mousePos = UserInputService:GetMouseLocation()
        local predictedPos = predictPosition(target.Part, 1000)
        local pos = Camera:WorldToViewportPoint(predictedPos)
        local aimPos = Vector2.new(pos.X, pos.Y)
        
        -- Handle different aim modes
        if aimbotSilent then
            -- Silent aim implementation would go here
            -- This requires game-specific mouse event hooking
        else
            if aimbotSmoothing then
                mousePos = mousePos:Lerp(aimPos, 1 / aimbotSmoothingAmount)
            else
                mousePos = aimPos
            end
            
            mousemoverel(mousePos.X - UserInputService:GetMouseLocation().X, mousePos.Y - UserInputService:GetMouseLocation().Y)
        end
        
        -- Handle auto shooting
        if aimbotAutoShoot and tick() - lastShotTime > SHOT_COOLDOWN then
            mouse1press()
            wait()
            mouse1release()
            lastShotTime = tick()
        end
        
        -- Handle trigger bot
        if aimbotTriggerBot then
            local ray = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
            
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
            if result and result.Instance and result.Instance:IsDescendantOf(target.Character) then
                wait(aimbotTriggerBotDelay)
                mouse1press()
                wait()
                mouse1release()
            end
        end
    end)
    
    -- Add toggle keys
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            local currentTime = tick()
            if currentTime - lastToggleTime >= TOGGLE_COOLDOWN then
                ui.MainFrame.Visible = not ui.MainFrame.Visible
                lastToggleTime = currentTime
            end
        elseif input.KeyCode == Enum.KeyCode.E then
            aimbotToggle.SetState(not aimbotActive)
        end
    end)
    
    -- Cleanup handler
    CoreGui.ChildRemoved:Connect(function(child)
        if child.Name == "TOSIndustriesV1" then
            for player, _ in pairs(ESP.Objects) do
                ESP:RemoveObject(player)
            end
            ESP.Enabled = false
            fovCircle:Remove()
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