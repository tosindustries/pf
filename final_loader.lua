local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()

-- Constants
local Colors = {
    Background = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(0, 170, 255),
    LightText = Color3.fromRGB(255, 255, 255),
    DarkText = Color3.fromRGB(150, 150, 150)
}

-- Utility Functions
local function GetPFCharacter(player)
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    
    -- Handle Phantom Forces character system
    local torso = char:FindFirstChild("Torso")
    if not torso then return nil end
    
    return char
end

local function GetPFHealth(character)
    if not character then return 0, 100 end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return 0, 100 end
    return humanoid.Health, humanoid.MaxHealth
end

-- ESP Settings
local ESPSettings = {
    Enabled = false,
    TeamCheck = true,
    TeamColor = true,
    ShowName = false,
    ShowHealth = false,
    ShowDistance = false,
    ShowBox = false,
    ShowTracer = false,
    MaxDistance = 1000,
    TextSize = 13,
    BoxThickness = 1,
    TracerThickness = 1,
    TextOutline = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- Aimbot Settings
local AimbotSettings = {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = true,
    TargetPart = "Head",
    Smoothness = 1,
    FOV = 100,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVThickness = 1,
    FOVTransparency = 0.7,
    MaxDistance = 1000,
    PredictionEnabled = false,
    PredictionAmount = 0.15,
    SilentAimEnabled = false,
    TriggerBotEnabled = false,
    TriggerBotDelay = 0.1,
    AutoWallEnabled = false,
    AutoWallMinDamage = 15,
    TargetMode = "Distance", -- Distance, Health, Random
    HitChance = 100,
    UnlockOnDeath = true,
    IgnoreInvisible = true,
    TargetPriority = {
        Head = true,
        Torso = true,
        Arms = false,
        Legs = false
    }
}

-- Create Window
local Window = Library:CreateWindow({
    Title = "TOS Industries | Phantom Forces",
    Center = true,
    AutoShow = true
})

-- Create Tabs
local Tabs = {
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
    Settings = Window:AddTab("Settings")
}

-- Combat Tab
local AimbotGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
local WeaponGroup = Tabs.Combat:AddRightGroupbox("Weapon")

-- Aimbot Settings
AimbotGroup:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        AimbotSettings.Enabled = Value
    end
})

AimbotGroup:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = true,
    Callback = function(Value)
        AimbotSettings.TeamCheck = Value
    end
})

AimbotGroup:AddToggle("VisibilityCheck", {
    Text = "Visibility Check",
    Default = true,
    Callback = function(Value)
        AimbotSettings.VisibilityCheck = Value
    end
})

AimbotGroup:AddDropdown("TargetPart", {
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Default = 1,
    Multi = false,
    Text = "Target Part",
    Callback = function(Value)
        AimbotSettings.TargetPart = Value
    end
})

AimbotGroup:AddSlider("Smoothness", {
    Text = "Smoothness",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        AimbotSettings.Smoothness = Value
    end
})

AimbotGroup:AddSlider("FOV", {
    Text = "FOV",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        AimbotSettings.FOV = Value
    end
})

-- Weapon Settings
WeaponGroup:AddToggle("NoRecoil", {
    Text = "No Recoil",
    Default = false
})

WeaponGroup:AddToggle("NoSpread", {
    Text = "No Spread",
    Default = false
})

WeaponGroup:AddToggle("AutoShoot", {
    Text = "Auto Shoot",
    Default = false
})

-- Visuals Tab
local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP")
local ESPSettingsGroup = Tabs.Visuals:AddRightGroupbox("ESP Settings")

-- ESP Toggles
ESPGroup:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = false,
    Callback = function(Value)
        ESPSettings.Enabled = Value
    end
})

ESPGroup:AddToggle("BoxESP", {
    Text = "Boxes",
    Default = false,
    Callback = function(Value)
        ESPSettings.ShowBox = Value
    end
})

ESPGroup:AddToggle("NameESP", {
    Text = "Names",
    Default = false,
    Callback = function(Value)
        ESPSettings.ShowName = Value
    end
})

ESPGroup:AddToggle("HealthESP", {
    Text = "Health",
    Default = false,
    Callback = function(Value)
        ESPSettings.ShowHealth = Value
    end
})

ESPGroup:AddToggle("TracerESP", {
    Text = "Tracers",
    Default = false,
    Callback = function(Value)
        ESPSettings.ShowTracer = Value
    end
})

-- ESP Settings
ESPSettingsGroup:AddSlider("MaxDistance", {
    Text = "Max Distance",
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Callback = function(Value)
        ESPSettings.MaxDistance = Value
    end
})

ESPSettingsGroup:AddSlider("TextSize", {
    Text = "Text Size",
    Default = 13,
    Min = 8,
    Max = 24,
    Rounding = 0,
    Callback = function(Value)
        ESPSettings.TextSize = Value
    end
})

ESPSettingsGroup:AddSlider("BoxThickness", {
    Text = "Box Thickness",
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(Value)
        ESPSettings.BoxThickness = Value
    end
})

ESPSettingsGroup:AddColorPicker("BoxColor", {
    Text = "Box Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        ESPSettings.BoxColor = Value
    end
})

ESPSettingsGroup:AddColorPicker("TracerColor", {
    Text = "Tracer Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        ESPSettings.TracerColor = Value
    end
})

-- Settings Tab
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

-- Initialize
Library.ToggleKeybind = Options.MenuKeybind

-- Theme Manager
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TOS Industries")
ThemeManager:ApplyToTab(Tabs.Settings)

-- ESP Objects
local ESPObjects = {}

local function CreateESPObject(player)
    if player == LocalPlayer then return end
    
    local espObject = {
        Player = player,
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    -- Initialize Box
    espObject.BoxOutline.Color = Color3.new(0, 0, 0)
    espObject.BoxOutline.Thickness = 3
    espObject.BoxOutline.Filled = false
    espObject.BoxOutline.Visible = false
    
    espObject.Box.Color = ESPSettings.BoxColor
    espObject.Box.Thickness = 1
    espObject.Box.Filled = false
    espObject.Box.Visible = false
    
    -- Initialize Name
    espObject.Name.Color = ESPSettings.TextColor
    espObject.Name.Size = ESPSettings.TextSize
    espObject.Name.Center = true
    espObject.Name.Outline = true
    espObject.Name.Visible = false
    
    -- Initialize Health
    espObject.Health.Color = ESPSettings.TextColor
    espObject.Health.Size = ESPSettings.TextSize
    espObject.Health.Center = true
    espObject.Health.Outline = true
    espObject.Health.Visible = false
    
    -- Initialize Distance
    espObject.Distance.Color = ESPSettings.TextColor
    espObject.Distance.Size = ESPSettings.TextSize
    espObject.Distance.Center = true
    espObject.Distance.Outline = true
    espObject.Distance.Visible = false
    
    -- Initialize Tracer
    espObject.Tracer.Color = ESPSettings.TracerColor
    espObject.Tracer.Thickness = 1
    espObject.Tracer.Visible = false
    
    ESPObjects[player] = espObject
end

local function RemoveESPObject(player)
    local espObject = ESPObjects[player]
    if not espObject then return end
    
    for _, drawing in pairs(espObject) do
        if typeof(drawing) == "table" and drawing.Remove then
            drawing:Remove()
        end
    end
    
    ESPObjects[player] = nil
end

local function UpdateESP()
    for player, espObject in pairs(ESPObjects) do
        local character = GetPFCharacter(player)
        if not character or not ESPSettings.Enabled then
            espObject.Box.Visible = false
            espObject.BoxOutline.Visible = false
            espObject.Name.Visible = false
            espObject.Health.Visible = false
            espObject.Distance.Visible = false
            espObject.Tracer.Visible = false
            continue
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then continue end
        
        local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if not onScreen then
            espObject.Box.Visible = false
            espObject.BoxOutline.Visible = false
            espObject.Name.Visible = false
            espObject.Health.Visible = false
            espObject.Distance.Visible = false
            espObject.Tracer.Visible = false
            continue
        end
        
        local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
        if distance > ESPSettings.MaxDistance then
            espObject.Box.Visible = false
            espObject.BoxOutline.Visible = false
            espObject.Name.Visible = false
            espObject.Health.Visible = false
            espObject.Distance.Visible = false
            espObject.Tracer.Visible = false
            continue
        end
        
        if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team then
            espObject.Box.Visible = false
            espObject.BoxOutline.Visible = false
            espObject.Name.Visible = false
            espObject.Health.Visible = false
            espObject.Distance.Visible = false
            espObject.Tracer.Visible = false
            continue
        end
        
        -- Update Box
        if ESPSettings.ShowBox then
            local boxSize = Vector2.new(2000 / distance, 2500 / distance)
            local boxPosition = Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2)
            
            espObject.BoxOutline.Size = boxSize
            espObject.BoxOutline.Position = boxPosition
            espObject.BoxOutline.Visible = true
            
            espObject.Box.Size = boxSize
            espObject.Box.Position = boxPosition
            espObject.Box.Color = ESPSettings.BoxColor
            espObject.Box.Visible = true
        else
            espObject.Box.Visible = false
            espObject.BoxOutline.Visible = false
        end
        
        -- Update Name
        if ESPSettings.ShowName then
            espObject.Name.Text = player.Name
            espObject.Name.Position = Vector2.new(vector.X, vector.Y - 40)
            espObject.Name.Color = ESPSettings.TextColor
            espObject.Name.Size = ESPSettings.TextSize
            espObject.Name.Visible = true
        else
            espObject.Name.Visible = false
        end
        
        -- Update Health
        if ESPSettings.ShowHealth then
            local health, maxHealth = GetPFHealth(character)
            espObject.Health.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
            espObject.Health.Position = Vector2.new(vector.X, vector.Y + 40)
            espObject.Health.Color = Color3.fromHSV(health/maxHealth * 0.3, 1, 1)
            espObject.Health.Size = ESPSettings.TextSize
            espObject.Health.Visible = true
        else
            espObject.Health.Visible = false
        end
        
        -- Update Distance
        if ESPSettings.ShowDistance then
            espObject.Distance.Text = math.floor(distance) .. " studs"
            espObject.Distance.Position = Vector2.new(vector.X, vector.Y + 25)
            espObject.Distance.Color = ESPSettings.TextColor
            espObject.Distance.Size = ESPSettings.TextSize
            espObject.Distance.Visible = true
        else
            espObject.Distance.Visible = false
        end
        
        -- Update Tracer
        if ESPSettings.ShowTracer then
            espObject.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espObject.Tracer.To = Vector2.new(vector.X, vector.Y)
            espObject.Tracer.Color = ESPSettings.TracerColor
            espObject.Tracer.Thickness = ESPSettings.TracerThickness
            espObject.Tracer.Visible = true
        else
            espObject.Tracer.Visible = false
        end
    end
end

-- Player Connections
Players.PlayerAdded:Connect(CreateESPObject)
Players.PlayerRemoving:Connect(RemoveESPObject)

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESPObject(player)
    end
end

-- Main Loop
RunService.RenderStepped:Connect(UpdateESP)

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = AimbotSettings.FOVThickness
FOVCircle.Color = AimbotSettings.FOVColor
FOVCircle.Transparency = AimbotSettings.FOVTransparency
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Update Combat Tab with more Aimbot features
local AimbotMainGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
local AimbotSettingsGroup = Tabs.Combat:AddRightGroupbox("Aimbot Settings")
local AimbotAdvancedGroup = Tabs.Combat:AddLeftGroupbox("Advanced")
local TriggerBotGroup = Tabs.Combat:AddRightGroupbox("Trigger Bot")

-- Main Aimbot Settings
AimbotMainGroup:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        AimbotSettings.Enabled = Value
    end
})

AimbotMainGroup:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Default = false,
    Callback = function(Value)
        AimbotSettings.SilentAimEnabled = Value
    end
})

AimbotMainGroup:AddToggle("ShowFOV", {
    Text = "Show FOV",
    Default = true,
    Callback = function(Value)
        AimbotSettings.ShowFOV = Value
        FOVCircle.Visible = Value and AimbotSettings.Enabled
    end
})

AimbotMainGroup:AddDropdown("TargetMode", {
    Values = {"Distance", "Health", "Random"},
    Default = 1,
    Multi = false,
    Text = "Target Mode",
    Tooltip = "How to select the target",
    Callback = function(Value)
        AimbotSettings.TargetMode = Value
    end
})

AimbotMainGroup:AddDropdown("TargetPart", {
    Values = {"Head", "Torso", "Random"},
    Default = 1,
    Multi = false,
    Text = "Target Part",
    Tooltip = "Which part to aim at",
    Callback = function(Value)
        AimbotSettings.TargetPart = Value
    end
})

-- Aimbot Settings
AimbotSettingsGroup:AddSlider("Smoothness", {
    Text = "Smoothness",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Tooltip = "Higher = smoother",
    Callback = function(Value)
        AimbotSettings.Smoothness = Value
    end
})

AimbotSettingsGroup:AddSlider("FOV", {
    Text = "FOV",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Tooltip = "Field of View radius",
    Callback = function(Value)
        AimbotSettings.FOV = Value
    end
})

AimbotSettingsGroup:AddSlider("HitChance", {
    Text = "Hit Chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Tooltip = "Chance to hit the target",
    Callback = function(Value)
        AimbotSettings.HitChance = Value
    end
})

AimbotSettingsGroup:AddSlider("MaxDistance", {
    Text = "Max Distance",
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        AimbotSettings.MaxDistance = Value
    end
})

-- Advanced Settings
AimbotAdvancedGroup:AddToggle("Prediction", {
    Text = "Enable Prediction",
    Default = false,
    Tooltip = "Predict target movement",
    Callback = function(Value)
        AimbotSettings.PredictionEnabled = Value
    end
})

AimbotAdvancedGroup:AddSlider("PredictionAmount", {
    Text = "Prediction Amount",
    Default = 0.15,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Tooltip = "How much to predict movement",
    Callback = function(Value)
        AimbotSettings.PredictionAmount = Value
    end
})

AimbotAdvancedGroup:AddToggle("AutoWall", {
    Text = "Auto Wall",
    Default = false,
    Tooltip = "Shoot through walls when possible",
    Callback = function(Value)
        AimbotSettings.AutoWallEnabled = Value
    end
})

AimbotAdvancedGroup:AddSlider("MinDamage", {
    Text = "Min Wall Damage",
    Default = 15,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Tooltip = "Minimum damage for Auto Wall",
    Callback = function(Value)
        AimbotSettings.AutoWallMinDamage = Value
    end
})

-- Trigger Bot Settings
TriggerBotGroup:AddToggle("TriggerBot", {
    Text = "Enable Trigger Bot",
    Default = false,
    Tooltip = "Automatically shoot when aiming at target",
    Callback = function(Value)
        AimbotSettings.TriggerBotEnabled = Value
    end
})

TriggerBotGroup:AddSlider("TriggerDelay", {
    Text = "Trigger Delay",
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Suffix = "s",
    Tooltip = "Delay before shooting",
    Callback = function(Value)
        AimbotSettings.TriggerBotDelay = Value
    end
})

-- FOV Circle Update
local function UpdateFOVCircle()
    if not AimbotSettings.ShowFOV or not AimbotSettings.Enabled then
        FOVCircle.Visible = false
        return
    end

    FOVCircle.Visible = true
    FOVCircle.Radius = AimbotSettings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Color = AimbotSettings.FOVColor
    FOVCircle.Thickness = AimbotSettings.FOVThickness
    FOVCircle.Transparency = AimbotSettings.FOVTransparency
end

-- Prediction Function
local function PredictPosition(position, velocity)
    return position + (velocity * AimbotSettings.PredictionAmount)
end

-- Get Closest Target Function
local function GetTarget()
    local closest = {
        Distance = math.huge,
        Player = nil,
        Part = nil,
        Position = nil
    }

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Team Check
        if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local character = GetPFCharacter(player)
        if not character then continue end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then continue end
        
        -- Distance Check
        local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > AimbotSettings.MaxDistance then continue end
        
        -- FOV Check
        local screenPoint = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        if (screenPosition - screenCenter).Magnitude > AimbotSettings.FOV then continue end
        
        -- Hit Chance
        if math.random(1, 100) > AimbotSettings.HitChance then continue end
        
        -- Target Part Selection
        local targetPart = character:FindFirstChild(AimbotSettings.TargetPart)
        if not targetPart then continue end
        
        -- Visibility Check
        if AimbotSettings.VisibilityCheck then
            local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * distance)
            local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character})
            if hit then continue end
        end
        
        -- Update Closest Target
        if distance < closest.Distance then
            closest.Distance = distance
            closest.Player = player
            closest.Part = targetPart
            closest.Position = targetPart.Position
        end
    end
    
    return closest
end

-- Aimbot Update Function
local function UpdateAimbot()
    if not AimbotSettings.Enabled then return end
    
    local target = GetTarget()
    if not target.Player then return end
    
    local targetPos = target.Position
    if AimbotSettings.PredictionEnabled then
        local velocity = target.Part.Velocity
        targetPos = PredictPosition(targetPos, velocity)
    end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end
    
    -- Silent Aim
    if AimbotSettings.SilentAimEnabled then
        -- Implement silent aim logic here
        return
    end
    
    -- Regular Aimbot
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local aimPos = Vector2.new(screenPos.X, screenPos.Y)
    local delta = (aimPos - mousePos) / AimbotSettings.Smoothness
    mousemoverel(delta.X, delta.Y)
    
    -- Trigger Bot
    if AimbotSettings.TriggerBotEnabled then
        local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * target.Distance)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        if hit and hit:IsDescendantOf(target.Player.Character) then
            task.wait(AimbotSettings.TriggerBotDelay)
            mouse1press()
            task.wait()
            mouse1release()
        end
    end
end

-- Connect Update Functions
RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    UpdateAimbot()
end)

return Library.Unloaded