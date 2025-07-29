-- LunaSoft HVH Cheat for CounterBlox
-- Version: 1.0
-- Author: Кира
-- Game: CounterBlox
-- Injector Compatibility: Xeno / Delta / Krnl

--// CONFIGURATION
local config = {
    aimbotEnabled = true,
    aimbotKey = Enum.UserInputType.MouseButton2,
    fov = 90,
    aimSmoothness = 0.15,
    silentAim = true,
    triggerbot = true,
    triggerbotDelay = 0,
    noRecoil = true,
    noSpread = true,
    showFOV = true,
    glowESP = true,
    espColor = Color3.fromRGB(255, 105, 180), -- Pink
    espOutline = true,
    teamCheck = true,
    wallCheck = true,
    uiKey = Enum.KeyCode.RightControl,
}

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// UI SETUP
local function createUI()
    -- Placeholder for modern hi-tech UI creation
    print("[LunaSoft] UI Initialized (hi-tech style)")
end

--// AIMBOT
local function getClosestTarget()
    local closest, distance = nil, config.fov
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            if config.teamCheck and player.Team == LocalPlayer.Team then continue end
            if player.Character.Humanoid.Health <= 0 then continue end
            local headPos = player.Character.Head.Position
            local screenPoint, visible = Camera:WorldToViewportPoint(headPos)
            if not visible then continue end
            local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - UIS:GetMouseLocation()).Magnitude
            if dist < distance then
                closest = player
                distance = dist
            end
        end
    end
    return closest
end

--// AIMLOCK
local function aimAt(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
    local aimPos = target.Character.Head.Position
    local camDir = (aimPos - Camera.CFrame.Position).Unit
    local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + camDir)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, config.aimSmoothness)
end

--// TRIGGERBOT
local function triggerBot()
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if target and target.Parent and Players:GetPlayerFromCharacter(target.Parent) then
        local enemy = Players:GetPlayerFromCharacter(target.Parent)
        if enemy.Team ~= LocalPlayer.Team and enemy.Character:FindFirstChild("Humanoid") and enemy.Character.Humanoid.Health > 0 then
            mouse1click()
        end
    end
end

--// GLOW ESP
local function applyGlow()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if config.teamCheck and player.Team == LocalPlayer.Team then continue end
            if player.Character.Humanoid.Health <= 0 then continue end
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    local glow = Instance.new("BoxHandleAdornment")
                    glow.Adornee = part
                    glow.AlwaysOnTop = true
                    glow.ZIndex = 5
                    glow.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                    glow.Transparency = 0.25
                    glow.Color3 = config.espColor
                    glow.Parent = part

                    if config.espOutline then
                        local outline = Instance.new("SelectionBox")
                        outline.Adornee = part
                        outline.LineThickness = 0.03
                        outline.Color3 = Color3.new(1, 1, 1)
                        outline.SurfaceTransparency = 1
                        outline.Parent = part
                    end
                end
            end
        end
    end
end

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    if config.glowESP then applyGlow() end
    if config.aimbotEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget()
        if target then aimAt(target) end
    end
    if config.triggerbot then triggerBot() end
end)

--// INIT
createUI()
print("[LunaSoft HVH] Loaded for CounterBlox")
