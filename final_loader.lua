local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

-- Safe call function
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Error in SafeCall:", result)
        return nil
    end
    return result
end

-- Multiple methods to find PF characters
local function GetCharacterFromReplication(player)
    if not player then return nil end
    
    return SafeCall(function()
        local replicationObject = ReplicatedStorage:FindFirstChild("ReplicationObject")
        if replicationObject then
            local char = replicationObject:FindFirstChild(player.Name)
            if char and char:FindFirstChild("Torso") then
                return char
            end
        end
        return nil
    end)
end

local function GetCharacterFromWorkspace(player)
    if not player then return nil end
    
    return SafeCall(function()
        -- Direct method
        local char = workspace:FindFirstChild(player.Name)
        if char and char:FindFirstChild("Torso") then
            return char
        end
        
        -- Search through workspace children
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Torso") then
                if obj.Name == player.Name then
                    return obj
                end
                
                local humanoid = obj:FindFirstChild("Humanoid")
                if humanoid and humanoid:GetAttribute("Player") == player then
                    return obj
                end
            end
        end
        
        return nil
    end)
end

-- Cache system
local cachedCharacters = {}
local lastUpdate = 0
local updateInterval = 1

local function GetAllCharacters()
    local characters = {}
    
    SafeCall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local character = GetCharacterFromReplication(player) or GetCharacterFromWorkspace(player)
            if character then
                characters[player] = character
            end
        end
    end)
    
    return characters
end

local function GetPFCharacter(player)
    if not player then return nil end
    
    return SafeCall(function()
        -- Update cache if needed
        local currentTime = tick()
        if currentTime - lastUpdate > updateInterval then
            cachedCharacters = GetAllCharacters()
            lastUpdate = currentTime
        end
        
        -- Return from cache
        if cachedCharacters[player] then
            if cachedCharacters[player]:FindFirstChild("Torso") then
                return cachedCharacters[player]
            end
        end
        
        -- If cache failed, try immediate lookup
        local character = GetCharacterFromReplication(player) or GetCharacterFromWorkspace(player)
        if character then
            cachedCharacters[player] = character
        end
        
        return character
    end)
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
    SilentAimEnabled = false,
    SilentAimHitChance = 100,
    HitChance = 100
}

-- Forward declare update functions
local UpdateFOVCircle, UpdateAimbot, UpdateESP

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = AimbotSettings.FOVThickness
FOVCircle.Color = AimbotSettings.FOVColor
FOVCircle.Transparency = AimbotSettings.FOVTransparency
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Update FOV Circle function
UpdateFOVCircle = function()
    SafeCall(function()
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
    end)
end

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
local AimbotMainGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
local AimbotSettingsGroup = Tabs.Combat:AddRightGroupbox("Aimbot Settings")
local SilentAimGroup = Tabs.Combat:AddLeftGroupbox("Silent Aim")

-- Main Aimbot Settings
AimbotMainGroup:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        AimbotSettings.Enabled = Value
        if not Value then
            FOVCircle.Visible = false
        end
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

AimbotMainGroup:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = true,
    Callback = function(Value)
        AimbotSettings.TeamCheck = Value
    end
})

AimbotMainGroup:AddDropdown("TargetPart", {
    Values = {"Head", "Torso"},
    Default = 1,
    Multi = false,
    Text = "Target Part",
    Callback = function(Value)
        AimbotSettings.TargetPart = Value
    end
})

-- Silent Aim Settings
SilentAimGroup:AddToggle("SilentAimEnabled", {
    Text = "Silent Aim",
    Default = false,
    Callback = function(Value)
        AimbotSettings.SilentAimEnabled = Value
    end
})

SilentAimGroup:AddSlider("SilentAimHitChance", {
    Text = "Hit Chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Callback = function(Value)
        AimbotSettings.SilentAimHitChance = Value
    end
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
    if not player then return end
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
    
    SafeCall(function()
        for _, drawing in pairs(espObject) do
            if type(drawing) == "table" and drawing.Remove then
                drawing:Remove()
            end
        end
    end)
    
    ESPObjects[player] = nil
end

-- Update Aimbot function
UpdateAimbot = function()
    if not AimbotSettings.Enabled then return end
    
    SafeCall(function()
        local target = GetTarget()
        if not target or not target.Part then return end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(target.Part.Position)
        if not onScreen then return end
        
        local mousePosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local targetPosition = Vector2.new(screenPoint.X, screenPoint.Y)
        local delta = (targetPosition - mousePosition) / AimbotSettings.Smoothness
        
        mousemoverel(delta.X, delta.Y)
    end)
end

-- Update ESP function
UpdateESP = function()
    SafeCall(function()
        for player, espObject in pairs(ESPObjects) do
            if not player or not espObject then continue end
            
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
            
            local torso = character:FindFirstChild("Torso")
            if not torso then continue end
            
            local vector, onScreen = Camera:WorldToViewportPoint(torso.Position)
            if not onScreen then
                espObject.Box.Visible = false
                espObject.BoxOutline.Visible = false
                espObject.Name.Visible = false
                espObject.Health.Visible = false
                espObject.Distance.Visible = false
                espObject.Tracer.Visible = false
                continue
            end
            
            local distance = (Camera.CFrame.Position - torso.Position).Magnitude
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
                local health = 100
                local maxHealth = 100
                
                espObject.Health.Text = math.floor(health) .. "/" .. math.floor(maxHealth)
                espObject.Health.Position = Vector2.new(vector.X, vector.Y + 40)
                espObject.Health.Color = Color3.fromHSV(health/maxHealth * 0.3, 1, 1)
                espObject.Health.Size = ESPSettings.TextSize
                espObject.Health.Visible = true
            else
                espObject.Health.Visible = false
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
    end)
end

-- Add this before the silent aim implementation
local function GetTarget()
    local closest = {
        Distance = math.huge,
        Player = nil,
        Part = nil
    }
    
    return SafeCall(function()
        local characters = GetAllCharacters()
        if not characters then return closest end
        
        for player, character in pairs(characters) do
            if not player or not character then continue end
            if player == LocalPlayer then continue end
            if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local targetPart = character:FindFirstChild(AimbotSettings.TargetPart)
            if not targetPart then 
                targetPart = character:FindFirstChild("Torso")
                if not targetPart then continue end
            end
            
            local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen and not AimbotSettings.SilentAimEnabled then continue end
            
            local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
            if distance > AimbotSettings.MaxDistance then continue end
            
            if not AimbotSettings.SilentAimEnabled or distance > AimbotSettings.MaxDistance / 2 then
                local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local fovDistance = (screenPosition - screenCenter).Magnitude
                
                if fovDistance > AimbotSettings.FOV then continue end
            end
            
            if distance < closest.Distance then
                closest.Distance = distance
                closest.Player = player
                closest.Part = targetPart
            end
        end
        
        return closest
    end) or closest
end

-- Update the silent aim implementation
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and AimbotSettings.SilentAimEnabled and method == "FireServer" then
        local success, result = pcall(function()
            local namecallString = tostring(self)
            if namecallString:find("ProjectileHandler") or namecallString:find("MainHandler") or namecallString:find("ShootHandler") then
                if math.random(1, 100) <= AimbotSettings.SilentAimHitChance then
                    local target = GetTarget()
                    if target and target.Player and target.Part then
                        if #args >= 3 then
                            local origin = args[2]
                            if typeof(origin) == "CFrame" then
                                local targetPos = target.Part.Position
                                
                                -- Add slight randomization
                                local spread = Vector3.new(
                                    math.random(-10, 10) / 100,
                                    math.random(-10, 10) / 100,
                                    math.random(-10, 10) / 100
                                )
                                
                                targetPos = targetPos + spread
                                
                                -- Calculate direction
                                local direction = (targetPos - origin.Position).Unit
                                
                                -- Create new CFrame
                                args[2] = CFrame.new(origin.Position, origin.Position + direction)
                            end
                        end
                    end
                end
            end
        end)
        
        if not success then
            warn("Silent aim error:", result)
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Player Connections
Players.PlayerAdded:Connect(function(player)
    SafeCall(function()
        CreateESPObject(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    SafeCall(function()
        RemoveESPObject(player)
    end)
end)

-- Initialize ESP for existing players
SafeCall(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESPObject(player)
        end
    end
end)

-- Main update loop with error handling
local function mainLoop()
    SafeCall(function()
        if UpdateFOVCircle then UpdateFOVCircle() end
        if UpdateAimbot then UpdateAimbot() end
        if UpdateESP then UpdateESP() end
    end)
end

-- Connect the main loop
RunService.RenderStepped:Connect(mainLoop)

return Library.Unloaded