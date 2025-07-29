-- LunaSoft CounterBlox [BETA BASE]
-- Works with Xeno Injector
-- Toggle Menu: RightShift

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local ESP = {}
local ToggleMenu = false

-- UI Placeholder
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Visible = false

-- Toggle UI
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleMenu = not ToggleMenu
        Frame.Visible = ToggleMenu
    end
end)

-- ESP
local function CreateESP(plr)
    if plr == LP or plr.Team == LP.Team then return end
    local box = Drawing.new("Text")
    box.Size = 18
    box.Center = true
    box.Outline = true
    box.Color = Color3.new(1, 1, 1)
    box.Visible = false
    ESP[plr] = box

    RunService.RenderStepped:Connect(function()
        if not plr.Character or not plr.Character:FindFirstChild("Head") then
            box.Visible = false
            return
        end

        local head = plr.Character.Head
        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
        if onScreen then
            box.Position = Vector2.new(pos.X, pos.Y - 25)
            box.Text = plr.Name
            box.Visible = true
        else
            box.Visible = false
        end
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    CreateESP(plr)
end

Players.PlayerAdded:Connect(CreateESP)

-- Injected Confirmation (You can replace with Webhook)
game.StarterGui:SetCore("SendNotification", {
    Title = "LunaSoft",
    Text = "CounterBlox cheat injected!",
    Duration = 5
})
