
-- LunaSilent v3.0 Hi-Tech UI
-- Автор: Кира 💗

-- 🌐 Конфигурация
local config = {
    fov = 80,
    aimKey = Enum.UserInputType.MouseButton2,
    silentAim = true,
    triggerBot = true,
    noSpread = true,
    glowESP = true,
    teamCheck = true,
    wallCheck = true,
    deadCheck = true
}

-- 🔌 Службы
local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local input = false

-- 🖼️ UI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LunaSilentUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 430, 0, 330)
main.Position = UDim2.new(0.3, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(30,30,35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local topBar = Instance.new("TextLabel", main)
topBar.Text = "LunaSilent v3.0"
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(90, 30, 120)
topBar.TextColor3 = Color3.fromRGB(255, 255, 255)
topBar.Font = Enum.Font.GothamBold
topBar.TextSize = 20

local function makeTab(name, pos)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 100, 0, 30)
    btn.Position = UDim2.new(0, 10 + pos*110, 0, 40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    return btn
end

local tabAimbot = makeTab("Aimbot", 0)
local tabESP = makeTab("ESP", 1)
local tabMisc = makeTab("Misc", 2)

local pages = {}
for _, tabName in ipairs({"Aimbot", "ESP", "Misc"}) do
    local page = Instance.new("Frame", main)
    page.Name = tabName
    page.Size = UDim2.new(1, -20, 1, -80)
    page.Position = UDim2.new(0, 10, 0, 75)
    page.BackgroundColor3 = Color3.fromRGB(35,35,40)
    page.Visible = false
    pages[tabName] = page
end
pages["Aimbot"].Visible = true

local function toggleButton(parent, name, default, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local state = default
    btn.Text = name .. ": " .. (state and "ON" or "OFF")
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- 🧠 Функции переключения вкладок
tabAimbot.MouseButton1Click:Connect(function()
    for n, f in pairs(pages) do f.Visible = false end
    pages["Aimbot"].Visible = true
end)
tabESP.MouseButton1Click:Connect(function()
    for n, f in pairs(pages) do f.Visible = false end
    pages["ESP"].Visible = true
end)
tabMisc.MouseButton1Click:Connect(function()
    for n, f in pairs(pages) do f.Visible = false end
    pages["Misc"].Visible = true
end)

-- ⚙️ Кнопки в Aimbot
toggleButton(pages["Aimbot"], "Silent Aim", config.silentAim, function(v) config.silentAim = v end).Position = UDim2.new(0, 10, 0, 10)
toggleButton(pages["Aimbot"], "Team Check", config.teamCheck, function(v) config.teamCheck = v end).Position = UDim2.new(0, 10, 0, 50)
toggleButton(pages["Aimbot"], "Wall Check", config.wallCheck, function(v) config.wallCheck = v end).Position = UDim2.new(0, 10, 0, 90)

-- ⚙️ ESP
toggleButton(pages["ESP"], "Glow ESP", config.glowESP, function(v) config.glowESP = v end).Position = UDim2.new(0, 10, 0, 10)

-- ⚙️ Misc
toggleButton(pages["Misc"], "TriggerBot", config.triggerBot, function(v) config.triggerBot = v end).Position = UDim2.new(0, 10, 0, 10)
toggleButton(pages["Misc"], "NoSpread", config.noSpread, function(v) config.noSpread = v end).Position = UDim2.new(0, 10, 0, 50)

-- TODO: Функции Aimbot, TriggerBot, GlowESP подключаются дальше
-- (Они будут добавлены после подтверждения UI)
