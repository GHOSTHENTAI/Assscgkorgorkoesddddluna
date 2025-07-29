
-- LunaEA v7 — Full UI + Glow + Aim + TriggerBot + NoSpread/NoRecoil

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Настройки
_G.TriggerBot = true
_G.SilentAim = true
_G.NoSpread = true
_G.NoRecoil = true
_G.GlowESP = true

-- UI Меню
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LunaEA_UI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0.015, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local function AddToggle(name, y, default, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = default and Color3.fromRGB(150, 80, 255) or Color3.fromRGB(80, 80, 80)
    btn.Text = name .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(150, 80, 255) or Color3.fromRGB(80, 80, 80)
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

AddToggle("TriggerBot", 10, _G.TriggerBot, function(v) _G.TriggerBot = v end)
AddToggle("SilentAim", 40, _G.SilentAim, function(v) _G.SilentAim = v end)
AddToggle("GlowESP", 70, _G.GlowESP, function(v) _G.GlowESP = v end)

-- Glow ESP
RunService.RenderStepped:Connect(function()
    if not _G.GlowESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team and plr.Character then
            local h = plr.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                for _, part in pairs(plr.Character:GetChildren()) do
                    if part:IsA("BasePart") and not part:FindFirstChild("Glow") then
                        local glow = Instance.new("BoxHandleAdornment")
                        glow.Name = "Glow"
                        glow.Adornee = part
                        glow.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                        glow.Color3 = Color3.fromRGB(255, 105, 180)
                        glow.Transparency = 0.25
                        glow.AlwaysOnTop = true
                        glow.ZIndex = 5
                        glow.Parent = part

                        local outline = Instance.new("SelectionBox", part)
                        outline.Adornee = part
                        outline.Color3 = Color3.new(1,1,1)
                        outline.LineThickness = 0.05
                        outline.Name = "Glow"
                    end
                end
            end
        end
    end
end)

-- Получение цели под прицелом
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

-- Silent Aim (FireServer)
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

-- TriggerBot
RunService.RenderStepped:Connect(function()
    if not _G.TriggerBot then return end
    local target = getMouseTargetEnemy()
    if target then
        mouse1press()
        wait()
        mouse1release()
    end
end)

-- NoSpread / NoRecoil
local function patchGunStats()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    local stats = tool:FindFirstChild("GunStats")
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
