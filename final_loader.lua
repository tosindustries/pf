local function LoadTOSIndustries()
    local Security = {
        _VERIFIED = true,
        _KEY = "TOS"..string.char(95,73,110,100,117,115,116,114,105,101,115),
        _SALT = string.char(84,79,83,95,73,78,68),
        _WATERMARK = "TOS_Industries_v1_"..string.char(67,79,80,89,82,73,71,72,84),
        _INITIALIZED = os.time(),
        _CHECKSUMS = {},
        _INSTANCES = {},
        _SIGNATURES = {},
        
        _CHECK = function(self)
            if not self._VERIFIED then return false end
            if not self._KEY:find("TOS") then return false end
            if not self._SALT:find("TOS") then return false end
            if not debug.info(2, "s"):find("TOS") then return false end
            if os.time() - self._INITIALIZED > 300 then return false end
            if not self:_ValidateInstances() then return false end
            if not self:_ValidateSignatures() then return false end
            return true
        end,

        _VALIDATE = function(self, module)
            if not self:_CHECK() then return false end
            if not module then return false end
            if not module._SEC then return false end
            if module._SEC ~= self._KEY then return false end
            if not self:_ValidateChecksum(module) then return false end
            if not self._INSTANCES[module] then return false end
            return true
        end,

        _GenerateChecksum = function(self, data)
            local sum = 0
            for i = 1, #data do
                sum = sum + string.byte(data:sub(i,i)) * i
            end
            return sum * #self._WATERMARK
        end,

        _ValidateChecksum = function(self, module)
            local checksum = self:_GenerateChecksum(tostring(module))
            if not self._CHECKSUMS[module] then
                self._CHECKSUMS[module] = checksum
                return true
            end
            return self._CHECKSUMS[module] == checksum
        end,

        _RegisterInstance = function(self, instance)
            if not self:_CHECK() then return false end
            local signature = tostring(instance)..self._WATERMARK
            self._INSTANCES[instance] = signature
            self._SIGNATURES[signature] = true
            return true
        end,

        _ValidateInstances = function(self)
            for instance, signature in pairs(self._INSTANCES) do
                if not self._SIGNATURES[signature] then return false end
                if tostring(instance)..self._WATERMARK ~= signature then return false end
            end
            return true
        end,

        _ValidateSignatures = function(self)
            for signature, _ in pairs(self._SIGNATURES) do
                local found = false
                for _, instanceSig in pairs(self._INSTANCES) do
                    if instanceSig == signature then
                        found = true
                        break
                    end
                end
                if not found then return false end
            end
            return true
        end,

        _SecureCall = function(self, func, ...)
            if not self:_CHECK() then return end
            if not self._SIGNATURES[tostring(func)] then return end
            return func(...)
        end
    }

    local env = getfenv(1)
    local protectedEnv = setmetatable({}, {
        __index = function(_, k)
            if k:find("TOS") and not debug.info(2, "s"):find("TOS") then
                error("TOS Industries security violation")
                return nil
            end
            return rawget(env, k)
        end,
        __newindex = function(_, k, v)
            if k:find("TOS") then
                error("TOS Industries security violation")
                return
            end
            rawset(env, k, v)
        end,
        __metatable = "Locked"
    })

    setfenv(1, protectedEnv)

    if not Security:_CHECK() then return end
    if not Security:_RegisterInstance(getfenv(1)) then return end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local Workspace = game:GetService("Workspace")

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

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

    local SkeletonPoints = {
        Head = {"Head", "UpperTorso"},
        UpperBody = {
            {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"RightLowerArm", "RightHand"},
            {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"LeftLowerArm", "LeftHand"},
        },
        LowerBody = {
            {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"},
            {"RightLowerLeg", "RightFoot"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"LeftLowerLeg", "LeftFoot"}
        },
        Torso = {"UpperTorso", "LowerTorso"}
    }

    local TOSIndustries = Instance.new("ScreenGui")
    TOSIndustries.Name = Security._KEY
    TOSIndustries.Parent = CoreGui
    TOSIndustries.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Security:_RegisterInstance(TOSIndustries)

    getgenv().AimAssist = {
        _SEC = Security._KEY,
        _INSTANCE_ID = Security:_GenerateChecksum("AimAssist"),
        Enabled = false,
        Mode = "Realistic",
        Smoothness = {
            Min = 0.15,
            Max = 0.32,
            Acceleration = 0.08,
            Deceleration = 0.12
        },
        FOV = 200,
        TargetPart = "UpperTorso",
        MaxDistance = 120,
        Acceleration = {
            Enabled = true,
            StartSpeed = 0.06,
            MaxSpeed = 0.22,
            BuildupTime = 0.3
        },
        Humanization = {
            Enabled = true,
            Fatigue = {
                Enabled = true,
                Amount = 0,
                IncreaseRate = 0.015,
                DecreaseRate = 0.008,
                Max = 0.35,
                AimPenalty = 0.2
            },
            Shakiness = {
                Amount = {Min = 0.02, Max = 0.08},
                Speed = {Min = 0.4, Max = 0.7}
            },
            Overaim = {
                Enabled = true,
                Amount = {Min = 0.1, Max = 0.25},
                Recovery = 0.15
            },
            Reaction = {
                Delay = {Min = 0.12, Max = 0.22},
                Distance = {Min = 0.3, Max = 0.7}
            }
        },
        TargetPriority = {
            Distance = 0.4,
            Angle = 0.6
        }
    }

    getgenv().ESP = {
        _SEC = Security._KEY,
        _INSTANCE_ID = Security:_GenerateChecksum("ESP"),
        Enabled = false,
        TeamCheck = true,
        BoxEnabled = true,
        BoxColor = Color3.fromRGB(255, 255, 255),
        BoxThickness = 1,
        BoxTransparency = 0.9,
        SkeletonEnabled = true,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        SkeletonThickness = 1,
        SkeletonTransparency = 0.8,
        NameEnabled = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        NameSize = 13,
        NameFont = Drawing.Fonts.System,
        HealthEnabled = true,
        HealthColor = Color3.fromRGB(0, 255, 0),
        HealthTransparency = 0.9,
        MaxDistance = 1000,
        RefreshRate = 0.01
    }

    if not Security:_RegisterInstance(getgenv().AimAssist) then return end
    if not Security:_RegisterInstance(getgenv().ESP) then return end

    local function CreateDrawing(type, properties)
        if not Security:_VALIDATE(ESP) then return end
        local drawing = Drawing.new(type)
        for property, value in pairs(properties) do
            drawing[property] = value
        end
        return drawing
    end

    local function GetPartPosition(part)
        local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
        return Vector2.new(screen.X, screen.Y), onScreen, screen.Z
    end

    local function CreateESPObject(player)
        if not Security:_VALIDATE(ESP) then return end
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
            Skeleton = {},
            Name = CreateDrawing("Text", {
                Text = player.Name,
                Size = ESP.NameSize,
                Center = true,
                Outline = true,
                Color = ESP.NameColor,
                Font = ESP.NameFont,
                Visible = false
            }),
            HealthBar = {
                Background = CreateDrawing("Square", {
                    Thickness = 1,
                    Color = Color3.new(0, 0, 0),
                    Transparency = ESP.HealthTransparency,
                    Filled = true,
                    Visible = false
                }),
                Main = CreateDrawing("Square", {
                    Thickness = 1,
                    Color = ESP.HealthColor,
                    Transparency = ESP.HealthTransparency,
                    Filled = true,
                    Visible = false
                })
            }
        }

        for _, connections in pairs(SkeletonPoints) do
            if type(connections) == "table" then
                for _, points in pairs(connections) do
                    table.insert(espObject.Skeleton, {
                        Line = CreateDrawing("Line", {
                            Thickness = ESP.SkeletonThickness,
                            Color = ESP.SkeletonColor,
                            Transparency = ESP.SkeletonTransparency,
                            Visible = false
                        }),
                        From = points[1],
                        To = points[2]
                    })
                end
            else
                table.insert(espObject.Skeleton, {
                    Line = CreateDrawing("Line", {
                        Thickness = ESP.SkeletonThickness,
                        Color = ESP.SkeletonColor,
                        Transparency = ESP.SkeletonTransparency,
                        Visible = false
                    }),
                    From = connections[1],
                    To = connections[2]
                })
            end
        end

        ESPObjects[player] = espObject
    end

    local function RemoveESPObject(player)
        if not Security:_VALIDATE(ESP) then return end
        local espObject = ESPObjects[player]
        if espObject then
            espObject.Box.Main:Remove()
            espObject.Box.Outline:Remove()
            
            for _, connection in pairs(espObject.Skeleton) do
                connection.Line:Remove()
            end
            
            espObject.Name:Remove()
            espObject.HealthBar.Background:Remove()
            espObject.HealthBar.Main:Remove()
            
            ESPObjects[player] = nil
        end
    end

    local function UpdateESP()
        if not Security:_VALIDATE(ESP) then
            ESP.Enabled = false
            return
        end
        
        for player, espObject in pairs(ESPObjects) do
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
                espObject.Box.Main.Visible = false
                espObject.Box.Outline.Visible = false
                espObject.Name.Visible = false
                espObject.HealthBar.Background.Visible = false
                espObject.HealthBar.Main.Visible = false
                for _, connection in pairs(espObject.Skeleton) do
                    connection.Line.Visible = false
                end
                continue
            end

            local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
            if distance > ESP.MaxDistance then continue end

            if ESP.TeamCheck and player.Team == LocalPlayer.Team then continue end

            if ESP.BoxEnabled then
                local boxSize = Vector2.new(2000 / distance, 2500 / distance)
                local boxPosition, onScreen = GetPartPosition(rootPart)
                
                espObject.Box.Main.Size = boxSize
                espObject.Box.Main.Position = boxPosition - boxSize / 2
                espObject.Box.Main.Visible = onScreen
                
                espObject.Box.Outline.Size = boxSize
                espObject.Box.Outline.Position = boxPosition - boxSize / 2
                espObject.Box.Outline.Visible = onScreen
            end

            if ESP.SkeletonEnabled then
                for _, connection in pairs(espObject.Skeleton) do
                    local fromPart = character:FindFirstChild(connection.From)
                    local toPart = character:FindFirstChild(connection.To)
                    
                    if fromPart and toPart then
                        local fromPos, fromOnScreen = GetPartPosition(fromPart)
                        local toPos, toOnScreen = GetPartPosition(toPart)
                        
                        connection.Line.From = fromPos
                        connection.Line.To = toPos
                        connection.Line.Visible = fromOnScreen and toOnScreen
                    else
                        connection.Line.Visible = false
                    end
                end
            end

            if ESP.NameEnabled then
                local namePos, onScreen = GetPartPosition(rootPart)
                espObject.Name.Position = Vector2.new(namePos.X, namePos.Y - 40)
                espObject.Name.Visible = onScreen
            end

            if ESP.HealthEnabled then
                local healthPos, onScreen = GetPartPosition(rootPart)
                local healthSize = Vector2.new(3, 50)
                local healthOffset = Vector2.new(-25, -25)
                
                espObject.HealthBar.Background.Size = healthSize
                espObject.HealthBar.Background.Position = Vector2.new(healthPos.X, healthPos.Y) + healthOffset
                espObject.HealthBar.Background.Visible = onScreen
                
                local healthScale = humanoid.Health / humanoid.MaxHealth
                espObject.HealthBar.Main.Size = Vector2.new(healthSize.X, healthSize.Y * healthScale)
                espObject.HealthBar.Main.Position = Vector2.new(healthPos.X, healthPos.Y + healthSize.Y * (1 - healthScale)) + healthOffset
                espObject.HealthBar.Main.Color = Color3.fromRGB(255 * (1 - healthScale), 255 * healthScale, 0)
                espObject.HealthBar.Main.Visible = onScreen
            end
        end
    end

    local function GetDynamicSmoothness(distance, targetVelocity, isNewTarget)
        if not Security:_VALIDATE(AimAssist) then return 1 end
        
        local base = math.lerp(
            AimAssist.Smoothness.Min, 
            AimAssist.Smoothness.Max, 
            math.clamp(distance / AimAssist.MaxDistance, 0, 1)
        )
        
        if AimAssist.Humanization.Fatigue.Enabled then
            base = base + (AimAssist.Humanization.Fatigue.Amount * AimAssist.Humanization.Fatigue.AimPenalty)
        end
        
        local velocityFactor = math.clamp(targetVelocity.Magnitude / 45, 0, 1)
        base = base + (velocityFactor * 0.15)
        
        if isNewTarget then
            base = base * (1 + math.random(AimAssist.Humanization.Reaction.Distance.Min * 100, 
                                         AimAssist.Humanization.Reaction.Distance.Max * 100) / 100)
        end
        
        return base
    end

    local function UpdateShake()
        local time = tick()
        local fatigueFactor = AimAssist.Humanization.Fatigue.Amount / AimAssist.Humanization.Fatigue.Max
        local shakeAmount = math.lerp(
            AimAssist.Humanization.Shakiness.Amount.Min,
            AimAssist.Humanization.Shakiness.Amount.Max,
            fatigueFactor
        )
        local shakeSpeed = math.lerp(
            AimAssist.Humanization.Shakiness.Speed.Min,
            AimAssist.Humanization.Shakiness.Speed.Max,
            fatigueFactor
        )
        
        State.ShakeOffset = Vector3.new(
            math.sin(time * shakeSpeed) * shakeAmount,
            math.cos(time * shakeSpeed * 1.3) * shakeAmount,
            math.sin(time * shakeSpeed * 0.7) * shakeAmount
        )
    end

    local function GetClosestPlayer()
        if not Security:_VALIDATE(AimAssist) then return end
        
        local ClosestPlayer = nil
        local ClosestScore = math.huge
        local MousePos = UserInputService:GetMouseLocation()
        
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                local Character = Player.Character
                if not Character then continue end
                
                local HitParts = {
                    Character:FindFirstChild(AimAssist.TargetPart),
                    Character:FindFirstChild("Head"),
                    Character:FindFirstChild("HumanoidRootPart")
                }
                
                local ValidPart = nil
                for _, Part in ipairs(HitParts) do
                    if Part then
                        ValidPart = Part
                        break
                    end
                end
                
                if not ValidPart then continue end
                
                local Distance = (ValidPart.Position - Camera.CFrame.Position).Magnitude
                if Distance > AimAssist.MaxDistance then continue end
                
                local ScreenPos, OnScreen = Camera:WorldToScreenPoint(ValidPart.Position)
                if not OnScreen then continue end
                
                local MouseDistance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                if MouseDistance > AimAssist.FOV then continue end
                
                local DistanceScore = Distance / AimAssist.MaxDistance
                local AngleScore = MouseDistance / AimAssist.FOV
                
                local FinalScore = (DistanceScore * AimAssist.TargetPriority.Distance) +
                                  (AngleScore * AimAssist.TargetPriority.Angle)
                
                if FinalScore < ClosestScore then
                    ClosestPlayer = {
                        Player = Player,
                        Part = ValidPart,
                        Distance = Distance,
                        ScreenDistance = MouseDistance
                    }
                    ClosestScore = FinalScore
                end
            end
        end
        
        return ClosestPlayer
    end

    local function SmoothAim(TargetInfo)
        if not Security:_VALIDATE(AimAssist) then
            AimAssist.Enabled = false
            return
        end
        
        local CurrentTime = tick()
        local IsNewTarget = TargetInfo.Player ~= State.LastTarget

        if IsNewTarget then
            State.ReactionDelay = math.random(
                AimAssist.Humanization.Reaction.Delay.Min * 100,
                AimAssist.Humanization.Reaction.Delay.Max * 100
            ) / 100
            State.LastTarget = TargetInfo.Player
            State.LastAimTime = CurrentTime
            State.CurrentAcceleration = AimAssist.Acceleration.StartSpeed
            
            if AimAssist.Humanization.Overaim.Enabled then
                local OveraimAmount = math.random(
                    AimAssist.Humanization.Overaim.Amount.Min * 100,
                    AimAssist.Humanization.Overaim.Amount.Max * 100
                ) / 100
                State.OveraimOffset = (Vector3.new(math.random(-100, 100), math.random(-100, 100), 0).Unit * OveraimAmount)
            end
        end

        if CurrentTime - State.LastAimTime < State.ReactionDelay then return end

        local TargetPos = TargetInfo.Part.Position
        local Velocity = TargetInfo.Player.Character.HumanoidRootPart.Velocity

        TargetPos = TargetPos + (Velocity * math.clamp(TargetInfo.Distance / 150, 0.1, 0.3))

        if AimAssist.Humanization.Enabled then
            UpdateShake()
            TargetPos = TargetPos + State.ShakeOffset
            
            if State.OveraimOffset.Magnitude > 0.01 then
                TargetPos = TargetPos + State.OveraimOffset
                State.OveraimOffset = State.OveraimOffset:Lerp(Vector3.new(), AimAssist.Humanization.Overaim.Recovery)
            end
        end

        local Smoothness = GetDynamicSmoothness(TargetInfo.Distance, Velocity, IsNewTarget)

        if AimAssist.Acceleration.Enabled then
            local AccelProgress = math.clamp((CurrentTime - State.LastAimTime) / AimAssist.Acceleration.BuildupTime, 0, 1)
            State.CurrentAcceleration = math.lerp(
                AimAssist.Acceleration.StartSpeed,
                AimAssist.Acceleration.MaxSpeed,
                AccelProgress
            )
            Smoothness = Smoothness * (1 - State.CurrentAcceleration)
        end

        local CurrentCamera = Camera.CFrame
        local TargetCFrame = CFrame.lookAt(CurrentCamera.Position, TargetPos)
        Camera.CFrame = CurrentCamera:Lerp(TargetCFrame, Smoothness)

        if AimAssist.Humanization.Fatigue.Enabled then
            AimAssist.Humanization.Fatigue.Amount = math.min(
                AimAssist.Humanization.Fatigue.Amount + AimAssist.Humanization.Fatigue.IncreaseRate,
                AimAssist.Humanization.Fatigue.Max
            )
        end
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = TOSIndustries
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.ClipsDescendants = true

    local Dragging, DragInput, DragStart, StartPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 30)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "TOS Industries PF"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20

    local TabHolder = Instance.new("Frame")
    TabHolder.Name = "TabHolder"
    TabHolder.Parent = MainFrame
    TabHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.Size = UDim2.new(0, 120, 1, -30)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = TabHolder
    TabContainer.BackgroundTransparency = 1
    TabContainer.Size = UDim2.new(1, 0, 1, 0)
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentArea.BorderSizePixel = 0
    ContentArea.Position = UDim2.new(0, 120, 0, 30)
    ContentArea.Size = UDim2.new(1, -120, 1, -30)

    local function CreateTab(name)
        if not Security:_VALIDATE(ESP) then return end
        local Tab = Instance.new("TextButton")
        Tab.Name = name
        Tab.Parent = TabContainer
        Tab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Tab.BorderSizePixel = 0
        Tab.Size = UDim2.new(1, -10, 0, 30)
        Tab.Font = Enum.Font.Gotham
        Tab.Text = name
        Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        Tab.TextSize = 14
        Tab.AutoButtonColor = false
        
        local Content = Instance.new("ScrollingFrame")
        Content.Name = name.."Content"
        Content.Parent = ContentArea
        Content.BackgroundTransparency = 1
        Content.Size = UDim2.new(1, 0, 1, 0)
        Content.ScrollBarThickness = 4
        Content.Visible = false
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = Content
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 5)
        
        return Tab, Content
    end

    local function CreateToggle(parent, text, default, callback)
        if not Security:_VALIDATE(ESP) then return end
        local Toggle = Instance.new("Frame")
        Toggle.Name = text.."Toggle"
        Toggle.Parent = parent
        Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Toggle.BorderSizePixel = 0
        Toggle.Size = UDim2.new(1, -20, 0, 35)
        Toggle.Position = UDim2.new(0, 10, 0, 0)

        local Title = Instance.new("TextLabel")
        Title.Parent = Toggle
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.Font = Enum.Font.Gotham
        Title.Text = text
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local Switch = Instance.new("TextButton")
        Switch.Parent = Toggle
        Switch.BackgroundColor3 = default and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 64, 64)
        Switch.BorderSizePixel = 0
        Switch.Position = UDim2.new(1, -40, 0.5, -10)
        Switch.Size = UDim2.new(0, 30, 0, 20)
        Switch.Font = Enum.Font.SourceSans
        Switch.Text = ""
        Switch.AutoButtonColor = false

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = Switch

        local Circle = Instance.new("Frame")
        Circle.Parent = Switch
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.Size = UDim2.new(0, 16, 0, 16)
        Circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        Circle.BorderSizePixel = 0

        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(1, 0)
        CircleCorner.Parent = Circle

        local Enabled = default
        Switch.MouseButton1Click:Connect(function()
            if not Security:_VALIDATE(ESP) then return end
            Enabled = not Enabled
            local CirclePosition = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local Color = Enabled and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 64, 64)
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = CirclePosition}):Play()
            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color}):Play()
            callback(Enabled)
        end)

        return Toggle
    end

    local AimbotTab, AimbotContent = CreateTab("TOS Aimbot")
    local ESPTab, ESPContent = CreateTab("TOS ESP")
    local SettingsTab, SettingsContent = CreateTab("TOS Settings")

    CreateToggle(AimbotContent, "Enable Aimbot", false, function(enabled)
        if not Security:_VALIDATE(AimAssist) then return end
        AimAssist.Enabled = enabled
    end)

    CreateToggle(AimbotContent, "Show FOV", false, function(enabled)
        if not Security:_VALIDATE(AimAssist) then return end
        AimAssist.ShowFOV = enabled
    end)

    CreateToggle(ESPContent, "Enable ESP", false, function(enabled)
        if not Security:_VALIDATE(ESP) then return end
        ESP.Enabled = enabled
    end)

    CreateToggle(ESPContent, "Show Boxes", true, function(enabled)
        if not Security:_VALIDATE(ESP) then return end
        ESP.BoxEnabled = enabled
    end)

    CreateToggle(ESPContent, "Show Skeleton", true, function(enabled)
        if not Security:_VALIDATE(ESP) then return end
        ESP.SkeletonEnabled = enabled
    end)

    CreateToggle(ESPContent, "Show Names", true, function(enabled)
        if not Security:_VALIDATE(ESP) then return end
        ESP.NameEnabled = enabled
    end)

    CreateToggle(ESPContent, "Show Health", true, function(enabled)
        if not Security:_VALIDATE(ESP) then return end
        ESP.HealthEnabled = enabled
    end)

    CreateToggle(ESPContent, "Team Check", true, function(enabled)
        if not Security:_VALIDATE(ESP) then return end
        ESP.TeamCheck = enabled
    end)

    local function SwitchTab(tab)
        if not Security:_VALIDATE(ESP) then
            MainFrame:Destroy()
            return
        end
        
        for _, v in pairs(TabContainer:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end
        
        for _, v in pairs(ContentArea:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end
        
        tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        ContentArea[tab.Name.."Content"].Visible = true
    end

    for _, tab in pairs(TabContainer:GetChildren()) do
        if tab:IsA("TextButton") then
            tab.MouseButton1Click:Connect(function()
                SwitchTab(tab)
            end)
        end
    end

    SwitchTab(AimbotTab)

    CloseButton.MouseButton1Click:Connect(function()
        TOSIndustries:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Delete then
            MainFrame.Visible = not MainFrame.Visible
            CreateNotification(MainFrame.Visible and "GUI Opened" or "GUI Closed")
        end
    end)

    local LastAim = tick()
    RunService.RenderStepped:Connect(function()
        if not Security:_VALIDATE(ESP) or not Security:_VALIDATE(AimAssist) then
            ESP.Enabled = false
            AimAssist.Enabled = false
            return
        end

        if AimAssist.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local Target = GetClosestPlayer()
            if Target then
                if tick() - LastAim > 0.016 then
                    SmoothAim(Target)
                    LastAim = tick()
                end
            else
                State.LastTarget = nil
                State.CurrentAcceleration = AimAssist.Acceleration.StartSpeed
            end
        else
            State.LastTarget = nil
            State.CurrentAcceleration = AimAssist.Acceleration.StartSpeed
            
            if AimAssist.Humanization.Fatigue.Enabled then
                AimAssist.Humanization.Fatigue.Amount = math.max(
                    0,
                    AimAssist.Humanization.Fatigue.Amount - AimAssist.Humanization.Fatigue.DecreaseRate
                )
            end
        end
        
        if ESP.Enabled then
            UpdateESP()
        end
    end)

    Players.PlayerAdded:Connect(CreateESPObject)
    Players.PlayerRemoving:Connect(RemoveESPObject)

    for _, player in pairs(Players:GetPlayers()) do
        CreateESPObject(player)
    end

    local SecurityCheck = coroutine.wrap(function()
        while task.wait(1) do
            if not Security:_VALIDATE(ESP) or 
               not Security:_VALIDATE(AimAssist) or
               TOSIndustries.Name ~= Security._KEY or
               not Security:_CHECK() then
                warn(Security._WATERMARK.." security violation detected")
                TOSIndustries:Destroy()
                break
            end
        end
    end)
    SecurityCheck()

    local function CreateNotification(text)
        local Notification = Instance.new("ScreenGui")
        Notification.Name = Security._KEY.."_Notification"
        Notification.Parent = CoreGui
        
        local Frame = Instance.new("Frame")
        Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Frame.BorderSizePixel = 0
        Frame.Position = UDim2.new(1, -300, 0.8, 0)
        Frame.Size = UDim2.new(0, 250, 0, 50)
        Frame.Parent = Notification
        
        local Title = Instance.new("TextLabel")
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Size = UDim2.new(1, -20, 0, 20)
        Title.Font = Enum.Font.GothamBold
        Title.Text = "TOS Industries PF"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Frame
        
        local Message = Instance.new("TextLabel")
        Message.BackgroundTransparency = 1
        Message.Position = UDim2.new(0, 10, 0, 25)
        Message.Size = UDim2.new(1, -20, 0, 20)
        Message.Font = Enum.Font.Gotham
        Message.Text = text
        Message.TextColor3 = Color3.fromRGB(255, 255, 255)
        Message.TextSize = 12
        Message.TextXAlignment = Enum.TextXAlignment.Left
        Message.Parent = Frame
        
        TweenService:Create(Frame, TweenInfo.new(0.5), {Position = UDim2.new(1, -270, 0.8, 0)}):Play()
        task.wait(2)
        TweenService:Create(Frame, TweenInfo.new(0.5), {Position = UDim2.new(1, 0, 0.8, 0)}):Play()
        task.wait(0.5)
        Notification:Destroy()
    end

    return true
end 