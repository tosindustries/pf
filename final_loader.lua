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
    local Mouse = LocalPlayer:GetMouse()
    
    -- Load ESP Library
    local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
    
    -- Initialize ESP
    ESP:Toggle(true)
    ESP.TeamColor = true
    ESP.Names = false
    ESP.Boxes = false
    ESP.Tracers = false
    ESP.Health = false
    ESP.Distance = false
    ESP.Skeleton = false
    ESP.TeamMates = true
    ESP.FaceCamera = true
    ESP.AutoRemove = true
    ESP.MaxDistance = 1000
    ESP.TextSize = 13
    ESP.BoxThickness = 2
    
    -- Skeleton Points
    ESP.SkeletonPoints = {
        Head = "Head",
        Torso = "HumanoidRootPart",
        LeftArm = "Left Arm",
        RightArm = "Right Arm",
        LeftLeg = "Left Leg",
        RightLeg = "Right Leg"
    }
    
    -- Variables for aimbot
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
    fovCircle.Color = Color3.fromRGB(255, 128, 0)
    fovCircle.Thickness = 1
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.NumSides = 60
    
    -- Create UI System with Orange Theme
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
    
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
    
    -- ESP Main Settings
    ESPMainGroup:AddToggle('ESPEnabled', {
        Text = 'Enable ESP',
        Default = false,
        Callback = function(Value)
            ESP:Toggle(Value)
        end
    })
    
    ESPMainGroup:AddToggle('ESPTeamCheck', {
        Text = 'Team Check',
        Default = true,
        Callback = function(Value)
            ESP.TeamMates = not Value
        end
    })
    
    ESPMainGroup:AddToggle('ESPTeamColor', {
        Text = 'Team Color',
        Default = true,
        Callback = function(Value)
            ESP.TeamColor = Value
        end
    })
    
    -- ESP Features
    ESPFeaturesGroup:AddToggle('ESPBoxes', {
        Text = 'Boxes',
        Default = false,
        Callback = function(Value)
            ESP.Boxes = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle('ESPHealth', {
        Text = 'Health Bar',
        Default = false,
        Callback = function(Value)
            ESP.Health = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle('ESPNames', {
        Text = 'Names',
        Default = false,
        Callback = function(Value)
            ESP.Names = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle('ESPDistance', {
        Text = 'Distance',
        Default = false,
        Callback = function(Value)
            ESP.Distance = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle('ESPTracers', {
        Text = 'Tracers',
        Default = false,
        Callback = function(Value)
            ESP.Tracers = Value
        end
    })
    
    ESPFeaturesGroup:AddToggle('ESPSkeleton', {
        Text = 'Skeleton',
        Default = false,
        Callback = function(Value)
            ESP.Skeleton = Value
        end
    })
    
    -- ESP Settings
    ESPSettingsGroup:AddSlider('ESPMaxDistance', {
        Text = 'Max Distance',
        Default = 1000,
        Min = 100,
        Max = 5000,
        Rounding = 0,
        Callback = function(Value)
            ESP.MaxDistance = Value
        end
    })
    
    ESPSettingsGroup:AddSlider('ESPTextSize', {
        Text = 'Text Size',
        Default = 13,
        Min = 8,
        Max = 24,
        Rounding = 0,
        Callback = function(Value)
            ESP.TextSize = Value
        end
    })
    
    ESPSettingsGroup:AddSlider('ESPBoxThickness', {
        Text = 'Box Thickness',
        Default = 2,
        Min = 1,
        Max = 5,
        Rounding = 0,
        Callback = function(Value)
            ESP.BoxThickness = Value
        end
    })
    
    -- Setup ESP for teams
    local function setupESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ESP:Add(player.Character, {
                    Name = player.Name,
                    Player = player,
                    PrimaryPart = player.Character:FindFirstChild("HumanoidRootPart")
                })
            end
        end
    end
    
    -- Setup ESP when players join
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            ESP:Add(character, {
                Name = player.Name,
                Player = player,
                PrimaryPart = character:WaitForChild("HumanoidRootPart")
            })
        end)
    end)
    
    -- Initial ESP setup
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            ESP:Add(player.Character, {
                Name = player.Name,
                Player = player,
                PrimaryPart = player.Character:FindFirstChild("HumanoidRootPart")
            })
        end
    end
    
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
    
    -- Camera rotation aimbot
    local function updateCamera(targetPosition)
        if not aimbotActive or not targetPosition then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Calculate angles needed to look at target
        local cameraPosition = Camera.CFrame.Position
        local direction = (targetPosition - cameraPosition).Unit
        
        -- Convert to angles
        local x = math.atan2(direction.X, direction.Z)
        local y = math.asin(direction.Y)
        
        if aimbotSmoothing then
            -- Smooth camera rotation
            local currentX = Camera.CFrame:ToEulerAnglesYXZ()
            local deltaX = (x - currentX) / aimbotSmoothingAmount
            local deltaY = (y - Camera.CFrame:ToEulerAnglesYXZ()) / aimbotSmoothingAmount
            
            -- Apply smoothed rotation
            Camera.CFrame = CFrame.new(cameraPosition) 
                * CFrame.Angles(0, currentX + deltaX, 0) 
                * CFrame.Angles(currentY + deltaY, 0, 0)
        else
            -- Instant camera rotation
            Camera.CFrame = CFrame.new(cameraPosition) 
                * CFrame.Angles(0, x, 0) 
                * CFrame.Angles(y, 0, 0)
        end
    end
    
    -- Update the aimbot logic
    RunService.RenderStepped:Connect(function()
        if showFOV and fovCircle then
            fovCircle.Position = UserInputService:GetMouseLocation()
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
        
        if not aimbotActive then return end
        if aimbotDisableOnJump and LocalPlayer.Character and 
           LocalPlayer.Character:FindFirstChild("Humanoid") and 
           math.abs(LocalPlayer.Character.Humanoid.FloorMaterial.Name) == "Air" then return end
        
        local target = getTargetPlayer()
        if not target then return end
        
        local predictedPos = predictPosition(target.Part, 1000)
        
        if not aimbotSilent then
            -- Regular aimbot - rotate camera
            updateCamera(predictedPos)
        end
        
        -- Handle auto shoot
        if aimbotAutoShoot and tick() - lastShotTime > SHOT_COOLDOWN then
            local _, onScreen = Camera:WorldToViewportPoint(predictedPos)
            if onScreen then
                mouse1press()
                wait()
                mouse1release()
                lastShotTime = tick()
            end
        end
        
        -- Handle trigger bot
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
    
    -- Add keybinds
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