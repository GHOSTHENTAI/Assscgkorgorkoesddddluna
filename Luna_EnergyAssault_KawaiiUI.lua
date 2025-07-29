
-- 🌸 CounterBlox Silent Aim + GlowESP by Кира
-- v1.0 для Xeno

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Mouse = LocalPlayer:GetMouse()

-- Конфиг
_G.SilentAim = true
_G.GlowESP = true
_G.TeamCheck = true

-- Проверка живых игроков
local function isAlive(player)
    local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

-- Получение цели для SilentAim
local function getTarget()
    local closest, dist = nil, 9999
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if _G.TeamCheck and player.Team == LocalPlayer.Team then continue end
            if not isAlive(player) then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mag < dist then
                    closest, dist = player, mag
                end
            end
        end
    end
    return closest
end

-- Glow ESP
RunService.RenderStepped:Connect(function()
    if _G.GlowESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Team ~= LocalPlayer.Team then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and not part:FindFirstChild("LunaGlow") then
                        local glow = Instance.new("BoxHandleAdornment")
                        glow.Name = "LunaGlow"
                        glow.Adornee = part
                        glow.AlwaysOnTop = true
                        glow.ZIndex = 5
                        glow.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                        glow.Transparency = 0.25
                        glow.Color3 = Color3.fromRGB(255, 105, 180)
                        glow.Parent = part

                        local outline = Instance.new("SelectionBox")
                        outline.Adornee = part
                        outline.LineThickness = 0.04
                        outline.Color3 = Color3.fromRGB(255, 255, 255)
                        outline.SurfaceTransparency = 1
                        outline.Parent = part
                    end
                end
            end
        end
    end
end)

-- Silent Aim хук
local raw = getrawmetatable(game)
setreadonly(raw, false)
local old = raw.__namecall

raw.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and typeof(args[1]) == "Ray" then
        if _G.SilentAim then
            local target = getTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local direction = (target.Character.Head.Position - Camera.CFrame.Position).Unit * 999
                args[1] = Ray.new(Camera.CFrame.Position, direction)
                return old(self, unpack(args))
            end
        end
    end
    return old(self, ...)
end)
