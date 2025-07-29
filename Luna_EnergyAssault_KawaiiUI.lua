
-- LunaSoft CounterBlox Advanced
-- Silent Aim, AimLock, TriggerBot, NoRecoil, NoSpread, Webhook Logger

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local Config = {
    Webhook = "https://your-webhook-url", -- Заменить на твой вебхук
    SilentAim = true,
    AimLock = true,
    TriggerBot = true,
    NoRecoil = true,
    NoSpread = true,
    BunnyHop = true,
    FOV = 75
}

-- Webhook Notify
pcall(function()
    HttpService:PostAsync(Config.Webhook, HttpService:JSONEncode({
        content = "**LunaSoft injected into CounterBlox** 🎯"
    }))
end)

-- Silent Aim / AimLock
local function GetClosestEnemy()
    local closest, dist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
            local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).magnitude
            if onScreen and mag < Config.FOV and mag < dist then
                closest = player
                dist = mag
            end
        end
    end
    return closest
end

-- TriggerBot
RunService.RenderStepped:Connect(function()
    if Config.TriggerBot then
        local target = Mouse.Target
        if target and target.Parent:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(target.Parent) ~= LocalPlayer then
            mouse1click()
        end
    end
end)

-- No Recoil / No Spread (заглушка, зависит от CounterBlox internals)
hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if Config.NoRecoil and tostring(self) == "RecoilModule" and method == "FireServer" then
        return -- блокируем отдачу
    end
    return self(...)
end)

-- BunnyHop
RunService.RenderStepped:Connect(function()
    if Config.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- UI заглушка
print("LunaSoft CounterBlox UI Loaded")
