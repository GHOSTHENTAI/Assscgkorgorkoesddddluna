
-- 🌸 LunaCB v2 — Counter Blox: Silent Aim + GlowESP + UI + AimLock
-- Автор: Кира 💗

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

-- Конфигурация
_G.SilentAim = true
_G.GlowESP = true
_G.AimLock = true
_G.TeamCheck = true

-- UI Меню
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LunaCB_Menu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 170)
frame.Position = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🌸 LunaCB v2"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 105, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- Функция для создания тумблеров
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

CreateToggle("Silent Aim", 35, _G.SilentAim, function(v) _G.SilentAim = v end)
CreateToggle("Glow ESP", 65, _G.GlowESP, function(v) _G.GlowESP = v end)
CreateToggle("Aim Lock", 95, _G.AimLock, function(v) _G.AimLock = v end)

-- Проверка цели
local function isAlive(player)
    local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

-- Поиск ближайшей цели
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
                    closest = player
                    dist = mag
                end
            end
        end
    end
    return closest
end

-- Aim Lock на ПКМ
RunService.RenderStepped:Connect(function()
    if _G.AimLock and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local aimDir = (headPos - Camera.CFrame.Position).Unit
            local camCF = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + aimDir)
            Camera.CFrame = camCF:Lerp(Camera.CFrame, 0.9)
        end
    end
end)

-- Glow ESP
RunService.RenderStepped:Connect(function()
    if _G.GlowESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
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
                local dir = (target.Character.Head.Position - Camera.CFrame.Position).Unit * 999
                args[1] = Ray.new(Camera.CFrame.Position, dir)
                return old(self, unpack(args))
            end
        end
    end
    return old(self, ...)
end)
