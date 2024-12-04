-- Initial check for parallel lua flag
if not game:IsLoaded() then game.Loaded:Wait() end

-- Initial protection layer
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

local function LoadTOSIndustries()
    -- Get PF modules
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

    -- Hook PF's bullet system
    local oldBulletObject_new = Modules.BulletObject.new
    Modules.BulletObject.new = newcclosure(function(...)
        local Args = {...}
        if Args[1]["extra"] and AimAssist.Enabled then
            local Target = GetClosestPlayer()
            if Target then
                Args[1]["velocity"] = (Target.Position - Args[1]["position"]).unit * Args[1]["extra"]["firearmObject"]:getWeaponStat("bulletspeed")
            end
        end
        return oldBulletObject_new(table.unpack(Args))
    end)

    -- Hook network send
    local oldNetwork_send = Modules.NetworkClient.send
    Modules.NetworkClient.send = newcclosure(function(self, Name, ...)
        local Args = {...}
        if Name == "newbullets" and AimAssist.Enabled then
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

    -- PF-specific environment checks
    local gameData = game:GetService("ReplicatedStorage"):WaitForChild("GameData", 1)
    if not gameData then return false end
    
    -- Blend in with PF's network handling
    local network = getupvalue(getrenv().shared.require("network"), 1)
    if not network then return false end
    
    -- Use PF's own functions for movement
    local char = require(game:GetService("ReplicatedStorage").Character)
    local movement = require(game:GetService("ReplicatedStorage").Movement)
    
    -- Blend with PF's camera system
    local camera = workspace.CurrentCamera
    local oldCam = camera.CFrame
    
    -- Use PF's own ray casting
    local function castRay(...)
        return workspace:FindPartOnRayWithWhitelist(...)
    end
    
    -- Blend aim calculations with PF's system
    local function calculateAim(pos)
        local bulletDrop = 0.0001 * movement.bulletAcceleration
        local travelTime = (pos - camera.CFrame.Position).Magnitude / movement.bulletSpeed
        return pos + Vector3.new(0, bulletDrop * travelTime ^ 2, 0)
    end
    
    local secureEnv = initSecureEnv()
    setupMemoryProtection()
    setupHooks()
    
    setfenv(1, secureEnv)
    
    local Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        TweenService = game:GetService("TweenService"),
        CoreGui = game:GetService("CoreGui")
    }
    
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

    -- Secure configuration tables
    getgenv().AimAssist = setmetatable({
        _SEC = "TOS_"..string.char(95,73,110,100,117,115,116,114,105,101,115),
        Enabled = false,
        Mode = "Realistic",
        Smoothness = {Min = 0.15, Max = 0.32},
        FOV = 200,
        TargetPart = "UpperTorso",
        MaxDistance = 120,
        TeamCheck = true
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
        HealthEnabled = true
    }, {
        __newindex = function(t, k, v)
            if k:match("hack") or k:match("cheat") then return end
            rawset(t, k, v)
        end
    })

    -- Secure drawing function
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

    -- Secure position calculation
    local function GetPartPosition(part)
        local success, result = pcall(function()
            return Camera:WorldToViewportPoint(part.Position)
        end)
        if not success then return Vector2.new(), false, 0 end
        return Vector2.new(result.X, result.Y), result.Z > 0, result.Z
    end

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
                
                local part = character:FindFirstChild(AimAssist.TargetPart) or 
                            character:FindFirstChild("HumanoidRootPart")
                if not part then continue end
                
                local pos, onScreen, distance = GetPartPosition(part)
                if not onScreen or distance > AimAssist.MaxDistance then continue end
                
                if AimAssist.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
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

    local function UpdateAim(target)
        if not target then return end
        
        local currentTime = tick()
        local isNewTarget = target.Player ~= State.LastTarget
        
        if isNewTarget then
            State.LastTarget = target.Player
            State.LastAimTime = currentTime
            State.CurrentAcceleration = 0
        end
        
        local mousePos = Services.UserInputService:GetMouseLocation()
        local aimDelta = (target.Position - mousePos)
        local smoothing = AimAssist.Smoothness.Min + 
            (AimAssist.Smoothness.Max - AimAssist.Smoothness.Min) * 
            (target.Distance / AimAssist.MaxDistance)
        
        mousemoverel(
            aimDelta.X * smoothing,
            aimDelta.Y * smoothing
        )
    end
end

local function CreateGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TOS_"..math.random(1000, 9999)
    gui.Parent = Services.CoreGui
    
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
    
    local aimToggle = CreateToggle("Aimbot", false, function(enabled)
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

local function Initialize()
    local gui = CreateGui()
    
    local lastAimUpdate = tick()
    local lastEspUpdate = tick()
    
    Services.RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        
        if AimAssist.Enabled and Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            if currentTime - lastAimUpdate >= 0.016 then
                local target = GetClosestPlayer()
                if target then
                    UpdateAim(target)
                end
                lastAimUpdate = currentTime
            end
        else
            State.LastTarget = nil
            State.CurrentAcceleration = 0
        end
        
        if ESP.Enabled and currentTime - lastEspUpdate >= ESP.RefreshRate then
            UpdateESP()
            lastEspUpdate = currentTime
        end
    end)
    
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
    
    return true
end

if not Initialize() then
    warn("TOS Industries PF failed to initialize")
    return false
end

return true 