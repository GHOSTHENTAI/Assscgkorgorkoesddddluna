
-- 🌸 LunaSilent v2.0 for Energy Assault (Xeno Compatible)
-- Автор: Кира 💗

-- Настройки
local config = {
    fov = 80,
    aimBind = Enum.UserInputType.MouseButton2, -- ПКМ
    teamCheck = true,
    deadCheck = true,
    wallCheck = true,
    silentAim = true,
    glowESP = true,
    glowColor = Color3.fromRGB(255, 150, 255),
    outlineColor = Color3.fromRGB(255, 255, 255)
}

-- Службы
local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- UI
local ui = Instance.new("ScreenGui", game.CoreGui)
ui.Name = "LunaSilentUI"
local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 350, 0, 270)
frame.Position = UDim2.new(0.65, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(245, 215, 255)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🌸 LunaSilent v2.0"
title.BackgroundColor3 = Color3.fromRGB(255, 180, 255)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- Кнопки
local function makeToggle(name, y, default, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Size = UDim2.new(0, 330, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(255, 200, 255)
    btn.Text = (default and "[ON] " or "[OFF] ") .. name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Cartoon
    btn.TextSize = 16
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "[ON] " or "[OFF] ") .. name
        callback(state)
    end)
end

-- Aimbot функции
local aiming = false

local function isAlive(p)
    local h = p.Character and p.Character:FindFirstChildWhichIsA("Humanoid")
    return h and h.Health > 0
end

local function isVisible(pos)
    local ray = Ray.new(cam.CFrame.Position, (pos - cam.CFrame.Position).Unit * 999)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {plr.Character})
    return not hit or hit.Transparency > 0.3
end

local function getTarget()
    local closest, dist = nil, config.fov
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("Head") then
            if config.teamCheck and v.Team == plr.Team then continue end
            if config.deadCheck and not isAlive(v) then continue end
            local pos, onScreen = cam:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if mag < dist and (not config.wallCheck or isVisible(v.Character.Head.Position)) then
                    closest, dist = v, mag
                end
            end
        end
    end
    return closest
end

-- Silent Aim Hook
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if config.silentAim and aiming and method == "FindPartOnRayWithIgnoreList" then
        local target = getTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head.Position
            args[1] = Ray.new(cam.CFrame.Position, (head - cam.CFrame.Position).Unit * 999)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- Ввод
uis.InputBegan:Connect(function(i)
    if i.UserInputType == config.aimBind then aiming = true end
end)
uis.InputEnded:Connect(function(i)
    if i.UserInputType == config.aimBind then aiming = false end
end)

-- Glow ESP
if config.glowESP then
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= plr and player.Team ~= plr.Team then
            local chr = player.Character or player.CharacterAdded:Wait()
            for _, part in pairs(chr:GetChildren()) do
                if part:IsA("BasePart") then
                    local glow = Instance.new("BoxHandleAdornment")
                    glow.Adornee = part
                    glow.AlwaysOnTop = true
                    glow.ZIndex = 5
                    glow.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                    glow.Transparency = 0.25
                    glow.Color3 = config.glowColor
                    glow.Parent = part

                    local outline = Instance.new("SelectionBox", part)
                    outline.Adornee = part
                    outline.LineThickness = 0.04
                    outline.Color3 = config.outlineColor
                    outline.SurfaceTransparency = 1
                end
            end
        end
    end
end

-- FOV круг
local fov = Drawing.new("Circle")
fov.Thickness = 2
fov.Radius = config.fov
fov.Filled = false
fov.Color = Color3.fromRGB(255, 120, 255)
fov.Transparency = 0.6

rs.RenderStepped:Connect(function()
    fov.Position = Vector2.new(mouse.X, mouse.Y + 36)
    fov.Visible = true
end)
