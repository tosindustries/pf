local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    
    -- Settings
    local Settings = {
        Aimbot = {
            Enabled = false,
            TeamCheck = true,
            WallCheck = true,
            AliveCheck = true,
            VisibilityCheck = true,
            Smoothness = 0.25,
            FOV = 400,
            TargetPart = "Head",
            Silent = false,
            AutoShoot = false,
            AutoWall = false,
            TriggerBot = false,
            TriggerDelay = 0,
            
            -- Advanced
            JumpCheck = false,
            DisableOnJump = false,
            DisableOnReload = false,
            IgnoreTransparency = false,
            IgnoreInvisible = true,
            
            -- Prediction
            Prediction = {
                Enabled = true,
                Velocity = 1000,
                DropCompensation = true,
                AutoAdjust = true,
                AimHeight = 0.5
            },
            
            -- Visuals
            ShowFOV = true,
            FOVColor = Color3.fromRGB(255, 128, 0),
            FOVThickness = 1,
            ShowSnaplines = false,
            SnaplinesColor = Color3.fromRGB(255, 128, 0),
            ShowTargetInfo = false,
            
            -- Priority
            TargetPriority = "Distance", -- Distance, Health, Random
            TargetParts = {"Head", "Torso", "HumanoidRootPart"},
            SwitchTargetTime = 0.5,
            
            -- Smoothing
            SmoothnessMethod = "Lerp", -- Lerp, Exponential, Linear
            AimAcceleration = 0.5,
            AimDeceleration = 0.25,
            
            -- Keybinds
            AimKey = Enum.UserInputType.MouseButton2,
            TriggerKey = Enum.KeyCode.E,
            ToggleKey = Enum.KeyCode.RightAlt
        }
    }
    
    -- FOV Circle
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = Settings.Aimbot.FOVThickness
    FOVCircle.NumSides = 50
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.ZIndex = 999
    FOVCircle.Transparency = 1
    FOVCircle.Color = Settings.Aimbot.FOVColor
    
    -- Utility Functions
    local function IsAlive(player)
        local character = player.Character
        return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
    end
    
    local function IsVisible(position, ignore)
        local ray = Ray.new(Camera.CFrame.Position, position - Camera.CFrame.Position)
        local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, ignore)
        
        if hit then
            if Settings.Aimbot.AutoWall then
                local material = hit.Material
                return material == Enum.Material.Glass or 
                       material == Enum.Material.Wood or 
                       material == Enum.Material.WoodPlanks or 
                       material == Enum.Material.Plastic
            end
            return false
        end
        return true
    end
    
    local function CalculatePrediction(part, velocity)
        if not Settings.Aimbot.Prediction.Enabled then return part.Position end
        
        local distance = (part.Position - Camera.CFrame.Position).Magnitude
        local timeToHit = distance / velocity
        local gravity = Vector3.new(0, -workspace.Gravity * Settings.Aimbot.Prediction.AimHeight, 0)
        local targetVelocity = part.Velocity
        
        -- Calculate predicted position with drop compensation
        local predictedPosition = part.Position + 
            (targetVelocity * timeToHit) + 
            (Settings.Aimbot.Prediction.DropCompensation and (0.5 * gravity * timeToHit * timeToHit) or Vector3.new())
        
        return predictedPosition
    end
    
    local function GetTargetPriority(player, data)
        if Settings.Aimbot.TargetPriority == "Distance" then
            return data.Distance
        elseif Settings.Aimbot.TargetPriority == "Health" then
            return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health or 100
        else
            return math.random()
        end
    end
    
    local function GetClosestPlayer()
        local ClosestPlayer = nil
        local ShortestDistance = math.huge
        local MousePosition = UserInputService:GetMouseLocation()

        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                if not Settings.Aimbot.TeamCheck or Player.Team ~= LocalPlayer.Team then
                    if not Settings.Aimbot.AliveCheck or IsAlive(Player) then
                        local Character = Player.Character
                        if Character then
                            for _, TargetPart in ipairs(Settings.Aimbot.TargetParts) do
                                local Part = Character:FindFirstChild(TargetPart)
                                if Part then
                                    if not Settings.Aimbot.VisibilityCheck or IsVisible(Part.Position, {LocalPlayer.Character, Character}) then
                                        local PartPosition, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                                        local Distance = (Vector2.new(PartPosition.X, PartPosition.Y) - MousePosition).Magnitude

                                        if OnScreen and Distance <= Settings.Aimbot.FOV then
                                            local Priority = GetTargetPriority(Player, {Distance = Distance})
                                            if Priority < ShortestDistance then
                                                ShortestDistance = Priority
                                                ClosestPlayer = {
                                                    Player = Player,
                                                    Character = Character,
                                                    Part = Part,
                                                    Position = PartPosition,
                                                    OnScreen = OnScreen,
                                                    Distance = Distance
                                                }
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        return ClosestPlayer
    end
    
    -- Aimbot Function
    local function AimAt(Position)
        local TargetPos = Position
        local CameraPos = Camera.CFrame.Position
        local NewCFrame = CFrame.new(CameraPos, TargetPos)
        
        if Settings.Aimbot.SmoothnessMethod == "Lerp" then
            Camera.CFrame = Camera.CFrame:Lerp(NewCFrame, Settings.Aimbot.Smoothness)
        elseif Settings.Aimbot.SmoothnessMethod == "Exponential" then
            local Delta = NewCFrame.LookVector - Camera.CFrame.LookVector
            local Smoothed = Camera.CFrame.LookVector + Delta * (1 - math.exp(-Settings.Aimbot.AimAcceleration * Settings.Aimbot.Smoothness))
            Camera.CFrame = CFrame.new(CameraPos, CameraPos + Smoothed)
        else -- Linear
            local Delta = NewCFrame.LookVector - Camera.CFrame.LookVector
            local Smoothed = Camera.CFrame.LookVector + Delta * Settings.Aimbot.Smoothness
            Camera.CFrame = CFrame.new(CameraPos, CameraPos + Smoothed)
        end
    end
    
    -- Silent Aim Implementation
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if Settings.Aimbot.Silent and Settings.Aimbot.Enabled and method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
            local Target = GetClosestPlayer()
            if Target and Target.Part then
                local PredictedPosition = Target.Part.Position
                
                if Settings.Aimbot.Prediction.Enabled then
                    local Velocity = Target.Part.Velocity
                    local TimeToTarget = (Target.Part.Position - Camera.CFrame.Position).Magnitude / Settings.Aimbot.Prediction.Velocity
                    PredictedPosition = Target.Part.Position + (Velocity * TimeToTarget)
                end
                
                args[1] = Ray.new(Camera.CFrame.Position, (PredictedPosition - Camera.CFrame.Position).Unit * 1000)
                return Target.Part, PredictedPosition
            end
        end
        
        return oldNamecall(self, unpack(args))
    end)
    
    -- Update Loop
    RunService.RenderStepped:Connect(function()
        -- Update FOV Circle
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Visible = Settings.Aimbot.Enabled and Settings.Aimbot.ShowFOV

        if Settings.Aimbot.Enabled and not Settings.Aimbot.Silent and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local Target = GetClosestPlayer()
            if Target then
                local PredictedPosition = Target.Part.Position
                
                if Settings.Aimbot.Prediction.Enabled then
                    local Velocity = Target.Part.Velocity
                    local TimeToTarget = (Target.Part.Position - Camera.CFrame.Position).Magnitude / Settings.Aimbot.Prediction.Velocity
                    PredictedPosition = Target.Part.Position + (Velocity * TimeToTarget)
                end
                
                AimAt(PredictedPosition)
            end
        end
    end)
    
    -- Create UI
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
    
    local Window = Library:CreateWindow({
        Title = "TOS Industries V1",
        Center = true,
        AutoShow = true,
    })
    
    -- Create Tabs
    local Tabs = {
        Aimbot = Window:AddTab("Aimbot"),
        ['UI Settings'] = Window:AddTab("Settings")
    }
    
    -- Create Groups
    local MainAimbotGroup = Tabs.Aimbot:AddLeftGroupbox("Main Settings")
    local FOVGroup = Tabs.Aimbot:AddRightGroupbox("FOV Settings")
    local PredictionGroup = Tabs.Aimbot:AddLeftGroupbox("Prediction")
    local AdvancedGroup = Tabs.Aimbot:AddRightGroupbox("Advanced")
    local BehaviorGroup = Tabs.Aimbot:AddLeftGroupbox("Behavior")
    local VisualsGroup = Tabs.Aimbot:AddRightGroupbox("Visuals")
    local PriorityGroup = Tabs.Aimbot:AddLeftGroupbox("Priority")
    local SmoothingGroup = Tabs.Aimbot:AddRightGroupbox("Smoothing")
    
    -- Main Settings
    MainAimbotGroup:AddToggle("AimbotEnabled", {
        Text = "Enable Aimbot",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.Enabled = Value
        end
    })
    
    MainAimbotGroup:AddToggle("SilentAim", {
        Text = "Silent Aim",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.Silent = Value
        end
    })
    
    MainAimbotGroup:AddToggle("TeamCheck", {
        Text = "Team Check",
        Default = true,
        Callback = function(Value)
            Settings.Aimbot.TeamCheck = Value
        end
    })
    
    MainAimbotGroup:AddToggle("WallCheck", {
        Text = "Wall Check",
        Default = true,
        Callback = function(Value)
            Settings.Aimbot.WallCheck = Value
        end
    })
    
    -- Behavior Settings
    BehaviorGroup:AddToggle("AutoShoot", {
        Text = "Auto Shoot",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.AutoShoot = Value
        end
    })
    
    BehaviorGroup:AddToggle("AutoWall", {
        Text = "Auto Wall",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.AutoWall = Value
        end
    })
    
    BehaviorGroup:AddToggle("TriggerBot", {
        Text = "Trigger Bot",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.TriggerBot = Value
        end
    })
    
    BehaviorGroup:AddSlider("TriggerDelay", {
        Text = "Trigger Delay",
        Default = 0,
        Min = 0,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
            Settings.Aimbot.TriggerDelay = Value / 1000
        end
    })
    
    -- Advanced Settings
    AdvancedGroup:AddToggle("JumpCheck", {
        Text = "Jump Check",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.JumpCheck = Value
        end
    })
    
    AdvancedGroup:AddToggle("DisableOnJump", {
        Text = "Disable On Jump",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.DisableOnJump = Value
        end
    })
    
    AdvancedGroup:AddToggle("DisableOnReload", {
        Text = "Disable On Reload",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.DisableOnReload = Value
        end
    })
    
    -- Priority Settings
    PriorityGroup:AddDropdown("TargetPriority", {
        Text = "Target Priority",
        Default = "Distance",
        Values = {"Distance", "Health", "Random"},
        Callback = function(Value)
            Settings.Aimbot.TargetPriority = Value
        end
    })
    
    PriorityGroup:AddDropdown("TargetPart", {
        Text = "Target Part",
        Default = "Head",
        Values = {"Head", "Torso", "HumanoidRootPart"},
        Callback = function(Value)
            Settings.Aimbot.TargetPart = Value
        end
    })
    
    -- Smoothing Settings
    SmoothingGroup:AddDropdown("SmoothnessMethod", {
        Text = "Smoothing Method",
        Default = "Lerp",
        Values = {"Lerp", "Exponential", "Linear"},
        Callback = function(Value)
            Settings.Aimbot.SmoothnessMethod = Value
        end
    })
    
    SmoothingGroup:AddSlider("Smoothness", {
        Text = "Smoothness",
        Default = 0.25,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            Settings.Aimbot.Smoothness = Value
        end
    })
    
    SmoothingGroup:AddSlider("AimAcceleration", {
        Text = "Acceleration",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            Settings.Aimbot.AimAcceleration = Value
        end
    })
    
    -- Prediction Settings
    PredictionGroup:AddToggle("Prediction", {
        Text = "Enable Prediction",
        Default = true,
        Callback = function(Value)
            Settings.Aimbot.Prediction.Enabled = Value
        end
    })
    
    PredictionGroup:AddToggle("DropCompensation", {
        Text = "Drop Compensation",
        Default = true,
        Callback = function(Value)
            Settings.Aimbot.Prediction.DropCompensation = Value
        end
    })
    
    PredictionGroup:AddSlider("PredictionVelocity", {
        Text = "Velocity",
        Default = 1000,
        Min = 100,
        Max = 3000,
        Rounding = 0,
        Callback = function(Value)
            Settings.Aimbot.Prediction.Velocity = Value
        end
    })
    
    PredictionGroup:AddSlider("AimHeight", {
        Text = "Aim Height",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            Settings.Aimbot.Prediction.AimHeight = Value
        end
    })
    
    -- Visual Settings
    VisualsGroup:AddToggle("ShowFOV", {
        Text = "Show FOV",
        Default = true,
        Callback = function(Value)
            Settings.Aimbot.ShowFOV = Value
        end
    })
    
    VisualsGroup:AddToggle("ShowSnaplines", {
        Text = "Show Snaplines",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.ShowSnaplines = Value
        end
    })
    
    VisualsGroup:AddToggle("ShowTargetInfo", {
        Text = "Show Target Info",
        Default = false,
        Callback = function(Value)
            Settings.Aimbot.ShowTargetInfo = Value
        end
    })
    
    -- FOV Settings
    FOVGroup:AddSlider("FOVSize", {
        Text = "FOV Size",
        Default = 400,
        Min = 50,
        Max = 800,
        Rounding = 0,
        Callback = function(Value)
            Settings.Aimbot.FOV = Value
        end
    })
    
    -- Settings Tab
    local SettingsGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu Settings')
    
    SettingsGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
        Default = 'RightShift',
        NoUI = true,
        Text = 'Menu keybind'
    })
    
    Library.ToggleKeybind = Options.MenuKeybind
    
    -- Initialize menu
    Library:OnUnload(function()
        if FOVCircle then
            FOVCircle:Remove()
        end
        Library.Unloaded = true
    end)
    
    Library:Notify("Script loaded successfully!", 5)
    
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
        TextOutline = true
    }

    -- ESP Objects
    local ESPObjects = {}

    -- Get PF Character
    local function GetPFCharacter(player)
        local success, result = pcall(function()
            -- PF stores characters in ReplicatedStorage
            local chars = game:GetService("ReplicatedStorage").Character
            if chars then
                return chars[player]
            end
            return nil
        end)
        if success and result then
            return result
        end
        return nil
    end

    -- Get PF Health
    local function GetPFHealth(character)
        local success, result = pcall(function()
            if character and character:FindFirstChild("Health") then
                return character.Health.Value, 100
            end
            return 0, 100
        end)
        if success then
            return result, 100
        end
        return 0, 100
    end

    -- Create ESP Object
    local function CreateESPObject(player)
        if player == LocalPlayer then return end
        
        local espObject = {
            Player = player,
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            HealthBar = Drawing.new("Square"),
            HealthBarOutline = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            TracerOutline = Drawing.new("Line")
        }
        
        -- Box Settings
        espObject.Box.Thickness = ESPSettings.BoxThickness
        espObject.Box.Filled = false
        espObject.Box.Visible = false
        espObject.BoxOutline.Thickness = ESPSettings.BoxThickness + 1
        espObject.BoxOutline.Filled = false
        espObject.BoxOutline.Color = Color3.new(0, 0, 0)
        espObject.BoxOutline.Visible = false
        
        -- Name Settings
        espObject.Name.Size = ESPSettings.TextSize
        espObject.Name.Center = true
        espObject.Name.Outline = ESPSettings.TextOutline
        espObject.Name.Visible = false
        
        -- Distance Settings
        espObject.Distance.Size = ESPSettings.TextSize
        espObject.Distance.Center = true
        espObject.Distance.Outline = ESPSettings.TextOutline
        espObject.Distance.Visible = false
        
        -- Health Bar Settings
        espObject.HealthBar.Thickness = 1
        espObject.HealthBar.Filled = true
        espObject.HealthBar.Visible = false
        espObject.HealthBarOutline.Thickness = 2
        espObject.HealthBarOutline.Filled = true
        espObject.HealthBarOutline.Color = Color3.new(0, 0, 0)
        espObject.HealthBarOutline.Visible = false
        
        -- Tracer Settings
        espObject.Tracer.Thickness = ESPSettings.TracerThickness
        espObject.Tracer.Visible = false
        espObject.TracerOutline.Thickness = ESPSettings.TracerThickness + 1
        espObject.TracerOutline.Color = Color3.new(0, 0, 0)
        espObject.TracerOutline.Visible = false
        
        ESPObjects[player] = espObject
        return espObject
    end

    -- Remove ESP Object
    local function RemoveESPObject(player)
        local espObject = ESPObjects[player]
        if espObject then
            for _, drawing in pairs(espObject) do
                if type(drawing) == "table" and drawing.Remove then
                    drawing:Remove()
                end
            end
            ESPObjects[player] = nil
        end
    end

    -- Update ESP Object
    local function UpdateESPObject(espObject)
        if not ESPSettings.Enabled then
            for _, drawing in pairs(espObject) do
                if type(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
            return
        end
        
        local player = espObject.Player
        local character = GetPFCharacter(player)
        if not character then
            return
        end
        
        -- Get health
        local health, maxHealth = GetPFHealth(character)
        if health <= 0 then
            return
        end
        
        -- Team Check
        if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team then
            return
        end
        
        -- Get character position
        local torso = character:FindFirstChild("Torso")
        if not torso then return end
        
        local head = character:FindFirstChild("Head")
        if not head then return end
        
        -- Distance Check
        local distance = (torso.Position - Camera.CFrame.Position).Magnitude
        if distance > ESPSettings.MaxDistance then
            return
        end
        
        -- Get corners for box ESP
        local topPos = head.Position + Vector3.new(0, 1, 0)
        local bottomPos = torso.Position - Vector3.new(0, 2, 0)
        
        local screenTop, onScreenTop = Camera:WorldToViewportPoint(topPos)
        local screenBottom, onScreenBottom = Camera:WorldToViewportPoint(bottomPos)
        
        if not onScreenTop or not onScreenBottom then
            return
        end
        
        local boxSize = Vector2.new(math.abs(screenTop.Y - screenBottom.Y) / 2, math.abs(screenTop.Y - screenBottom.Y))
        local boxPosition = Vector2.new(screenTop.X - boxSize.X / 2, screenTop.Y)
        
        -- Set Color
        local color = ESPSettings.TeamColor and player.TeamColor.Color or Color3.new(1, 1, 1)
        
        -- Update Box
        if ESPSettings.ShowBox then
            espObject.Box.Size = boxSize
            espObject.Box.Position = boxPosition
            espObject.Box.Color = color
            espObject.Box.Visible = true
            
            espObject.BoxOutline.Size = boxSize
            espObject.BoxOutline.Position = boxPosition
            espObject.BoxOutline.Visible = true
        else
            espObject.Box.Visible = false
            espObject.BoxOutline.Visible = false
        end
        
        -- Update Name
        if ESPSettings.ShowName then
            espObject.Name.Text = player.Name
            espObject.Name.Position = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y - 16)
            espObject.Name.Color = color
            espObject.Name.Visible = true
        else
            espObject.Name.Visible = false
        end
        
        -- Update Distance
        if ESPSettings.ShowDistance then
            espObject.Distance.Text = string.format("%.0f studs", distance)
            espObject.Distance.Position = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y + boxSize.Y)
            espObject.Distance.Color = color
            espObject.Distance.Visible = true
        else
            espObject.Distance.Visible = false
        end
        
        -- Update Health Bar
        if ESPSettings.ShowHealth then
            local healthPercent = health / maxHealth
            local barSize = Vector2.new(2, boxSize.Y * healthPercent)
            local barPosition = Vector2.new(boxPosition.X - 5, boxPosition.Y + boxSize.Y * (1 - healthPercent))
            
            espObject.HealthBar.Size = barSize
            espObject.HealthBar.Position = barPosition
            espObject.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
            espObject.HealthBar.Visible = true
            
            espObject.HealthBarOutline.Size = Vector2.new(4, boxSize.Y)
            espObject.HealthBarOutline.Position = Vector2.new(boxPosition.X - 6, boxPosition.Y)
            espObject.HealthBarOutline.Visible = true
        else
            espObject.HealthBar.Visible = false
            espObject.HealthBarOutline.Visible = false
        end
        
        -- Update Tracer
        if ESPSettings.ShowTracer then
            local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            local tracerStart = Vector2.new(boxPosition.X + boxSize.X/2, boxPosition.Y + boxSize.Y)
            
            espObject.Tracer.From = screenCenter
            espObject.Tracer.To = tracerStart
            espObject.Tracer.Color = color
            espObject.Tracer.Visible = true
            
            espObject.TracerOutline.From = screenCenter
            espObject.TracerOutline.To = tracerStart
            espObject.TracerOutline.Visible = true
        else
            espObject.Tracer.Visible = false
            espObject.TracerOutline.Visible = false
        end
    end

    -- Update all ESP Objects
    local function UpdateESP()
        for _, espObject in pairs(ESPObjects) do
            pcall(UpdateESPObject, espObject)
        end
    end

    -- Initialize ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESPObject(player)
        end
    end

    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        CreateESPObject(player)
    end)

    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        RemoveESPObject(player)
    end)

    -- Update ESP
    RunService.RenderStepped:Connect(UpdateESP)

    -- Add ESP UI elements
    local ESPTab = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

    ESPTab:AddToggle("ESPEnabled", {
        Text = "Enable ESP",
        Default = false,
        Callback = function(Value)
            ESPSettings.Enabled = Value
        end
    })

    ESPTab:AddToggle("ESPTeamCheck", {
        Text = "Team Check",
        Default = true,
        Callback = function(Value)
            ESPSettings.TeamCheck = Value
        end
    })

    ESPTab:AddToggle("ESPTeamColor", {
        Text = "Team Color",
        Default = true,
        Callback = function(Value)
            ESPSettings.TeamColor = Value
        end
    })

    ESPTab:AddToggle("ESPBox", {
        Text = "Show Box",
        Default = false,
        Callback = function(Value)
            ESPSettings.ShowBox = Value
        end
    })

    ESPTab:AddToggle("ESPName", {
        Text = "Show Name",
        Default = false,
        Callback = function(Value)
            ESPSettings.ShowName = Value
        end
    })

    ESPTab:AddToggle("ESPHealth", {
        Text = "Show Health",
        Default = false,
        Callback = function(Value)
            ESPSettings.ShowHealth = Value
        end
    })

    ESPTab:AddToggle("ESPDistance", {
        Text = "Show Distance",
        Default = false,
        Callback = function(Value)
            ESPSettings.ShowDistance = Value
        end
    })

    ESPTab:AddToggle("ESPTracer", {
        Text = "Show Tracer",
        Default = false,
        Callback = function(Value)
            ESPSettings.ShowTracer = Value
        end
    })

    ESPTab:AddSlider("ESPMaxDistance", {
        Text = "Max Distance",
        Default = 1000,
        Min = 100,
        Max = 5000,
        Rounding = 0,
        Callback = function(Value)
            ESPSettings.MaxDistance = Value
        end
    })

    ESPTab:AddSlider("ESPTextSize", {
        Text = "Text Size",
        Default = 13,
        Min = 8,
        Max = 24,
        Rounding = 0,
        Callback = function(Value)
            ESPSettings.TextSize = Value
            for _, espObject in pairs(ESPObjects) do
                espObject.Name.Size = Value
                espObject.Distance.Size = Value
            end
        end
    })
    
    return true
end

local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result