local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    if game.PlaceId ~= 292439477 then return false end
    
    -- Core Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local Camera = workspace.CurrentCamera
    
    local LocalPlayer = Players.LocalPlayer
    
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
    for _, player in pairs(Players:GetPlayers()) do
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
    local aimbotTargetMode = "Distance"
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
    
    -- Initialize FOV Circle
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = showFOV
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
        
        if aimbotTargetMode == "Distance" then
            table.sort(players, function(a, b) return a.Distance < b.Distance end)
        elseif aimbotTargetMode == "Health" then
            table.sort(players, function(a, b) return a.Health < b.Health end)
        elseif aimbotTargetMode == "Random" then
            return players[math.random(1, #players)]
        end
        
        return players[1]
    end
    
    -- Create UI System
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    local Window = Library:CreateWindow("TOS Industries V1")
    
    -- Create Tabs
    local AimbotTab = Window:AddTab("Aimbot")
    local VisualsTab = Window:AddTab("Visuals")
    
    -- Create Groups
    local MainAimbotGroup = AimbotTab:AddLeftGroupbox("Main Settings")
    local TargetingGroup = AimbotTab:AddRightGroupbox("Targeting")
    local BehaviorGroup = AimbotTab:AddLeftGroupbox("Behavior")
    local SmoothingGroup = AimbotTab:AddRightGroupbox("Smoothing")
    local PredictionGroup = AimbotTab:AddLeftGroupbox("Prediction")
    local FOVGroup = AimbotTab:AddRightGroupbox("FOV")
    local AdvancedGroup = AimbotTab:AddLeftGroupbox("Advanced")
    
    local ESPGroup = VisualsTab:AddLeftGroupbox("ESP")
    local ESPSettingsGroup = VisualsTab:AddRightGroupbox("ESP Settings")
    
    -- Main Aimbot Settings
    MainAimbotGroup:AddToggle("AimbotEnabled", {
        Text = "Enable Aimbot",
        Default = false,
        Callback = function(Value)
            aimbotActive = Value
        end
    })
    
    MainAimbotGroup:AddToggle("TeamCheck", {
        Text = "Team Check",
        Default = true,
        Callback = function(Value)
            aimbotTeamCheck = Value
        end
    })
    
    MainAimbotGroup:AddToggle("VisibilityCheck", {
        Text = "Visibility Check",
        Default = true,
        Callback = function(Value)
            aimbotVisibilityCheck = Value
        end
    })
    
    -- Targeting Settings
    TargetingGroup:AddDropdown("TargetMode", {
        Text = "Target Mode",
        Default = "Distance",
        Values = {"Distance", "Health", "Random"},
        Callback = function(Value)
            aimbotTargetMode = Value
        end
    })
    
    TargetingGroup:AddDropdown("TargetPart", {
        Text = "Target Part",
        Default = "Head",
        Values = {"Head", "HumanoidRootPart", "Torso"},
        Callback = function(Value)
            aimbotTargetPart = Value
        end
    })
    
    -- Behavior Settings
    BehaviorGroup:AddToggle("SilentAim", {
        Text = "Silent Aim",
        Default = false,
        Callback = function(Value)
            aimbotSilent = Value
        end
    })
    
    BehaviorGroup:AddToggle("AutoShoot", {
        Text = "Auto Shoot",
        Default = false,
        Callback = function(Value)
            aimbotAutoShoot = Value
        end
    })
    
    BehaviorGroup:AddToggle("TriggerBot", {
        Text = "Trigger Bot",
        Default = false,
        Callback = function(Value)
            aimbotTriggerBot = Value
        end
    })
    
    BehaviorGroup:AddSlider("TriggerDelay", {
        Text = "Trigger Delay (ms)",
        Default = 0,
        Min = 0,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
            aimbotTriggerBotDelay = Value / 1000
        end
    })
    
    BehaviorGroup:AddToggle("AutoReload", {
        Text = "Auto Reload",
        Default = false,
        Callback = function(Value)
            aimbotAutoReload = Value
        end
    })
    
    -- Smoothing Settings
    SmoothingGroup:AddToggle("Smoothing", {
        Text = "Use Smoothing",
        Default = true,
        Callback = function(Value)
            aimbotSmoothing = Value
        end
    })
    
    SmoothingGroup:AddSlider("SmoothingAmount", {
        Text = "Smoothing Amount",
        Default = 2,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(Value)
            aimbotSmoothingAmount = Value
        end
    })
    
    -- Prediction Settings
    PredictionGroup:AddToggle("Prediction", {
        Text = "Enable Prediction",
        Default = true,
        Callback = function(Value)
            aimbotPrediction = Value
        end
    })
    
    PredictionGroup:AddSlider("PredictionAmount", {
        Text = "Prediction Amount",
        Default = 0.165,
        Min = 0,
        Max = 1,
        Rounding = 3,
        Callback = function(Value)
            aimbotPredictionAmount = Value
        end
    })
    
    -- FOV Settings
    FOVGroup:AddToggle("ShowFOV", {
        Text = "Show FOV",
        Default = true,
        Callback = function(Value)
            showFOV = Value
            if fovCircle then
                fovCircle.Visible = Value
            end
        end
    })
    
    FOVGroup:AddSlider("FOVSize", {
        Text = "FOV Size",
        Default = 120,
        Min = 30,
        Max = 800,
        Rounding = 0,
        Callback = function(Value)
            fovSize = Value
            if fovCircle then
                fovCircle.Radius = Value
            end
        end
    })
    
    -- Advanced Settings
    AdvancedGroup:AddToggle("Wallbang", {
        Text = "Wallbang",
        Default = false,
        Callback = function(Value)
            aimbotWallbang = Value
        end
    })
    
    AdvancedGroup:AddToggle("JumpCheck", {
        Text = "Jump Check",
        Default = false,
        Callback = function(Value)
            aimbotJumpCheck = Value
        end
    })
    
    AdvancedGroup:AddToggle("DisableOnJump", {
        Text = "Disable While Jumping",
        Default = false,
        Callback = function(Value)
            aimbotDisableOnJump = Value
        end
    })
    
    -- ESP Settings
    ESPGroup:AddToggle("ESPEnabled", {
        Text = "Enable ESP",
        Default = false,
        Callback = function(Value)
            ESP.Enabled = Value
        end
    })
    
    ESPGroup:AddToggle("BoxESP", {
        Text = "Show Boxes",
        Default = true,
        Callback = function(Value)
            ESP.ShowBox = Value
        end
    })
    
    ESPGroup:AddToggle("HealthESP", {
        Text = "Show Health",
        Default = true,
        Callback = function(Value)
            ESP.ShowHealth = Value
        end
    })
    
    ESPGroup:AddToggle("NameESP", {
        Text = "Show Names",
        Default = true,
        Callback = function(Value)
            ESP.ShowName = Value
        end
    })
    
    ESPGroup:AddToggle("DistanceESP", {
        Text = "Show Distance",
        Default = true,
        Callback = function(Value)
            ESP.ShowDistance = Value
        end
    })
    
    ESPGroup:AddToggle("TracerESP", {
        Text = "Show Tracers",
        Default = true,
        Callback = function(Value)
            ESP.ShowTracer = Value
        end
    })
    
    -- ESP Settings
    ESPSettingsGroup:AddToggle("ESPTeamCheck", {
        Text = "Team Check",
        Default = true,
        Callback = function(Value)
            ESP.TeamCheck = Value
        end
    })
    
    ESPSettingsGroup:AddDropdown("TracerOrigin", {
        Text = "Tracer Origin",
        Default = "Bottom",
        Values = {"Bottom", "Mouse", "Top"},
        Callback = function(Value)
            ESP.TracerOrigin = Value
        end
    })
    
    ESPSettingsGroup:AddSlider("ESPDistance", {
        Text = "ESP Distance",
        Default = 1000,
        Min = 100,
        Max = 2000,
        Rounding = 0,
        Callback = function(Value)
            ESP.MaxDistance = Value
        end
    })
    
    -- Update FOV Circle and Aimbot
    RunService.RenderStepped:Connect(function()
        if showFOV and fovCircle then
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
        
        if aimbotSilent then
            -- Silent aim implementation
        else
            if aimbotSmoothing then
                mousePos = mousePos:Lerp(aimPos, 1 / aimbotSmoothingAmount)
            else
                mousePos = aimPos
            end
            
            mousemoverel(mousePos.X - UserInputService:GetMouseLocation().X, mousePos.Y - UserInputService:GetMouseLocation().Y)
        end
        
        if aimbotAutoShoot and tick() - lastShotTime > SHOT_COOLDOWN then
            mouse1press()
            wait()
            mouse1release()
            lastShotTime = tick()
        end
        
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
    
    -- Add keybinds
    Library:OnUnload(function()
        if fovCircle then
            fovCircle:Remove()
        end
        ESP.Enabled = false
        for player, _ in pairs(ESP.Objects) do
            ESP:RemoveObject(player)
        end
        Library.Unloaded = true
    end)
    
    -- Initialize menu
    Library:SetWatermarkVisibility(true)
    Library:SetWatermark("TOS Industries V1")
    
    Library.KeybindFrame.Visible = false
    Library:ToggleKeybind(Enum.KeyCode.RightShift)
    
    Library:Notify("Script loaded successfully!", 5)
    
    return true
end

local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result