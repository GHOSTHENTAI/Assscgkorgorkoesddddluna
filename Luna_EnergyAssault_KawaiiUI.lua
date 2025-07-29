
-- LunaSoft CounterBlox HVH Cheat [Full Version]

-- Settings
local Settings = {
    Aimbot = true,
    SilentAim = true,
    TriggerBot = true,
    NoRecoil = true,
    NoSpread = true,
    FOV = 120,
    KeyBind = Enum.KeyCode.E,
    Webhook = "https://your-discord-webhook-url"
}

-- UI Setup (Basic placeholder)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Visible = false

local ToggleKey = Enum.KeyCode.RightShift
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == ToggleKey then
        Frame.Visible = not Frame.Visible
    end
end)

-- Send webhook
spawn(function()
    pcall(function()
        game:HttpPost(Settings.Webhook, '{"content": "✅ LunaSoft CounterBlox Injected!"}', Enum.HttpContentType.ApplicationJson)
    end)
end)

-- Utilities
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- No Recoil / No Spread Hook
local function ApplyNoRecoilNoSpread()
    local repStorage = game:GetService("ReplicatedStorage")
    local events = repStorage:FindFirstChild("Events")
    if events and events:FindFirstChild("Shoot") then
        local originalFire = events.Shoot.FireServer
        events.Shoot.FireServer = function(self, ...)
            local args = {...}
            if Settings.NoSpread and typeof(args[2]) == "CFrame" then
                args[2] = Camera.CFrame -- eliminate spread by using direct aim
            end
            return originalFire(self, unpack(args))
        end
    end
end

-- Silent Aim
local function GetClosestEnemy()
    local closest = nil
    local shortest = math.huge

    for _, enemy in pairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Team ~= LocalPlayer.Team and enemy.Character and enemy.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(enemy.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < shortest and dist < Settings.FOV then
                    shortest = dist
                    closest = enemy
                end
            end
        end
    end
    return closest
end

-- TriggerBot
RunService.RenderStepped:Connect(function()
    if Settings.TriggerBot and Mouse.Target then
        local target = Players:GetPlayerFromCharacter(Mouse.Target:FindFirstAncestorOfClass("Model"))
        if target and target ~= LocalPlayer and target.Team ~= LocalPlayer.Team then
            mouse1press()
            wait()
            mouse1release()
        end
    end
end)

-- Aimbot
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsKeyDown(Settings.KeyBind) then
        local enemy = GetClosestEnemy()
        if enemy and enemy.Character and enemy.Character:FindFirstChild("Head") then
            local aimPos = Camera:WorldToViewportPoint(enemy.Character.Head.Position)
            mousemoverel((aimPos.X - Mouse.X) / 3, (aimPos.Y - Mouse.Y) / 3)
        end
    end
end)

-- Apply patches
ApplyNoRecoilNoSpread()
