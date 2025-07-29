
-- 🌸 LunaSoft TriggerBot + Silent Aim + NoSpread (Full Fix)
-- Автор: Кира 💗

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Глобальные флаги
_G.SilentAim = _G.SilentAim or true
_G.TriggerBot = _G.TriggerBot or true
_G.NoSpread = _G.NoSpread or true
_G.TeamCheck = _G.TeamCheck or true

-- Проверка на живого игрока
local function isAlive(player)
    local h = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
    return h and h.Health > 0
end

-- Цель ближайшая к прицелу
local function getTarget()
    local closest, dist = nil, 9999
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            if _G.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if not isAlive(v) then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then
                    closest, dist = v, mag
                end
            end
        end
    end
    return closest
end

-- TriggerBot (фикшен)
RunService.RenderStepped:Connect(function()
    if _G.TriggerBot then
        local target = getTarget()
        if target and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end
    end
end)

-- Silent Aim + NoSpread (в одном хукe)
local rawmt = getrawmetatable(game)
setreadonly(rawmt, false)
local oldNamecall = rawmt.__namecall

rawmt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and typeof(args[1]) == "Ray" then
        if _G.SilentAim then
            local target = getTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local direction = (target.Character.Head.Position - Camera.CFrame.Position).Unit * 999
                args[1] = Ray.new(Camera.CFrame.Position, direction)
                return oldNamecall(self, unpack(args))
            end
        elseif _G.NoSpread then
            local direction = Camera.CFrame.LookVector * 999
            args[1] = Ray.new(Camera.CFrame.Position, direction)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
