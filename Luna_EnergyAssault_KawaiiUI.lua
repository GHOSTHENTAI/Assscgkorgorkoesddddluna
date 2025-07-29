
-- LunaSoft CounterBlox HVH Cheat (Base v1)
-- Features: SilentAim, TriggerBot, NoRecoil, NoSpread, GlowESP, BunnyHop, Webhook Logger
-- Made for Xeno Injector

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

--// Settings
local settings = {
    SilentAim = true,
    TriggerBot = true,
    NoRecoil = true,
    NoSpread = true,
    GlowESP = true,
    BunnyHop = true,
    Webhook = "https://yourwebhook.url", -- вставь сюда вебхук
}

--// Webhook Logger
spawn(function()
    pcall(function()
        syn.request({
            Url = settings.Webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode({
                ["username"] = "LunaSoft Logger",
                ["content"] = "**User injected LunaSoft in CounterBlox!**\nUsername: " .. plr.Name
            })
        })
    end)
end)

--// SilentAim Placeholder
local function getClosestEnemy()
    local closest, distance = nil, math.huge
    for _, enemy in ipairs(Players:GetPlayers()) do
        if enemy ~= plr and enemy.Team ~= plr.Team and enemy.Character and enemy.Character:FindFirstChild("Head") then
            local screenPos, visible = workspace.CurrentCamera:WorldToScreenPoint(enemy.Character.Head.Position)
            if visible then
                local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if mag < distance then
                    distance = mag
                    closest = enemy
                end
            end
        end
    end
    return closest
end

--// TriggerBot
RunService.RenderStepped:Connect(function()
    if settings.TriggerBot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) == false then
        local target = getClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local ray = Ray.new(workspace.CurrentCamera.CFrame.Position, (target.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).Unit * 5000)
            local part, pos = workspace:FindPartOnRay(ray, plr.Character, false, true)
            if part and part:IsDescendantOf(target.Character) then
                mouse1click()
            end
        end
    end
end)

--// NoRecoil/NoSpread
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() then
        if key == "Spread" or key == "Recoil" then
            return 0
        end
    end
    return oldIndex(self, key)
end)

--// Glow ESP
if settings.GlowESP then
    for _, enemy in ipairs(Players:GetPlayers()) do
        if enemy ~= plr and enemy.Team ~= plr.Team then
            enemy.CharacterAdded:Connect(function(char)
                wait(1)
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        local glow = Instance.new("BoxHandleAdornment", part)
                        glow.Adornee = part
                        glow.AlwaysOnTop = true
                        glow.ZIndex = 10
                        glow.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
                        glow.Color3 = Color3.fromRGB(255, 105, 180)
                        glow.Transparency = 0.2
                    end
                end
            end)
        end
    end
end

--// BunnyHop
UIS.InputBegan:Connect(function(input, gpe)
    if settings.BunnyHop and input.KeyCode == Enum.KeyCode.Space then
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            if plr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                plr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)
