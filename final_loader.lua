-- TOS Industries v1
-- Copyright (c) 2024 TOS Industries. All rights reserved.
-- This script is protected by various security measures.
-- Unauthorized use, copying, or distribution is strictly prohibited.

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Solara compatibility layer
local function setupSolaraCompat()
    local env = getfenv(0)
    if not env or type(env) ~= "table" then return false end
    
    -- Solara-specific checks
    local function validateSolara()
        local success = pcall(function()
            return game:GetService("CoreGui"):WaitForChild("RobloxGui", 1)
        end)
        return success
    end
    
    -- Wait for game load
    if not game:IsLoaded() then 
        game.Loaded:Wait()
    end
    
    -- Additional validation
    if not validateSolara() then
        warn("Initialization failed - Please try again")
        return false
    end
    
    return true
end

-- Initial validation
if not setupSolaraCompat() then
    warn("Compatibility check failed")
    return false
end

-- Protected environment setup
local function createSecureEnv()
    local secureEnv = {}
    local blacklistedKeys = {
        "http",
        "Kick",
        "kick",
        "HttpGet",
        "HttpPost"
    }
    
    return setmetatable(secureEnv, {
        __index = function(_, key)
            if table.find(blacklistedKeys, key) then
                return function() end
            end
            return getfenv(0)[key]
        end
    })
end

-- Set up protected environment
local secureEnv = createSecureEnv()
setfenv(1, secureEnv)

-- Anti-tamper protection
local function setupAntiTamper()
    local success, result = pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return false end
        
        local old = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "HttpGet" or method == "HttpPost" then
                return old(self, ...)
            end
            if method:match("Kick") or method:match("kick") then
                return wait(9e9)
            end
            return old(self, ...)
        end)
        
        setreadonly(mt, true)
        return true
    end)
    
    return success and result
end

-- Memory protection optimized for Solara
local function protectMemory()
    local protected = {}
    
    -- Basic environment protection
    for k, v in pairs(getfenv()) do
        if type(v) == "function" then
            protected[k] = function(...)
                local success, result = pcall(v, ...)
                if not success then return nil end
                return result
            end
        else
            protected[k] = v
        end
    end
    
    -- Solara-specific protection
    protected._G = setmetatable({}, {
        __index = _G,
        __newindex = function() end,
        __metatable = "Protected"
    })
    
    return protected
end

-- Initialize security with Solara compatibility
local function initSecurity()
    local success = pcall(function()
        -- Set up anti-tamper
        if not setupAntiTamper() then
            return false
        end
        
        -- Set up memory protection
        local protectedEnv = protectMemory()
        setfenv(1, protectedEnv)
        
        -- Disable idle detection
        for _, v in pairs(getconnections(LocalPlayer.Idled)) do
            v:Disable()
        end
    end)
    
    return success
end

-- Initialize security
if not initSecurity() then
    warn("Security initialization failed - Please try again")
    return false
end

-- Initial checks and security setup
repeat task.wait() until game:IsLoaded() and game.GameId ~= 0

-- Security setup first
local function initSecureEnv()
    local env = getfenv(1)
    local protected = {}
    
    for k,v in pairs(env) do
        protected[k] = v
    end
    
    protected.game = setmetatable({}, {
        __index = function(_, k)
            if k:match("Security") or k:match("Anti") then return function() return true end end
            return game[k]
        end,
        __metatable = "Locked"
    })
    
    return setmetatable(protected, {
        __index = function(_, k)
            if k:match("hack") or k:match("cheat") then return nil end
            return env[k]
        end,
        __metatable = "Locked"
    })
end

-- Memory protection
local function setupMemoryProtection()
    local fakeEnv = {}
    local realEnv = getrenv()
    
    for k,v in pairs(realEnv) do
        if type(v) == "function" then
            fakeEnv[k] = function(...)
                local name = debug.getinfo(2, "n").name
                if name and (name:match("Anti") or name:match("Check")) then
                    return true
                end
                return v(...)
            end
        else
            fakeEnv[k] = v
        end
    end
    
    debug.setupvalue(getfenv, 1, fakeEnv)
end

-- Hook protection
local function setupHooks()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then return wait(9e9) end
        if method:match("Security") or method:match("Anti") then return true end
        return oldNamecall(self, ...)
    end))
end

-- Apply security
local secureEnv = initSecureEnv()
setupMemoryProtection()
setupHooks()
setfenv(1, secureEnv)

-- Services with error handling
local Services = setmetatable({}, {
    __index = function(self, key)
        local success, service = pcall(game.GetService, game, key)
        if success then
            self[key] = service
            return service
        end
        warn("Failed to get service:", key)
        return nil
    end
})

-- Core services
local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

if not LocalPlayer or not Camera then
    warn("Failed to initialize - core components not found")
    return false
end

-- Get PF modules with validation
local Modules = {}
local success, result = pcall(function()
    for i,v in next, getgc(true) do
        if typeof(v) == "table" then
            if rawget(v, "send") and rawget(v, "getPing") then
                Modules.NetworkClient = v
            elseif rawget(v, "new") and rawget(v, "setColor") and rawget(v, "step") then
                Modules.BulletObject = v
            elseif rawget(v, "getController") then
                Modules.Camera = v
            end
        end
    end
end)

if not success or not Modules.NetworkClient or not Modules.BulletObject then
    warn("Failed to get required modules")
    return false
end

-- ESP Component
local ESP = {
    Enabled = false,
    BoxEnabled = false,
    SkeletonEnabled = false,
    NameEnabled = false,
    HealthEnabled = false,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    MaxDistance = 1000,
    Players = {},
    Connections = {}
}

-- Aimbot Component
local Aimbot = {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = true,
    TargetPart = "Head",
    Smoothness = 1,
    FOV = 100,
    MaxDistance = 1000,
    CurrentTarget = nil
}

-- ESP Functions
function ESP:CreateDrawings()
    local player = {}
    player.Box = Drawing.new("Square")
    player.Box.Thickness = 1
    player.Box.Filled = false
    player.Box.Visible = false
    player.Box.Color = self.BoxColor
    player.Box.Transparency = 1

    player.Name = Drawing.new("Text")
    player.Name.Center = true
    player.Name.Size = self.TextSize
    player.Name.Outline = true
    player.Name.Visible = false
    player.Name.Color = self.TextColor

    player.Health = Drawing.new("Text")
    player.Health.Center = true
    player.Health.Size = self.TextSize
    player.Health.Outline = true
    player.Health.Visible = false
    player.Health.Color = self.TextColor

    player.Skeleton = {}
    local SkeletonPoints = {
        "Head-UpperTorso",
        "UpperTorso-LowerTorso",
        "UpperTorso-LeftUpperArm",
        "LeftUpperArm-LeftLowerArm",
        "UpperTorso-RightUpperArm",
        "RightUpperArm-RightLowerArm",
        "LowerTorso-LeftUpperLeg",
        "LeftUpperLeg-LeftLowerLeg",
        "LowerTorso-RightUpperLeg",
        "RightUpperLeg-RightLowerLeg"
    }

    for _, point in pairs(SkeletonPoints) do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        line.Color = self.SkeletonColor
        player.Skeleton[point] = line
    end

    return player
end

function ESP:GetCharacter(player)
    local character = player.Character
    if not character then return nil end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return nil end
    if humanoid.Health <= 0 then return nil end
    
    return character, humanoid, rootPart
end

function ESP:IsTeammate(player)
    if not self.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

function ESP:GetBoxPositions(character)
    local cframe = character:GetBoundingBox()
    local size = cframe.Size
    local position = cframe.Position
    
    local viewportSize = Camera.ViewportSize
    local screenPosition, onScreen = Camera:WorldToViewportPoint(position)
    if not onScreen then return nil end
    
    local sizeX = math.abs(Camera:WorldToViewportPoint(position + Vector3.new(size.X/2, 0, 0)).X - Camera:WorldToViewportPoint(position - Vector3.new(size.X/2, 0, 0)).X)
    local sizeY = math.abs(Camera:WorldToViewportPoint(position + Vector3.new(0, size.Y/2, 0)).Y - Camera:WorldToViewportPoint(position - Vector3.new(0, size.Y/2, 0)).Y)
    
    return Vector2.new(screenPosition.X - sizeX/2, screenPosition.Y - sizeY/2), Vector2.new(sizeX, sizeY)
end

function ESP:UpdateESP()
    for player, drawings in pairs(self.Players) do
        if not player or not player.Parent then
            self:RemovePlayer(player)
            continue
        end

        local character, humanoid, rootPart = self:GetCharacter(player)
        if not character or self:IsTeammate(player) then
            self:ToggleDrawings(drawings, false)
            continue
        end

        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > self.MaxDistance then
            self:ToggleDrawings(drawings, false)
            continue
        end

        local boxPos, boxSize = self:GetBoxPositions(character)
        if not boxPos then
            self:ToggleDrawings(drawings, false)
            continue
        end

        -- Update Box
        if self.BoxEnabled then
            drawings.Box.Visible = true
            drawings.Box.Position = boxPos
            drawings.Box.Size = boxSize
        else
            drawings.Box.Visible = false
        end

        -- Update Name
        if self.NameEnabled then
            drawings.Name.Visible = true
            drawings.Name.Position = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y - 20)
            drawings.Name.Text = player.Name
        else
            drawings.Name.Visible = false
        end

        -- Update Health
        if self.HealthEnabled and humanoid then
            drawings.Health.Visible = true
            drawings.Health.Position = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y + boxSize.Y + 5)
            drawings.Health.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            drawings.Health.Color = Color3.fromHSV(humanoid.Health/humanoid.MaxHealth * 0.3, 1, 1)
        else
            drawings.Health.Visible = false
        end

        -- Update Skeleton
        if self.SkeletonEnabled then
            self:UpdateSkeleton(character, drawings.Skeleton)
        else
            for _, line in pairs(drawings.Skeleton) do
                line.Visible = false
            end
        end
    end
end

function ESP:UpdateSkeleton(character, skeletonDrawings)
    local function getPartPosition(part)
        if not part then return nil end
        local position = Camera:WorldToViewportPoint(part.Position)
        if position.Z < 0 then return nil end
        return Vector2.new(position.X, position.Y)
    end

    for connection, line in pairs(skeletonDrawings) do
        local part1, part2 = unpack(connection:split("-"))
        local pos1 = getPartPosition(character:FindFirstChild(part1))
        local pos2 = getPartPosition(character:FindFirstChild(part2))
        
        if pos1 and pos2 then
            line.Visible = true
            line.From = pos1
            line.To = pos2
        else
            line.Visible = false
        end
    end
end

function ESP:ToggleDrawings(drawings, visible)
    drawings.Box.Visible = visible and self.BoxEnabled
    drawings.Name.Visible = visible and self.NameEnabled
    drawings.Health.Visible = visible and self.HealthEnabled
    
    if drawings.Skeleton then
        for _, line in pairs(drawings.Skeleton) do
            line.Visible = visible and self.SkeletonEnabled
        end
    end
end

function ESP:AddPlayer(player)
    if self.Players[player] then return end
    self.Players[player] = self:CreateDrawings()
end

function ESP:RemovePlayer(player)
    local drawings = self.Players[player]
    if not drawings then return end
    
    for _, drawing in pairs(drawings) do
        if type(drawing) == "table" then
            for _, line in pairs(drawing) do
                line:Remove()
            end
        else
            drawing:Remove()
        end
    end
    
    self.Players[player] = nil
end

-- Aimbot Functions
function Aimbot:GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if self.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local character, humanoid, rootPart = ESP:GetCharacter(player)
        if not character then continue end

        local targetPart = character:FindFirstChild(self.TargetPart)
        if not targetPart then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end

        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > self.MaxDistance then continue end

        local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if screenDistance > self.FOV then continue end

        if self.VisibilityCheck then
            local ray = Ray.new(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position)
            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character})
            if hit then continue end
        end

        if screenDistance < shortestDistance then
            closestPlayer = player
            shortestDistance = screenDistance
        end
    end

    return closestPlayer
end

function Aimbot:Update()
    if not self.Enabled then 
        self.CurrentTarget = nil
        return 
    end

    self.CurrentTarget = self:GetClosestPlayer()
    if not self.CurrentTarget then return end

    local character = self.CurrentTarget.Character
    if not character then return end

    local targetPart = character:FindFirstChild(self.TargetPart)
    if not targetPart then return end

    local targetPos = targetPart.Position
    local cameraPos = Camera.CFrame.Position
    local targetRotation = CFrame.lookAt(cameraPos, targetPos)
    
    -- Smooth aim
    local currentRotation = Camera.CFrame.Rotation
    local smoothRotation = currentRotation:Lerp(targetRotation, 1 - math.pow(0.02, self.Smoothness))
    
    if Modules.Camera and Modules.Camera.setRoll then
        Modules.Camera:setRoll(smoothRotation)
    else
        Camera.CFrame = CFrame.new(cameraPos) * smoothRotation
    end
end

-- Initialize core components
local initialized = false
local function init()
    if initialized then return end
    
    -- Initialize ESP
    for _, player in pairs(Players:GetPlayers()) do
        ESP:AddPlayer(player)
    end
    
    -- Set up connections
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESP:AddPlayer(player)
    end)
    
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP:RemovePlayer(player)
    end)
    
    -- Set up update loop
    RunService.RenderStepped:Connect(function()
        if ESP.Enabled then
            ESP:UpdateESP()
        end
        if Aimbot.Enabled then
            Aimbot:Update()
        end
    end)
    
    initialized = true
end

-- Start initialization
if game:IsLoaded() then
    init()
else
    game.Loaded:Wait()
    init()
end

-- Return success
return true

-- GUI Component
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wally2'))()

local Window = Library:CreateWindow("TOS Industries v1")

-- Main Window
local MainTab = Window:CreateFolder("Main")
local VisualsTab = Window:CreateFolder("Visuals")
local AimbotTab = Window:CreateFolder("Aimbot")
local SettingsTab = Window:CreateFolder("Settings")

-- Main Tab
MainTab:Toggle("Enable", function(bool)
    ESP.Enabled = bool
    Aimbot.Enabled = bool
end)

MainTab:Toggle("Team Check", function(bool)
    ESP.TeamCheck = bool
    Aimbot.TeamCheck = bool
end)

-- Visuals Tab
VisualsTab:Toggle("Box ESP", function(bool)
    ESP.BoxEnabled = bool
end)

VisualsTab:Toggle("Skeleton ESP", function(bool)
    ESP.SkeletonEnabled = bool
end)

VisualsTab:Toggle("Name ESP", function(bool)
    ESP.NameEnabled = bool
end)

VisualsTab:Toggle("Health ESP", function(bool)
    ESP.HealthEnabled = bool
end)

VisualsTab:ColorPicker("Box Color", Color3.fromRGB(255, 255, 255), function(color)
    ESP.BoxColor = color
end)

VisualsTab:ColorPicker("Skeleton Color", Color3.fromRGB(255, 255, 255), function(color)
    ESP.SkeletonColor = color
end)

VisualsTab:ColorPicker("Text Color", Color3.fromRGB(255, 255, 255), function(color)
    ESP.TextColor = color
end)

VisualsTab:Slider("Max Distance", {
    min = 100,
    max = 2000,
    precise = false
}, function(value)
    ESP.MaxDistance = value
end)

-- Aimbot Tab
AimbotTab:Toggle("Enable Aimbot", function(bool)
    Aimbot.Enabled = bool
end)

AimbotTab:Toggle("Visibility Check", function(bool)
    Aimbot.VisibilityCheck = bool
end)

AimbotTab:Dropdown("Target Part", {"Head", "UpperTorso", "HumanoidRootPart"}, function(selected)
    Aimbot.TargetPart = selected
end)

AimbotTab:Slider("Smoothness", {
    min = 1,
    max = 10,
    precise = true
}, function(value)
    Aimbot.Smoothness = value
end)

AimbotTab:Slider("FOV", {
    min = 30,
    max = 500,
    precise = false
}, function(value)
    Aimbot.FOV = value
end)

AimbotTab:Slider("Max Distance", {
    min = 100,
    max = 2000,
    precise = false
}, function(value)
    Aimbot.MaxDistance = value
end)

-- Settings Tab
SettingsTab:Button("Unload", function()
    -- Clean up ESP
    for player, drawings in pairs(ESP.Players) do
        ESP:RemovePlayer(player)
    end
    
    -- Disconnect all connections
    for _, connection in pairs(ESP.Connections) do
        connection:Disconnect()
    end
    
    -- Remove GUI
    for _, obj in pairs(game:GetDescendants()) do
        if obj.Name == "TOS Industries v1" then
            obj:Destroy()
        end
    end
end)

SettingsTab:Label("TOS Industries v1", {
    TextSize = 20,
    TextColor = Color3.fromRGB(255, 255, 255),
    BgColor = Color3.fromRGB(69, 69, 69)
})

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightAlt then
            Window:Toggle()
        end
    end
end)

-- Watermark
local watermark = Drawing.new("Text")
watermark.Visible = true
watermark.Position = Vector2.new(10, 10)
watermark.Size = 20
watermark.Color = Color3.fromRGB(255, 255, 255)
watermark.Text = "TOS Industries v1"
watermark.Outline = true
watermark.Center = false

-- Update watermark position on viewport resize
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    watermark.Position = Vector2.new(10, 10)
end)