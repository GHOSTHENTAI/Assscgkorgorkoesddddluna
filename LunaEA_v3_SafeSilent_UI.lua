
-- 🌸 LunaEA v3 — Safe Silent Aim + UI (CSGO Style)
-- Работает в Energy Assault, совместимо с Xeno

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UIS = game:GetService("UserInputService")

-- Настройки
_G.SafeSilent = true
_G.TeamCheck = true
_G.GlowESP = true
_G.FOV = 150

-- UI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LunaEA_Menu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.02, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🌸 LunaEA v3"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 105, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

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

CreateToggle("Silent Aim", 35, _G.SafeSilent, function(v) _G.SafeSilent = v end)
CreateToggle("Glow ESP", 65, _G.GlowESP, function(v) _G.GlowESP = v end)

-- FOV Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Color = Color3.fromRGB(255, 105, 180)
fovCircle.Radius = _G.FOV
fovCircle.Thickness = 2
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
end)

-- Glow ESP
RunService.RenderStepped:Connect(function()
    if _G.GlowESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character then
                for _, part in pairs(p.Character:GetChildren()) do
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

-- Проверка игрока
local function isAlive(player)
    local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

-- Поиск цели в пределах FOV
local function getTarget()
    local closest, dist = nil, _G.FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and player.Character and player.Character:FindFirstChild("Head") then
            if _G.TeamCheck and player.Team == LocalPlayer.Team then continue end
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

-- Silent Aim Hook
local raw = getrawmetatable(game)
setreadonly(raw, false)
local old = raw.__namecall
raw.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and typeof(args[1]) == "Ray" then
        if _G.SafeSilent then
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
