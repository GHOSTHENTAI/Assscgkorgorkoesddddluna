
-- 🌙 LunaSoft v3.1 | Перетаскиваемое меню + плавный aimbot + Glow ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().SoftAimbot = false
getgenv().SoftESP = false
getgenv().SoftSpeed = 30
local AimbotSmoothness = 0.08
local MaxAimDistance = 150

local function getClosestTarget()
    local closest, shortest = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local ray = RaycastParams.new()
                    ray.FilterType = Enum.RaycastFilterType.Blacklist
                    ray.FilterDescendantsInstances = {LocalPlayer.Character, p.Character}
                    local result = Workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position), ray)
                    if not result then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if dist < shortest and dist < MaxAimDistance then
                            shortest = dist
                            closest = head
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if getgenv().SoftAimbot then
        local target = getClosestTarget()
        if target then
            local direction = (target.Position - Camera.CFrame.Position).Unit
            local goal = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
            Camera.CFrame = Camera.CFrame:Lerp(goal, AimbotSmoothness)
        end
    end
end)

local function applyGlow(player)
    if not player.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 140, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0
    highlight.Name = "LunaGlow"
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
end

local function clearGlow(player)
    if player.Character and player.Character:FindFirstChild("LunaGlow") then
        player.Character:FindFirstChild("LunaGlow"):Destroy()
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().SoftESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team then
                if not (plr.Character and plr.Character:FindFirstChild("LunaGlow")) then
                    applyGlow(plr)
                end
            end
        end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            clearGlow(plr)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and getgenv().SoftSpeed > 16 then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and UserInputService:IsKeyDown(Enum.KeyCode.W) then
            root.CFrame = root.CFrame + root.CFrame.LookVector * (getgenv().SoftSpeed * 0.01)
        end
    end
end)

-- 🎛 UI (добавлено перетаскивание)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LunaSoftUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 20, 1, -220)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- 🖱 Перетаскивание меню
local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function makeButton(y, text, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.Size = UDim2.new(0, 210, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

makeButton(20, "🔫 Toggle Aimbot", function()
    getgenv().SoftAimbot = not getgenv().SoftAimbot
end)

makeButton(60, "🌈 Toggle Glow ESP", function()
    getgenv().SoftESP = not getgenv().SoftESP
end)

makeButton(100, "🚀 Set Speed to 30", function()
    getgenv().SoftSpeed = 30
end)

makeButton(140, "❌ Close Menu", function()
    gui:Destroy()
end)

StarterGui:SetCore("SendNotification", {
    Title = "LunaSoft v3.1",
    Text = "Меню с перетаскиванием загружено 💜",
    Duration = 4
})

.BackgroundTransparency = 1

local speedInput = Instance.new("TextBox", speedTab)
speedInput.Position = UDim2.new(0, 10, 0, 10)
speedInput.Size = UDim2.new(0, 240, 0, 30)
speedInput.PlaceholderText = "Скорость (16-60)"
speedInput.Text = ""
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 14
speedInput.BackgroundColor3 = Color3.fromRGB(90, 60, 90)
speedInput.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0,6)

speedInput.FocusLost:Connect(function()
    local val = tonumber(speedInput.Text)
    if val and val >= 16 and val <= 60 then
        getgenv().SoftSpeed = val
        speedInput.PlaceholderText = "✅ Установлено: " .. val
    else
        speedInput.PlaceholderText = "❌ Ошибка! 16-60"
    end
end)

-- Добавление кнопок вкладок
local aimBtn = createTab("Aimbot")
aimBtn.Position = UDim2.new(0, 0, 0, 0)
aimBtn.MouseButton1Click:Connect(function()
    switchContent(aimTab)
end)

local espBtn = createTab("ESP")
espBtn.Position = UDim2.new(0, 90, 0, 0)
espBtn.MouseButton1Click:Connect(function()
    switchContent(espTab)
end)

local speedBtn = createTab("Speed")
speedBtn.Position = UDim2.new(0, 180, 0, 0)
speedBtn.MouseButton1Click:Connect(function()
    switchContent(speedTab)
end)

-- Уведомление
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "LunaSoft v4",
        Text = "Интерфейс с вкладками загружен 💜",
        Duration = 4
    })
end)




-- 🌸 LunaSoft TriggerBot + Silent Aim by Кира 💗

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function isAlive(player)
    local h = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
    return h and h.Health > 0
end

local function getTarget()
    local closest, dist = nil, 9999
    for _, v in pairs(Players:GetPlayers()) do
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

-- TriggerBot
RunService.RenderStepped:Connect(function()
    if _G.TriggerBot then
        local target = getTarget()
        if target then
            mouse1click()
        end
    end
end)

-- Silent Aim Hook
local rawmt = getrawmetatable(game)
setreadonly(rawmt, false)
local oldNamecall = rawmt.__namecall

rawmt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if _G.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local target = getTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local direction = (target.Character.Head.Position - Camera.CFrame.Position).Unit * 999
            args[1] = Ray.new(Camera.CFrame.Position, direction)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
