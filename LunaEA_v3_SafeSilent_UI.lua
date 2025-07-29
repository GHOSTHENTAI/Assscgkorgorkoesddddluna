
-- LunaEA v5 Lite — Проверенная стабильная версия
-- Features: Silent Aim, TriggerBot, FOV UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

_G.FOV = 150
_G.SilentAim = true
_G.TriggerBot = true

-- Рисуем FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = _G.FOV
fovCircle.Thickness = 2
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(255, 105, 180)
fovCircle.Visible = true
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
end)

-- Получаем цель
local function getTarget()
    local closest, dist = nil, _G.FOV
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character then
            local h = plr.Character:FindFirstChild("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if h and h.Health > 0 and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local diff = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if diff < dist then
                        -- Проверка на стены
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        local ray = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 999, rayParams)
                        if ray and ray.Instance:IsDescendantOf(plr.Character) then
                            closest = plr
                            dist = diff
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Silent Aim
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if tostring(self) == "ShootEvent" and getnamecallmethod() == "FireServer" and _G.SilentAim then
        local tgt = getTarget()
        if tgt and tgt.Character and tgt.Character:FindFirstChild("Head") then
            args[2] = tgt.Character.Head.Position
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)

-- TriggerBot
RunService.RenderStepped:Connect(function()
    if not _G.TriggerBot then return end
    local tgt = getTarget()
    if tgt then
        mouse1press()
        wait()
        mouse1release()
    end
end)
