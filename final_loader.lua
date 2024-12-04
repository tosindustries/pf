-- TOS Industries v1
-- Copyright (c) 2024 TOS Industries. All rights reserved.

local function loadScript()
    -- Core Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    -- Wait for game load
    if not game:IsLoaded() then 
        game.Loaded:Wait()
    end
    
    -- Basic Security
    local mt = getrawmetatable(game)
    if mt and setreadonly then
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" then return wait(9e9) end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
    
    -- Load UI Library (using Orion UI)
    local success, OrionLib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    end)
    
    if not success or not OrionLib then
        warn("Failed to load UI Library")
        return false
    end
    
    -- Create Window
    local Window = OrionLib:MakeWindow({
        Name = "TOS Industries v1",
        HidePremium = true,
        SaveConfig = false,
        IntroEnabled = false
    })
    
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
    
    -- Create Tabs
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    local VisualsTab = Window:MakeTab({
        Name = "Visuals",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    local AimbotTab = Window:MakeTab({
        Name = "Aimbot",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    -- Main Tab
    MainTab:AddToggle({
        Name = "Enable",
        Default = false,
        Callback = function(Value)
            ESP.Enabled = Value
            Aimbot.Enabled = Value
        end
    })
    
    MainTab:AddToggle({
        Name = "Team Check",
        Default = true,
        Callback = function(Value)
            ESP.TeamCheck = Value
            Aimbot.TeamCheck = Value
        end
    })
    
    -- Visuals Tab
    VisualsTab:AddToggle({
        Name = "Box ESP",
        Default = false,
        Callback = function(Value)
            ESP.BoxEnabled = Value
        end
    })
    
    VisualsTab:AddToggle({
        Name = "Skeleton ESP",
        Default = false,
        Callback = function(Value)
            ESP.SkeletonEnabled = Value
        end
    })
    
    VisualsTab:AddToggle({
        Name = "Name ESP",
        Default = false,
        Callback = function(Value)
            ESP.NameEnabled = Value
        end
    })
    
    VisualsTab:AddToggle({
        Name = "Health ESP",
        Default = false,
        Callback = function(Value)
            ESP.HealthEnabled = Value
        end
    })
    
    VisualsTab:AddColorpicker({
        Name = "Box Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            ESP.BoxColor = Value
        end
    })
    
    VisualsTab:AddColorpicker({
        Name = "Skeleton Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            ESP.SkeletonColor = Value
        end
    })
    
    VisualsTab:AddSlider({
        Name = "ESP Distance",
        Min = 100,
        Max = 2000,
        Default = 1000,
        Increment = 50,
        Callback = function(Value)
            ESP.MaxDistance = Value
        end
    })
    
    -- Aimbot Tab
    AimbotTab:AddToggle({
        Name = "Enable Aimbot",
        Default = false,
        Callback = function(Value)
            Aimbot.Enabled = Value
        end
    })
    
    AimbotTab:AddToggle({
        Name = "Visibility Check",
        Default = true,
        Callback = function(Value)
            Aimbot.VisibilityCheck = Value
        end
    })
    
    AimbotTab:AddDropdown({
        Name = "Target Part",
        Default = "Head",
        Options = {"Head", "UpperTorso", "HumanoidRootPart"},
        Callback = function(Value)
            Aimbot.TargetPart = Value
        end
    })
    
    AimbotTab:AddSlider({
        Name = "Smoothness",
        Min = 1,
        Max = 10,
        Default = 1,
        Increment = 0.5,
        Callback = function(Value)
            Aimbot.Smoothness = Value
        end
    })
    
    AimbotTab:AddSlider({
        Name = "FOV",
        Min = 30,
        Max = 500,
        Default = 100,
        Increment = 10,
        Callback = function(Value)
            Aimbot.FOV = Value
        end
    })
    
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
        
        Camera.CFrame = CFrame.new(cameraPos) * smoothRotation
    end
    
    -- Initialize
    for _, player in pairs(Players:GetPlayers()) do
        ESP:AddPlayer(player)
    end
    
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESP:AddPlayer(player)
    end)
    
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP:RemovePlayer(player)
    end)
    
    -- Main update loop
    RunService.RenderStepped:Connect(function()
        if ESP.Enabled then
            ESP:UpdateESP()
        end
        if Aimbot.Enabled then
            Aimbot:Update()
        end
    end)
    
    return true
end

-- Execute safely
local success, result = pcall(loadScript)
if not success then
    warn("Script failed:", result)
    return false
end

return result