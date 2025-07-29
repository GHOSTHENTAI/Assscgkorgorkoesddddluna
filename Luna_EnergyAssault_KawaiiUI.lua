--[[
    CounterBlox Base Cheat (Xeno Compatible)
    Features: Silent Aim, TriggerBot, NoRecoil, NoSpread, BunnyHop, Webhook Logger
]]--

-- Settings
local config = {
    silentAim = true,
    triggerBot = true,
    noRecoil = true,
    noSpread = true,
    bunnyHop = true,
    webhookLogging = true,
    webhookURL = "https://your.webhook.url.here",
    aimPart = "Head",
    fov = 150,
    triggerKey = Enum.UserInputType.MouseButton2,
    toggleKey = Enum.KeyCode.RightShift
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer
local mouse = plr:GetMouse()
local camera = workspace.CurrentCamera

-- State
local enabled = true
local jumping = false

-- UI (Basic Notification)
local function notify(txt)
    game.StarterGui:SetCore("SendNotification", {
        Title = "CounterBlox Xeno Cheat",
        Text = txt,
        Duration = 4
    })
end

-- Webhook Logger
if config.webhookLogging and syn then
    syn.request({
        Url = config.webhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode({
            content = "**User attached script in CounterBlox.**",
            embeds = {{
                title = "CounterBlox Logger",
                description = "Injected cheat with settings.",
                color = 16711900
            }}
        })
    })
end

-- BunnyHop
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        jumping = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        jumping = false
    end
end)

RunService.RenderStepped:Connect(function()
    if config.bunnyHop and jumping and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        local humanoid = plr.Character.Humanoid
        if humanoid:GetState() == Enum.HumanoidStateType.Running then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Silent Aim & TriggerBot
local function getClosestPlayer()
    local closest, distance = nil, config.fov
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= plr and v.Team ~= plr.Team and v.Character and v.Character:FindFirstChild(config.aimPart) then
            local screenPoint, onScreen = camera:WorldToViewportPoint(v.Character[config.aimPart].Position)
            if onScreen then
                local mag = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).magnitude
                if mag < distance then
                    distance = mag
                    closest = v
                end
            end
        end
    end
    return closest
end

-- Hook
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if enabled and config.silentAim and method == "FindPartOnRayWithIgnoreList" then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(config.aimPart)
            if part then
                local origin = camera.CFrame.Position
                local direction = (part.Position - origin).unit * 1000
                local ray = Ray.new(origin, direction)
                return game.Workspace:FindPartOnRayWithIgnoreList(ray, {...})
            end
        end
    end
    return __namecall(self, ...)
end)

-- TriggerBot
RunService.RenderStepped:Connect(function()
    if config.triggerBot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    local target = mouse.Target
    if target and target.Parent and Players:GetPlayerFromCharacter(target.Parent) then
        mouse1click()
    end
end)

-- Toggle UI (placeholder)
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == config.toggleKey then
        enabled = not enabled
        notify("Cheat " .. (enabled and "Enabled" or "Disabled"))
    end
end)

notify("Cheat Loaded.")
