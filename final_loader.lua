-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Library
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()

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

-- Update FOV Circle Position
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end)

-- Mouse Functions
local function mouse1press()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true)
end

local function mouse1release()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false)
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
        ESP:Toggle(Value)
    end
})

ESPMainGroup:AddToggle("ESPTeamCheck", {
    Text = "Team Check",
    Default = true,
    Callback = function(Value)
        ESP.TeamMates = not Value
    end
})

ESPMainGroup:AddToggle("ESPTeamColor", {
    Text = "Team Color",
    Default = true,
    Callback = function(Value)
        ESP.TeamColor = Value
    end
})

-- ESP Features
ESPFeaturesGroup:AddToggle("ESPBoxes", {
    Text = "Boxes",
    Default = false,
    Callback = function(Value)
        ESP.Boxes = Value
    end
})

ESPFeaturesGroup:AddToggle("ESPHealth", {
    Text = "Health Bar",
    Default = false,
    Callback = function(Value)
        ESP.Health = Value
    end
})

ESPFeaturesGroup:AddToggle("ESPNames", {
    Text = "Names",
    Default = false,
    Callback = function(Value)
        ESP.Names = Value
    end
})

ESPFeaturesGroup:AddToggle("ESPDistance", {
    Text = "Distance",
    Default = false,
    Callback = function(Value)
        ESP.Distance = Value
    end
})

ESPFeaturesGroup:AddToggle("ESPTracers", {
    Text = "Tracers",
    Default = false,
    Callback = function(Value)
        ESP.Tracers = Value
    end
})

ESPFeaturesGroup:AddToggle("ESPSkeleton", {
    Text = "Skeleton",
    Default = false,
    Callback = function(Value)
        ESP.Skeleton = Value
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
        ESP.MaxDistance = Value
    end
})

ESPSettingsGroup:AddSlider("ESPTextSize", {
    Text = "Text Size",
    Default = 13,
    Min = 8,
    Max = 24,
    Rounding = 0,
    Callback = function(Value)
        ESP.TextSize = Value
    end
})

ESPSettingsGroup:AddSlider("ESPBoxThickness", {
    Text = "Box Thickness",
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(Value)
        ESP.BoxThickness = Value
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
    if showFOV and fovCircle then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
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
        -- Calculate angles needed to look at target
        local cameraPosition = Camera.CFrame.Position
        local direction = (predictedPos - cameraPosition).Unit
        
        -- Convert to angles
        local x = math.atan2(direction.X, direction.Z)
        local y = math.asin(direction.Y)
        
        -- Get current camera angles
        local currentX, currentY = Camera.CFrame:ToEulerAnglesYXZ()
        
        if aimbotSmoothing then
            -- Smooth camera rotation
            local deltaX = (x - currentX) / aimbotSmoothingAmount
            local deltaY = (y - currentY) / aimbotSmoothingAmount
            
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

-- Silent aim implementation
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if aimbotSilent and method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
        local target = getTargetPlayer()
        if target then
            local predictedPos = predictPosition(target.Part, 1000)
            args[1] = Ray.new(Camera.CFrame.Position, (predictedPos - Camera.CFrame.Position).Unit * 1000)
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

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