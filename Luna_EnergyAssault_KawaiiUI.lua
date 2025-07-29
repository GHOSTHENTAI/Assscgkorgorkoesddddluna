
-- 🌸 LunaSoft Kawaii Aim v1.1 for Energy Assault
-- Автор: Кира 💗

-- 🌸 Настройки
local config = {
    fov = 80,
    aimBind = Enum.UserInputType.MouseButton2, -- ПКМ
    teamCheck = true,
    deadCheck = true,
    wallCheck = true,
    esp = true,
    glowColor = Color3.fromRGB(255, 150, 255),
    outlineColor = Color3.fromRGB(255, 255, 255)
}

-- 🌸 Службы
local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- 🌸 UI
local ui = Instance.new("ScreenGui", game.CoreGui)
ui.Name = "🌸LunaCuteUI"
local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 350, 0, 250)
frame.Position = UDim2.new(0.65, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 230, 255)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🌸 LunaSoft Kawaii Menu 🌸"
title.BackgroundColor3 = Color3.fromRGB(255, 180, 255)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.Fantasy
title.TextSize = 20

-- 🌸 Создание переключателей
local function toggleBtn(name, y, state, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Size = UDim2.new(0, 330, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(255, 200, 255)
    btn.Text = (state and "[ON] " or "[OFF] ") .. name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Cartoon
    btn.TextSize = 16
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "[ON] " or "[OFF] ") .. name
        callback(state)
    end)
end

-- 🌸 Aimbot логика
local aiming = false
local function isAlive(player)
    local h = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
    return h and h.Health > 0
end

local function isVisible(pos)
    local ray = Ray.new(cam.CFrame.Position, (pos - cam.CFrame.Position).Unit * 999)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {plr.Character})
    return not hit or hit.Transparency > 0.3
end

local function getClosest()
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

-- 🌸 Aimbot Loop
rs.RenderStepped:Connect(function()
    if aiming then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head.Position
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, head), 0.12)
        end
    end
end)

uis.InputBegan:Connect(function(i)
    if i.UserInputType == config.aimBind then aiming = true end
end)
uis.InputEnded:Connect(function(i)
    if i.UserInputType == config.aimBind then aiming = false end
end)

-- 🌸 ESP
if config.esp then
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
                    glow.Transparency = 0.2
                    glow.Color3 = config.glowColor
                    glow.Parent = part

                    local outline = Instance.new("SelectionBox", part)
                    outline.Adornee = part
                    outline.LineThickness = 0.03
                    outline.Color3 = config.outlineColor
                    outline.SurfaceTransparency = 1
                end
            end
        end
    end
end

-- 🌸 FOV круг
local circle = Drawing.new("Circle")
circle.Radius = config.fov
circle.Thickness = 1.5
circle.Filled = false
circle.Color = Color3.fromRGB(255, 150, 255)
circle.Transparency = 0.5
rs.RenderStepped:Connect(function()
    circle.Position = Vector2.new(mouse.X, mouse.Y + 36)
    circle.Visible = true
end)
