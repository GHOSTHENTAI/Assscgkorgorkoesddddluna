
-- LunaEA v6 LITE — TriggerBot, NoSpread, NoRecoil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

_G.SilentAim = true
_G.TriggerBot = true
_G.NoSpread = true
_G.NoRecoil = true

-- Получение врага под прицелом
local function getMouseTargetEnemy()
    local target = Mouse.Target
    if target and target.Parent then
        local plr = Players:GetPlayerFromCharacter(target.Parent)
        if plr and plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team then
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return plr
            end
        end
    end
    return nil
end

-- Silent Aim через FireServer
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if tostring(self) == "ShootEvent" and getnamecallmethod() == "FireServer" and _G.SilentAim then
        local tgt = getMouseTargetEnemy()
        if tgt and tgt.Character and tgt.Character:FindFirstChild("Head") then
            args[2] = tgt.Character.Head.Position
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)

-- TriggerBot (без FOV)
RunService.RenderStepped:Connect(function()
    if not _G.TriggerBot then return end
    local target = getMouseTargetEnemy()
    if target then
        mouse1press()
        task.wait()
        mouse1release()
    end
end)

-- NoSpread + NoRecoil
local function patchGunStats()
    local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    if not weapon then return end
    local stats = weapon:FindFirstChild("GunStats")
    if stats and stats:IsA("ModuleScript") then
        local env = getsenv(stats)
        if env and type(env) == "table" then
            if _G.NoSpread and env.Spread then env.Spread = 0 end
            if _G.NoRecoil and env.Recoil then env.Recoil = 0 end
        end
    end
end

RunService.RenderStepped:Connect(function()
    pcall(patchGunStats)
end)
