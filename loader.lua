-- Services
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace")
}

Services.LocalPlayer = Services.Players.LocalPlayer
Services.Camera = Workspace.CurrentCamera

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()

-- Utility Functions
local function isVisible(character, origin)
    if not character then return false end
    local head = character:FindFirstChild("Head")
    if not head then return false end
    local ray = Ray.new(origin, (head.Position - origin).Unit * 1000)
    local part = workspace:FindPartOnRayWithIgnoreList(ray, {Services.LocalPlayer.Character})
    return part and part:IsDescendantOf(character)
end

local function predictPosition(position, velocity)
    if not position or not velocity then return position end
    local bulletSpeed = 1000
    local timeToHit = (position - Services.Camera.CFrame.Position).Magnitude / bulletSpeed
    return position + (velocity * timeToHit)
end

-- Drawing Functions
local function createDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

-- Settings
getgenv().AimAssist = {
    Enabled = false,
    Mode = "Realistic",
    FOV = 200,
    TargetPart = "UpperTorso",
    MaxDistance = 120,
    TeamCheck = true,
    VisibilityCheck = true,
    
    -- Realism Settings
    Smoothness = 0.15,
    Humanization = {
        Enabled = true,
        Amount = 0.2
    },
    Prediction = {
        Enabled = true,
        Amount = 0.165
    }
}

getgenv().ESP = {
    Enabled = false,
    TeamCheck = true,
    BoxEnabled = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1,
    BoxTransparency = 0.9,
    NameEnabled = true,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 13,
    HealthEnabled = true,
    MaxDistance = 1000,
    Objects = {},
    SkeletonEnabled = true,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThickness = 1,
    SkeletonTransparency = 0.9,
}

-- ESP Implementation
local function createESPObject(player)
    local espObject = {
        Player = player,
        Box = createDrawing("Square", {
            Thickness = ESP.BoxThickness,
            Filled = false,
            Transparency = ESP.BoxTransparency,
            Color = ESP.BoxColor,
            Visible = false
        }),
        Name = createDrawing("Text", {
            Size = ESP.NameSize,
            Center = true,
            Outline = true,
            Color = ESP.NameColor,
            Visible = false
        }),
        HealthBar = createDrawing("Square", {
            Thickness = 1,
            Filled = true,
            Transparency = 1,
            Visible = false
        }),
        Skeleton = {
            UpperTorsoToHead = createDrawing("Line", {
                Thickness = ESP.SkeletonThickness,
                Transparency = ESP.SkeletonTransparency,
                Color = ESP.SkeletonColor,
                Visible = false
            }),
            UpperTorsoToLeftArm = createDrawing("Line", {
                Thickness = ESP.SkeletonThickness,
                Transparency = ESP.SkeletonTransparency,
                Color = ESP.SkeletonColor,
                Visible = false
            }),
            UpperTorsoToRightArm = createDrawing("Line", {
                Thickness = ESP.SkeletonThickness,
                Transparency = ESP.SkeletonTransparency,
                Color = ESP.SkeletonColor,
                Visible = false
            }),
            UpperTorsoToLowerTorso = createDrawing("Line", {
                Thickness = ESP.SkeletonThickness,
                Transparency = ESP.SkeletonTransparency,
                Color = ESP.SkeletonColor,
                Visible = false
            }),
            LowerTorsoToLeftLeg = createDrawing("Line", {
                Thickness = ESP.SkeletonThickness,
                Transparency = ESP.SkeletonTransparency,
                Color = ESP.SkeletonColor,
                Visible = false
            }),
            LowerTorsoToRightLeg = createDrawing("Line", {
                Thickness = ESP.SkeletonThickness,
                Transparency = ESP.SkeletonTransparency,
                Color = ESP.SkeletonColor,
                Visible = false
            })
        }
    }
    ESP.Objects[player] = espObject
    return espObject
end

local function removeESPObject(player)
    local espObject = ESP.Objects[player]
    if espObject then
        for _, drawing in pairs(espObject) do
            if type(drawing) == "table" and drawing.Remove then
                drawing:Remove()
            end
        end
        ESP.Objects[player] = nil
    end
end

local function updateESPObject(espObject)
    if not ESP.Enabled then
        for _, drawing in pairs(espObject) do
            if type(drawing) == "table" and drawing.Visible ~= nil then
                drawing.Visible = false
            end
        end
        return
    end

    local player = espObject.Player
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    -- Team Check
    if ESP.TeamCheck and player.Team == Services.LocalPlayer.Team then return end

    -- Distance Check
    local distance = (rootPart.Position - Services.Camera.CFrame.Position).Magnitude
    if distance > ESP.MaxDistance then return end

    -- Get Corners
    local box = {
        TopLeft = Services.Camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(-2, 3, 0).Position),
        TopRight = Services.Camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(2, 3, 0).Position),
        BottomLeft = Services.Camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(-2, -3.5, 0).Position),
        BottomRight = Services.Camera:WorldToViewportPoint(rootPart.CFrame * CFrame.new(2, -3.5, 0).Position)
    }

    -- Update Box
    if ESP.BoxEnabled then
        local boxSize = Vector2.new(
            math.max(math.abs(box.TopLeft.X - box.TopRight.X), math.abs(box.BottomLeft.X - box.BottomRight.X)),
            math.max(math.abs(box.TopLeft.Y - box.BottomLeft.Y), math.abs(box.TopRight.Y - box.BottomRight.Y))
        )
        local boxPosition = Vector2.new(
            math.min(box.TopLeft.X, box.TopRight.X, box.BottomLeft.X, box.BottomRight.X),
            math.min(box.TopLeft.Y, box.TopRight.Y, box.BottomLeft.Y, box.BottomRight.Y)
        )
        
        espObject.Box.Size = boxSize
        espObject.Box.Position = boxPosition
        espObject.Box.Visible = true
    end

    -- Update Name
    if ESP.NameEnabled then
        espObject.Name.Text = player.Name
        espObject.Name.Position = Vector2.new(
            (box.TopLeft.X + box.TopRight.X) / 2,
            box.TopLeft.Y - 20
        )
        espObject.Name.Visible = true
    end

    -- Update Health Bar
    if ESP.HealthEnabled then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local barSize = Vector2.new(2, math.abs(box.TopLeft.Y - box.BottomLeft.Y))
        local barPosition = Vector2.new(box.TopLeft.X - 5, box.TopLeft.Y)
        
        espObject.HealthBar.Size = Vector2.new(2, barSize.Y * healthPercent)
        espObject.HealthBar.Position = Vector2.new(barPosition.X, barPosition.Y + barSize.Y * (1 - healthPercent))
        espObject.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
        espObject.HealthBar.Visible = true
    end

    -- Update Skeleton
    if ESP.SkeletonEnabled then
        local character = espObject.Player.Character
        if character then
            local head = character:FindFirstChild("Head")
            local upperTorso = character:FindFirstChild("UpperTorso")
            local lowerTorso = character:FindFirstChild("LowerTorso")
            local leftArm = character:FindFirstChild("LeftUpperArm")
            local rightArm = character:FindFirstChild("RightUpperArm")
            local leftLeg = character:FindFirstChild("LeftUpperLeg")
            local rightLeg = character:FindFirstChild("RightUpperLeg")

            if head and upperTorso and lowerTorso then
                -- Head to UpperTorso
                local headPos = Services.Camera:WorldToViewportPoint(head.Position)
                local upperTorsoPos = Services.Camera:WorldToViewportPoint(upperTorso.Position)
                espObject.Skeleton.UpperTorsoToHead.From = Vector2.new(upperTorsoPos.X, upperTorsoPos.Y)
                espObject.Skeleton.UpperTorsoToHead.To = Vector2.new(headPos.X, headPos.Y)
                espObject.Skeleton.UpperTorsoToHead.Visible = true

                -- Arms
                if leftArm then
                    local leftArmPos = Services.Camera:WorldToViewportPoint(leftArm.Position)
                    espObject.Skeleton.UpperTorsoToLeftArm.From = Vector2.new(upperTorsoPos.X, upperTorsoPos.Y)
                    espObject.Skeleton.UpperTorsoToLeftArm.To = Vector2.new(leftArmPos.X, leftArmPos.Y)
                    espObject.Skeleton.UpperTorsoToLeftArm.Visible = true
                end

                if rightArm then
                    local rightArmPos = Services.Camera:WorldToViewportPoint(rightArm.Position)
                    espObject.Skeleton.UpperTorsoToRightArm.From = Vector2.new(upperTorsoPos.X, upperTorsoPos.Y)
                    espObject.Skeleton.UpperTorsoToRightArm.To = Vector2.new(rightArmPos.X, rightArmPos.Y)
                    espObject.Skeleton.UpperTorsoToRightArm.Visible = true
                end

                -- Torso connection
                local lowerTorsoPos = Services.Camera:WorldToViewportPoint(lowerTorso.Position)
                espObject.Skeleton.UpperTorsoToLowerTorso.From = Vector2.new(upperTorsoPos.X, upperTorsoPos.Y)
                espObject.Skeleton.UpperTorsoToLowerTorso.To = Vector2.new(lowerTorsoPos.X, lowerTorsoPos.Y)
                espObject.Skeleton.UpperTorsoToLowerTorso.Visible = true

                -- Legs
                if leftLeg then
                    local leftLegPos = Services.Camera:WorldToViewportPoint(leftLeg.Position)
                    espObject.Skeleton.LowerTorsoToLeftLeg.From = Vector2.new(lowerTorsoPos.X, lowerTorsoPos.Y)
                    espObject.Skeleton.LowerTorsoToLeftLeg.To = Vector2.new(leftLegPos.X, leftLegPos.Y)
                    espObject.Skeleton.LowerTorsoToLeftLeg.Visible = true
                end

                if rightLeg then
                    local rightLegPos = Services.Camera:WorldToViewportPoint(rightLeg.Position)
                    espObject.Skeleton.LowerTorsoToRightLeg.From = Vector2.new(lowerTorsoPos.X, lowerTorsoPos.Y)
                    espObject.Skeleton.LowerTorsoToRightLeg.To = Vector2.new(rightLegPos.X, rightLegPos.Y)
                    espObject.Skeleton.LowerTorsoToRightLeg.Visible = true
                end
            end
        end
    else
        for _, line in pairs(espObject.Skeleton) do
            line.Visible = false
        end
    end
end

-- Aimbot Implementation
local FOVCircle = createDrawing("Circle", {
    Thickness = 1,
    NumSides = 60,
    Radius = AimAssist.FOV,
    Filled = false,
    Transparency = 1,
    Color = Color3.fromRGB(255, 128, 0),
    Visible = true
})

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = Services.UserInputService:GetMouseLocation()

    for _, player in pairs(Services.Players:GetPlayers()) do
        if player == Services.LocalPlayer then continue end
        if AimAssist.TeamCheck and player.Team == Services.LocalPlayer.Team then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local part = character:FindFirstChild(AimAssist.TargetPart)
        if not part then continue end

        if AimAssist.VisibilityCheck and not isVisible(character, Services.Camera.CFrame.Position) then continue end

        local pos, onScreen = Services.Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
        if distance <= AimAssist.FOV and distance < shortestDistance then
            closestPlayer = {
                Player = player,
                Character = character,
                Part = part,
                Position = part.Position,
                Distance = distance
            }
            shortestDistance = distance
        end
    end

    return closestPlayer
end

local function aimAt(position)
    if not position then return end
    
    local targetPos = position
    local cameraPos = Services.Camera.CFrame.Position
    local newCFrame = CFrame.new(cameraPos, targetPos)
    
    if AimAssist.Mode == "Realistic" then
        -- Smooth camera movement
        local currentCFrame = Services.Camera.CFrame
        local smoothness = AimAssist.Smoothness
        
        -- Calculate angle difference
        local targetAngle = (targetPos - cameraPos).Unit
        local currentAngle = currentCFrame.LookVector
        
        -- Lerp the camera angle
        local resultAngle = currentAngle:Lerp(targetAngle, smoothness)
        Services.Camera.CFrame = CFrame.new(cameraPos, cameraPos + resultAngle)
    else
        -- Instant snap
        Services.Camera.CFrame = newCFrame
    end
end

-- Main Update Loop
local function updateAimbot()
    if not AimAssist.Enabled then 
        FOVCircle.Visible = false
        return 
    end

    -- Only show FOV circle when aiming
    FOVCircle.Visible = Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    FOVCircle.Position = Services.UserInputService:GetMouseLocation()
    FOVCircle.Radius = AimAssist.FOV

    -- Only aim when right mouse button is held
    if not Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        return
    end

    local target = getClosestPlayer()
    if not target then return end

    local predictedPos = target.Position
    if AimAssist.Prediction.Enabled then
        predictedPos = predictPosition(target.Position, target.Character.HumanoidRootPart.Velocity)
    end

    aimAt(predictedPos)

    -- Auto Shoot
    if Toggles.AutoShoot and Toggles.AutoShoot.Value then
        mouse1press()
        task.wait()
        mouse1release()
    end
end

local function updateESP()
    for _, espObject in pairs(ESP.Objects) do
        updateESPObject(espObject)
    end
end

-- Initialize ESP
for _, player in pairs(Services.Players:GetPlayers()) do
    if player ~= Services.LocalPlayer then
        createESPObject(player)
    end
end

-- Player Connections
Services.Players.PlayerAdded:Connect(function(player)
    createESPObject(player)
end)

Services.Players.PlayerRemoving:Connect(function(player)
    removeESPObject(player)
end)

-- Main Loop
Services.RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        for _, player in pairs(Services.Players:GetPlayers()) do
            if player ~= Services.LocalPlayer then
                local espObject = ESP.Objects[player]
                if not espObject then
                    espObject = createESPObject(player)
                end
                updateESPObject(espObject)
            end
        end
    end
    
    if AimAssist.Enabled then
        updateAimbot()
    end
end)

-- Create Window
local Window = Library:CreateWindow({
    Title = 'TOS Industries | Big Paintball 2',
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

-- Create Tabs
local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    ['Settings'] = Window:AddTab('Settings')
}

-- Combat Tab
local AimbotGroup = Tabs.Combat:AddLeftGroupbox('Aimbot')
local WeaponGroup = Tabs.Combat:AddRightGroupbox('Weapon')

-- Aimbot Settings
AimbotGroup:AddToggle('AimbotEnabled', {
    Text = 'Enable Aimbot',
    Default = false,
    Callback = function(Value)
        getgenv().AimAssist.Enabled = Value
    end
})

AimbotGroup:AddDropdown('AimbotMode', {
    Values = {'Realistic', 'Silent', 'Rage'},
    Default = 1,
    Multi = false,
    Text = 'Aimbot Mode',
    Tooltip = 'Select aimbot behavior',
    Callback = function(Value)
        getgenv().AimAssist.Mode = Value
    end
})

AimbotGroup:AddSlider('Smoothness', {
    Text = 'Smoothness',
    Default = 0.15,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Tooltip = 'Aimbot smoothness',
    Callback = function(Value)
        getgenv().AimAssist.Smoothness = Value
    end
})

AimbotGroup:AddDropdown('TargetPart', {
    Values = {'Head', 'UpperTorso', 'HumanoidRootPart'},
    Default = 2,
    Multi = false,
    Text = 'Target Part',
    Tooltip = 'Select which part to target',
    Callback = function(Value)
        getgenv().AimAssist.TargetPart = Value
    end
})

-- Weapon Settings
WeaponGroup:AddToggle('NoRecoil', {
    Text = 'No Recoil',
    Default = false
})

WeaponGroup:AddToggle('AutoShoot', {
    Text = 'Auto Shoot',
    Default = false
})

-- Visuals Tab
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP')

ESPGroup:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        getgenv().ESP.Enabled = Value
    end
})

ESPGroup:AddToggle('BoxESP', {
    Text = 'Boxes',
    Default = true,
    Callback = function(Value)
        getgenv().ESP.BoxEnabled = Value
    end
})

ESPGroup:AddToggle('NameESP', {
    Text = 'Names',
    Default = true,
    Callback = function(Value)
        getgenv().ESP.NameEnabled = Value
    end
})

ESPGroup:AddToggle('HealthESP', {
    Text = 'Health',
    Default = true,
    Callback = function(Value)
        getgenv().ESP.HealthEnabled = Value
    end
})

ESPGroup:AddToggle('SkeletonESP', {
    Text = 'Skeleton',
    Default = true,
    Callback = function(Value)
        getgenv().ESP.SkeletonEnabled = Value
    end
})

-- Settings Tab
local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Menu')

SettingsGroup:AddButton('Unload', function()
    Library:Unload()
end)

SettingsGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})

-- Initialize
Library.ToggleKeybind = Options.MenuKeybind

-- Theme Manager
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('TOS Industries')
ThemeManager:ApplyToTab(Tabs.Settings)

-- Initialize script
local function Init()
    if not game:IsLoaded() then 
        game.Loaded:Wait()
    end
    
    -- Verify game
    if game.PlaceId ~= 3606833500 then -- Big Paintball 2 PlaceID
        return error("This script is only for Big Paintball 2!")
    end
    
    Library:Notify('Loading TOS Industries...', 3)
    Library:Notify('Successfully loaded!', 5)
    return true
end

return Init() 