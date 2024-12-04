-- Initial setup
repeat task.wait() until game:IsLoaded() and game.GameId ~= 0

if not newcclosure and not getgc then
    game:GetService("Players").LocalPlayer:Kick("Executor Not Supported!")
end

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    CoreGui = game:GetService("CoreGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

-- Get PF modules first
local Modules = {}
for i,v in next, getgc(true) do
    if typeof(v) == "table" then
        if rawget(v, "send") and rawget(v, "getPing") then
            Modules.NetworkClient = v
        elseif rawget(v, "new") and rawget(v, "setColor") and rawget(v, "step") then
            Modules.BulletObject = v
        elseif rawget(v, "removeEntry") and rawget(v, "operateOnAllEntries") and rawget(v, "getEntry") then
            Modules.ReplicationInterface = v
        end
    end
end

-- Setup environment
xpcall(function()
    local oldBulletObject_new = Modules.BulletObject.new
    Modules.BulletObject.new = newcclosure(function(...)
        local Args = {...}
        if Args[1]["extra"] and AimAssist and AimAssist.Enabled then
            local Target = GetClosestPlayer()
            if Target then
                Args[1]["velocity"] = (Target.Position - Args[1]["position"]).unit * Args[1]["extra"]["firearmObject"]:getWeaponStat("bulletspeed")
            end
        end
        return oldBulletObject_new(table.unpack(Args))
    end)
end, function()
    LocalPlayer:Kick('Check if you have "FFlagDebugRunParallelLuaOnMainThread" set to "True" or modules not found.')
end)

-- Hook network send
xpcall(function()
    local oldNetwork_send = Modules.NetworkClient.send
    Modules.NetworkClient.send = newcclosure(function(self, Name, ...)
        local Args = {...}
        if Name == "newbullets" and AimAssist and AimAssist.Enabled then
            local UniqueId, BulletData, Time = ...
            for i,v in next, BulletData["bullets"] do
                local Target = GetClosestPlayer()
                if Target then
                    v[1] = (Target.Position - BulletData["firepos"]).unit
                end
            end
            return oldNetwork_send(self, Name, UniqueId, BulletData, Time)
        end
        return oldNetwork_send(self, Name, ...)
    end)
end, function()
    warn("Network hook failed")
end)

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local State = {
    LastTarget = nil,
    LastAimTime = 0,
    CurrentAcceleration = 0,
    OveraimOffset = Vector3.new(),
    ReactionDelay = 0,
    ShakeOffset = Vector3.new(),
    LastMouseMove = 0,
    MouseVelocity = Vector2.new()
}

local ESPObjects = {}

-- Initialize configurations
getgenv().AimAssist = setmetatable({
    _SEC = "TOS_"..string.char(95,73,110,100,117,115,116,114,105,101,115),
    Enabled = false,
    Mode = "Silent",
    FOV = 200,
    TargetPart = "Head",
    MaxDistance = 1000,
    TeamCheck = true,
    VisibilityCheck = true,
    SmoothAim = {
        Enabled = true,
        Smoothness = 0.25
    }
}, {
    __newindex = function(t, k, v)
        if k:match("hack") or k:match("cheat") then return end
        rawset(t, k, v)
    end
})

getgenv().ESP = setmetatable({
    _SEC = "TOS_"..string.char(95,73,110,100,117,115,116,114,105,101,115),
    Enabled = false,
    TeamCheck = true,
    BoxEnabled = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1,
    BoxTransparency = 0.9,
    NameEnabled = true,
    HealthEnabled = true,
    MaxDistance = 1000,
    RefreshRate = 0.01
}, {
    __newindex = function(t, k, v)
        if k:match("hack") or k:match("cheat") then return end
        rawset(t, k, v)
    end
})

-- Core drawing functions
local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    local success, result = pcall(function()
        for property, value in pairs(properties) do
            drawing[property] = value
        end
    end)
    if not success then drawing:Remove() return nil end
    return drawing
end

local function GetPartPosition(part)
    local success, result = pcall(function()
        return Camera:WorldToViewportPoint(part.Position)
    end)
    if not success then return Vector2.new(), false, 0 end
    return Vector2.new(result.X, result.Y), result.Z > 0, result.Z
end

-- ESP Functions
local function CreateESPObject(player)
    if player == LocalPlayer then return end
    
    local espObject = {
        Box = {
            Outline = CreateDrawing("Square", {
                Thickness = ESP.BoxThickness + 2,
                Color = Color3.new(0, 0, 0),
                Transparency = ESP.BoxTransparency,
                Filled = false,
                Visible = false
            }),
            Main = CreateDrawing("Square", {
                Thickness = ESP.BoxThickness,
                Color = ESP.BoxColor,
                Transparency = ESP.BoxTransparency,
                Filled = false,
                Visible = false
            })
        },
        Name = CreateDrawing("Text", {
            Text = player.Name,
            Size = 13,
            Center = true,
            Outline = true,
            Color = Color3.new(1, 1, 1),
            Visible = false
        }),
        Health = CreateDrawing("Square", {
            Thickness = 1,
            Color = Color3.new(0, 1, 0),
            Transparency = 0.9,
            Filled = true,
            Visible = false
        })
    }
    
    ESPObjects[player] = espObject
end

local function UpdateESP()
    for player, espObject in pairs(ESPObjects) do
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
            espObject.Box.Main.Visible = false
            espObject.Box.Outline.Visible = false
            espObject.Name.Visible = false
            espObject.Health.Visible = false
            continue
        end
        
        local pos, onScreen, distance = GetPartPosition(rootPart)
        if not onScreen or distance > ESP.MaxDistance then
            espObject.Box.Main.Visible = false
            espObject.Box.Outline.Visible = false
            espObject.Name.Visible = false
            espObject.Health.Visible = false
            continue
        end
        
        if ESP.TeamCheck and player.Team == LocalPlayer.Team then
            espObject.Box.Main.Visible = false
            espObject.Box.Outline.Visible = false
            espObject.Name.Visible = false
            espObject.Health.Visible = false
            continue
        end
        
        local boxSize = Vector2.new(1500 / distance, 2000 / distance)
        
        if ESP.BoxEnabled then
            espObject.Box.Main.Size = boxSize
            espObject.Box.Main.Position = pos - boxSize / 2
            espObject.Box.Main.Visible = true
            
            espObject.Box.Outline.Size = boxSize
            espObject.Box.Outline.Position = pos - boxSize / 2
            espObject.Box.Outline.Visible = true
        end
        
        if ESP.NameEnabled then
            espObject.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 15)
            espObject.Name.Visible = true
        end
        
        if ESP.HealthEnabled then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            espObject.Health.Size = Vector2.new(2, boxSize.Y * healthPercent)
            espObject.Health.Position = Vector2.new(pos.X - boxSize.X / 2 - 5, pos.Y - boxSize.Y / 2 + (boxSize.Y * (1 - healthPercent)))
            espObject.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            espObject.Health.Visible = true
        end
    end
end

local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ClosestScore = math.huge
    local MousePos = Services.UserInputService:GetMouseLocation()
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local part = character:FindFirstChild(AimAssist.TargetPart)
            if not part then continue end
            
            local pos, onScreen, distance = GetPartPosition(part)
            if not onScreen or distance > AimAssist.MaxDistance then continue end
            
            if AimAssist.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            if AimAssist.VisibilityCheck then
                local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Camera, LocalPlayer.Character, character})
                if hit then continue end
            end
            
            local mouseDistance = (pos - MousePos).Magnitude
            if mouseDistance > AimAssist.FOV then continue end
            
            local score = (distance * 0.2) + (mouseDistance * 0.8)
            if score < ClosestScore then
                ClosestScore = score
                ClosestPlayer = {
                    Player = player,
                    Part = part,
                    Position = pos,
                    Distance = distance
                }
            end
        end
    end
    
    return ClosestPlayer
end

-- GUI Implementation
local function CreateGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TOS_"..math.random(1000, 9999)
    gui.Parent = gethui()
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 200, 0, 240)
    main.Position = UDim2.new(0.5, -100, 0.5, -120)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    main.BorderSizePixel = 0
    main.Parent = gui
    main.Visible = false
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.BorderSizePixel = 0
    title.Text = "TOS Industries PF"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = main
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -20, 1, -40)
    container.Position = UDim2.new(0, 10, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = main
    
    local function CreateToggle(name, default, callback)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(1, 0, 0, 25)
        toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 64, 64)
        toggle.BorderSizePixel = 0
        toggle.Text = name
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.Font = Enum.Font.Gotham
        toggle.TextSize = 14
        toggle.Parent = container
        toggle.AutoButtonColor = false
        
        local enabled = default
        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 64, 64)
            callback(enabled)
        end)
        
        return toggle
    end
    
    local aimToggle = CreateToggle("Silent Aim", false, function(enabled)
        AimAssist.Enabled = enabled
    end)
    
    local espToggle = CreateToggle("ESP", false, function(enabled)
        ESP.Enabled = enabled
    end)
    
    local boxToggle = CreateToggle("Boxes", true, function(enabled)
        ESP.BoxEnabled = enabled
    end)
    
    local nameToggle = CreateToggle("Names", true, function(enabled)
        ESP.NameEnabled = enabled
    end)
    
    local healthToggle = CreateToggle("Health", true, function(enabled)
        ESP.HealthEnabled = enabled
    end)
    
    local teamToggle = CreateToggle("Team Check", true, function(enabled)
        ESP.TeamCheck = enabled
        AimAssist.TeamCheck = enabled
    end)
    
    Services.UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Delete then
            main.Visible = not main.Visible
        end
    end)
    
    return gui
end

-- Initialize
local function Initialize()
    local gui = CreateGui()
    
    -- Setup player handling
    Services.Players.PlayerAdded:Connect(CreateESPObject)
    Services.Players.PlayerRemoving:Connect(function(player)
        if ESPObjects[player] then
            for _, drawing in pairs(ESPObjects[player]) do
                if type(drawing) == "table" then
                    for _, obj in pairs(drawing) do
                        if obj.Remove then obj:Remove() end
                    end
                elseif drawing.Remove then
                    drawing:Remove()
                end
            end
            ESPObjects[player] = nil
        end
    end)
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        CreateESPObject(player)
    end
    
    -- Main loop
    local lastUpdate = tick()
    Services.RunService.RenderStepped:Connect(function()
        if ESP.Enabled then
            UpdateESP()
        end
        
        if AimAssist.Enabled then
            local target = GetClosestPlayer()
            if target then
                if AimAssist.Mode == "Silent" then
                    -- Silent aim handled by hooks
                elseif AimAssist.SmoothAim.Enabled then
                    local mousePos = Services.UserInputService:GetMouseLocation()
                    local aimDelta = (target.Position - mousePos)
                    mousemoverel(
                        aimDelta.X * AimAssist.SmoothAim.Smoothness,
                        aimDelta.Y * AimAssist.SmoothAim.Smoothness
                    )
                end
            end
        end
    end)
    
    return true
end

if not Initialize() then
    warn("TOS Industries PF failed to initialize")
    return false
end

return true