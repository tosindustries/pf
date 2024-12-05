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
    
    -- Initialize FOV Circle
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = showFOV
    fovCircle.Radius = fovSize
    fovCircle.Color = Color3.new(1, 1, 1)
    fovCircle.Thickness = 1
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.NumSides = 60
    
    -- Rest of your code (ESP system, aimbot functions, etc.)
    -- ... (Keep all the existing functions like isVisible, predictPosition, etc.)
    
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