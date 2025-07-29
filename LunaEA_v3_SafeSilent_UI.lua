
-- 🌸 LunaEA v4 — TriggerBot + FireServer Silent Aim + UI
-- Автор: Кира 💗 | Energy Assault (Xeno Ready)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

-- Настройки
_G.TriggerBot = true
_G.SilentFireAim = true
_G.TeamCheck = true
_G.FOV = 150

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LunaEA_Menu"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 160)
frame.Position = UDim2.new(0.02, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local function CreateToggle(text, yPos, default, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = default and Color3.fromRGB(60, 255, 150) or Color3.fromRGB(255, 60, 80)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(60, 255, 150) or Color3.fromRGB(255, 60, 80)
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

CreateToggle("TriggerBot", 10, _G.TriggerBot, function(v) _G.TriggerBot = v end)
CreateToggle("Silent FireAim", 40, _G.SilentFireAim, function(v) _G.SilentFireAim = v end)

-- FOV круг
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Color = Color3.fromRGB(255, 105, 180)
fovCircle.Radius = _G.FOV
fovCircle.Thickness = 2
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
end)

-- Получить цель
local function getTarget()
    local closest, dist = nil, _G.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if mag < dist then
                        closest = p
                        dist = mag
                    end
                end
            end
        end
    end
    return closest
end

-- TriggerBot
RunService.RenderStepped:Connect(function()
    if not _G.TriggerBot then return end
    local target = getTarget()
    if target then
        mouse1press()
        wait()
        mouse1release()
    end
end)

-- Silent Aim (через FireServer)
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if _G.SilentFireAim and tostring(self) == "ShootEvent" and method == "FireServer" then
        local target = getTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local pos = target.Character.Head.Position
            args[2] = pos -- Перезаписываем позицию выстрела
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)
