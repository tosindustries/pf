local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Debug function
local function DebugLog(...)
    print("[DEBUG]", ...)
end

-- Character detection with debug logging
local function GetCharacterFromPF(player)
    if not player then 
        DebugLog("No player provided")
        return nil 
    end
    
    DebugLog("Searching for character of player:", player.Name)
    
    -- Try to get from PF's character system
    for _, folder in pairs(workspace:GetChildren()) do
        if folder:IsA("Folder") and (folder.Name == "Players" or folder.Name == "Characters") then
            DebugLog("Found potential character folder:", folder.Name)
            for _, model in pairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
                    if root and root:IsDescendantOf(workspace) then
                        -- Check if this model belongs to our player
                        local success, result = pcall(function()
                            return model:FindFirstChild("Head") and 
                                   model:FindFirstChild("Humanoid") and 
                                   (model.Name == player.Name or 
                                    model:GetAttribute("Player") == player.Name or 
                                    model:FindFirstChild("Humanoid"):GetAttribute("Player") == player.Name)
                        end)
                        
                        if success and result then
                            DebugLog("Found character for", player.Name, "in", folder.Name)
                            return model
                        end
                    end
                end
            end
        end
    end
    
    -- Try direct character reference
    if player.Character and player.Character:FindFirstChild("Torso") then
        DebugLog("Found character through player.Character for", player.Name)
        return player.Character
    end
    
    -- Try workspace direct children
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name == player.Name and obj:FindFirstChild("Torso") then
            DebugLog("Found character in workspace root for", player.Name)
            return obj
        end
    end
    
    DebugLog("Failed to find character for", player.Name)
    return nil
end

-- Cache system with debug
local cachedCharacters = {}
local lastUpdate = 0
local updateInterval = 0.1

local function GetAllCharacters()
    local characters = {}
    local currentTime = tick()
    
    if currentTime - lastUpdate < updateInterval then
        return cachedCharacters
    end
    
    DebugLog("Updating character cache...")
    local playerCount = 0
    local foundCount = 0
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        playerCount = playerCount + 1
        
        local character = GetCharacterFromPF(player)
        if character then
            foundCount = foundCount + 1
            characters[player] = character
        end
    end
    
    DebugLog(string.format("Found %d/%d characters", foundCount, playerCount))
    
    cachedCharacters = characters
    lastUpdate = currentTime
    return characters
end

-- ESP Update function with debug
UpdateESP = function()
    SafeCall(function()
        local characters = GetAllCharacters()
        DebugLog("ESP Update - Found", #characters, "characters")
        
        for player, espObject in pairs(ESPObjects) do
            if not player or not espObject then 
                DebugLog("Invalid player or ESP object")
                continue 
            end
            
            local character = characters[player]
            if not character then
                DebugLog("No character found for", player.Name)
                espObject.Box.Visible = false
                espObject.BoxOutline.Visible = false
                espObject.Name.Visible = false
                espObject.Health.Visible = false
                espObject.Distance.Visible = false
                espObject.Tracer.Visible = false
                continue
            end
            
            if not ESPSettings.Enabled then
                DebugLog("ESP disabled")
                continue
            end
            
            local torso = character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
            if not torso then
                DebugLog("No torso found for", player.Name)
                continue
            end
            
            local vector, onScreen = Camera:WorldToViewportPoint(torso.Position)
            if not onScreen then
                DebugLog(player.Name, "not on screen")
                espObject.Box.Visible = false
                espObject.BoxOutline.Visible = false
                espObject.Name.Visible = false
                espObject.Health.Visible = false
                espObject.Distance.Visible = false
                espObject.Tracer.Visible = false
                continue
            end
            
            -- If we got here, we can draw ESP
            DebugLog("Drawing ESP for", player.Name)
            
            local distance = (Camera.CFrame.Position - torso.Position).Magnitude
            if distance > ESPSettings.MaxDistance then
                DebugLog(player.Name, "too far")
                continue
            end
            
            if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team then
                DebugLog(player.Name, "on same team")
                continue
            end
            
            -- Update ESP elements
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
                
                DebugLog("Drew box for", player.Name)
            end
            
            if ESPSettings.ShowName then
                espObject.Name.Text = player.Name
                espObject.Name.Position = Vector2.new(vector.X, vector.Y - 40)
                espObject.Name.Color = ESPSettings.TextColor
                espObject.Name.Size = ESPSettings.TextSize
                espObject.Name.Visible = true
                
                DebugLog("Drew name for", player.Name)
            end
            
            if ESPSettings.ShowTracer then
                espObject.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                espObject.Tracer.To = Vector2.new(vector.X, vector.Y)
                espObject.Tracer.Color = ESPSettings.TracerColor
                espObject.Tracer.Thickness = ESPSettings.TracerThickness
                espObject.Tracer.Visible = true
                
                DebugLog("Drew tracer for", player.Name)
            end
        end
    end)
end

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
FOVCircle.NumSides = 60

-- Get Target Function
local function GetTarget()
    local closest = {
        Distance = math.huge,
        Player = nil,
        Part = nil
    }
    
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
        
        local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local fovDistance = (screenPosition - screenCenter).Magnitude
        
        if fovDistance > AimbotSettings.FOV then continue end
        
        if AimbotSettings.VisibilityCheck then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
            
            local rayOrigin = Camera.CFrame.Position
            local rayDirection = (targetPart.Position - rayOrigin).Unit
            local rayResult = workspace:Raycast(rayOrigin, rayDirection * distance, rayParams)
            
            if rayResult then continue end
        end
        
        if distance < closest.Distance then
            closest.Distance = distance
            closest.Player = player
            closest.Part = targetPart
        end
    end
    
    return closest
end

-- Update FOV Circle function
UpdateFOVCircle = function()
    if not AimbotSettings.ShowFOV or not AimbotSettings.Enabled then
        FOVCircle.Visible = false
        return
    end
    
    FOVCircle.Visible = true
    FOVCircle.Radius = AimbotSettings.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Color = AimbotSettings.FOVColor
    FOVCircle.Thickness = AimbotSettings.FOVThickness
    FOVCircle.Transparency = AimbotSettings.FOVTransparency
end

-- Update Aimbot function
UpdateAimbot = function()
    if not AimbotSettings.Enabled then return end
    
    local target = GetTarget()
    if not target or not target.Part then return end
    
    local screenPoint, onScreen = Camera:WorldToViewportPoint(target.Part.Position)
    if not onScreen then return end
    
    local mousePosition = UserInputService:GetMouseLocation()
    local targetPosition = Vector2.new(screenPoint.X, screenPoint.Y)
    local delta = (targetPosition - mousePosition) / AimbotSettings.Smoothness
    
    mousemoverel(delta.X, delta.Y)
end

-- Silent Aim Implementation
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and AimbotSettings.SilentAimEnabled and method == "FireServer" then
        local namecallString = tostring(self)
        if namecallString:find("ProjectileHandler") or namecallString:find("MainHandler") or namecallString:find("ShootHandler") then
            if math.random(1, 100) <= AimbotSettings.SilentAimHitChance then
                local target = GetTarget()
                if target and target.Part then
                    if #args >= 2 then
                        local origin = args[2]
                        if typeof(origin) == "CFrame" then
                            local targetPos = target.Part.Position
                            
                            -- Add slight randomization
                            local spread = Vector3.new(
                                math.random(-5, 5) / 100,
                                math.random(-5, 5) / 100,
                                math.random(-5, 5) / 100
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
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Main update loop with error handling
local function mainLoop()
    SafeCall(function()
        UpdateFOVCircle()
        UpdateAimbot()
        UpdateESP()
    end)
end

-- Connect the main loop
RunService.RenderStepped:Connect(mainLoop)

return Library.Unloaded