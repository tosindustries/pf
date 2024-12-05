local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    
    -- ESP Settings
    local ESPSettings = {
        Enabled = false,
        TeamCheck = true,
        TeamColor = true,
        Boxes = false,
        Names = false,
        Health = false,
        Distance = false,
        Tracers = false,
        MaxDistance = 1000,
        TextSize = 13,
        BoxThickness = 2,
        BoxTransparency = 1,
        TextTransparency = 1,
        TracerTransparency = 1,
        TeamMates = false
    }
    
    -- ESP Objects Container
    local ESPObjects = {}
    
    -- Create ESP Object for a player
    local function createESPObject(player)
        if player == LocalPlayer then return end
        
        local espObject = {
            Player = player,
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"),
            HealthBarOutline = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            TracerOutline = Drawing.new("Line")
        }
        
        -- Box Settings
        espObject.Box.Thickness = ESPSettings.BoxThickness
        espObject.Box.Filled = false
        espObject.Box.Transparency = ESPSettings.BoxTransparency
        espObject.BoxOutline.Thickness = ESPSettings.BoxThickness + 1
        espObject.BoxOutline.Filled = false
        espObject.BoxOutline.Color = Color3.new(0, 0, 0)
        espObject.BoxOutline.Transparency = ESPSettings.BoxTransparency
        
        -- Name Settings
        espObject.Name.Size = ESPSettings.TextSize
        espObject.Name.Center = true
        espObject.Name.Outline = true
        espObject.Name.Transparency = ESPSettings.TextTransparency
        
        -- Distance Settings
        espObject.Distance.Size = ESPSettings.TextSize
        espObject.Distance.Center = true
        espObject.Distance.Outline = true
        espObject.Distance.Transparency = ESPSettings.TextTransparency
        
        -- Health Bar Settings
        espObject.HealthBar.Thickness = 2
        espObject.HealthBar.Filled = true
        espObject.HealthBarOutline.Thickness = 3
        espObject.HealthBarOutline.Filled = true
        espObject.HealthBarOutline.Color = Color3.new(0, 0, 0)
        
        -- Tracer Settings
        espObject.Tracer.Thickness = 1
        espObject.Tracer.Transparency = ESPSettings.TracerTransparency
        espObject.TracerOutline.Thickness = 2
        espObject.TracerOutline.Transparency = ESPSettings.TracerTransparency
        espObject.TracerOutline.Color = Color3.new(0, 0, 0)
        
        ESPObjects[player] = espObject
        return espObject
    end
    
    -- Remove ESP Object
    local function removeESPObject(player)
        local espObject = ESPObjects[player]
        if espObject then
            for _, drawing in pairs(espObject) do
                if typeof(drawing) == "table" and drawing.Remove then
                    drawing:Remove()
                end
            end
            ESPObjects[player] = nil
        end
    end
    
    -- Update ESP Object
    local function updateESPObject(espObject)
        if not ESPSettings.Enabled then
            for _, drawing in pairs(espObject) do
                if typeof(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
            return
        end
        
        local player = espObject.Player
        local character = player.Character
        if not character then
            return
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then
            return
        end
        
        -- Team Check
        if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team and not ESPSettings.TeamMates then
            return
        end
        
        -- Distance Check
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > ESPSettings.MaxDistance then
            return
        end
        
        -- Get Corners
        local box = {
            TopLeft = Camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(-2, 3, 0).Position),
            TopRight = Camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(2, 3, 0).Position),
            BottomLeft = Camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(-2, -3.5, 0).Position),
            BottomRight = Camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(2, -3.5, 0).Position)
        }
        
        -- Check if on screen
        if not box.TopLeft or not box.TopRight or not box.BottomLeft or not box.BottomRight then
            return
        end
        
        -- Calculate Box
        local boxSize = Vector2.new(
            math.max(math.abs(box.TopLeft.X - box.TopRight.X), math.abs(box.BottomLeft.X - box.BottomRight.X)),
            math.max(math.abs(box.TopLeft.Y - box.BottomLeft.Y), math.abs(box.TopRight.Y - box.BottomRight.Y))
        )
        local boxPosition = Vector2.new(
            math.min(box.TopLeft.X, box.TopRight.X, box.BottomLeft.X, box.BottomRight.X),
            math.min(box.TopLeft.Y, box.TopRight.Y, box.BottomLeft.Y, box.BottomRight.Y)
        )
        
        -- Set Color
        local color = ESPSettings.TeamColor and player.TeamColor.Color or Color3.new(1, 1, 1)
        
        -- Update Box
        if ESPSettings.Boxes then
            espObject.Box.Size = boxSize
            espObject.Box.Position = boxPosition
            espObject.Box.Color = color
            espObject.Box.Visible = true
            
            espObject.BoxOutline.Size = boxSize
            espObject.BoxOutline.Position = boxPosition
            espObject.BoxOutline.Visible = true
        else
            espObject.Box.Visible = false
            espObject.BoxOutline.Visible = false
        end
        
        -- Update Name
        if ESPSettings.Names then
            espObject.Name.Text = player.Name
            espObject.Name.Position = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y - 15)
            espObject.Name.Color = color
            espObject.Name.Visible = true
        else
            espObject.Name.Visible = false
        end
        
        -- Update Distance
        if ESPSettings.Distance then
            espObject.Distance.Text = string.format("%.0f studs", distance)
            espObject.Distance.Position = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y + boxSize.Y + 3)
            espObject.Distance.Color = color
            espObject.Distance.Visible = true
        else
            espObject.Distance.Visible = false
        end
        
        -- Update Health Bar
        if ESPSettings.Health and humanoid then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barSize = Vector2.new(2, boxSize.Y * healthPercent)
            local barPosition = Vector2.new(boxPosition.X - 5, boxPosition.Y + boxSize.Y * (1 - healthPercent))
            
            espObject.HealthBar.Size = barSize
            espObject.HealthBar.Position = barPosition
            espObject.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
            espObject.HealthBar.Visible = true
            
            espObject.HealthBarOutline.Size = Vector2.new(4, boxSize.Y)
            espObject.HealthBarOutline.Position = Vector2.new(boxPosition.X - 6, boxPosition.Y)
            espObject.HealthBarOutline.Visible = true
        else
            espObject.HealthBar.Visible = false
            espObject.HealthBarOutline.Visible = false
        end
        
        -- Update Tracer
        if ESPSettings.Tracers then
            local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            local tracerStart = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y + boxSize.Y)
            
            espObject.Tracer.From = screenCenter
            espObject.Tracer.To = tracerStart
            espObject.Tracer.Color = color
            espObject.Tracer.Visible = true
            
            espObject.TracerOutline.From = screenCenter
            espObject.TracerOutline.To = tracerStart
            espObject.TracerOutline.Visible = true
        else
            espObject.Tracer.Visible = false
            espObject.TracerOutline.Visible = false
        end
    end
    
    -- Update all ESP Objects
    local function updateESP()
        for _, espObject in pairs(ESPObjects) do
            pcall(updateESPObject, espObject)
        end
    end
    
    -- Initialize ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESPObject(player)
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        createESPObject(player)
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        removeESPObject(player)
    end)
    
    -- Update ESP
    RunService.RenderStepped:Connect(updateESP)
    
    -- Variables
    local aimbotActive = false
    local aimbotTeamCheck = true
    local aimbotVisibilityCheck = true
    local aimbotTargetMode = "Distance"
    local aimbotTargetPart = "Head"
    local aimbotSilent = false
    local aimbotAutoShoot = false
    local aimbotTriggerBot = false
    local aimbotTriggerBotDelay = 0
    local aimbotSmoothing = true
    local aimbotSmoothingAmount = 2
    local aimbotPrediction = true
    local aimbotPredictionAmount = 0.165
    local aimbotWallbang = false
    local aimbotJumpCheck = false
    local aimbotDisableOnJump = false
    local showFOV = true
    local fovSize = 120
    local lastShotTime = 0
    local SHOT_COOLDOWN = 0.1
    
    -- FOV Circle
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = true
    fovCircle.Radius = fovSize
    fovCircle.Color = Color3.fromRGB(255, 128, 0)
    fovCircle.Thickness = 1
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.NumSides = 60
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Check if point is within FOV circle
    local function isWithinFOVCircle(point)
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        return (point - screenCenter).Magnitude <= fovSize
    end
    
    -- Mouse Functions
    local function mouse1press()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true)
    end
    
    local function mouse1release()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false)
    end
    
    -- Aimbot Functions
    local function isVisible(part)
        if not part then return false end
        
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
        if not part or not aimbotPrediction then return part and part.Position end
        local distance = (part.Position - Camera.CFrame.Position).Magnitude
        local timeToHit = distance / velocity
        return part.Position + (part.Velocity * timeToHit * aimbotPredictionAmount)
    end
    
    local function canWallbang(origin, part)
        if not part or not aimbotWallbang then return false end
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
        if not LocalPlayer.Character then return nil end
        
        local players = {}
        local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, player in pairs(Players:GetPlayers()) do
            if not player or player == LocalPlayer then continue end
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
    
    -- Create UI System with Orange Theme
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    
    -- Create Window
    local Window = Library:CreateWindow({
        Title = "TOS Industries V1",
        Center = true,
        AutoShow = true,
    })
    
    -- Set Orange Theme
    Library.AccentColor = Color3.fromRGB(255, 128, 0)
    Library.AccentColorDark = Color3.fromRGB(204, 102, 0)
    Library.BackgroundColor = Color3.fromRGB(20, 20, 20)
    Library.OutlineColor = Color3.fromRGB(40, 40, 40)
    Library.FontColor = Color3.fromRGB(255, 255, 255)
    
    -- Create Tabs
    local Tabs = {
        Aimbot = Window:AddTab("Aimbot"),
        Visuals = Window:AddTab("Visuals"),
        ['UI Settings'] = Window:AddTab("Settings")
    }
    
    -- Create Groups
    local MainAimbotGroup = Tabs.Aimbot:AddLeftGroupbox("Main Settings")
    local TargetingGroup = Tabs.Aimbot:AddRightGroupbox("Targeting")
    local BehaviorGroup = Tabs.Aimbot:AddLeftGroupbox("Behavior")
    local SmoothingGroup = Tabs.Aimbot:AddRightGroupbox("Smoothing")
    local PredictionGroup = Tabs.Aimbot:AddLeftGroupbox("Prediction")
    local FOVGroup = Tabs.Aimbot:AddRightGroupbox("FOV")
    local AdvancedGroup = Tabs.Aimbot:AddLeftGroupbox("Advanced")
    
    local ESPMainGroup = Tabs.Visuals:AddLeftGroupbox("ESP Main")
    local ESPFeaturesGroup = Tabs.Visuals:AddRightGroupbox("ESP Features")
    local ESPSettingsGroup = Tabs.Visuals:AddLeftGroupbox("ESP Settings")
    
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
    
    -- ESP Main Settings
    ESPMainGroup:AddToggle("ESPEnabled", {
        Text = "Enable ESP",
        Default = false,
        Callback = function(Value)
            ESPSettings.Enabled = Value
        end
    })
    
    ESPMainGroup:AddToggle("ESPTeamCheck", {
        Text = "Team Check",
        Default = true,
        Callback = function(Value)
            ESPSettings.TeamCheck = Value
        end
    })
    
    ESPMainGroup:AddToggle("ESPTeamColor", {
        Text = "Team Color",
        Default = true,
        Callback = function(Value)
            ESPSettings.TeamColor = Value
        end
    })
    
    -- ESP Features
    ESPFeaturesGroup:AddToggle("ESPBoxes", {
        Text = "Boxes",
        Default = false,
        Callback = function(Value)
            ESPSettings.Boxes = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle("ESPHealth", {
        Text = "Health Bar",
        Default = false,
        Callback = function(Value)
            ESPSettings.Health = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle("ESPNames", {
        Text = "Names",
        Default = false,
        Callback = function(Value)
            ESPSettings.Names = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle("ESPDistance", {
        Text = "Distance",
        Default = false,
        Callback = function(Value)
            ESPSettings.Distance = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle("ESPTracers", {
        Text = "Tracers",
        Default = false,
        Callback = function(Value)
            ESPSettings.Tracers = Value
        end
    })
    
    -- ESP Settings
    ESPSettingsGroup:AddSlider("ESPMaxDistance", {
        Text = "Max Distance",
        Default = 1000,
        Min = 100,
        Max = 5000,
        Rounding = 0,
        Callback = function(Value)
            ESPSettings.MaxDistance = Value
        end
    })
    
    ESPSettingsGroup:AddSlider("ESPTextSize", {
        Text = "Text Size",
        Default = 13,
        Min = 8,
        Max = 24,
        Rounding = 0,
        Callback = function(Value)
            ESPSettings.TextSize = Value
            for _, espObject in pairs(ESPObjects) do
                espObject.Name.Size = Value
                espObject.Distance.Size = Value
            end
        end
    })
    
    ESPSettingsGroup:AddSlider("ESPBoxThickness", {
        Text = "Box Thickness",
        Default = 2,
        Min = 1,
        Max = 5,
        Rounding = 0,
        Callback = function(Value)
            ESPSettings.BoxThickness = Value
            for _, espObject in pairs(ESPObjects) do
                espObject.Box.Thickness = Value
                espObject.BoxOutline.Thickness = Value + 1
            end
        end
    })
    
    -- Settings Tab
    local SettingsGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu Settings')
    
    SettingsGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
        Default = 'RightShift',
        NoUI = true,
        Text = 'Menu keybind'
    })
    
    SettingsGroup:AddToggle('Keybinds', {
        Text = 'Show Keybinds',
        Default = true,
        Callback = function(Value)
            Library.KeybindFrame.Visible = Value
        end
    })
    
    SettingsGroup:AddToggle('Watermark', {
        Text = 'Show Watermark',
        Default = true,
        Callback = function(Value)
            Library:SetWatermarkVisibility(Value)
        end
    })
    
    -- Initialize ESP
    ESP.Players = true
    ESP.Boxes = true
    ESP.Names = true
    ESP.Health = true
    ESP.Distance = true
    ESP.Tracers = true
    ESP.TeamColor = true
    ESP.TeamMates = false
    ESP.FaceCamera = true
    ESP.AutoRemove = true
    
    -- Create ESP container
    local container = Instance.new("Folder")
    container.Name = "ESP_Container"
    container.Parent = game.CoreGui
    
    -- Initialize ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP:Add(player, {
                Name = player.Name,
                Player = player,
                PrimaryPart = "HumanoidRootPart",
                Color = player.TeamColor.Color,
                IsEnabled = "ESP_Enabled"
            })
        end
    end
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        ESP:Add(player, {
            Name = player.Name,
            Player = player,
            PrimaryPart = "HumanoidRootPart",
            Color = player.TeamColor.Color,
            IsEnabled = "ESP_Enabled"
        })
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        ESP:Remove(player)
    end)
    
    -- Update aimbot
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if showFOV and fovCircle then
                fovCircle.Visible = true
                fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            else
                fovCircle.Visible = false
            end
            
            if not aimbotActive then return end
            if not LocalPlayer.Character then return end
            
            if aimbotDisableOnJump and LocalPlayer.Character and 
               LocalPlayer.Character:FindFirstChild("Humanoid") and 
               LocalPlayer.Character.Humanoid.FloorMaterial == Enum.Material.Air then return end
            
            local target = getTargetPlayer()
            if not target or not target.Part then return end
            
            local predictedPos = predictPosition(target.Part, 1000)
            if not predictedPos then return end
            
            if not aimbotSilent then
                local cameraPosition = Camera.CFrame.Position
                local direction = (predictedPos - cameraPosition).Unit
                
                local x = math.atan2(direction.X, direction.Z)
                local y = math.asin(direction.Y)
                
                local currentX, currentY = Camera.CFrame:ToEulerAnglesYXZ()
                
                if aimbotSmoothing then
                    local deltaX = (x - currentX) / aimbotSmoothingAmount
                    local deltaY = (y - currentY) / aimbotSmoothingAmount
                    
                    Camera.CFrame = CFrame.new(cameraPosition) 
                        * CFrame.Angles(0, currentX + deltaX, 0) 
                        * CFrame.Angles(currentY + deltaY, 0, 0)
                else
                    Camera.CFrame = CFrame.new(cameraPosition) 
                        * CFrame.Angles(0, x, 0) 
                        * CFrame.Angles(y, 0, 0)
                end
            end
            
            if aimbotAutoShoot and tick() - lastShotTime > SHOT_COOLDOWN then
                local _, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    mouse1press()
                    wait()
                    mouse1release()
                    lastShotTime = tick()
                end
            end
            
            if aimbotTriggerBot then
                local ray = Camera:ScreenPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
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
    end)
    
    -- Silent aim implementation
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if aimbotSilent and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast") and not checkcaller() then
            local target = getClosestPlayerToCursor()
            if target and target.Part then
                -- Double check FOV
                if not isWithinFOVCircle(target.ScreenPosition) then
                    return oldNamecall(self, unpack(args))
                end
                
                -- Force hit the target part
                if method == "Raycast" then
                    return {
                        Instance = target.Part,
                        Position = target.Part.Position,
                        Normal = (Camera.CFrame.Position - target.Part.Position).Unit,
                        Material = target.Part.Material
                    }
                else
                    -- For FindPartOnRay methods
                    return target.Part, target.Part.Position
                end
            end
        end
        
        return oldNamecall(self, unpack(args))
    end)

    -- Improved hit registration
    local oldIndex = nil
    oldIndex = hookmetamethod(game, "__index", function(self, index)
        if aimbotSilent and not checkcaller() then
            if index == "Hit" or index == "Target" then
                local target = getClosestPlayerToCursor()
                if target and target.Part and isWithinFOVCircle(target.ScreenPosition) then
                    return target.Part
                end
            elseif index == "HitPos" then
                local target = getClosestPlayerToCursor()
                if target and target.Part and isWithinFOVCircle(target.ScreenPosition) then
                    return target.Part.Position
                end
            end
        end
        
        return oldIndex(self, index)
    end)

    -- Improved target selection
    local function getClosestPlayerToCursor()
        local closestPlayer = nil
        local shortestDistance = math.huge
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if not player or player == LocalPlayer then continue end
            if aimbotTeamCheck and player.Team == LocalPlayer.Team then continue end

            local character = player.Character
            if not character then continue end

            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end

            local part = character:FindFirstChild(aimbotTargetPart)
            if not part then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end

            local screenPos = Vector2.new(pos.X, pos.Y)
            if not isWithinFOVCircle(screenPos) then continue end

            local distance = (screenPos - screenCenter).Magnitude
            if distance < shortestDistance then
                closestPlayer = {
                    Player = player,
                    Character = character,
                    Part = part,
                    Position = pos,
                    Distance = distance,
                    ScreenPosition = screenPos
                }
                shortestDistance = distance
            end
        end

        return closestPlayer
    end

    -- Cleanup
    Library:OnUnload(function()
        if fovCircle then
            fovCircle:Remove()
        end
        ESP:Toggle(false)
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