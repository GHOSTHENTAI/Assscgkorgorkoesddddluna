
-- LunaSoft CounterBlox HVH Internal | Xeno Supported

if not game:IsLoaded() then game.Loaded:Wait() end

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

--// Notification
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "LunaSoft HVH",
        Text = "Cheat Loaded Successfully! Press RightShift to toggle menu.",
        Duration = 5
    })
end)

--// UI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "LunaSoftUI"

local menuOpen = false
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Visible = false

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
        frame.Visible = menuOpen
    end
end)

--// ESP Example (Safe)
local function createESP(plr)
    if plr == lp or not plr.Character or not plr.Character:FindFirstChild("Head") then return end
    local esp = Instance.new("BillboardGui", plr.Character.Head)
    esp.Name = "LunaESP"
    esp.Size = UDim2.new(4,0, 1,0)
    esp.AlwaysOnTop = true

    local name = Instance.new("TextLabel", esp)
    name.Size = UDim2.new(1,0,1,0)
    name.Text = plr.Name
    name.TextColor3 = Color3.new(1, 0.2, 0.5)
    name.BackgroundTransparency = 1
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= lp then createESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(1)
        createESP(p)
    end)
end)
