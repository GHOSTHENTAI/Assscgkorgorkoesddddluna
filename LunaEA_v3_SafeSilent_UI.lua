
-- 🌸 LunaEA Debug — Проверка Silent Aim (__namecall Hook)
-- Цель: убедиться, что Roblox вызывает Raycast для стрельбы

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Проверка ближайшей цели (без изменений)
local function getTarget()
    local closest, dist = nil, 9999
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if head and humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < dist then
                        closest = player
                        dist = mag
                    end
                end
            end
        end
    end
    return closest
end

-- Hook на __namecall
local raw = getrawmetatable(game)
setreadonly(raw, false)
local old = raw.__namecall

raw.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- Дебаг вывод
    print("[DEBUG] Namecall Method:", method)
    if typeof(args[1]) == "Ray" then
        print("[DEBUG] Ray Detected:", args[1].Origin, "->", args[1].Direction)
    end

    -- Silent Aim если метод совпадает
    if (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and typeof(args[1]) == "Ray" then
        local target = getTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local dir = (target.Character.Head.Position - Camera.CFrame.Position).Unit * 999
            args[1] = Ray.new(Camera.CFrame.Position, dir)
            print("[DEBUG] Silent Aim переопределил направление выстрела.")
            return old(self, unpack(args))
        end
    end

    return old(self, ...)
end)
