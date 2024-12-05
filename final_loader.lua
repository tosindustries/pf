local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    if game.PlaceId ~= 292439477 then return false end
    
    -- Core Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    
    -- Create UI System
    local UI = {}
    
    function UI.new()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "TOSIndustriesV1"
        screenGui.ResetOnSpawn = false
        
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
            screenGui.Parent = game:GetService("CoreGui")
        else
            screenGui.Parent = game:GetService("CoreGui")
        end
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 300, 0, 400)
        mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 8)
        mainCorner.Parent = mainFrame
        
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.BackgroundTransparency = 1
        shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        shadow.Size = UDim2.new(1, 47, 1, 47)
        shadow.ZIndex = 0
        shadow.Image = "rbxassetid://6015897843"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.Parent = mainFrame
        
        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 35)
        topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        topBar.BorderSizePixel = 0
        topBar.Parent = mainFrame
        
        local topCorner = Instance.new("UICorner")
        topCorner.CornerRadius = UDim.new(0, 8)
        topCorner.Parent = topBar
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -40, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "TOS Industries v1"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = topBar
        
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -35, 0, 2)
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 95, 95)
        closeButton.Text = "×"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 20
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = topBar
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeButton
        
        closeButton.MouseButton1Click:Connect(function()
            mainFrame.Visible = false
        end)
        
        local menuButtons = Instance.new("Frame")
        menuButtons.Name = "MenuButtons"
        menuButtons.Size = UDim2.new(1, -20, 0, 40)
        menuButtons.Position = UDim2.new(0, 10, 0, 45)
        menuButtons.BackgroundTransparency = 1
        menuButtons.Parent = mainFrame
        
        local menuLayout = Instance.new("UIListLayout")
        menuLayout.FillDirection = Enum.FillDirection.Horizontal
        menuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
        menuLayout.Padding = UDim.new(0, 10)
        menuLayout.Parent = menuButtons
        
        local contentContainer = Instance.new("Frame")
        contentContainer.Name = "ContentContainer"
        contentContainer.Size = UDim2.new(1, -20, 1, -95)
        contentContainer.Position = UDim2.new(0, 10, 0, 90)
        contentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        contentContainer.BorderSizePixel = 0
        contentContainer.Parent = mainFrame
        
        local containerCorner = Instance.new("UICorner")
        containerCorner.CornerRadius = UDim.new(0, 8)
        containerCorner.Parent = contentContainer
        
        -- Create pages
        local pages = {
            Aimbot = Instance.new("ScrollingFrame"),
            Visuals = Instance.new("ScrollingFrame"),
            Settings = Instance.new("ScrollingFrame")
        }
        
        for name, frame in pairs(pages) do
            frame.Name = name .. "Page"
            frame.Size = UDim2.new(1, -20, 1, -20)
            frame.Position = UDim2.new(0, 10, 0, 10)
            frame.BackgroundTransparency = 1
            frame.BorderSizePixel = 0
            frame.ScrollBarThickness = 2
            frame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
            frame.Visible = false
            frame.Parent = contentContainer
            
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 10)
            layout.Parent = frame
        end
        
        local buttons = {
            Aimbot = UI.createMenuButton("Aimbot", 1, menuButtons),
            Visuals = UI.createMenuButton("Visuals", 2, menuButtons),
            Settings = UI.createMenuButton("Settings", 3, menuButtons)
        }
        
        local currentPage = "Aimbot"
        pages[currentPage].Visible = true
        buttons[currentPage].BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        buttons[currentPage].TextColor3 = Color3.fromRGB(255, 255, 255)
        
        for name, button in pairs(buttons) do
            button.MouseButton1Click:Connect(function()
                if currentPage == name then return end
                
                -- Hide current page
                pages[currentPage].Visible = false
                buttons[currentPage].BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                buttons[currentPage].TextColor3 = Color3.fromRGB(200, 200, 200)
                
                -- Show new page
                currentPage = name
                pages[currentPage].Visible = true
                button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end
        
        -- Make window draggable
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return {
            ScreenGui = screenGui,
            MainFrame = mainFrame,
            Pages = pages
        }
    end
    
    function UI.createMenuButton(text, order, parent)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Size = UDim2.new(0, 70, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        button.Text = text
        button.TextColor3 = Color3.fromRGB(200, 200, 200)
        button.TextSize = 14
        button.Font = Enum.Font.GothamSemibold
        button.LayoutOrder = order
        button.Parent = parent
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        return button
    end
    
    function UI.createToggle(text, parent, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        button.BorderSizePixel = 0
        button.Text = ""
        button.Parent = container
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = button
        
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -45, 0.5, -10)
        toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        toggle.BorderSizePixel = 0
        toggle.Parent = button
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(0, 2, 0.5, -8)
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Parent = toggle
        
        local state = false
        
        local function updateToggle()
            state = not state
            local pos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local color = state and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(255, 255, 255)
            
            indicator.Position = pos
            indicator.BackgroundColor3 = color
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 30, 45)
            
            callback(state)
        end
        
        button.MouseButton1Click:Connect(updateToggle)
        
        return {
            Frame = container,
            SetState = function(newState)
                if state ~= newState then
                    updateToggle()
                end
            end
        }
    end
    
    function UI.createSlider(text, parent, min, max, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 45)
        container.BackgroundTransparency = 1
        container.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. (default or min)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local sliderBG = Instance.new("Frame")
        sliderBG.Name = "SliderBG"
        sliderBG.Size = UDim2.new(1, -20, 0, 6)
        sliderBG.Position = UDim2.new(0, 10, 0, 30)
        sliderBG.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        sliderBG.BorderSizePixel = 0
        sliderBG.Parent = container
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = sliderBG
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBG
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = sliderFill
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0.5, -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        knob.Parent = sliderFill
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        
        local value = default or min
        local dragging = false
        local dragConnection
        local endConnection
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pos)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. ": " .. value
            callback(value)
        end
        
        sliderBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
                
                dragConnection = UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                endConnection = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        if dragConnection then dragConnection:Disconnect() end
                        if endConnection then endConnection:Disconnect() end
                    end
                end)
            end
        end)
        
        return {
            Frame = container,
            SetValue = function(newValue)
                value = math.clamp(newValue, min, max)
                local pos = (value - min) / (max - min)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                label.Text = text .. ": " .. value
                callback(value)
            end
        }
    end
    
    -- Create UI first
    local ui = UI.new()
    
    -- Initialize variables
    local aimbotActive = false
    local lastToggleTime = 0
    local TOGGLE_COOLDOWN = 0.3
    
    -- Create drawings
    local function createDrawings()
        local fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 100
        fovCircle.Radius = 100
        fovCircle.Filled = false
        fovCircle.Visible = false
        fovCircle.ZIndex = 999
        fovCircle.Transparency = 1
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        local snapLine = Drawing.new("Line")
        snapLine.Thickness = 1.5
        snapLine.Visible = false
        snapLine.ZIndex = 999
        snapLine.Transparency = 1
        snapLine.Color = Color3.fromRGB(255, 0, 0)
        
        return fovCircle, snapLine
    end
    
    local fovCircle, snapLine = createDrawings()
    
    -- ESP System
    local ESP = {
        Enabled = false,
        BoxEnabled = true,
        SkeletonEnabled = true,
        NameEnabled = true,
        HealthEnabled = true,
        TeamCheck = true,
        BoxColor = Color3.fromRGB(255, 255, 255),
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        MaxDistance = 1000,
        Players = {},
        Connections = {}
    }
    
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
                drawings.Box.Size = boxSize
                drawings.Box.Position = boxPos
                drawings.Box.Visible = true
            else
                drawings.Box.Visible = false
            end

            -- Update Name
            if self.NameEnabled then
                drawings.Name.Position = Vector2.new(boxPos.X + boxSize.X/2, boxPos.Y - 20)
                drawings.Name.Text = string.format("%s [%d]", player.Name, math.floor(distance))
                drawings.Name.Visible = true
            else
                drawings.Name.Visible = false
            end

            -- Update Health
            if self.HealthEnabled then
                drawings.Health.Position = Vector2.new(boxPos.X - 20, boxPos.Y + boxSize.Y/2)
                drawings.Health.Text = string.format("%d HP", math.floor(humanoid.Health))
                drawings.Health.Visible = true
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
        if not self.Enabled then visible = false end
        
        if drawings.Box then
            drawings.Box.Visible = visible and self.BoxEnabled
        end
        if drawings.Name then
            drawings.Name.Visible = visible and self.NameEnabled
        end
        if drawings.Health then
            drawings.Health.Visible = visible and self.HealthEnabled
        end
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
        
        if drawings.Box then 
            if type(drawings.Box) == "table" then
                if drawings.Box.Outline then drawings.Box.Outline:Remove() end
                if drawings.Box.Main then drawings.Box.Main:Remove() end
            else
                drawings.Box:Remove() 
            end
        end
        if drawings.Name then drawings.Name:Remove() end
        if drawings.Health then drawings.Health:Remove() end
        if drawings.Skeleton then
            for _, line in pairs(drawings.Skeleton) do
                if type(line) == "table" and line.Line then
                    line.Line:Remove()
                elseif type(line) == "userdata" then
                    line:Remove()
                end
            end
        end
        
        self.Players[player] = nil
    end
    
    -- Initialize ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP:AddPlayer(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        ESP:AddPlayer(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        ESP:RemovePlayer(player)
    end)
    
    -- Update FOV circle position
    RunService.RenderStepped:Connect(function()
        if fovCircle.Visible then
            fovCircle.Position = UserInputService:GetMouseLocation()
        end
    end)
    
    -- Create UI
    local ui = UI.new()
    
    -- Modify close button behavior
    local closeButton = ui.MainFrame.TopBar.CloseButton
    closeButton.MouseButton1Click:Connect(function()
        ui.MainFrame.Visible = not ui.MainFrame.Visible
    end)
    
    -- Initialize Aimbot
    local Aimbot = {
        Enabled = false,
        Active = false,
        Silent = false,
        ShowFOV = true,
        TargetPart = "Head",
        FOV = 100,
        Smoothness = 2,
        TeamCheck = true,
        VisibilityCheck = false,
        PredictMovement = true,
        PredictionAmount = 0.165,
        HitChance = 100,
        AutoShoot = false
    }
    
    -- Create UI elements
    local aimbotToggle = UI.createToggle("Enable Aimbot", ui.Pages.Aimbot, function(state)
        Aimbot.Enabled = state
        if not state then
            Aimbot.Active = false
            Aimbot.Silent = false
        end
        fovCircle.Visible = state and Aimbot.ShowFOV
    end)
    
    local silentAimToggle = UI.createToggle("Silent Aim", ui.Pages.Aimbot, function(state)
        Aimbot.Silent = state
        if state then
            Aimbot.Active = false
        end
    end)
    
    local fovCircleToggle = UI.createToggle("Show FOV Circle", ui.Pages.Aimbot, function(state)
        Aimbot.ShowFOV = state
        fovCircle.Visible = state and Aimbot.Enabled
    end)
    
    local autoShootToggle = UI.createToggle("Auto Shoot", ui.Pages.Aimbot, function(state)
        Aimbot.AutoShoot = state
    end)
    
    local hitChanceSlider = UI.createSlider("Hit Chance", ui.Pages.Aimbot, 1, 100, 100, function(value)
        Aimbot.HitChance = value
    end)
    
    local fovSlider = UI.createSlider("FOV Size", ui.Pages.Aimbot, 10, 800, 100, function(value)
        Aimbot.FOV = value
        fovCircle.Radius = value
    end)
    
    local smoothnessSlider = UI.createSlider("Smoothness", ui.Pages.Aimbot, 1, 10, 2, function(value)
        Aimbot.Smoothness = value
    end)
    
    local teamCheckToggle = UI.createToggle("Team Check", ui.Pages.Aimbot, function(state)
        Aimbot.TeamCheck = state
    end)
    
    local visibilityCheckToggle = UI.createToggle("Visibility Check", ui.Pages.Aimbot, function(state)
        Aimbot.VisibilityCheck = state
    end)
    
    local predictionToggle = UI.createToggle("Movement Prediction", ui.Pages.Aimbot, function(state)
        Aimbot.PredictMovement = state
    end)
    
    -- Set initial states
    aimbotToggle.SetState(false)
    silentAimToggle.SetState(false)
    fovCircleToggle.SetState(true)
    autoShootToggle.SetState(false)
    hitChanceSlider.SetValue(100)
    fovSlider.SetValue(100)
    smoothnessSlider.SetValue(2)
    teamCheckToggle.SetState(true)
    visibilityCheckToggle.SetState(false)
    predictionToggle.SetState(true)
    
    -- Make sure UI is visible initially
    ui.MainFrame.Visible = true
    
    -- Main Loop
    RunService:BindToRenderStep("ESP_Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
        if ESP.Enabled then
            ESP:UpdateESP()
        end
        
        -- Update FOV Circle and Snapline
        if Aimbot.Enabled and Aimbot.ShowFOV then
            fovCircle.Position = UserInputService:GetMouseLocation()
            fovCircle.Radius = Aimbot.FOV
            fovCircle.Visible = true
            
            -- Update snapline if we have a target
            local target = Aimbot:GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(Aimbot.TargetPart)
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        snapLine.From = UserInputService:GetMouseLocation()
                        snapLine.To = Vector2.new(pos.X, pos.Y)
                        snapLine.Visible = true and Aimbot.ShowFOV -- Only show if FOV circle is visible
                    else
                        snapLine.Visible = false
                    end
                else
                    snapLine.Visible = false
                end
            else
                snapLine.Visible = false
            end
        else
            fovCircle.Visible = false
            snapLine.Visible = false
        end
    end)
    
    -- Cleanup
    local function cleanup()
        RunService:UnbindFromRenderStep("ESP_Aimbot")
        
        for _, connection in pairs(ESP.Connections) do
            connection:Disconnect()
        end
        
        for player in pairs(ESP.Players) do
            ESP:RemovePlayer(player)
        end
        
        if fovCircle then fovCircle:Remove() end
        if snapLine then snapLine:Remove() end
        if ui and ui.ScreenGui then ui.ScreenGui:Destroy() end
    end
    
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if ui and child == ui.ScreenGui then
            cleanup()
        end
    end)
    
    -- Aimbot Functions
    local function GetClosestPlayerToCursor()
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local part = character:FindFirstChild(Aimbot.TargetPart)
            if not part then continue end
            
            local partPos = part.Position
            if Aimbot.PredictMovement then
                local velocity = part.Velocity
                partPos = partPos + (velocity * Aimbot.PredictionAmount)
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(partPos)
            if not onScreen then continue end
            
            local screenPosition = Vector2.new(screenPos.X, screenPos.Y)
            local distance = (screenPosition - mousePos).Magnitude
            
            if distance > Aimbot.FOV then continue end
            
            if Aimbot.VisibilityCheck then
                local rayOrigin = Camera.CFrame.Position
                local rayDirection = (partPos - rayOrigin).Unit
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {character, Camera}
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                
                local raycastResult = workspace:Raycast(rayOrigin, rayDirection * 1000, raycastParams)
                if raycastResult then continue end
            end
            
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
        
        return closestPlayer
    end
    
    -- Create Visuals Tab UI elements
    local espToggle = UI.createToggle("Enable ESP", ui.Pages.Visuals, function(state)
        ESP.Enabled = state
        if not state then
            for _, drawings in pairs(ESP.Players) do
                ESP:ToggleDrawings(drawings, false)
            end
        end
    end)
    
    local boxesToggle = UI.createToggle("Show Boxes", ui.Pages.Visuals, function(state)
        ESP.BoxEnabled = state
    end)
    
    local namesToggle = UI.createToggle("Show Names", ui.Pages.Visuals, function(state)
        ESP.NameEnabled = state
    end)
    
    local healthToggle = UI.createToggle("Show Health", ui.Pages.Visuals, function(state)
        ESP.HealthEnabled = state
    end)
    
    local skeletonToggle = UI.createToggle("Show Skeleton", ui.Pages.Visuals, function(state)
        ESP.SkeletonEnabled = state
    end)
    
    local espTeamCheckToggle = UI.createToggle("Team Check", ui.Pages.Visuals, function(state)
        ESP.TeamCheck = state
    end)
    
    -- Set initial states for ESP
    espToggle.SetState(false)
    boxesToggle.SetState(true)
    namesToggle.SetState(true)
    healthToggle.SetState(true)
    skeletonToggle.SetState(true)
    espTeamCheckToggle.SetState(true)
    
    -- Fix menu reopening with RightShift
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            ui.MainFrame.Visible = not ui.MainFrame.Visible
        end
    end)
    
    return true
end

local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result