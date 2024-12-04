local function startScript()
    if not game:IsLoaded() then game.Loaded:Wait() end
    if game.PlaceId ~= 292439477 then return false end
    
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()
    
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
        
        local snapLine = Drawing.new("Line")
        snapLine.Thickness = 1.5
        snapLine.Visible = false
        snapLine.ZIndex = 999
        snapLine.Transparency = 1
        snapLine.Color = Color3.fromRGB(255, 0, 0)
        
        return fovCircle, snapLine
    end
    
    local fovCircle, snapLine = createDrawings()
    
    -- Create UI first
    local ui = UI.new()
    
    -- Initialize ESP
    local ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = true,
        TeamCheck = true,
        Players = {},
        Connections = {}
    }
    
    -- Initialize Aimbot
    local Aimbot = {
        Enabled = false,
        Active = false,
        Silent = false,
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
        fovCircle.Visible = state
    end)
    
    local silentAimToggle = UI.createToggle("Silent Aim", ui.Pages.Aimbot, function(state)
        Aimbot.Silent = state
        if state then
            Aimbot.Active = false
        end
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
    
    -- Visuals Tab
    local espToggle = UI.createToggle("Enable ESP", ui.Pages.Visuals, function(state)
        ESP.Enabled = state
    end)
    
    local boxesToggle = UI.createToggle("Show Boxes", ui.Pages.Visuals, function(state)
        ESP.Boxes = state
    end)
    
    local namesToggle = UI.createToggle("Show Names", ui.Pages.Visuals, function(state)
        ESP.Names = state
    end)
    
    local healthToggle = UI.createToggle("Show Health", ui.Pages.Visuals, function(state)
        ESP.Health = state
    end)
    
    local distanceToggle = UI.createToggle("Show Distance", ui.Pages.Visuals, function(state)
        ESP.Distance = state
    end)
    
    local tracersToggle = UI.createToggle("Show Tracers", ui.Pages.Visuals, function(state)
        ESP.Tracers = state
    end)
    
    -- Set initial states
    aimbotToggle.SetState(false)
    silentAimToggle.SetState(false)
    autoShootToggle.SetState(false)
    hitChanceSlider.SetValue(100)
    fovSlider.SetValue(100)
    smoothnessSlider.SetValue(2)
    teamCheckToggle.SetState(true)
    visibilityCheckToggle.SetState(false)
    predictionToggle.SetState(true)
    espToggle.SetState(false)
    boxesToggle.SetState(true)
    namesToggle.SetState(true)
    healthToggle.SetState(true)
    distanceToggle.SetState(true)
    tracersToggle.SetState(true)
    
    -- Make sure UI is visible initially
    ui.MainFrame.Visible = true
    
    -- Initialize ESP
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        ESP:CreatePlayer(player)
    end)
    
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        ESP:RemovePlayer(player)
    end)
    
    -- Initialize existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP:CreatePlayer(player)
        end
    end
    
    -- Update ESP in RenderStepped
    RunService:BindToRenderStep("ESP", Enum.RenderPriority.Camera.Value + 1, function()
        ESP:Update()
    end)
    
    -- Main Loop
    RunService:BindToRenderStep("ESP_Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
        ESP:Update()
        Aimbot:Update()
        
        -- Update FOV Circle
        if Aimbot.Enabled then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = Aimbot.FOV
            fovCircle.Visible = true
            
            -- Update snapline if we have a target
            local target = Aimbot:GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(Aimbot.TargetPart)
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        snapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        snapLine.To = Vector2.new(pos.X, pos.Y)
                        snapLine.Visible = true
                    else
                        snapLine.Visible = false
                    end
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
    
    return true
end

local success, result = pcall(startScript)
if not success then
    warn("Script failed to start:", result)
    return false
end

return result