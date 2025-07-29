
-- 🌸 LunaSoft v6 Full (UI + SilentAim + TriggerBot + NoSpread + GlowESP)
-- Автор: Кира 💗

-- [1] Настройка переменных
_G.SilentAim = true
_G.TriggerBot = true
_G.NoSpread = true
_G.TeamCheck = true
_G.EnableGlowESP = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- [2] Визуальное меню
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "LunaUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 270, 0, 300)
Frame.Position = UDim2.new(0.5, -135, 0.4, -150)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", Frame)
title.Text = "🌸 LunaSoft v6"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 135, 255)
title.TextSize = 18
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1

-- Toggle helper
function CreateToggle(name, posY, default, callback)
    local button = Instance.new("TextButton", Frame)
    button.Size = UDim2.new(1, -20, 0, 25)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.BackgroundColor3 = default and Color3.fromRGB(60, 255, 150) or Color3.fromRGB(255, 60, 80)
    button.Text = name .. ": " .. (default and "ON" or "OFF")
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14

    local state = default
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(60, 255, 150) or Color3.fromRGB(255, 60, 80)
        button.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

CreateToggle("Silent Aim", 40, _G.SilentAim, function(v) _G.SilentAim = v end)
CreateToggle("TriggerBot", 70, _G.TriggerBot, function(v) _G.TriggerBot = v end)
CreateToggle("No Spread", 100, _G.NoSpread, function(v) _G.NoSpread = v end)
CreateToggle("Glow ESP", 130, _G.EnableGlowESP, function(v) _G.EnableGlowESP = v end)

-- [3] Glow ESP
RunService.RenderStepped:Connect(function()
    if _G.EnableGlowESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and not part:FindFirstChild("LunaGlow") then
                        local glow = Instance.new("BoxHandleAdornment")
                        glow.Name = "LunaGlow"
                        glow.Adornee = part
                        glow.AlwaysOnTop = true
                        glow.ZIndex = 5
                        glow.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                        glow.Transparency = 0.25
                        glow.Color3 = Color3.fromRGB(255, 128, 255)
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

-- [4] Проверка цели
local function isAlive(player)
    local h = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
    return h and h.Health > 0
end

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

-- [5] TriggerBot
RunService.RenderStepped:Connect(function()
    if _G.TriggerBot then
        local ray = Mouse.UnitRay
        local hitPart = workspace:FindPartOnRayWithIgnoreList(Ray.new(ray.Origin, ray.Direction * 1000), {LocalPlayer.Character})
        if hitPart and hitPart.Parent then
            local target = Players:GetPlayerFromCharacter(hitPart.Parent)
            if target and target ~= LocalPlayer and isAlive(target) and target.Team ~= LocalPlayer.Team then
                mouse1press()
                task.wait(0.05)
                mouse1release()
            end
        end
    end
end)

-- [6] Silent Aim + NoSpread
local rawmt = getrawmetatable(game)
setreadonly(rawmt, false)
local old = rawmt.__namecall
rawmt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and typeof(args[1]) == "Ray" then
        if _G.SilentAim then
            local target = getTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                args[1] = Ray.new(Camera.CFrame.Position, (target.Character.Head.Position - Camera.CFrame.Position).Unit * 999)
                return old(self, unpack(args))
            end
        elseif _G.NoSpread then
            args[1] = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 999)
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)
